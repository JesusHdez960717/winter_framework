import 'package:collection/collection.dart';
import 'package:http_parser/http_parser.dart';

final _emptyHeaders = HttpHeaders._empty();

class HttpHeaders extends UnmodifiableMapView<String, List<String>> {
  /// The HTTP {@code Accept} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-5.3.2">Section 5.3.2 of RFC 7231</a>
  static final String ACCEPT = "Accept";

  /// The HTTP {@code Accept-Charset} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-5.3.3">Section 5.3.3 of RFC 7231</a>
  static final String ACCEPT_CHARSET = "Accept-Charset";

  /// The HTTP {@code Accept-Encoding} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-5.3.4">Section 5.3.4 of RFC 7231</a>
  static final String ACCEPT_ENCODING = "Accept-Encoding";

  /// The HTTP {@code Accept-Language} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-5.3.5">Section 5.3.5 of RFC 7231</a>
  static final String ACCEPT_LANGUAGE = "Accept-Language";

  /// The HTTP {@code Accept-Patch} header field name.
  /// @since 5.3.6
  /// @see <a href="https://tools.ietf.org/html/rfc5789#section-3.1">Section 3.1 of RFC 5789</a>
  static final String ACCEPT_PATCH = "Accept-Patch";

  /// The HTTP {@code Accept-Ranges} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7233#section-2.3">Section 5.3.5 of RFC 7233</a>
  static final String ACCEPT_RANGES = "Accept-Ranges";

  /// The CORS {@code Access-Control-Allow-Credentials} response header field name.
  /// @see <a href="https://www.w3.org/TR/cors/">CORS W3C recommendation</a>
  static final String ACCESS_CONTROL_ALLOW_CREDENTIALS =
      "Access-Control-Allow-Credentials";

  /// The CORS {@code Access-Control-Allow-Headers} response header field name.
  /// @see <a href="https://www.w3.org/TR/cors/">CORS W3C recommendation</a>
  static final String ACCESS_CONTROL_ALLOW_HEADERS =
      "Access-Control-Allow-Headers";

  /// The CORS {@code Access-Control-Allow-Methods} response header field name.
  /// @see <a href="https://www.w3.org/TR/cors/">CORS W3C recommendation</a>
  static final String ACCESS_CONTROL_ALLOW_METHODS =
      "Access-Control-Allow-Methods";

  /// The CORS {@code Access-Control-Allow-Origin} response header field name.
  /// @see <a href="https://www.w3.org/TR/cors/">CORS W3C recommendation</a>
  static final String ACCESS_CONTROL_ALLOW_ORIGIN =
      "Access-Control-Allow-Origin";

  /// The CORS {@code Access-Control-Expose-Headers} response header field name.
  /// @see <a href="https://www.w3.org/TR/cors/">CORS W3C recommendation</a>
  static final String ACCESS_CONTROL_EXPOSE_HEADERS =
      "Access-Control-Expose-Headers";

  /// The CORS {@code Access-Control-Max-Age} response header field name.
  /// @see <a href="https://www.w3.org/TR/cors/">CORS W3C recommendation</a>
  static final String ACCESS_CONTROL_MAX_AGE = "Access-Control-Max-Age";

  /// The CORS {@code Access-Control-Request-Headers} request header field name.
  /// @see <a href="https://www.w3.org/TR/cors/">CORS W3C recommendation</a>
  static final String ACCESS_CONTROL_REQUEST_HEADERS =
      "Access-Control-Request-Headers";

  /// The CORS {@code Access-Control-Request-Method} request header field name.
  /// @see <a href="https://www.w3.org/TR/cors/">CORS W3C recommendation</a>
  static final String ACCESS_CONTROL_REQUEST_METHOD =
      "Access-Control-Request-Method";

  /// The HTTP {@code Age} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7234#section-5.1">Section 5.1 of RFC 7234</a>
  static final String AGE = "Age";

  /// The HTTP {@code Allow} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-7.4.1">Section 7.4.1 of RFC 7231</a>
  static final String ALLOW = "Allow";

