import 'dart:convert';

import 'http_headers.dart';
import 'media_type.dart';

class HttpEntity<T> {
  final HttpHeaders headers;
  final T? body;

  HttpEntity({
    HttpHeaders? headers,
    this.body,
  }) : headers = headers ?? HttpHeaders.empty();

  bool get hasBody => body != null;

  String? header(String header) => headers[header];

  /// The encoding of the message body.
  ///
  /// This is parsed from the "charset" parameter of the Content-Type header in
  /// [headers].
  ///
  /// If [headers] doesn't have a Content-Type header or it specifies an
  /// encoding that `dart:convert` doesn't support, this will be `null`.
  Encoding? get encoding {
    var contentType = _contentType;
    if (contentType == null) return null;
    if (!contentType.parameters.containsKey('charset')) return null;
    return Encoding.getByName(contentType.parameters['charset']);
  }

  /// The parsed version of the Content-Type header in [headers].
  ///
  /// This is cached for efficient access.
  MediaType? get _contentType {
    return headers[HttpHeaders.CONTENT_TYPE] != null
        ? MediaType.parse(headers[HttpHeaders.CONTENT_TYPE]!)
        : null;
  }
}
