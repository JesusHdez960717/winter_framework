import '../../../http/http.dart';
import '../../winter_server.dart';
import 'exceptions.dart';

abstract class ExceptionHandler {
  Future<ResponseEntity> call(
    RequestEntity request,
    Exception error,
    StackTrace stackTrac,
  );
}

class SimpleExceptionHandler extends ExceptionHandler {
  @override
  Future<ResponseEntity> call(
    RequestEntity request,
    Exception exception,
    StackTrace stackTrac,
  ) async {
    if (exception is ValidationException) {
      return ResponseEntity(
        headers: HttpHeaders({}),
        body: om.serialize(exception.violations),
        status: HttpStatus.valueOf(exception.statusCode),
      );
    } else if (exception is ApiException) {
      return ResponseEntity(
        headers: HttpHeaders({}),
        body: exception.message,
        status: HttpStatus.valueOf(exception.statusCode),
      );
    }
    return ResponseEntity.internalServerError(body: exception.toString());
  }
}
