import 'package:collection/collection.dart';

enum HttpMethod {
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
  HEAD,
  OPTIONS;

  static HttpMethod valueOf(String method) {
    return HttpMethod.values.firstWhere(
      (element) => element.name.toLowerCase() == method.toLowerCase(),
    );
  }

  static HttpMethod? valueOfOrNull(String method) {
    return HttpMethod.values.firstWhereOrNull(
      (element) => element.name.toLowerCase() == method.toLowerCase(),
    );
  }
}
