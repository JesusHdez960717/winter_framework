import 'dart:async';

import '../http/http.dart';

class WinterRouter {
  String basePath;
  List<WinterRoute> routes;

  WinterRouter({
    this.basePath = '',
    this.routes = const [],
  });

  List<WinterRoute> get expandedRoutes {
    return flattenRoutes(routes, initialPath: basePath);
  }

  List<WinterRoute> flattenRoutes(
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
  final String path;
  final HttpMethod method;
  final FutureOr<ResponseEntity<Out>> Function(RequestEntity<In> request)
      handler;

  List<WinterRoute> routes;

  WinterRoute({
    required this.path,
    required this.method,
    required this.handler,
    this.routes = const [],
  });
}
