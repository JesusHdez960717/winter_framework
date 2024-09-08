import '../winter/winter.dart';

class CustomExceptionHandler extends ExceptionHandler {
  @override
  Future<ResponseEntity> call(
      RequestEntity request, Exception error, StackTrace stackTrac) async {
    return ResponseEntity.badRequest(body: 'Exception handler');
  }
}
