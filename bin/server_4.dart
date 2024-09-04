import 'dart:core';

bool matchUrl(String templateUrl, String actualUrl) {
  // Separar las partes de la URL y los parámetros de consulta
  String templateUrlPath = templateUrl.split('?').first;
  String actualUrlPath = actualUrl.split('?').first;

  // Crear una expresión regular para encontrar los parámetros de ruta en la plantilla
  final RegExp pathParamPattern = RegExp(r'{([^}]+)}');

  // Crear una expresión regular para capturar los valores correspondientes en la URL real
  String regexPattern = templateUrlPath.replaceAllMapped(pathParamPattern, (match) => r'([^/?]+)');
  regexPattern = '^' + regexPattern + r'$'; // Añadir el inicio y el final

  // Comprobar si la parte de la URL coincide
  final RegExpMatch? matchUrlPath = RegExp(regexPattern).firstMatch(actualUrlPath);
  if (matchUrlPath == null) {
    return false;
  }

  return true;
}

void main() {
  final String templateUrl = '/test2/{param}';
  final String actualUrl1 = '/test2/abc?query_param1_key=query_param1_value&query_param2_key=query_param2_value';
  final String actualUrl2 = '/test1/';
  final String actualUrl3 = '/test2/abc';

  print(matchUrl(templateUrl, actualUrl1)); // true
  print(matchUrl(templateUrl, actualUrl2)); // false
  print(matchUrl(templateUrl, actualUrl3)); // false
}
