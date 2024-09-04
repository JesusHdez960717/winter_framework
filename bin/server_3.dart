import 'dart:core';

Map<String, String> extractPathParams(String templateUrl, String actualUrl) {
  actualUrl = Uri.parse(actualUrl).path;

  // Separar la parte de la URL que contiene los parámetros de consulta (si existe)
  String templateUrlPath = templateUrl.split('?').first;
  String actualUrlPath = actualUrl.split('?').first;

  // Crear una expresión regular para encontrar los parámetros de ruta en la plantilla
  final RegExp pathParamPattern = RegExp(r'{([^}]+)}');

  // Crear una expresión regular para capturar los valores correspondientes en la URL real
  String regexPattern = templateUrlPath.replaceAllMapped(pathParamPattern, (match) => r'([^/?]+)');

  // Añadir el inicio (^) y el final opcional ($) para asegurar una coincidencia completa
  regexPattern = '^' + regexPattern;

  // Encontrar los valores de los parámetros de ruta en la URL real
  final RegExpMatch? matchUrl = RegExp(regexPattern).firstMatch(actualUrlPath);

  Map<String, String> pathParam = {};
  Iterable<RegExpMatch> matches = pathParamPattern.allMatches(templateUrlPath);

  int index = 1;
  for (final RegExpMatch match in matches) {
    String paramName = match.group(1)!;
    String paramValue = matchUrl?.group(index++) ?? '';
    pathParam[paramName] = paramValue;
  }

  return pathParam;
}

Map<String, String> extractQueryParams(String actualUrl) {
  Uri uri = Uri.parse(actualUrl);
  return uri.queryParameters;
}

void main() {
  final String templateUrl = '/test/{path-param-1}/test/{path-param-2}';
  final String actualUrl = 'https://mi-url.com/test/abc/test/def?query_param1_key=query_param1_value&query_param2_key=query_param2_value';

  Map<String, String> pathParams = extractPathParams(templateUrl, actualUrl);
  Map<String, String> queryParams = extractQueryParams(actualUrl);

  print('Path Parameters: $pathParams');
  print('Query Parameters: $queryParams');
}
