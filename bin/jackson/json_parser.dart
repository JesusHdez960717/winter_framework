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
typedef FromJsonParserFunction<T, U> = T Function(U property);
typedef ToJsonParserFunction<T, U> = T Function(U property);

class PropertyParser<T, U> {
  final FromJsonParserFunction<T, U> fromJsonParser;
  final ToJsonParserFunction<U, T> toJsonParser;

  const PropertyParser(this.fromJsonParser, this.toJsonParser);
}

class FromJsonParser<T, U> {
  final FromJsonParserFunction<T, U> parser;

  const FromJsonParser(this.parser);
}

class ToJsonParser<T, U> {
  final ToJsonParserFunction<T, U> parser;

  const ToJsonParser(this.parser);
}

//-------------------------- parser --------------------------\\
class JsonParser {
  late final NamingStrategy namingStrategy;

  JsonParser({NamingStrategy? namingStrategy}) {
    this.namingStrategy = namingStrategy ?? NamingStrategies.basic;
  }

  String serialize(Object object) {
    return jsonEncode(_toMap(object, {}));
  }

  Object _toMap(Object object, Set<Object> seen) {
    if (seen.contains(object)) {
      throw StateError('Circular reference detected');
    }

    if (object is List) {
      return object.map((e) => _toMap(e, seen)).toList();
    } else if (object is Map) {
      return object.map((key, val) => MapEntry(key, _toMap(val, seen)));
    } else if (object is String || object is num || object is bool) {
      return object;
    } else if (object is DateTime) {
      //--------------------- middle
      return object.toIso8601String();
    } else if (object is Duration) {
      return object.inMilliseconds;
    } else if (object is Uri) {
      return object.toString();
    } else if (object is RegExp) {
      return object.pattern;
      //--------------------------
    } else {
      seen.add(object);

      ///its a normal object/class, use mirror to parse its internal fields
      var result = <String, dynamic>{};

      var objectMirror = reflect(object);
      var classMirror = objectMirror.type;

      ToJsonParser? classParser = classMirror.metadata
          .firstWhereOrNull((element) => element.reflectee is ToJsonParser)
          ?.reflectee as ToJsonParser?;
      if (classParser != null) {
        return classParser.parser(object);
      }

      //si la clase no tiene el parser, hago el parse mio, recorro todos los campos y los parseo-
      for (var declaration in classMirror.declarations.values) {
        if (declaration is VariableMirror && !declaration.isStatic) {
          var fieldName = _getFieldName(declaration);
          var fieldValue =
              objectMirror.getField(declaration.simpleName).reflectee;

          ToJsonParser? fieldParser = declaration.metadata
              .firstWhereOrNull((element) => element.reflectee is ToJsonParser)
              ?.reflectee as ToJsonParser?;
          if (fieldParser != null) {
            result[fieldName] = (fieldParser.parser as ToJsonParserFunction<int, int>)(fieldValue);
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
}
