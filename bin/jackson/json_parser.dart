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
///Definicion de funcion para hacer el parseo de un json a un objeto
typedef FromJsonParserFunction = dynamic Function(dynamic property);

///Definicion de funcion para hacer el parseo de un objeto a un json
typedef ToJsonParserFunction = dynamic Function(dynamic property);

///Definicion de funcion para hacer el casteo de: List<dynamic> a List<T>
typedef ListParserFunction<T> = List<T> Function(List property);

///Annotation con ambas funciones from-json y to-json
class PropertyParser {
  final FromJsonParserFunction fromJsonParser;
  final ToJsonParserFunction toJsonParser;

  const PropertyParser(this.fromJsonParser, this.toJsonParser);
}

///Annotation para personalizar el parsea a un objeto a un json
class FromJsonParser {
  final FromJsonParserFunction parser;

  const FromJsonParser(this.parser);
}

///Annotation para personalizar el parsea a un json de un objeto
class ToJsonParser {
  final ToJsonParserFunction parser;

  const ToJsonParser(this.parser);
}

///Annotation para obtener el tipo T de una lista y hacerle el parser
class CastList<T> {
  final ListParserFunction<T> parser;

  const CastList() : parser = listCaster;
}

///funcion por defecto para hacer el parser de una List<dynamic> a List<T>
List<T> listCaster<T>(List list) => list.cast<T>();
//-------------------------- parser --------------------------\\

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

  Map<Type, FromJsonParserFunction> defaultFromJsonParser = {
    DateTime: (dynamic value) => DateTime.parse(value),
    Duration: (dynamic value) => Duration(milliseconds: value),
    Uri: (dynamic value) => Uri.parse(value),
    RegExp: (dynamic value) => RegExp(value),
    String: (dynamic value) => value as String,
    num: (dynamic value) => value as num,
    int: (dynamic value) => value as int,
    double: (dynamic value) => value as double,
    bool: (dynamic value) => value as bool,
  };

  JsonParser({
    NamingStrategy? namingStrategy,
    Map<Type, ToJsonParserFunction>? defaultToJsonParser,
    Map<Type, FromJsonParserFunction>? defaultFromJsonParser,
  }) {
    this.namingStrategy = namingStrategy ?? NamingStrategies.basic;

    if (defaultToJsonParser != null) {
      this.defaultToJsonParser.addAll(defaultToJsonParser);
    }

    if (defaultFromJsonParser != null) {
      this.defaultFromJsonParser.addAll(defaultFromJsonParser);
    }
  }

  String serialize(dynamic object, {bool cleanUp = false}) {
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

  dynamic _toMap(dynamic object, Set<dynamic> seen) {
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

      /// It's a normal object/class, use mirror to parse its internal fields
      var result = <String, dynamic>{};

      var objectMirror = reflect(object);
      var classMirror = objectMirror.type;

      ToJsonParserFunction? classParserFunction =
          _getToJsonParser(classMirror.metadata);
      if (classParserFunction != null) {
        return classParserFunction(object);
      }

      // If the class doesn't have a parser, do the default, iterate through all fields and parse them
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

  // -------------------------- DESERIALIZE FUNCTION -------------------------- \\
  dynamic deserialize(String jsonString, Type targetType) {
    dynamic jsonObject = jsonDecode(jsonString);
    return _fromMap(jsonObject, targetType);
  }

  dynamic _fromMap(dynamic json, Type targetType) {
    if (json == null) return null;

    if (json is List) {
      ClassMirror classMirror =
          reflectType(targetType) as ClassMirror; //class mirror on 'list'
      TypeMirror paramTypeMirror =
          classMirror.typeArguments.first; //class mirror in T (siendo List<T>)
      Type subType = paramTypeMirror.reflectedType; //T

      return json.map((item) => _fromMap(item, subType)).toList();
    } else if (defaultFromJsonParser.containsKey(targetType)) {
      return defaultFromJsonParser[targetType]!(json);
    } else {
      var classMirror = reflectClass(targetType);
      var instanceMirror = classMirror.newInstance(Symbol(''), []);

      for (var declaration in classMirror.declarations.values) {
        if (declaration is VariableMirror && !declaration.isStatic) {
          String fieldName = _getFieldName(declaration);

          if (json[fieldName] != null) {
            FromJsonParserFunction? parserFunction =
                _getFromJsonParser(declaration.metadata);

            var fieldValue = json[fieldName];

            if (parserFunction != null) {
              fieldValue = parserFunction(fieldValue);
            } else {
              if (fieldValue is Map) {
                print('map 1');
              } else {}
              fieldValue = _fromMap(fieldValue, declaration.type.reflectedType);
            }

            if (fieldValue is List) {
              CastList? castListAnnotation = declaration.metadata
                  .firstWhereOrNull((element) => element.reflectee is CastList)
                  ?.reflectee as CastList?;

              if (castListAnnotation != null) {
                instanceMirror.setField(declaration.simpleName,
                    castListAnnotation.parser(fieldValue));
                continue;
              } else {
                TypeMirror fieldTypeMirror =
                    (declaration.type as ClassMirror).typeArguments.first;
                String listParam = fieldTypeMirror.reflectedType.toString();
                String rawFieldName =
                    MirrorSystem.getName(declaration.simpleName);

                throw StateError(
                    'Cant parse List without know it\'s type at runtime. Try add `@CastList<$listParam>()` on `List<$listParam> $rawFieldName;`');
              }
            } else if (fieldValue is Map) {
              print('map');
            }

            instanceMirror.setField(declaration.simpleName, fieldValue);
          }
        }
      }

      return instanceMirror.reflectee;
    }
  }

  FromJsonParserFunction? _getFromJsonParser(List<InstanceMirror> metadata) {
    PropertyParser? propertyParserLv1 = metadata
        .firstWhereOrNull((element) => element.reflectee is PropertyParser)
        ?.reflectee as PropertyParser?;
    if (propertyParserLv1 != null) {
      return propertyParserLv1.fromJsonParser;
    }

    FromJsonParser? propertyParserLv2 = metadata
        .firstWhereOrNull((element) => element.reflectee is FromJsonParser)
        ?.reflectee as FromJsonParser?;
    if (propertyParserLv2 != null) {
      return propertyParserLv2.parser;
    }
    return null;
  }

  //--------------------------
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
}
