// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A Shelf adapter for handling [HttpRequest] objects from `dart:io`'s
/// [HttpServer].
///
/// One can provide an instance of [HttpServer] as the `requests` parameter in
/// [serveRequests].
///
/// This adapter supports request hijacking; see [Request.hijack].
///
/// [Request]s passed to a [RequestHandler] will contain the [Request.context] key
/// `"shelf.io.connection_info"` containing the [HttpConnectionInfo] object from
/// the underlying [HttpRequest].
///
/// When creating [Response] instances for this adapter, you can set the
/// `"shelf.io.buffer_output"` key in [Response.context]. If `true`,
/// (the default), streamed responses will be buffered to improve performance.
/// If `false`, all chunks will be pushed over the wire as they're received.
/// See [HttpResponse.bufferOutput] for more information.
library;

import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http_parser/http_parser.dart' hide MediaType;
import 'package:stack_trace/stack_trace.dart';

import '../http/http.dart';
import 'core.dart';

void catchTopLevelErrors(void Function() callback,
    void Function(dynamic error, StackTrace) onError) {
  if (Zone.current.inSameErrorZone(Zone.root)) {
    return runZonedGuarded(callback, onError);
  } else {
    return callback();
  }
}

/// Starts an [HttpServer] that listens on the specified [address] and
/// [port] and sends requests to [handler].
///
/// If a [securityContext] is provided an HTTPS server will be started.
///
/// See the documentation for [HttpServer.bind] and [HttpServer.bindSecure]
/// for more details on [address], [port], [backlog], and [shared].
///
/// {@template shelf_io_header_defaults}
/// Every response will get a "date" header.
/// If the either header is present in the `Response`, it will not be
/// overwritten.
/// Pass [poweredByHeader] to set the default content for "X-Powered-By",
/// pass `null` to omit this header.
/// {@endtemplate}
Future<HttpServer> serve(
  RequestHandler handler,
  Object address,
  int port, {
  ExcHandler? exceptionHandler,
  SecurityContext? securityContext,
  int? backlog,
  bool shared = false,
  bool allowBodyOnGetMethod = false,
}) async {
  backlog ??= 0;
  var server = await (securityContext == null
      ? HttpServer.bind(address, port, backlog: backlog, shared: shared)
      : HttpServer.bindSecure(
          address,
          port,
          securityContext,
          backlog: backlog,
          shared: shared,
        ));
  server.listen(
    (request) => handleRequest(
      request,
      handler,
      exceptionHandler ??
          (request, error, stackTrace) => _logError(
                request,
                error.toString(),
                stackTrace,
              ),
      allowBodyOnGetMethod: allowBodyOnGetMethod,
    ),
  );
  return server;
}

/// Uses [handler] to handle [request].
///
/// Returns a [Future] which completes when the request has been handled.
///
/// {@macro shelf_io_header_defaults}
Future<void> handleRequest(
  HttpRequest request,
  RequestHandler handler,
  ExcHandler exceptionHandler, {
  bool allowBodyOnGetMethod = false,
}) async {
  HttpMethod? method = HttpMethod.valueOfOrNull(request.method);
  if (method == null) {
    final response = ResponseEntity(
      status: HttpStatus.METHOD_NOT_ALLOWED,
      body: 'Method ${request.method} not allowed',
      headers: HttpHeaders({
        HttpHeaders.CONTENT_TYPE: [MediaType.TEXT_PLAIN.mimeType],
      }),
    );
    await _writeResponse(response, request.response);
    return;
  }

  RequestEntity winterRequest;
  try {
    winterRequest = _fromHttpRequest(request);
    // ignore: avoid_catching_errors
  } on ArgumentError catch (error, stackTrace) {
    if (error.name == 'method' || error.name == 'requestedUri') {
      _logTopLevelError('Error parsing request.\n$error', stackTrace);
      final response = ResponseEntity(
        status: HttpStatus.BAD_REQUEST,
        body: 'Bad Request',
        headers: HttpHeaders({
          HttpHeaders.CONTENT_TYPE: [MediaType.TEXT_PLAIN.mimeType]
        }),
      );
      await _writeResponse(
        response,
        request.response,
      );
    } else {
      _logTopLevelError('Error parsing request.\n$error', stackTrace);
      final response = ResponseEntity.internalServerError();
      await _writeResponse(
        response,
        request.response,
      );
    }
    return;
  } catch (error, stackTrace) {
    _logTopLevelError('Error parsing request.\n$error', stackTrace);
    final response = ResponseEntity.internalServerError();
    await _writeResponse(
      response,
      request.response,
    );
    return;
  }

  ResponseEntity? response;

  if (!allowBodyOnGetMethod &&
      (method == HttpMethod.GET || method == HttpMethod.DELETE) &&
      (await winterRequest.body())?.isNotEmpty == true) {
    response = ResponseEntity.badRequest(
        body: "Get & Delete methods can't have a body");
    await _writeResponse(response, request.response);
    return;
  } else {
    try {
      response = await handler(winterRequest);
    } on Exception catch (error, stackTrace) {
      try {
        response = await exceptionHandler(
          winterRequest,
          error,
          stackTrace,
        );
      } on Exception catch (error, stackTrace) {
        response = _logError(
          winterRequest,
          'Error thrown by handler.\n$error',
          stackTrace,
        );
      }
    }
  }

  await _writeResponse(response, request.response);
  return;
}