  /// The HTTP {@code Authorization} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7235#section-4.2">Section 4.2 of RFC 7235</a>
  static final String AUTHORIZATION = "Authorization";

  /// The HTTP {@code Cache-Control} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7234#section-5.2">Section 5.2 of RFC 7234</a>
  static final String CACHE_CONTROL = "Cache-Control";

  /// The HTTP {@code Connection} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7230#section-6.1">Section 6.1 of RFC 7230</a>
  static final String CONNECTION = "Connection";

  /// The HTTP {@code Content-Encoding} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-3.1.2.2">Section 3.1.2.2 of RFC 7231</a>
  static final String CONTENT_ENCODING = "Content-Encoding";

  /// The HTTP {@code Content-Disposition} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc6266">RFC 6266</a>
  static final String CONTENT_DISPOSITION = "Content-Disposition";

  /// The HTTP {@code Content-Language} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-3.1.3.2">Section 3.1.3.2 of RFC 7231</a>
  static final String CONTENT_LANGUAGE = "Content-Language";

  /// The HTTP {@code Content-Length} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7230#section-3.3.2">Section 3.3.2 of RFC 7230</a>
  static final String CONTENT_LENGTH = "Content-Length";

  /// The HTTP {@code Content-Location} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-3.1.4.2">Section 3.1.4.2 of RFC 7231</a>
  static final String CONTENT_LOCATION = "Content-Location";

  /// The HTTP {@code Content-Range} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7233#section-4.2">Section 4.2 of RFC 7233</a>
  static final String CONTENT_RANGE = "Content-Range";

  /// The HTTP {@code Content-Type} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-3.1.1.5">Section 3.1.1.5 of RFC 7231</a>
  static final String CONTENT_TYPE = "Content-Type";

  /// The HTTP {@code Cookie} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc2109#section-4.3.4">Section 4.3.4 of RFC 2109</a>
  static final String COOKIE = "Cookie";

  /// The HTTP {@code Date} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-7.1.1.2">Section 7.1.1.2 of RFC 7231</a>
  static final String DATE = "Date";

  /// The HTTP {@code ETag} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7232#section-2.3">Section 2.3 of RFC 7232</a>
  static final String ETAG = "ETag";

  /// The HTTP {@code Expect} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-5.1.1">Section 5.1.1 of RFC 7231</a>
  static final String EXPECT = "Expect";

  /// The HTTP {@code Expires} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7234#section-5.3">Section 5.3 of RFC 7234</a>
  static final String EXPIRES = "Expires";

  /// The HTTP {@code From} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-5.5.1">Section 5.5.1 of RFC 7231</a>
  static final String FROM = "From";

  /// The HTTP {@code Host} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7230#section-5.4">Section 5.4 of RFC 7230</a>
  static final String HOST = "Host";

  /// The HTTP {@code If-Match} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7232#section-3.1">Section 3.1 of RFC 7232</a>
  static final String IF_MATCH = "If-Match";

  /// The HTTP {@code If-Modified-Since} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7232#section-3.3">Section 3.3 of RFC 7232</a>
  static final String IF_MODIFIED_SINCE = "If-Modified-Since";

  /// The HTTP {@code If-None-Match} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7232#section-3.2">Section 3.2 of RFC 7232</a>
  static final String IF_NONE_MATCH = "If-None-Match";

  /// The HTTP {@code If-Range} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7233#section-3.2">Section 3.2 of RFC 7233</a>
  static final String IF_RANGE = "If-Range";

  /// The HTTP {@code If-Unmodified-Since} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7232#section-3.4">Section 3.4 of RFC 7232</a>
  static final String IF_UNMODIFIED_SINCE = "If-Unmodified-Since";

  /// The HTTP {@code Last-Modified} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7232#section-2.2">Section 2.2 of RFC 7232</a>
  static final String LAST_MODIFIED = "Last-Modified";

  /// The HTTP {@code Link} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc5988">RFC 5988</a>
  static final String LINK = "Link";

  /// The HTTP {@code Location} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-7.1.2">Section 7.1.2 of RFC 7231</a>
  static final String LOCATION = "Location";

