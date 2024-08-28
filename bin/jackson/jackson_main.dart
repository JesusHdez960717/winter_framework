import 'json_parser.dart';
import 'naming_strategies.dart';

void main() async {
  // Crear algunas direcciones
  Address address1 = Address('Main Street', 123);
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

  print(jsonString);

  /*List<int> l = [
    1,2
  ];
  JsonParser parser = JsonParser(namingStrategy: NamingStrategies.snakeCase);
  String jsonString = parser.serialize(l);
  print(jsonString);*/
}

class Address {
  String streetName;
  int houseNumber;

  Address(this.streetName, this.houseNumber);
}

int toJson(int prop) => prop * 1000;

class User {
  @JsonProperty('user-----name')
  String userName;

  @ToJsonParser<int, int>(toJson)
  //@PropertyParser(fromJson, toJson)
  int userId;

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
    this.additionalAttributes,
  );
}
