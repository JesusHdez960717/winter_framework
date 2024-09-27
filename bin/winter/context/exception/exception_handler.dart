import '../../winter.dart';

abstract class ExceptionHandler {
  Future<ResponseEntity> call(
    RequestEntity request,
    Exception error,
    StackTrace stackTrace,
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
        exception.statusCode,
        body: om.serialize(exception.violations),
      );
    } else if (exception is ApiException) {
      return ResponseEntity(
        exception.statusCode,
        body: exception.message,
      );
    }
    return ResponseEntity.internalServerError(body: exception.toString());
  }
}
