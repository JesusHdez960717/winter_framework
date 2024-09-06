import 'dart:async';

import 'package:shelf/shelf.dart';

import '../../http/http.dart';

extension RequestExt on Request {
  FutureOr<RequestEntity<T>> toEntity<T>() async {
    return RequestEntity(
      method: HttpMethod.valueOf(method),
      headers: HttpHeaders(headers),
      requestedUri: requestedUri,
      url: url,
      handlerPath: handlerPath,
      protocolVersion: protocolVersion,
      body: contentLength != null
          ? await readAsString() as T
          : null, //TODO: 123456789 aplicar la conversion/mapeo
    );
  }
}

extension ResponseExt on ResponseEntity {
  FutureOr<Response> toResponse() {
    return Response(
      status.value,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }
}
