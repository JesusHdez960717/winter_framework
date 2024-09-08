import '../../http/http.dart';
import '../core.dart';

class WinterRoute<In, Out> {
  final String path;
  final HttpMethod method;
  final RequestHandler handler;

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
    required RequestHandler handler,
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

  Future<ResponseEntity> invoke(RequestEntity request) async {
    return await handler(request);
  }
}
