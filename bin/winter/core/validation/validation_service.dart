import 'dart:mirrors';

import 'package:collection/collection.dart'; // needed firstWhereOrNull. You have to add this manually, for some reason it cannot be added automatically

import '../core.dart';

typedef ValidationFunction = List<ConstrainViolation> Function(dynamic object);

class Valid {
  final List<ValidationFunction> validations;

  const Valid(this.validations);
}

class ConstrainViolation {
  final dynamic value;
  final String fieldName;
  final String message;

  const ConstrainViolation({
    required this.value,
    required this.fieldName,
    required this.message,
  });
}

class ValidationException {
  final List<ConstrainViolation> violations;

  const ValidationException(this.violations);
}

class ValidationService {
  late final NamingStrategy namingStrategy;

  ValidationService({
    NamingStrategy? namingStrategy,
  }) {
    this.namingStrategy = namingStrategy ?? NamingStrategies.basic;
  }

  List<ConstrainViolation> validate(dynamic object) {
    List<ConstrainViolation> violations = [];

    var objectMirror = reflect(object);
    var classMirror = objectMirror.type;
    for (var declaration in classMirror.declarations.values) {
      if (declaration is VariableMirror && !declaration.isStatic) {
        var fieldName = _getFieldName(declaration);
        var fieldValue =
            objectMirror.getField(declaration.simpleName).reflectee;

        Valid? _valid = _getValid(declaration.metadata);
        if (_valid != null) {
          for (var element in _valid.validations) {
            violations.addAll(element(fieldValue));
          }
        }
      }
    }

    return violations;
  }

  Valid? _getValid(List<InstanceMirror> metadata) {
    Valid? validAnnot = metadata
        .firstWhereOrNull((element) => element.reflectee is Valid)
        ?.reflectee as Valid?;
    if (validAnnot != null) {
      return validAnnot;
    }

    return null;
  }

  //Duplicated from object mapper
  String _getFieldName(DeclarationMirror field) {
    JsonProperty? jsonPropAnnotation = field.metadata
        .firstWhereOrNull((element) => element.reflectee is JsonProperty)
        ?.reflectee as JsonProperty?;

    if (jsonPropAnnotation != null) {
      return jsonPropAnnotation.name;
    }

    String rawFieldName = MirrorSystem.getName(field.simpleName);
    return namingStrategy(rawFieldName);
  }
}
