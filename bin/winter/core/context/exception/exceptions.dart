import '../../../http/http.dart';
import '../validation/validation.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.message,
  });
}

/// exception for 400
class BadRequestException extends ApiException {
  static final HttpStatus status = HttpStatus.BAD_REQUEST;

  BadRequestException({String? message})
      : super(
          message: message ?? status.reasonPhrase,
          statusCode: status.value,
        );
}

/// exception for 401
class ForbiddenException extends ApiException {
  static final HttpStatus status = HttpStatus.UNAUTHORIZED;

  ForbiddenException({String? message})
      : super(
          message: message ?? status.reasonPhrase,
          statusCode: status.value,
        );
}

/// exception for 402
class PaymentRequiredException extends ApiException {
  static final HttpStatus status = HttpStatus.PAYMENT_REQUIRED;

  PaymentRequiredException({String? message})
      : super(
          message: message ?? status.reasonPhrase,
          statusCode: status.value,
        );
}

/// exception for 403
class UnauthorizedException extends ApiException {
  static final HttpStatus status = HttpStatus.FORBIDDEN;

  UnauthorizedException({String? message})
      : super(
          message: message ?? status.reasonPhrase,
          statusCode: status.value,
        );
}

/// exception for 404
class NotFoundException extends ApiException {
  static final HttpStatus status = HttpStatus.NOT_FOUND;

  NotFoundException({String? message})
      : super(
          message: message ?? status.reasonPhrase,
          statusCode: status.value,
        );
}

/// exception for 409
class ConflictException extends ApiException {
  static final HttpStatus status = HttpStatus.CONFLICT;

  ConflictException({String? message})
      : super(
          message: message ?? status.reasonPhrase,
          statusCode: status.value,
        );
}

/// exception for 500
class InternalServerErrorException extends ApiException {
  static final HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;

  InternalServerErrorException({String? message})
      : super(
          message: message ?? status.reasonPhrase,
          statusCode: status.value,
        );
}

/// Validation exception 422
class UnprocessableEntityException extends ApiException {
  static final HttpStatus status = HttpStatus.UNPROCESSABLE_ENTITY;

  UnprocessableEntityException({String? message})
      : super(
          message: message ?? status.reasonPhrase,
          statusCode: status.value,
        );
}

class ValidationException extends UnprocessableEntityException {
  final List<ConstrainViolation> violations;

  ValidationException({required this.violations});
}
