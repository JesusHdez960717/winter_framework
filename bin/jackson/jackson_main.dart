import 'json_parser.dart';
import 'naming_strategies.dart';

void main() async {
  // Crear algunas direcciones
  /*Address address1 = Address('Main Street', 123);
  Address address2 = Address('Second Street', 456);
  Address singleAddress = Address('Single', 111);

  // Crear un mapa de atributos adicionales
  Map<String, dynamic> additionalAttributes = {
    'nickname': 'JD',
    'preferences': {'newsletter': true, 'sms': false},
  };

  // Crear una instancia de User con una lista de direcciones y un mapa de atributos adicionales
  User user = User(
    'JohnDoe',
    42,
    true,
    [address1, address2],
    singleAddress,
    additionalAttributes,
  );

  // Crear una instancia de JsonParser
  JsonParser parser = JsonParser(namingStrategy: NamingStrategies.snakeCase);

  // Serializar el objeto User a JSON
  String jsonString = parser.serialize(user);

  print(jsonString);*/

  /*List<int> l = [
    1,2
  ];
  JsonParser parser = JsonParser(namingStrategy: NamingStrategies.snakeCase);
  String jsonString = parser.serialize(l);
  print(jsonString);*/

  Map<dynamic, int> l = {
    Address('Main Street', 123): 1,
    Address('Second Street', 456): 2,
  };
  JsonParser parser = JsonParser(
    namingStrategy: NamingStrategies.snakeCase,
    defaultToJsonParser: {
      int: (dynamic object) => (object as int) * 5,
    },
  );

  String jsonString = parser.serialize(l, cleanUp: true);
  print(jsonString);
}

class Address {
  String streetName;
  int houseNumber;

  Address(this.streetName, this.houseNumber);
}

dynamic toJsonL1(dynamic prop) => prop * 1000;

dynamic toJsonDuration(dynamic object) => (object as Duration).inHours;

class User {
  @JsonProperty('user-----name')
  String userName;

  @ToJsonParser(toJsonL1)
  int userId;

  Duration duration;

  bool isActive;
  List<Address> addresses;
  Address singleAddress;
  Map<String, dynamic> additionalAttributes;

  User(
    this.userName,
    this.userId,
    this.isActive,
    this.addresses,
    this.singleAddress,
    this.additionalAttributes, {
    this.duration = const Duration(days: 2),
  });
}
