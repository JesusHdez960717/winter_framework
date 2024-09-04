import '../../http/http.dart';

ResponseEntity<String> notFoundResponse = ResponseEntity(
  headers: HttpHeaders.empty(),
  body: 'Route not found',
  status: HttpStatus.NOT_FOUND,
);

ResponseEntity<String> methodNotAllowedResponse = ResponseEntity(
  headers: HttpHeaders.empty(),
  body: 'Method not allowed',
  status: HttpStatus.METHOD_NOT_ALLOWED,
);
