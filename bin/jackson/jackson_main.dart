import '../winter/winter.dart';
import '../winter/core/object_mapper/object_mapper_impl.dart';

void main() async {
  Address address1 = Address.named(streetName: 'Main Street', houseNumber: 123);
  Address address2 =
      Address.named(streetName: 'Second Street', houseNumber: 456);
  Address singleAddress = Address.named(streetName: 'Single', houseNumber: 111);

  // Crear un mapa de atributos adicionales
  Map<String, dynamic> additionalAttributes = {
    'nickname': 'JD',
    'preferences': {'newsletter': true, 'sms': false},
    'list': ['monday', 'weekend']
  };

  // Crear una instancia de User con una lista de direcciones y un mapa de atributos adicionales
  User user = User.named(
    userName: 'User name',
    userId: 42,
    isActive: true,
    addresses: [address1, address2],
    duration: Duration(days: 2),
    singleAddress: singleAddress,
    additionalAttributes: additionalAttributes,
  );

  ObjectMapperImpl parser =
      ObjectMapperImpl(namingStrategy: NamingStrategies.snakeCase);

  String jsonString = parser.serialize(user);
  print(jsonString);

  print('---------------------------------------------------');

  User user2 = parser.deserialize(jsonString, User);
  print(user2.toString());

  print(user == user2);
}

class Address {
  String? streetName;
  int? houseNumber;

  Address();

  Address.named({
    this.streetName,
    this.houseNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          streetName == other.streetName &&
          houseNumber == other.houseNumber;

  @override
  int get hashCode => streetName.hashCode ^ houseNumber.hashCode;

  @override
  String toString() {
    return 'Address{streetName: $streetName, houseNumber: $houseNumber}';
  }
}

class User {
  @CastMap<String, dynamic>()
  Map<String, dynamic>? additionalAttributes;

  String? userName;

  int? userId;

  Duration? duration;

  bool? isActive;

  @CastList<Address>()
  List<Address>? addresses;

  Address? singleAddress;

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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final User otherUser = other as User;
    return userName == otherUser.userName &&
        userId == otherUser.userId &&
        duration == otherUser.duration &&
        isActive == otherUser.isActive &&
        _listEquals(addresses, otherUser.addresses) &&
        singleAddress == otherUser.singleAddress &&
        _mapEquals(additionalAttributes, otherUser.additionalAttributes);
  }

  bool _listEquals(List? a, List? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _mapEquals(Map? a, Map? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null || a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;

      final valueA = a[key];
      final valueB = b[key];

      // Comparar recursivamente si el valor es otro Map
      if (valueA is Map && valueB is Map) {
        if (!_mapEquals(valueA, valueB)) return false;
      } else if (valueA is List && valueB is List) {
        return _listEquals(valueA, valueB);
      } else if (valueA != valueB) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode =>
      userName.hashCode ^
      userId.hashCode ^
      duration.hashCode ^
      isActive.hashCode ^
      addresses.hashCode ^
      singleAddress.hashCode ^
      additionalAttributes.hashCode;

  @override
  String toString() {
    return 'User{userName: $userName, userId: $userId, duration: $duration, isActive: $isActive, addresses: $addresses, singleAddress: $singleAddress, additionalAttributes: $additionalAttributes}';
  }
}
