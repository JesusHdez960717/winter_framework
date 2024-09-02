import 'dart:async';

import '../../jackson/object_mapper_impl.dart';
import '../http/http_method.dart';
import '../http/request_entity.dart';
import '../http/response_entity.dart';
import 'object_mapper.dart';

class RequestRoute<In, Out> {
  final String path;
  final HttpMethod method;
  final FutureOr<ResponseEntity<Out>> Function(RequestEntity<In> request) handler;

  RequestRoute({
    required this.path,
    required this.method,
    required this.handler,
  });
}

class BuildContext {
  ///Storage when was this context created
  final DateTime timestamp;

  final ObjectMapper objectMapper;

  final List<RequestRoute> routes;

  static BuildContext _singleton = BuildContext._internal();

  /// Return the current instance of the context.
  /// If there is no one, it create one
  factory BuildContext() {
    return _singleton;
  }

  ///reset to its basic the context instance
  factory BuildContext.resetInstance() {
    return _singleton = BuildContext._internal();
  }

  BuildContext._internal()
      : timestamp = DateTime.now(),
        objectMapper = ObjectMapperImpl(),
        routes = [];
}
