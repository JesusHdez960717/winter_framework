import '../winter/winter.dart';
import 'object_mapper_impl.dart';

void main() async {
  // Crear algunas direcciones
  /*Address address1 = Address.named(streetName: 'Main Street', houseNumber: 123);
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
    userName: null,
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

  print('---------------------------------------------------');

  User userBack = parser.deserialize(jsonString, User);
  print(userBack.toString());*/

  /*JsonParser parser = JsonParser(namingStrategy: NamingStrategies.snakeCase);

  List<int> list = [1, 2, 3];
  String jsonString = parser.serialize(list);
  print(jsonString);

  List<int> list2 = parser.deserialize(jsonString, List<int>).cast<int>();
  print(list2.toString());*/

  /*JsonParser parser = JsonParser(namingStrategy: NamingStrategies.snakeCase);

  Map<String, int> map = {"123":123, "456":456};
  String jsonString = parser.serialize(map);
  print(jsonString);

  Map<String, int> map2 = parser.deserialize(jsonString, Map<String, int>).cast<String, int>();
  print(map2.toString());*/

  /*ObjectMapperImpl parser =
      ObjectMapperImpl(namingStrategy: NamingStrategies.snakeCase);
  Map<String, User> map = {
    "123": User.named(userName: "123"),
    "456": User.named(userName: "456")
  };
  String jsonString = parser.serialize(map);
  print(jsonString);

  print('---------------------------------------------------');

  Map<String, User> map2 =
      parser.deserialize(jsonString, Map<String, User>).cast<String, User>();
  print(map2.toString());*/
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

class User {
  // @CastMap<String, dynamic>()
  // Map<String, dynamic>? additionalAttributes;

  String? userName;

  // int? userId;
  //
  // Duration? duration;
  //
  // bool? isActive;
  //
  // @CastList<Address>()
  // List<Address>? addresses;
  //
  // Address? singleAddress;

  User();

  User.named({
    required this.userName,
    // required this.userId,
    // required this.duration,
    // required this.isActive,
    // required this.addresses,
    // required this.singleAddress,
    // required this.additionalAttributes,
  });
//
// @override
// String toString() {
//   return 'User{userName: $userName, userId: $userId, duration: $duration, isActive: $isActive, addresses: $addresses, singleAddress: $singleAddress, additionalAttributes: $additionalAttributes}';
// }
}
