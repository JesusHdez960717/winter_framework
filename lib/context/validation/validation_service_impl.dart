import 'package:winter/winter.dart';

typedef ValidationFunction = bool Function(
  dynamic object,
  ConstraintValidatorContext cvc,
);

class Valid {
  final List<ValidationFunction> validations;

  const Valid(this.validations);
}

mixin ValidMessage {
  String get defaultMessage;
}

class ConstraintValidatorContext {
  List<String> templateViolations;
  List<ConstrainViolation> constrainViolations;
  final bool concatParentName;
  final Valid parent;

  ConstraintValidatorContext({
    required this.parent,
    List<ConstrainViolation>? constrainViolations,
    this.concatParentName = true,
  })  : constrainViolations = constrainViolations ?? [],
        templateViolations = [];

  ///Add a default violation that will be completed with the default value and field name
  void addTemplateViolation(String message) {
    templateViolations.add(message);
  }

  ///Add a fully customizable violation
  void addViolation({
    required dynamic value,
    required String fieldName,
    required String message,
  }) {
    constrainViolations.add(
      ConstrainViolation(
        value: value,
        fieldName: fieldName,
        message: message,
      ),
    );
  }

  bool hasAnyViolations() {
    return constrainViolations.isNotEmpty || templateViolations.isNotEmpty;
  }

  bool isValid() {
    return constrainViolations.isEmpty && templateViolations.isEmpty;
  }
}

class ValidationServiceImpl extends ValidationService {
  late final NamingStrategy namingStrategy;
  final String? baseName;
  final String? defaultFieldSeparator;
  final bool? defaultTrowException;

  ValidationServiceImpl({
    NamingStrategy? namingStrategy,
    this.baseName = 'root',
    this.defaultFieldSeparator = '.',
    this.defaultTrowException = false,
  }) {
    this.namingStrategy = namingStrategy ?? NamingStrategies.basic;
  }

  @override
  List<ConstrainViolation> validate(
    dynamic object, {
    String? parentFieldName,
    String? fieldSeparator,
    bool? throwExceptionOnFail = false,
  }) {
    return [];
  }
}
