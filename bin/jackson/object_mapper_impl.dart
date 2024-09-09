import 'dart:convert';
import 'dart:mirrors';

import 'package:collection/collection.dart'; // needed firstWhereOrNull. You have to add this manually, for some reason it cannot be added automatically

import '../winter/core/object_mapper.dart';

class ObjectMapperImpl extends ObjectMapper {
  ObjectMapperImpl({
    super.namingStrategy,
    super.defaultToJsonParser,
    super.defaultFromJsonParser,
  });

  @override
  String serialize(dynamic object, {bool cleanUp = false}) {
    dynamic parsedObject = _toMap(object, {});

    if (parsedObject is String) {
      return parsedObject;
    }

    dynamic cleanedUpObject = parsedObject;

    if (cleanUp) {
      cleanedUpObject = cleanUpObject(parsedObject);
    }

    // Beautify the JSON with indentation
    return JsonEncoder.withIndent('  ').convert(cleanedUpObject);
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
    if (object == null) {
      return object;
    }

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
  @override
  dynamic deserialize(String jsonString, Type targetType) {
    if (targetType == String) {
      return jsonString;
    }
    dynamic jsonObject = jsonDecode(jsonString);
    return _fromMap(jsonObject, targetType);
  }

  dynamic _fromMap(dynamic json, Type targetType) {
    if (json == null) return null;

    if (json is List) {
      ClassMirror classMirror = reflectType(targetType) as ClassMirror;
      TypeMirror paramTypeMirror = classMirror.typeArguments.first;
      Type subType = paramTypeMirror.reflectedType;

      return json.map((item) => _fromMap(item, subType)).toList();
    } else if (defaultFromJsonParser.containsKey(targetType)) {
      return defaultFromJsonParser[targetType]!(json);
    } else if (json is Map) {
      var classMirror = reflectClass(targetType);
      var instanceMirror = classMirror.newInstance(Symbol(''), []);

      for (var declaration in classMirror.declarations.values) {
        if (declaration is VariableMirror && !declaration.isStatic) {
          String fieldName = _getFieldName(declaration);

          if (json.containsKey(fieldName)) {
            FromJsonParserFunction? parserFunction =
                _getFromJsonParser(declaration.metadata);

            var fieldValue = json[fieldName];

            if (parserFunction != null) {
              fieldValue = parserFunction(fieldValue);
            } else {
              if (fieldValue is Map) {
                //TODO
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
              CastMap? castMapAnnotation = declaration.metadata
                  .firstWhereOrNull((element) => element.reflectee is CastMap)
                  ?.reflectee as CastMap?;

              if (castMapAnnotation != null) {
                instanceMirror.setField(declaration.simpleName,
                    castMapAnnotation.parser(fieldValue));
                continue;
              } else {
                TypeMirror fieldFirstTypeMirror =
                    (declaration.type as ClassMirror).typeArguments.first;
                String firstMapParam =
                    fieldFirstTypeMirror.reflectedType.toString();

                TypeMirror fieldSecondTypeMirror =
                    (declaration.type as ClassMirror).typeArguments[1];
                String secondMapParam =
                    fieldSecondTypeMirror.reflectedType.toString();

                String rawFieldName =
                    MirrorSystem.getName(declaration.simpleName);

                throw StateError(
                    'Cant parse Map without know it\'s type at runtime. Try add `@CastMap<$firstMapParam, $secondMapParam>()` on `Map<$firstMapParam, $secondMapParam> $rawFieldName;`');
              }
            }

            instanceMirror.setField(declaration.simpleName, fieldValue);
          } else {
            ClassMirror classMirror = declaration.type as ClassMirror;
            List<TypeMirror> fieldTypeMirror = classMirror.typeArguments;
            String params = fieldTypeMirror
                .fold(
                  "",
                  (previousValue, reflectedType) =>
                      '$previousValue, ${reflectedType.toString()}',
                )
                .replaceFirst(",", "")
                .trim();

            if (params.isNotEmpty) {
              params = '<$params>';
            }

            String rawFieldName = MirrorSystem.getName(declaration.simpleName);

            throw StateError(
                'No value in map present for field: `${classMirror.reflectedType}$params $rawFieldName`');
          }
        }
      }

      return instanceMirror.reflectee;
    } else {
      throw StateError('No hay mapper para este tipo de dato');
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
