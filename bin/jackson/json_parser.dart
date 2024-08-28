import 'dart:convert';
import 'dart:mirrors';

import 'package:collection/collection.dart'; // needed firstWhereOrNull. You have to add this manually, for some reason it cannot be added automatically

import 'naming_strategies.dart';

//-------------------------- naming --------------------------\\
typedef NamingStrategy = String Function(String value);

class JsonProperty {
  final String name;

  const JsonProperty(this.name);
}

//-------------------------- naming --------------------------\\
//-------------------------- parser --------------------------\\
typedef FromJsonParserFunction = dynamic Function(dynamic property);
typedef ToJsonParserFunction = dynamic Function(dynamic property);

class PropertyParser {
  final FromJsonParserFunction fromJsonParser;
  final ToJsonParserFunction toJsonParser;

  const PropertyParser(this.fromJsonParser, this.toJsonParser);
}

class FromJsonParser {
  final FromJsonParserFunction parser;

  const FromJsonParser(this.parser);
}

class ToJsonParser {
  final ToJsonParserFunction parser;

  const ToJsonParser(this.parser);
}

class JsonParser {
  late final NamingStrategy namingStrategy;
  Map<Type, ToJsonParserFunction> defaultToJsonParser = {
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

  JsonParser({
    NamingStrategy? namingStrategy,
    Map<Type, ToJsonParserFunction>? defaultToJsonParser,
  }) {
    this.namingStrategy = namingStrategy ?? NamingStrategies.basic;

    this.defaultToJsonParser.addAll(defaultToJsonParser ?? {});
  }

  String serialize(Object object, {bool cleanUp = false}) {
    dynamic parsedObject = _toMap(object, {});

    if (parsedObject is String) {
      return parsedObject;
    }

    dynamic cleanedUpObject = parsedObject;

    if (cleanUp) {
      cleanedUpObject = cleanUpObject(parsedObject);
    }

    return jsonEncode(cleanedUpObject);
  }

  dynamic cleanUpObject(dynamic parsedObject) {
    if (parsedObject is List) {
      return parsedObject.map((e) => cleanUpObject(e)).toList();
    } else if (parsedObject is Map) {
      return parsedObject.map((key, value) {
        return MapEntry(key.toString(), cleanUpObject(value));
      });
    } else {
      return parsedObject.toString();
    }
  }

  Object _toMap(Object object, Set<Object> seen) {
    if (seen.contains(object)) {
      throw StateError('Circular reference detected');
    }

    if (object is List) {
      return object.map((e) => _toMap(e, seen)).toList();
    } else if (object is Map) {
      return object
          .map((key, val) => MapEntry(_toMap(key, seen), _toMap(val, seen)));
    } else if (defaultToJsonParser.containsKey(object.runtimeType)) {
      return defaultToJsonParser[object.runtimeType]!(object);
    } else {
      seen.add(object);

      ///its a normal object/class, use mirror to parse its internal fields
      var result = <String, dynamic>{};

      var objectMirror = reflect(object);
      var classMirror = objectMirror.type;

      ToJsonParserFunction? classParserFunction =
          _getToJsonParser(classMirror.metadata);
      if (classParserFunction != null) {
        return classParserFunction(object);
      }

      //si la clase no tiene el parser, hago el default, recorro todos los campos y los parseo-
      for (var declaration in classMirror.declarations.values) {
        if (declaration is VariableMirror && !declaration.isStatic) {
          var fieldName = _getFieldName(declaration);
          var fieldValue =
              objectMirror.getField(declaration.simpleName).reflectee;

          ToJsonParserFunction? classParserFunction =
              _getToJsonParser(declaration.metadata);
          if (classParserFunction != null) {
            result[fieldName] = classParserFunction(fieldValue);
          } else {
            result[fieldName] = _toMap(fieldValue, seen);
          }
        }
      }
      return result;
    }
  }

  String _getFieldName(DeclarationMirror field) {
    JsonProperty? jsonPropAnnotation = field.metadata
        .firstWhereOrNull((element) => element.reflectee is JsonProperty)
        ?.reflectee as JsonProperty?;

    if (jsonPropAnnotation != null) {
      return jsonPropAnnotation.name;
    }

    String rawFieldName = MirrorSystem.getName(field.simpleName);
    return namingStrategy(rawFieldName);
  }

  ToJsonParserFunction? _getToJsonParser(List<InstanceMirror> metadata) {
    PropertyParser? propertyParserLv1 = metadata
        .firstWhereOrNull((element) => element.reflectee is PropertyParser)
        ?.reflectee as PropertyParser?;
    if (propertyParserLv1 != null) {
      return propertyParserLv1.toJsonParser;
    }

    ToJsonParser? propertyParserLv2 = metadata
        .firstWhereOrNull((element) => element.reflectee is ToJsonParser)
        ?.reflectee as ToJsonParser?;
    if (propertyParserLv2 != null) {
      return propertyParserLv2.parser;
    }
    return null;
  }
}
