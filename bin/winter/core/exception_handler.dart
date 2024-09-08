import '../http/http.dart';

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
    Exception error,
    StackTrace stackTrac,
  ) async {
    return ResponseEntity.internalServerError(body: error.toString());
  }
}
