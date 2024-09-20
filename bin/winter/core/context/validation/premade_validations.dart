import 'validation_service_impl.dart';

class NotEmpty extends Valid with ValidMessage {
  const NotEmpty() : super(const [notEmpty]);

  @override
  String get defaultMessage => 'Value can\'t be empty';
}

bool notEmpty(dynamic property, ConstraintValidatorContext cvc) {
  if (property == null) {
    return true;
  } else if (property is String && property.isEmpty) {
    cvc.addTemplateViolation('Text can\'t be empty');
  } else if (property is List && property.isEmpty) {
    cvc.addTemplateViolation('List can\'t be empty');
  } else if (property is Map && property.isEmpty) {
    cvc.addTemplateViolation('Map can\'t be empty');
  } else if (property is Set && property.isEmpty) {
    cvc.addTemplateViolation('Set can\'t be empty');
  }
  return cvc.isValid();
}

class Size extends Valid with ValidMessage {dfghjfghjdfghj
  final int min;
  final int max;

  const Size({required this.min, required this.max}) : super(const [size]);

  @override
  String get defaultMessage => 'Value must between $min & $max';
}

bool size(dynamic property, ConstraintValidatorContext cvc) {
  if (property == null) {
    return true;
  } else if (property is String && property.isEmpty) {
    cvc.addTemplateViolation('Text can\'t be empty');
  } else if (property is List && property.isEmpty) {
    cvc.addTemplateViolation('List can\'t be empty');
  } else if (property is Map && property.isEmpty) {
    cvc.addTemplateViolation('Map can\'t be empty');
  } else if (property is Set && property.isEmpty) {
    cvc.addTemplateViolation('Set can\'t be empty');
  }
  return cvc.isValid();
}

class NotNull extends Valid with ValidMessage {
  const NotNull() : super(const [notNull]);

  @override
  String get defaultMessage => 'Value can\'t be null';
}

bool notNull(dynamic property, ConstraintValidatorContext cvc) {
  return property != null;
}
