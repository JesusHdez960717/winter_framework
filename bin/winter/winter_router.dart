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
    this.config.onLoadedRoutes.afterInit(
          expandedRoutes, //llama al getter para que haga el flatten cuando se inicializa
        );
  }

  List<WinterRoute> get expandedRoutes {
    _expandedRoutes ??= _flattenRoutes(_rawRoutes, initialPath: basePath);

    return _expandedRoutes ?? [];
  }

  @override
  Future<ResponseEntity> call(RequestEntity request) async {
    //busco las rutas que coincidan con el path
    String urlPath = '/${request.url.path}';
    List<WinterRoute> matchedRoutes = expandedRoutes
        .where(
          (element) => element.match(urlPath),
        )
        .toList();

    //no hay ninguna: 404
    if (matchedRoutes.isEmpty) {
      return ResponseEntity.notFound();
    } else {
      //hay alguna, reviso method
      WinterRoute? finalRoute = matchedRoutes.firstWhereOrNull(
        (element) => element.method == HttpMethod(request.method),
      );
      if (finalRoute == null) {
        //ninguna coincide con ese method
        return ResponseEntity.methodNotAllowed();
      } else {
        request.setUpPathParams(finalRoute.path);
        try {
          return await finalRoute.handler(request);
        } on Exception catch (error, stackTrace) {
          return WinterServer.instance.context.exceptionHandler.call(
            request,
            error,
            stackTrace,
          );
        }
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
