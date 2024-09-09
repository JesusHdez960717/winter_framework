import '../winter/winter.dart';

class CustomExceptionHandler extends ExceptionHandler {
  static ExceptionHandler exceptionHandler = CustomExceptionHandler();

  @override
  Future<ResponseEntity> call(
      RequestEntity request, Exception error, StackTrace stackTrac) async {
    return ResponseEntity.badRequest(body: 'Exception handler');
  }
}
