import 'package:test/test.dart';

import '../../bin/jackson/object_mapper_impl.dart';
import '../../bin/winter/winter.dart';

late ObjectMapper parser;

void main() {
  setUpAll(() {
    // Global config for all tests
    ///it's used `prettyPrint: false` to avoid errors with indentation & spacing
    parser = ObjectMapperImpl(
      namingStrategy: NamingStrategies.snakeCase, //by default use
      prettyPrint: false,
    );
  });

  test('Serialize - Map<String, dynamic>', () async {
    Map<String, dynamic> object = {"name": "John", "age": 30, "active": true};
    String result = '{"name":"John","age":30,"active":true}';
    String jsonString = parser.serialize(object);

    expect(jsonString, result);
  });

  test('Serialize - Map<String, String>', () async {
    Map<String, dynamic> object = {"name": "John", "age": "30", "active": true};
    String result = '{"name":"John","age":"30","active":true}';
    String jsonString = parser.serialize(object);

    expect(jsonString, result);
  });

  test('Serialize - List<String>', () async {
    ObjectMapperImpl parser = ObjectMapperImpl(
      namingStrategy: NamingStrategies.snakeCase,
      prettyPrint: false,
    );

    List<String> object = ["John", '30', "active"];
    String result = '["John","30","active"]';
    String jsonString = parser.serialize(object);

    expect(jsonString, result);
  });

  test('Serialize - List<dynamic>', () async {
    ObjectMapperImpl parser = ObjectMapperImpl(
      namingStrategy: NamingStrategies.snakeCase,
      prettyPrint: false,
    );

    List<dynamic> object = ["John", 30, "active"];
    String result = '["John",30,"active"]';
    String jsonString = parser.serialize(object);

    expect(jsonString, result);
  });

  //---------- Single types ----------\\
  test('Serialize/Deserialize: DateTime', () async {
    DateTime object = DateTime.now();
    String expectedString = object.toIso8601String();
    String jsonString = parser.serialize(object);

    expect(expectedString, jsonString);

    DateTime deserializedObject = parser.deserialize(jsonString, DateTime);
    expect(deserializedObject.toIso8601String(), object.toIso8601String());
  });

  test('Serialize/Deserialize: DateTime (Custom Parser)', () async {
    ObjectMapperImpl customParser = ObjectMapperImpl(
      defaultSerializerOverride: {
        DateTime: (dynamic object) =>
        (object as DateTime).millisecondsSinceEpoch,
      },
      defaultDeserializerOverride: {
        DateTime: (dynamic value) =>
            DateTime.fromMillisecondsSinceEpoch(int.parse(value)),
      },
    );

    DateTime object = DateTime.now();
    String expectedString = '${object.millisecondsSinceEpoch}';
    String jsonString = customParser.serialize(object);

    expect(expectedString, jsonString);

    DateTime deserializedObject =
    customParser.deserialize(jsonString, DateTime);

    expect(deserializedObject.millisecondsSinceEpoch,
        object.millisecondsSinceEpoch);
  });

  test('Serialize/Deserialize: Duration', () async {
    Duration object = Duration(days: 5);
    int rawResult = object.inMilliseconds;
    String result = rawResult.toString();
    String jsonString = parser.serialize(object);

    expect(jsonString, result);

    Duration duration = parser.deserialize(jsonString, Duration);
    expect(object.inMilliseconds, duration.inMilliseconds);
  });

  test('Serialize/Deserialize: Duration (Custom Parser)', () async {
    //use custom parser to double
    ObjectMapperImpl parser = ObjectMapperImpl(
      defaultSerializerOverride: {
        Duration: (dynamic object) => (object as Duration).toString(),
      },
      defaultDeserializerOverride: {
        Duration: (dynamic value) {
          List<String> parts = (value as String).split(".");

          // Obtiene la parte de horas, minutos, segundos
          List<String> timeParts = parts[0].split(":");
          int hours = int.parse(timeParts[0]);
          int minutes = int.parse(timeParts[1]);
          int seconds = int.parse(timeParts[2]);

          // Obtiene la parte de milisegundos si existe
          int milliseconds = parts.length > 1 ? int.parse(parts[1]) : 0;

          Duration d = Duration(
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            milliseconds: milliseconds ~/ 1000,
          );
          return d;
        },
      },
    );

    Duration object =
        Duration(days: 5, hours: 3, seconds: 20, milliseconds: 850);

    String expectedSerializedResult = object.toString();
    String jsonString = parser.serialize(object);

    expect(jsonString, expectedSerializedResult);

    Duration duration = parser.deserialize(jsonString, Duration);
    expect(object.inMilliseconds, duration.inMilliseconds);
  });

  test('Serialize/Deserialize: Uri', () async {
    Uri object = Uri.parse('https://google.com');

    String expectedResult = object.toString();

    String jsonString = parser.serialize(object);

    expect(jsonString, expectedResult);

    Uri uri = Uri.parse(jsonString);
    expect(uri.toString(), object.toString());
  });

  test('Serialize/Deserialize: Uri (Custom Parser)', () async {
    //Can't think in a custom serializer for uri
  });

  test('Serialize/Deserialize: RegExp', () async {
    RegExp object = RegExp(r'^[a-zA-Z0-9]+$');
    String jsonString = parser.serialize(object);

    RegExp deserializedObject = parser.deserialize(jsonString, RegExp);
    expect(deserializedObject.pattern, object.pattern);
  });

  test('Serialize/Deserialize: RegExp (Custom Parser)', () async {
    //Can't think in a custom serializer for regex
  });

  test('Serialize/Deserialize: String', () async {
    String object = "Hello, world!";
    String expectedString = "Hello, world!";
    String jsonString = parser.serialize(object);

    expect(expectedString, jsonString);

    String deserializedObject = parser.deserialize(jsonString, String);
    expect(deserializedObject, object);
  });

  test('Serialize/Deserialize: String (Custom Parser)', () async {
    ObjectMapperImpl customParser = ObjectMapperImpl(
      defaultSerializerOverride: {
        String: (dynamic object) => object.toString().toUpperCase(),
      },
      defaultDeserializerOverride: {
        String: (dynamic value) => value.toString().toLowerCase(),
      },
    );

    String object = "Hello, World!".toLowerCase();
    String expectedString = "Hello, world!".toUpperCase();
    String jsonString = customParser.serialize(object);
    expect(expectedString, jsonString);

    String deserializedObject = customParser.deserialize(jsonString, String);
    expect(deserializedObject, object.toLowerCase());
  });

  test('Serialize/Deserialize: num', () async {
    num object = 123.45;
    String expectedNum = '123.45';
    String jsonString = parser.serialize(object);
    expect(expectedNum, jsonString);

    num deserializedObject = parser.deserialize(jsonString, num);
    expect(deserializedObject, object);
  });

  test('Serialize/Deserialize: num (Custom Parser)', () async {
    ObjectMapperImpl customParser = ObjectMapperImpl(
      defaultSerializerOverride: {
        num: (dynamic object) => (object as num).toString(),
      },
      defaultDeserializerOverride: {
        num: (dynamic value) => num.parse(value),
      },
    );

    num object = 123.45;
    String expectedNum = '123.45';
    String jsonString = customParser.serialize(object);
    expect(expectedNum, jsonString);

    num deserializedObject = customParser.deserialize(jsonString, num);
    expect(deserializedObject, object);
  });

  test('Serialize/Deserialize: int', () async {
    int object = 42;
    String expectedNum = '42';
    String jsonString = parser.serialize(object);
    expect(expectedNum, jsonString);

    int deserializedObject = parser.deserialize(jsonString, int);
    expect(deserializedObject, object);
  });

  test('Serialize/Deserialize: int (Custom Parser)', () async {
    ObjectMapperImpl customParser = ObjectMapperImpl(
      defaultSerializerOverride: {
        int: (dynamic object) => (object as int).toString(),
      },
      defaultDeserializerOverride: {
        int: (dynamic value) => int.parse(value),
      },
    );

    int object = 42;
    String jsonString = customParser.serialize(object);

    int deserializedObject = customParser.deserialize(jsonString, int);
    expect(deserializedObject, object);
  });

  test('Serialize/Deserialize: double', () async {
    double object = 42.42;
    String expectedString = '42.42';
    String jsonString = parser.serialize(object);
    expect(expectedString, jsonString);

    double deserializedObject = parser.deserialize(jsonString, double);
    expect(deserializedObject, object);
  });

  test('Serialize/Deserialize: double (Custom Parser)', () async {
    ObjectMapperImpl customParser = ObjectMapperImpl(
      defaultSerializerOverride: {
        double: (dynamic object) => (object as double).toStringAsFixed(5),
      },
      defaultDeserializerOverride: {
        double: (dynamic value) => double.parse(value),
      },
    );

    double object = 42.4200;
    String expectedString = '42.42000';
    String jsonString = customParser.serialize(object);
    expect(expectedString, jsonString);

    double deserializedObject = customParser.deserialize(jsonString, double);
    expect(deserializedObject, object);
  });

  test('Serialize/Deserialize: bool', () async {
    bool object = true;
    String expectedString = 'true';
    String jsonString = parser.serialize(object);
    expect(expectedString, jsonString);

    bool deserializedObject = parser.deserialize(jsonString, bool);
    expect(deserializedObject, object);
  });

  test('Serialize/Deserialize: bool (Custom Parser)', () async {
    ObjectMapperImpl customParser = ObjectMapperImpl(
      defaultSerializerOverride: {
        bool: (dynamic object) => (object as bool) ? "yes" : "no",
      },
      defaultDeserializerOverride: {
        bool: (dynamic value) => value == "yes",
      },
    );

    bool object = true;
    String expectedString = 'yes';
    String jsonString = customParser.serialize(object);
    expect(expectedString, jsonString);

    bool deserializedObject = customParser.deserialize(jsonString, bool);
    expect(deserializedObject, object);
  });
}
