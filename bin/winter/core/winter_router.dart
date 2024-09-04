import 'dart:async';

import 'package:shelf/shelf.dart';

import '../http/http.dart';

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
  }) : _routes = routes {
    expandedRoutes;//llama al getter para que haga el flatten
  }

  //TODO: por tema eficiencia se pueden agrupar las rutas por su method, o el flatten hacerlo igual jerarquico
  List<WinterRoute>? _expandedRoutes;

  List<WinterRoute> get expandedRoutes {
    _expandedRoutes ??= _flattenRoutes(_routes, initialPath: basePath);

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
      if (route.match('/${request.url.path}')) {
        return await route.invoke(request);
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
        if (isValidUri(fullPath)) {
          result.add(
            WinterRoute(
              path: fullPath,
              method: route.method,
              handler: route.handler,
            ),
          );
        } else {
          print(
              '$fullPath is not a valid URL. IGNORING'); //TODO: agregar un flag para lanzar excepcion o ignorar
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

class WinterRoute<In, Out> {
  final String path;
  final HttpMethod method;
  final RequestHandler<In, Out> handler;

  final List<WinterRoute> routes;

  WinterRoute._(
    this.method,
    this.path,
    this.handler,
    this.routes,
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

    return WinterRoute._(
      method,
      path,
      handler,
      routes,
    );
  }

  bool match(String rawActualUrl) {
    // Separar las partes de la URL y los parámetros de consulta
    String templateUrlPath = path.split('?').first;
    String actualUrlPath = rawActualUrl.split('?').first;

    // Crear una expresión regular para encontrar los parámetros de ruta en la plantilla
    final RegExp pathParamPattern = RegExp(r'{([^}]+)}');

    // Crear una expresión regular para capturar los valores correspondientes en la URL real
    String regexPattern = templateUrlPath.replaceAllMapped(
        pathParamPattern, (match) => r'([^/?]+)');
    regexPattern = '^' + regexPattern + r'$'; // Añadir el inicio y el final

    // Comprobar si la parte de la URL coincide
    final RegExpMatch? matchUrlPath =
        RegExp(regexPattern).firstMatch(actualUrlPath);

    return matchUrlPath != null;
  }

  Future<Response> invoke(Request request) async {
    RequestEntity<In> requestEntity = await request.toEntity(templateUrl: path);
    return (await handler(requestEntity)).toResponse();
  }
}

extension RequestExt on Request {
  FutureOr<RequestEntity<T>> toEntity<T>({required String templateUrl}) async {
    return RequestEntity(
      method: HttpMethod.valueOf(method),
      headers: HttpHeaders(headers),
      requestedUri: requestedUri,
      templateUrl: templateUrl,
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
