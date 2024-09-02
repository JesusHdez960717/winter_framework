import 'package:http_parser/http_parser.dart';

import 'http_entity.dart';
import 'http_headers.dart';
import 'http_status.dart';

class ResponseEntity<T> extends HttpEntity<T> {
  HttpStatus status;

  ResponseEntity({
    required super.headers,
    required super.body,
    required this.status,
  });

  ResponseEntity.ok({
    HttpHeaders? headers,
    T? body,
  }) : this(
          status: HttpStatus.OK,
          body: body,
          headers: headers,
        );

  /// The date and time after which the response's data should be considered
  /// stale.
  ///
  /// This is parsed from the Expires header in [headers]. If [headers] doesn't
  /// have an Expires header, this will be `null`.
  DateTime? get expires {
    if (_expiresCache != null) return _expiresCache;
    if (!headers.containsKey(HttpHeaders.EXPIRES)) return null;
    _expiresCache = parseHttpDate(headers[HttpHeaders.EXPIRES]!);
    return _expiresCache;
  }

  DateTime? _expiresCache;

  /// The date and time the source of the response's data was last modified.
  ///
  /// This is parsed from the Last-Modified header in [headers]. If [headers]
  /// doesn't have a Last-Modified header, this will be `null`.
  DateTime? get lastModified {
    if (_lastModifiedCache != null) return _lastModifiedCache;
    if (!headers.containsKey(HttpHeaders.LAST_MODIFIED)) return null;
    _lastModifiedCache = parseHttpDate(headers[HttpHeaders.LAST_MODIFIED]!);
    return _lastModifiedCache;
  }

  DateTime? _lastModifiedCache;
}
