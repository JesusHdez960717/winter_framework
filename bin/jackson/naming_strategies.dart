import 'package:change_case/change_case.dart';

import 'json_parser.dart';

class NamingStrategies {
  // Example: "exampleString" -> "exampleString"
  static NamingStrategy get basic => (String value) => value;

  // Example: "exampleString" -> "example_string"
  static NamingStrategy get snakeCase => (String value) => value.toSnakeCase();

  // Example: "exampleString" -> "exampleString"
  static NamingStrategy camelCase = (String value) => value.toCamelCase();

  // Example: "exampleString" -> "ExampleString"
  static NamingStrategy pascalCase = (String value) => value.toPascalCase();

  // Example: "exampleString" -> "example-string"
  static NamingStrategy kebabCase = (String value) => value.toKebabCase();

  // Example: "exampleString" -> "example.string"
  static NamingStrategy dotCase = (String value) => value.toDotCase();

  // Example: "exampleString" -> "example/string"
  static NamingStrategy pathCase = (String value) => value.toPathCase();

  // Example: "exampleString" -> "EXAMPLE_STRING"
  static NamingStrategy constantCase = (String value) => value.toConstantCase();

  // Example: "exampleString" -> "Example-String"
  static NamingStrategy headerCase = (String value) => value.toHeaderCase();

  // Example: "exampleString" -> "Example string"
  static NamingStrategy sentenceCase = (String value) => value.toSentenceCase();

  // Example: "exampleString" -> "Example String"
  static NamingStrategy titleCase = (String value) => value.toTitleCase();

  // Example: "ExampleString" -> "eXAMPLEsTRING"
  static NamingStrategy swapCase = (String value) => value.toSwapCase();

  // Example: "exampleString" -> "EXAMPLESTRING"
  static NamingStrategy upperCase = (String value) => value.toUpperCase();

  // Example: "exampleString" -> "examplestring"
  static NamingStrategy lowerCase = (String value) => value.toLowerCase();
}
