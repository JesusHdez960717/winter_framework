/// Clase que representa una validacion fallada de un objeto:
///
/// Example:
/// Teniendo la clase:
///
/// class Address {
///   @Valid([notNull, notEmpty])
///   String? streetName;
///
///   @NotNull()
///   int? houseNumber;
///
///   Address({
///     this.streetName,
///     this.houseNumber,
///   });
///
///   @override
///   String toString() {
///     return 'Address{streetName: $streetName, houseNumber: $houseNumber}';
///   }
/// }
///
/// Creamos una instancia:
///     Address address = Address(
///       streetName: '',
///       houseNumber: null,
///     );
///
/// Validamos la instancia `address`:
///     List<ConstrainViolation> violations = vs.validate(address);
///
/// Nos devuelve las ConstrainViolations:
///     List<ConstrainViolation> correctValidations = [
///       //El campo streetName no puede ser ni null ni vacio, la validacion de null no falla,
///       //pero la de NotEmpty si, por lo que se genera un ConstrainViolation con esos datos
///       ConstrainViolation(
///         value: '',
///         fieldName: 'root.streetName',
///         message: 'Text can\'t be empty',
///       ),
///       //De igual manera el houseNumber falla porque su valor es null
///       ConstrainViolation(
///         value: null,
///         fieldName: 'root.houseNumber',
///         message: 'Value can\'t be null',
///       ),
///     ];
///
///
class ConstrainViolation {
  ///Valor con el que fallo la validacion
  final dynamic value;

  ///Nombre del campo en el que fallo la validacion
  ///Si forma parte de un objeto anidado o una lista o map o similar,
  ///el nombre del field sera una concatenacion de todos los field-name desde el root hasta el campos especifico
  final String fieldName;

  ///El mensaje de la validacion fallida
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