import 'json_parser.dart';
import 'naming_strategies.dart';

void main() async {
  // Crear algunas direcciones
  Address address1 = Address.named(streetName: 'Main Street', houseNumber: 123);
  Address address2 =
      Address.named(streetName: 'Second Street', houseNumber: 456);
  Address singleAddress = Address.named(streetName: 'Single', houseNumber: 111);

  // Crear un mapa de atributos adicionales
  Map<String, dynamic> additionalAttributes = {
    'nickname': 'JD',
    'preferences': {'newsletter': true, 'sms': false},
  };

  // Crear una instancia de User con una lista de direcciones y un mapa de atributos adicionales
  User user = User.named(
    userName: 'JohnDoe',
    userId: 42,
    isActive: true,
    addresses: [address1, address2],
    duration: Duration(days: 2),
    singleAddress: singleAddress,
    additionalAttributes: additionalAttributes,
  );

  // Crear una instancia de JsonParser
  JsonParser parser = JsonParser(namingStrategy: NamingStrategies.snakeCase);

  // Serializar el objeto User a JSON
  String jsonString = parser.serialize(user);

  print(jsonString);

  User userBack = parser.deserialize(jsonString);
  print(userBack.toString());
}

class Address {
  String? streetName;
  int? houseNumber;

  Address();

  Address.named({
    this.streetName,
    this.houseNumber,
  });
}

dynamic toJsonL1(dynamic prop) => prop * 1000;

dynamic toJsonDuration(dynamic object) => (object as Duration).inHours;

typedef ListParserFunction = List Function(List property);

class ListAnnotation {
  final ListParserFunction parser;

  const ListAnnotation(this.parser);
}

List parse(List list) => list.cast<Address>();

class User {
  String? userName;

  int? userId;

  Duration? duration;

  bool? isActive;

  @ListAnnotation(parse)
  List<Address>? addresses;

  Address? singleAddress;
  Map<String, dynamic>? additionalAttributes;

  User();

  User.named({
    required this.userName,
    required this.userId,
    required this.duration,
    required this.isActive,
    required this.addresses,
    required this.singleAddress,
    required this.additionalAttributes,
  });

  @override
  String toString() {
    return 'User{userName: $userName, userId: $userId, duration: $duration, isActive: $isActive, addresses: $addresses, singleAddress: $singleAddress, additionalAttributes: $additionalAttributes}';
  }
}
