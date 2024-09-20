class ConstrainViolation {
  final dynamic value;
  final String fieldName;
  final String message;

  const ConstrainViolation({
    required this.value,
    required this.fieldName,
    required this.message,
  });

  @override
  String toString() {
    return 'ConstrainViolation{value: $value, fieldName: $fieldName, message: $message}';
  }

  //needed for tests
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstrainViolation &&
          runtimeType == other.runtimeType &&
          value.toString() == other.value.toString() &&
          fieldName == other.fieldName &&
          message == other.message;

  @override
  int get hashCode => value.hashCode ^ fieldName.hashCode ^ message.hashCode;
}

abstract class ValidationService {
  List<ConstrainViolation> validate(
    dynamic object, {
    String? parentFieldName,
    String? fieldSeparator,
  });
}

class ValidationException {
  final List<ConstrainViolation> violations;

  const ValidationException(this.violations);
}