  /// The HTTP {@code Max-Forwards} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-5.1.2">Section 5.1.2 of RFC 7231</a>
  static final String MAX_FORWARDS = "Max-Forwards";

  /// The HTTP {@code Origin} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc6454">RFC 6454</a>
  static final String ORIGIN = "Origin";

  /// The HTTP {@code Pragma} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7234#section-5.4">Section 5.4 of RFC 7234</a>
  static final String PRAGMA = "Pragma";

  /// The HTTP {@code Proxy-Authenticate} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7235#section-4.3">Section 4.3 of RFC 7235</a>
  static final String PROXY_AUTHENTICATE = "Proxy-Authenticate";

  /// The HTTP {@code Proxy-Authorization} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7235#section-4.4">Section 4.4 of RFC 7235</a>
  static final String PROXY_AUTHORIZATION = "Proxy-Authorization";

  /// The HTTP {@code Range} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7233#section-3.1">Section 3.1 of RFC 7233</a>
  static final String RANGE = "Range";

  /// The HTTP {@code Referer} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-5.5.2">Section 5.5.2 of RFC 7231</a>
  static final String REFERER = "Referer";

  /// The HTTP {@code Retry-After} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-7.1.3">Section 7.1.3 of RFC 7231</a>
  static final String RETRY_AFTER = "Retry-After";

  /// The HTTP {@code Server} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-7.4.2">Section 7.4.2 of RFC 7231</a>
  static final String SERVER = "Server";

  /// The HTTP {@code Set-Cookie} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc2109#section-4.2.2">Section 4.2.2 of RFC 2109</a>
  static final String SET_COOKIE = "Set-Cookie";

  /// The HTTP {@code Set-Cookie2} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc2965">RFC 2965</a>
  static final String SET_COOKIE2 = "Set-Cookie2";

  /// The HTTP {@code TE} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7230#section-4.3">Section 4.3 of RFC 7230</a>
  static final String TE = "TE";

  /// The HTTP {@code Trailer} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7230#section-4.4">Section 4.4 of RFC 7230</a>
  static final String TRAILER = "Trailer";

  /// The HTTP {@code Transfer-Encoding} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7230#section-3.3.1">Section 3.3.1 of RFC 7230</a>
  static final String TRANSFER_ENCODING = "Transfer-Encoding";

  /// The HTTP {@code Upgrade} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7230#section-6.7">Section 6.7 of RFC 7230</a>
  static final String UPGRADE = "Upgrade";

  /// The HTTP {@code User-Agent} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-5.5.3">Section 5.5.3 of RFC 7231</a>
  static final String USER_AGENT = "User-Agent";

  /// The HTTP {@code Vary} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7231#section-7.1.4">Section 7.1.4 of RFC 7231</a>
  static final String VARY = "Vary";

  /// The HTTP {@code Via} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7230#section-5.7.1">Section 5.7.1 of RFC 7230</a>
  static final String VIA = "Via";

  /// The HTTP {@code Warning} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7234#section-5.5">Section 5.5 of RFC 7234</a>
  static final String WARNING = "Warning";

  /// The HTTP {@code WWW-Authenticate} header field name.
  /// @see <a href="https://tools.ietf.org/html/rfc7235#section-4.1">Section 4.1 of RFC 7235</a>
  static final String WWW_AUTHENTICATE = "WWW-Authenticate";

  HttpHeaders(Map<String, List<String>>? headers) : super(headers ?? {});

  HttpHeaders.fromSingleValues(Map<String, String>? headers)
      : super(_expandToHeadersAll(headers ?? {}) ?? {});

  late final Map<String, String> singleValues = UnmodifiableMapView(
    CaseInsensitiveMap.from(
      map((key, value) => MapEntry(key, joinHeaderValues(value)!)),
    ),
  );

  factory HttpHeaders.from(Map<String, List<String>>? values) {
    if (values == null || values.isEmpty) {
      return _emptyHeaders;
    } else if (values is HttpHeaders) {
      return values;
    } else {
      return HttpHeaders._(values.entries);
    }
  }

