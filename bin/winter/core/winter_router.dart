import 'dart:async';

import 'package:shelf/shelf.dart';

import '../http/http.dart';

/// Check if the [regexp] is non-capturing.
bool _isNoCapture(String regexp) {
  // Construct a new regular expression matching anything containing regexp,
  // then match with empty-string and count number of groups.
  return RegExp('^(?:$regexp)|.*\$').firstMatch('')!.groupCount == 0;
}

typedef RequestHandler<In, Out> = FutureOr<ResponseEntity<Out>> Function(
    RequestEntity<In> request);

class WinterRouter {
  static ResponseEntity<String> notFoundResponse = ResponseEntity(
    headers: HttpHeaders.empty(),
    body: 'Route not found',
    status: HttpStatus.NOT_FOUND,
  );

  static ResponseEntity<String> methodNotAllowedResponse = ResponseEntity(
    headers: HttpHeaders.empty(),
    body: 'Method not allowed',
    status: HttpStatus.METHOD_NOT_ALLOWED,
  );

  String basePath;
  final List<WinterRoute> _routes;

  WinterRouter({
    this.basePath = '',
    List<WinterRoute> routes = const [],
  }) : _routes = routes;

  List<WinterRoute>? _expandedRoutes;

  List<WinterRoute> get expandedRoutes {
    if (_expandedRoutes != null) {
      _expandedRoutes = _flattenRoutes(_routes, initialPath: basePath);
    }

    return _expandedRoutes ?? [];
  }

  Future<Response> call(Request request) async {
    HttpMethod? requestMethod =
        HttpMethod.valueOfOrNull(request.method.toUpperCase());
    if (requestMethod == null) {
      return methodNotAllowedResponse.toResponse();
    }

    for (var route in expandedRoutes) {
      if (route.method != requestMethod) {
        continue;
      }
      var params = route.match('/${request.url.path}');
      if (params != null) {
        return await route.invoke(request, params);
      }
    }
    return notFoundResponse.toResponse();
  }

  List<WinterRoute> _flattenRoutes(
    List<WinterRoute> routers, {
    String initialPath = '',
  }) {
    List<WinterRoute> result = [];

    void flattenRoutes(String parentPath, List<WinterRoute> routes) {
      for (var route in routes) {
        String fullPath =
            (parentPath + route.path).replaceAll(RegExp(r'/+'), '/');
        result.add(
          WinterRoute(
            path: fullPath,
            method: route.method,
            handler: route.handler,
          ),
        );
        if (route.routes.isNotEmpty) {
          flattenRoutes(fullPath, route.routes);
        }
      }
    }

    flattenRoutes(basePath, routers);

    return result;
  }
}

class WinterRoute<In, Out> {
  /// Pattern for parsing the route pattern
  static final RegExp _parser = RegExp(r'([^<]*)(?:<([^>|]+)(?:\|([^>]*))?>)?');

  final String path;
  final HttpMethod method;
  final RequestHandler<In, Out> handler;

  /// Expression that the request path must match.
  ///
  /// This also captures any parameters in the route pattern.
  final RegExp _routePattern;

  /// Names for the parameters in the route pattern.
  final List<String> _params;

  /// List of parameter names in the route pattern.
  List<String> get params => _params.toList(); // exposed for using generator.

  final List<WinterRoute> routes;

  WinterRoute._(
    this.method,
    this.path,
    this.handler,
    this.routes,
    this._routePattern,
    this._params,
  );

  factory WinterRoute({
    required String path,
    required HttpMethod method,
    required RequestHandler<In, Out> handler,
    List<WinterRoute> routes = const [],
  }) {
    if (!path.startsWith('/')) {
      throw ArgumentError.value(
          path, 'path', 'expected route to start with a slash');
    }

    final params = <String>[];
    var pattern = '';
    for (var m in _parser.allMatches(path)) {
      pattern += RegExp.escape(m[1]!);
      if (m[2] != null) {
        params.add(m[2]!);
        if (m[3] != null && !_isNoCapture(m[3]!)) {
          throw ArgumentError.value(
              path, 'path', 'expression for "${m[2]}" is capturing');
        }
        pattern += '(${m[3] ?? r'[^/]+'})';
      }
    }
    final routePattern = RegExp('^$pattern\$');

    return WinterRoute._(
      method,
      path,
      handler,
      routes,
      routePattern,
      params,
    );
  }

  /// Returns a map from parameter name to value, if the path matches the
  /// route pattern. Otherwise returns null.
  Map<String, String>? match(String path) {
    // Check if path matches the route pattern
    var m = _routePattern.firstMatch(path);
    if (m == null) {
      return null;
    }
    // Construct map from parameter name to matched value
    var params = <String, String>{};
    for (var i = 0; i < _params.length; i++) {
      // first group is always the full match, we ignore this group.
      params[_params[i]] = m[i + 1]!;
    }
    return params;
  }

  Future<Response> invoke(Request request, Map<String, String> params) async {
    RequestEntity<In> requestEntity = await request.toEntity();
    if (handler is RequestHandler || _params.isEmpty) {
      // ignore: avoid_dynamic_calls
      return (await handler(requestEntity)).toResponse();
    }
    return (await Function.apply(handler, [
      requestEntity,
      ..._params.map((n) => params[n]),
    ]) as ResponseEntity<Out>)
        .toResponse();
  }
}

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
