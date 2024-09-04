import 'dart:core';

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

void main() {
  print(isValidUri('/test/\\123'));          // false (contiene una barra invertida)
  print(isValidUri('/test/{param}'));       // true (válido dependiendo del uso)
  print(isValidUri('/test/123'));           // true
  print(isValidUri('//test2/{param}'));     // false (inicia con //)
  print(isValidUri('/test/12 3'));          // false (contiene un espacio)
}
