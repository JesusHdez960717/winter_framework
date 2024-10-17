import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf/src/request.dart';
import 'package:shelf/src/response.dart';

import 'winter.dart';

///Dependency Injection: easy access to the current dependency injection instance
DependencyInjection get di => Winter.instance.context.dependencyInjection;

///Dependency Injection: easy access to the current object mapper instance
ObjectMapper get om => Winter.instance.context.objectMapper;

///Validation Service: easy access to the current validation service instance
ValidationService get vs => Winter.instance.context.validationService;

///Exception Handler: easy access to the current exception handler instance
ExceptionHandler get eh => Winter.instance.context.exceptionHandler;

typedef WinterHandler = FutureOr<ResponseEntity> Function(
  RequestEntity request,
);

class Winter {
  static Winter get instance {
    if (_server == null) {
      throw StateError(
        'Server has\'t starter yet. Try starting one first.',
      );
    }
    return _server!;
  }

  static Winter? _server;

  static bool get isRunning => _server != null;

  final BuildContext context;
  final ServerConfig config;
  final AbstractWinterRouter router;
  final FilterConfig globalFilterConfig;

  final HttpServer _rawServer;

  Winter._({
    required this.context,
    required this.config,
    required this.router,
    required this.globalFilterConfig,
    required HttpServer rawServer,
  }) : _rawServer = rawServer;

  /*static Future<Winter> server({
    BuildContext? context,
    ServerConfig? config,
    AbstractWinterRouter? router,
    FilterConfig? globalFilterConfig,
  }) async {

  }*/
  
  static Future<Winter> run({
    BuildContext? context,
    ServerConfig? config,
    AbstractWinterRouter? router,
    FilterConfig? globalFilterConfig,
  }) async {
    if (isRunning) {
      throw StateError('Server already starter');
    }

    final startTime = DateTime.now();

    BuildContext nonNullContext = context ?? BuildContext();
    ServerConfig nonNullConfig = config ?? ServerConfig();
    AbstractWinterRouter nonNullRouter = router ?? BasicRouter();
    FilterConfig nonNullGlobalFilterConfig =
        globalFilterConfig ?? const FilterConfig([]);

    HttpServer rawServer = await shelf_io.serve(
      poweredByHeader: 'Winter-Server',
      (request) => _handleRunRequest(
        router: nonNullRouter,
        globalFilterConfig: nonNullGlobalFilterConfig,
        request: request,
      ),
      nonNullConfig.ip,
      nonNullConfig.port,
    );

    Winter nextRunningServer = Winter._(
      context: nonNullContext,
      config: nonNullConfig,
      router: nonNullRouter,
      globalFilterConfig: nonNullGlobalFilterConfig,
      rawServer: rawServer,
    );

    _server = nextRunningServer;

    final endTime = DateTime.now();
    double timeDiff = endTime.difference(startTime).inMilliseconds / 1000;
    print('Server started on port ${rawServer.port} ($timeDiff sec)');

    return nextRunningServer;
  }

  Future close({bool force = false}) async {
    await _rawServer.close(force: force);
    _server = null;
  }

  static FutureOr<Response> _handleRunRequest({
    required Request request,
    required AbstractWinterRouter router,
    required FilterConfig globalFilterConfig,
  }) async {
    RequestEntity requestEntity = RequestEntity(
      request.method,
      request.requestedUri,
      body: request.read(),
      context: request.context,
      encoding: request.encoding,
      handlerPath: request.handlerPath,
      headers: request.headers,
      protocolVersion: request.protocolVersion,
      url: request.url,
    );

    try {
      FilterConfig? routeFilterConfig;
      if (router is WinterRouter) {
        routeFilterConfig = router.handlerRoute(requestEntity)?.filterConfig;
      }

      WinterHandler baseCall = router.handler(requestEntity);

      FilterChain filterChain = FilterChain(
        [
          ...globalFilterConfig.filters,
          if (routeFilterConfig != null) ...routeFilterConfig.filters,
        ],
        baseCall,
      );

      return await filterChain.doFilter(requestEntity);
    } on Exception catch (error, stackTrace) {
      return Winter.instance.context.exceptionHandler.call(
        requestEntity,
        error,
        stackTrace,
      );
    }
  }
}
