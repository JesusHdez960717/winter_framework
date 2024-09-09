import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http_parser/http_parser.dart' hide MediaType;

import '../core/winter_server.dart';
import 'http_headers.dart';
import 'media_type.dart';

class HttpEntity {
  final HttpHeaders headers;
  late final _Body _rawBody;

  bool get hasBody =>
      _rawBody.contentLength != null && _rawBody.contentLength! > 0;

  HttpEntity({
    Object? body,
    Encoding? encoding,
    Map<String, Object>? headers,
  }) : this._withBody(_Body(body, encoding), headers);

  HttpEntity._withBody(
    _Body body,
    Map<String, Object>? headers,
  ) : this._all(
          body,
          HttpHeaders.from(_adjustHeaders(expandToHeadersAll(headers), body)),
        );

  HttpEntity._all(
    this._rawBody,
    this.headers,
  );

  Future<T?> body<T>() async {
    //TODO: ver si se valida esto
    if (T != String &&
        headers.singleValues[HttpHeaders.CONTENT_TYPE] !=
            MediaType.APPLICATION_JSON.mimeType) {
      print(
          'Se quiere parsear un body que no tiene content-type de tipo application/json');
    }

    if (_cachedBody == null || _cachedBody is! T) {
      _cachedBody = WinterServer.instance.context.objectMapper.deserialize(
        await _readAsString(encoding),
        T,
      );
    }
    return _cachedBody as T;
  }

  Object? _cachedBody;

  /// Returns a [Future] containing the body as a String.
  ///
  /// If [encoding] is passed, that's used to decode the body.
  /// Otherwise the encoding is taken from the Content-Type header. If that
  /// doesn't exist or doesn't have a "charset" parameter, UTF-8 is used.
  ///
  /// This calls [rawRead] internally, which can only be called once.
  Future<String> _readAsString([Encoding? encoding]) {
    encoding ??= this.encoding ?? utf8;
    return encoding.decodeStream(rawRead);
  }

  Stream<List<int>> get rawRead => _rawBody.read();

  List<String>? header(String header) => headers[header];

  /// The parsed version of the Content-Type header in [headers].
  ///
  /// This is cached for efficient access.
  MediaType? get contentType {
    return headers[HttpHeaders.CONTENT_TYPE] != null
        ? MediaType.parse(headers.singleValues[HttpHeaders.CONTENT_TYPE]!)
        : _rawBody.contentType;
  }

  /// The encoding of the message body.
  ///
  /// This is parsed from the "charset" parameter of the Content-Type header in
  /// [headers].
  ///
  /// If [headers] doesn't have a Content-Type header or it specifies an
  /// encoding that `dart:convert` doesn't support, this will be `null`.
  Encoding? get encoding {
    var innerContentType = contentType;
    if (innerContentType == null) return null;
    if (!innerContentType.parameters.containsKey('charset')) return null;
    return Encoding.getByName(innerContentType.parameters['charset']);
  }
}

class _Body {
  /// The contents of the message body.
  ///
  /// This will be `null` after [read] is called.
  Stream<List<int>>? _stream;

  /// The encoding used to encode the stream returned by [read], or `null` if no
  /// encoding was used.
  final Encoding? encoding;

  /// The length of the stream returned by [read], or `null` if that can't be
  /// determined efficiently.
  final int? contentLength;

  final MediaType? contentType;

  _Body._(this._stream, this.encoding, this.contentLength, this.contentType);

