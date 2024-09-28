import 'dart:async';

import 'package:collection/collection.dart';

import 'winter.dart';

abstract class WinterRouter {
  Future<ResponseEntity> call(RequestEntity request);
}

class SimpleWinterRouter extends WinterRouter {
  String basePath;
  final RouterConfig config;

  final List<WinterRoute> _rawRoutes;

  List<WinterRoute>? _expandedRoutes;

  SimpleWinterRouter({
    this.basePath = '',
    List<WinterRoute> routes = const [],
    RouterConfig? config,
  })  : _rawRoutes = routes,
        config = config ?? RouterConfig() {
    ///call getter to make flatten on init
    this.config.onLoadedRoutes.afterInit(expandedRoutes);
  }

  List<WinterRoute> get expandedRoutes {
    _expandedRoutes ??= _flattenRoutes(_rawRoutes, initialPath: basePath);

    return _expandedRoutes ?? [];
  }

  @override
  Future<ResponseEntity> call(RequestEntity request) async {
    ///find routes that match with the path
    String urlPath = '/${request.url.path}';
    List<WinterRoute> matchedRoutes = expandedRoutes
        .where(
          (element) => element.match(urlPath),
        )
        .toList();

    ///no routes found: 404
    if (matchedRoutes.isEmpty) {
      return ResponseEntity.notFound();
    } else {
      ///there is some route, check method (get, post, put...)
      WinterRoute? finalRoute = matchedRoutes.firstWhereOrNull(
        (element) => element.method == HttpMethod(request.method),
      );
      if (finalRoute == null) {
        ///no route matching method: 415
        return ResponseEntity.methodNotAllowed();
      } else {
        ///founded route: set up query & path params & run handler
        request.setUpPathParams(finalRoute.path);
        return await finalRoute.handler(request);
      }
    }
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
        final currentRoute = WinterRoute(
          path: fullPath,
          method: route.method,
          handler: route.handler,
        );
        if (isValidUri(fullPath)) {
          result.add(currentRoute);
        } else {
          config.onInvalidUrl.onInvalid(currentRoute);
        }

        if (route.routes.isNotEmpty) {
          flattenRoutes(fullPath, route.routes);
        }
      }
    }

    flattenRoutes(basePath, routers);

    return result;
  }

  bool isValidUri(String path) {
    // Intenta crear un objeto Uri con solo el path
    try {
      path = path.replaceAll('{', '%7B');
      path = path.replaceAll('}', '%7D');
      Uri uri = Uri(path: path);
      // Valida que el path no contenga caracteres no permitidos y que no comience con "//"
      return !path.startsWith('//') && uri.path == path;
    } catch (e) {
      return false;
    }
  }
}
