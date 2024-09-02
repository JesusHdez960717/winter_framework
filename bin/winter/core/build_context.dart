import '../../jackson/object_mapper_impl.dart';
import 'object_mapper.dart';

class BuildContext {
  ///Storage when was this context created
  final DateTime timestamp;

  final ObjectMapper objectMapper;

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
        objectMapper = ObjectMapperImpl();
}
