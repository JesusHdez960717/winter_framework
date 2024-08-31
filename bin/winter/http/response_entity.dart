import 'http_headers.dart';
import 'http_status.dart';

class ResponseEntity<T> {
  HttpHeaders headers;
  T? body;
  HttpStatus status;

  ResponseEntity({
    HttpHeaders? headers,
    this.body,
    HttpStatus? status,
  })  : headers = headers ?? HttpHeaders.empty(),
        status = status ?? HttpStatus.OK;

  bool get hasBody => body != null;
}