  factory HttpHeaders.fromEntries(
    Iterable<MapEntry<String, List<String>>>? entries,
  ) {
    if (entries == null || (entries is List && entries.isEmpty)) {
      return _emptyHeaders;
    } else {
      return HttpHeaders._(entries);
    }
  }

  HttpHeaders._(Iterable<MapEntry<String, List<String>>> entries)
      : super(
          CaseInsensitiveMap.fromEntries(
            entries
                .where((e) => e.value.isNotEmpty)
                .map((e) => MapEntry(e.key, List.unmodifiable(e.value))),
          ),
        );

  HttpHeaders._empty() : super(const {});

  factory HttpHeaders.empty() => _emptyHeaders;
}

/// Returns a [Map] with the values from [original] and the values from
/// [updates].
///
/// For keys that are the same between [original] and [updates], the value in
/// [updates] is used.
///
/// If [updates] is `null` or empty, [original] is returned unchanged.
Map<K, V> updateMap<K, V>(Map<K, V> original, Map<K, V?>? updates) {
  if (updates == null || updates.isEmpty) return original;

  final value = Map.of(original);
  for (var entry in updates.entries) {
    final val = entry.value;
    if (val == null) {
      value.remove(entry.key);
    } else {
      value[entry.key] = val;
    }
  }

  return value;
}

/// Adds a header with [name] and [value] to [headers], which may be null.
///
/// Returns a new map without modifying [headers].
Map<String, Object> addHeader(
  Map<String, Object>? headers,
  String name,
  String value,
) {
  headers = headers == null ? {} : Map.from(headers);
  headers[name] = value;
  return headers;
}

/// Removed the header with case-insensitive name [name].
///
/// Returns a new map without modifying [headers].
Map<String, Object> removeHeader(
  Map<String, Object>? headers,
  String name,
) {
  headers = headers == null ? {} : Map.from(headers);
  headers.removeWhere((header, value) => equalsIgnoreAsciiCase(header, name));
  return headers;
}

/// Returns the header with the given [name] in [headers].
///
/// This works even if [headers] is `null`, or if it's not yet a
/// case-insensitive map.
String? findHeader(Map<String, List<String>?>? headers, String name) {
  if (headers == null) return null;
  if (headers is CaseInsensitiveMap) {
    return joinHeaderValues(headers[name]);
  }

  for (var key in headers.keys) {
    if (equalsIgnoreAsciiCase(key, name)) {
      return joinHeaderValues(headers[key]);
    }
  }
  return null;
}

Map<String, List<String>> updateHeaders(
  Map<String, List<String>> initialHeaders,
  Map<String, Object?>? changeHeaders,
) {
  return updateMap<String, List<String>>(
    initialHeaders,
    _expandToHeadersAll(changeHeaders),
  );
}

Map<String, List<String>>? _expandToHeadersAll(
  Map<String, Object?>? headers,
) {
  if (headers is Map<String, List<String>>) return headers;
  if (headers == null || headers.isEmpty) return null;

  return Map.fromEntries(headers.entries.map((e) {
    final val = e.value;
    return MapEntry(e.key, val == null ? [] : expandHeaderValue(val));
  }));
}

Map<String, List<String>>? expandToHeadersAll(
  Map<String, Object>? headers,
) {
  if (headers is Map<String, List<String>>) return headers;
  if (headers == null || headers.isEmpty) return null;

  return Map.fromEntries(headers.entries.map((e) {
    return MapEntry(e.key, expandHeaderValue(e.value));
  }));
}

List<String> expandHeaderValue(Object v) {
  if (v is String) {
    return [v];
  } else if (v is List<String>) {
    return v;
  } else if ((v as dynamic) == null) {
    return const [];
  } else {
    throw ArgumentError('Expected String or List<String>, got: `$v`.');
  }
}

/// Multiple header values are joined with commas.
/// See https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-p1-messaging-21#page-22
String? joinHeaderValues(List<String>? values) {
  if (values == null) return null;
  if (values.isEmpty) return '';
  if (values.length == 1) return values.single;
  return values.join(',');
}
