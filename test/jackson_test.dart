import 'package:test/test.dart';

import '../bin/jackson/object_mapper_impl.dart';
import '../bin/winter/winter.dart';

void main() {
  test('Base Usage - DateTime', () async {
    ObjectMapper parser =
        ObjectMapperImpl(namingStrategy: NamingStrategies.snakeCase);

    DateTime object = DateTime.now();
    String result = object.toIso8601String();
    String jsonString = parser.serialize(object);

    expect(jsonString, result);
  });

  test('Base Usage - DateTime - Custom Parser', () async {
    ObjectMapperImpl parser = ObjectMapperImpl(
      namingStrategy: NamingStrategies.snakeCase,
      defaultToJsonParser: {
        DateTime: (dynamic object) => (object as DateTime).toString(),
      },
    );

    DateTime object = DateTime.now();
    String result = object.toString();
    String jsonString = parser.serialize(object);

    expect(jsonString, result);
  });

  test('Base Usage - Int', () async {
    ObjectMapperImpl parser = ObjectMapperImpl(namingStrategy: NamingStrategies.snakeCase);

    int object = 5;
    String result = "5";
    String jsonString = parser.serialize(object);

    expect(jsonString, result);
  });

  test('Base Usage - List', () async {
    ObjectMapperImpl parser = ObjectMapperImpl(namingStrategy: NamingStrategies.snakeCase);

    List<int> object = [1, 2, 3, 4, 5];
    String result = "[1,2,3,4,5]";
    String jsonString = parser.serialize(object);

    expect(jsonString, result);
  });
}
