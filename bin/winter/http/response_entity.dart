import 'package:shelf/shelf.dart';

import '../winter.dart';

class ResponseEntity extends Response {
  ResponseEntity(
    super.statusCode, {
    Object? body,
    ObjectMapper? objectMapper,
    super.headers,
    super.encoding,
    super.context,
  }) : super(
          body: body is! Stream
              ? (objectMapper ?? WinterServer.instance.context.objectMapper)
                  .serialize(body)
              : body,
        );

  ResponseEntity.ok({
    Object? body,
  }) : this(
          HttpStatus.OK.value,
          body: body,
        );

  ResponseEntity.internalServerError({
    Object? body,
  }) : this(
          HttpStatus.INTERNAL_SERVER_ERROR.value,
          body: body ?? 'Internal Server Error',
        );

  ResponseEntity.badRequest({
    Object? body,
  }) : this(
          HttpStatus.BAD_REQUEST.value,
          body: body ?? 'Bad Request',
        );

  ResponseEntity.notFound({
    Object? body,
  }) : this(
          HttpStatus.NOT_FOUND.value,
          body: body ?? 'Not found',
        );

  ResponseEntity.methodNotAllowed({
    Object? body,
  }) : this(
          HttpStatus.METHOD_NOT_ALLOWED.value,
          body: body ?? 'Method not allowed',
        );
}
