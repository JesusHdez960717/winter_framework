import '../../winter.dart';

class RequestRoute extends ScanComponent {
  final String path;
  final HttpMethod method;
  final FilterConfig? filterConfig;

  const RequestRoute({
    required this.path,
    required this.method,
    this.filterConfig,
    super.order,
  });
}

class GetRoute extends RequestRoute {
  const GetRoute({required super.path, super.order, super.filterConfig})
      : super(method: HttpMethod.get);
}

class QueryRoute extends RequestRoute {
  const QueryRoute({required super.path, super.order, super.filterConfig})
      : super(method: HttpMethod.query);
}

class PostRoute extends RequestRoute {
  const PostRoute({required super.path, super.order, super.filterConfig})
      : super(method: HttpMethod.post);
}

class PutRoute extends RequestRoute {
  const PutRoute({required super.path, super.order, super.filterConfig})
      : super(method: HttpMethod.put);
}

class PatchRoute extends RequestRoute {
  const PatchRoute({required super.path, super.order, super.filterConfig})
      : super(method: HttpMethod.patch);
}

class DeleteRoute extends RequestRoute {
  const DeleteRoute({required super.path, super.order, super.filterConfig})
      : super(method: HttpMethod.delete);
}

class HeadRoute extends RequestRoute {
  const HeadRoute({required super.path, super.order, super.filterConfig})
      : super(method: HttpMethod.head);
}

class OptionsRoute extends RequestRoute {
  const OptionsRoute({required super.path, super.order, super.filterConfig})
      : super(method: HttpMethod.options);
}
