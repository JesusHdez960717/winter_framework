import 'object_mapper.dart';

class ObjectMapperImpl extends ObjectMapper {
  Map<Type, ToJsonParserFunction> defaultSerializer = {
    DateTime: (dynamic object) => (object as DateTime).toIso8601String(),
    Duration: (dynamic object) => (object as Duration).inMilliseconds,
    Uri: (dynamic object) => (object as Uri).toString(),
    RegExp: (dynamic object) => (object as RegExp).pattern,
    String: (dynamic object) => (object as String),
    num: (dynamic object) => (object as num),
    int: (dynamic object) => (object as int),
    double: (dynamic object) => (object as double),
    bool: (dynamic object) => (object as bool),
  };

  Map<Type, FromJsonParserFunction> defaultDeserializer = {
    DateTime: (dynamic value) => DateTime.parse(value.toString()),
    Duration: (dynamic value) =>
        Duration(milliseconds: int.parse(value.toString())),
    Uri: (dynamic value) => Uri.parse(value.toString()),
    RegExp: (dynamic value) => RegExp(value.toString()),
    String: (dynamic value) => value as String,
    num: (dynamic value) => num.parse(value.toString()),
    int: (dynamic value) => int.parse(value.toString()),
    double: (dynamic value) => double.parse(value.toString()),
    bool: (dynamic value) => bool.parse(value.toString()),
  };

  ObjectMapperImpl({
    super.namingStrategy,
    Map<Type, ToJsonParserFunction>? defaultSerializerOverride,
    Map<Type, FromJsonParserFunction>? defaultDeserializerOverride,
    super.prettyPrint,
  }) {
    defaultSerializer.addAll(defaultSerializerOverride ?? {});
    defaultDeserializer.addAll(defaultDeserializerOverride ?? {});
  }

  @override
  String serialize(dynamic object) {
    return '';
  }

  @override
  T deserialize<T>(String jsonString) {
    return 5 as T;
  }

  @override
  List<T> deserializeList<T>(String jsonString) {
    return [];
  }

  @override
  Map<K, V> deserializeMap<K, V>(String jsonString) {
    return {};
  }
}