/// Creates a new [Request] from the provided [HttpRequest].
RequestEntity _fromHttpRequest(HttpRequest request) {
  var headers = <String, List<String>>{};
  request.headers.forEach((k, v) {
    headers[k] = v;
  });

  // Remove the Transfer-Encoding header per the adapter requirements.
  headers.remove(HttpHeaders.TRANSFER_ENCODING);

  return RequestEntity(
    method: HttpMethod.valueOf(request.method),
    requestedUri: request.requestedUri,
    protocolVersion: request.protocolVersion,
    headers: HttpHeaders(headers),
    body: request,
  );
}

Future<void> _writeResponse(
  ResponseEntity response,
  HttpResponse httpResponse,
) {
  httpResponse.statusCode = response.status.value;

  // An adapter must not add or modify the `Transfer-Encoding` parameter, but
  // the Dart SDK sets it by default. Set this before we fill in
  // [response.headers] so that the user or Shelf can explicitly override it if
  // necessary.
  httpResponse.headers.chunkedTransferEncoding = false;

  var coding = response.headers.singleValues[HttpHeaders.TRANSFER_ENCODING];
  if (coding != null && !equalsIgnoreAsciiCase(coding, 'identity')) {
    // If the response is already in a chunked encoding, de-chunk it because
    // otherwise `dart:io` will try to add another layer of chunking.
    response = response.copyWith(
      body: chunkedCoding.decoder.bind(response.rawRead),
    );
    httpResponse.headers.set(HttpHeaders.TRANSFER_ENCODING, 'chunked');
  } else if (response.status.value >= 200 &&
      response.status.value != 204 &&
      response.status.value != 304 &&
      response.mimeType != 'multipart/byteranges') {
    // If the response isn't chunked yet and there's no other way to tell its
    // length, enable `dart:io`'s chunked encoding.
    httpResponse.headers.set(HttpHeaders.TRANSFER_ENCODING, 'chunked');
  }

  if (!response.headers.containsKey(HttpHeaders.DATE)) {
    httpResponse.headers.date = DateTime.now().toUtc();
  }

  response.headers.forEach((header, value) {
    httpResponse.headers.set(header, value);
  });

  return httpResponse
      .addStream(response.rawRead)
      .then((_) => httpResponse.close());
}

ResponseEntity _logError(
  RequestEntity request,
  String message,
  StackTrace stackTrace,
) {
  // Add information about the request itself.
  var buffer = StringBuffer();
  buffer.write('${request.method} ${request.requestedUri.path}');
  if (request.requestedUri.query.isNotEmpty) {
    buffer.write('?${request.requestedUri.query}');
  }
  buffer.writeln();
  buffer.write(message);

  _logTopLevelError(buffer.toString(), stackTrace);
  return ResponseEntity.internalServerError();
}

void _logTopLevelError(String message, StackTrace stackTrace) {
  final chain = Chain.forTrace(stackTrace)
      .foldFrames((frame) => frame.isCore || frame.package == 'shelf')
      .terse;

  stderr.writeln('ERROR - ${DateTime.now()}');
  stderr.writeln(message);
  stderr.writeln(chain);
}