  /// Converts [body] to a byte stream and wraps it in a [Body].
  ///
  /// [body] may be either a [Body], a [String], a [List<int>], a
  /// [Stream<List<int>>], or `null`. If it's a [String], [encoding] will be
  /// used to convert it to a [Stream<List<int>>].
  factory _Body(Object? body, [Encoding? encoding]) {
    if (body is _Body) return body;

    Stream<List<int>> stream;
    int? contentLength;
    MediaType? contentType;
    if (body == null) {
      contentLength = 0;
      stream = Stream.fromIterable([]);
    } else if (body is List<int>) {
      // Avoid performance overhead from an unnecessary cast.
      contentLength = body.length;
      stream = Stream.value(body);
    } else if (body is List) {
      contentLength = body.length;
      stream = Stream.value(body.cast());
    } else if (body is Stream<List<int>>) {
      // Avoid performance overhead from an unnecessary cast.
      stream = body;
    } else if (body is Stream) {
      stream = body.cast();
    } else {
      late final String safeBody;
      if (body is String) {
        safeBody = body;
        contentType = MediaType.TEXT_PLAIN;
      } else {
        safeBody = WinterServer.instance.context.objectMapper.serialize(body);
        contentType = MediaType.APPLICATION_JSON;
      }

      if (encoding == null) {
        var encoded = utf8.encode(safeBody);
        // If the text is plain ASCII, don't modify the encoding. This means
        // that an encoding of "text/plain" will stay put.
        if (!_isPlainAscii(encoded, safeBody.length)) encoding = utf8;
        contentLength = encoded.length;
        stream = Stream.fromIterable([encoded]);
      } else {
        var encoded = encoding.encode(safeBody);
        contentLength = encoded.length;
        stream = Stream.fromIterable([encoded]);
      }
    }

    return _Body._(stream, encoding, contentLength, contentType);
  }

  /// Returns whether [bytes] is plain ASCII.
  ///
  /// [codeUnits] is the number of code units in the original string.
  static bool _isPlainAscii(List<int> bytes, int codeUnits) {
    // Most non-ASCII code units will produce multiple bytes and make the text
    // longer.
    if (bytes.length != codeUnits) return false;

    // Non-ASCII code units between U+0080 and U+009F produce 8-bit characters
    // with the high bit set.
    return bytes.every((byte) => byte & 0x80 == 0);
  }

  /// Returns a [Stream] representing the body.
  ///
  /// Can only be called once.
  Stream<List<int>> read() {
    if (_stream == null) {
      throw StateError("The 'read' method can only be called once on a "
          'Request/Response object.');
    }
    var stream = _stream!;
    _stream = null;
    return stream;
  }
}

/// Adds information about [encoding] to [headers].
///
/// Returns a new map without modifying [headers].
Map<String, List<String>> _adjustHeaders(
  Map<String, List<String>>? headers,
  _Body body,
) {
  var sameEncoding = _sameEncoding(headers, body);
  if (sameEncoding) {
    if (body.contentLength == null ||
        findHeader(headers, 'content-length') == '${body.contentLength}') {
      return headers ?? HttpHeaders.empty();
    } else if (body.contentLength == 0 &&
        (headers == null || headers.isEmpty)) {
      return HttpHeaders.def();
    }
  }

  var newHeaders = headers == null
      ? CaseInsensitiveMap<List<String>>()
      : CaseInsensitiveMap<List<String>>.from(headers);

  if (!sameEncoding) {
    if (newHeaders[HttpHeaders.CONTENT_TYPE] == null) {
      newHeaders[HttpHeaders.CONTENT_TYPE] = [
        'application/octet-stream; charset=${body.encoding!.name}'
      ];
    } else {
      final contentType = MediaType.parse(
              joinHeaderValues(newHeaders[HttpHeaders.CONTENT_TYPE])!)
          .parameters['charset'] = body.encoding!.name;
      newHeaders[HttpHeaders.CONTENT_TYPE] = [contentType.toString()];
    }
  }

  final explicitOverrideOfZeroLength = body.contentLength == 0 &&
      findHeader(headers, HttpHeaders.CONTENT_LENGTH) != null;

  if (body.contentLength != null && !explicitOverrideOfZeroLength) {
    final coding = joinHeaderValues(newHeaders[HttpHeaders.TRANSFER_ENCODING]);
    if (coding == null || equalsIgnoreAsciiCase(coding, 'identity')) {
      newHeaders['content-length'] = [body.contentLength.toString()];
    }
  }

  newHeaders[HttpHeaders.CONTENT_TYPE] =
      headers?[HttpHeaders.CONTENT_TYPE] ?? [body.contentType!.mimeType];

  return newHeaders;
}

/// Returns whether [headers] declares the same encoding as [body].
bool _sameEncoding(Map<String, List<String>?>? headers, _Body body) {
  if (body.encoding == null) return true;

  var contentType = findHeader(headers, 'content-type');
  if (contentType == null) return false;

  var charset = MediaType.parse(contentType).parameters['charset'];
  return Encoding.getByName(charset) == body.encoding;
}
