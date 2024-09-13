import '../../bin/winter/core/core.dart';

List<ConstrainViolation> notEmpty(dynamic property) {
  if (property is String) {
    return property.isEmpty
        ? [
            ConstrainViolation(
                value: property,
                fieldName: 'name-test',
                message: 'Cant be empty')
          ]
        : [];
  }
  return [];
}

class Tool {
  @Valid([notEmpty])
  String name;

  Tool({required this.name});

  @override
  String toString() {
    return 'Tool{name: $name}';
  }
}
