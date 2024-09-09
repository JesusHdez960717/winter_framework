import 'dart:async';
import 'dart:io';

import 'core.dart';
import 'winter_io.dart' as WinterIo;

class WinterServer {
  static WinterServer get instance {
    if (_winterServer == null) {
      throw StateError(
          'Server hasn\'t starter yet. Try calling start() first.');
    }
    return _winterServer!;
  }

  static WinterServer? _winterServer;

  final BuildContext context;
  final ServerConfig config;
  final WinterRouter router;
  final ExceptionHandler exceptionHandler;

  late final HttpServer runningServer;

  bool get isRunning => _isRunning;
  bool _isRunning = false;

  WinterServer({
    BuildContext? context,
    ServerConfig? config,
    WinterRouter? router,
    ExceptionHandler? exceptionHandler,
    WinterDI? di,
  })  : context = context ?? BuildContext(),
        config = config ?? ServerConfig(),
        router = router ?? SimpleWinterRouter(),
        exceptionHandler = exceptionHandler ?? SimpleExceptionHandler();

  ///Start the web server with all the current config in this object
  ///beforeStart:
  /// - Function to be called right before the server actually start
  /// - Its delay is counted in the `start time` of the server
  /// - Waits for it to complete to start the server
  /// - Calling `WinterServer.instance` in this method will result in an `StateError` because the server isnt already started
  ///afterStart:
  /// - Function to be called right after the server actually start
  /// - Its delay is counted in the `start time` of the server
  /// - Waits for it to complete to mark the server as started
  /// - In this method the `WinterServer.instance` will already by initialized
  ///
  /// Example:
  /// void main() async {
  ///   await WinterServer(
  ///     config: ServerConfig(port: 9090),
  ///     router: WinterRouter(
  ///       config: RouterConfig(
  ///         onInvalidUrl: OnInvalidUrl.fail(),
  ///       ),
  ///       routes: [
  ///         WinterRoute(
  ///           path: '/',
  ///           method: HttpMethod.GET,
  ///           handler: _rootHandler,
  ///         ),
  ///       ],
  ///     ),
  ///   ).start(
  ///     beforeStart: () async {
  ///       ///print(WinterServer.instance);///Throws state error
  ///
  ///       ///config some DI or whatever
  ///       WinterDI.instance.put(
  ///         'Hello world (from DI)',
  ///         tag: 'hello-world',
  ///       );
  ///     },
  ///     afterStart: () async {
  ///       print(
  ///         WinterServer.instance.di.find<String>(tag: 'hello-world'),
  ///       ); ///current instance
  ///     },
  ///   );
  /// }
  ///
  /// ResponseEntity _rootHandler(RequestEntity req) {
  ///   return ResponseEntity.ok(body: 'Hello, World!\n');
  /// }
  Future<WinterServer> start({
    Future Function()? beforeStart,
    Future Function()? afterStart,
  }) async {
    if (_winterServer != null) {
      throw StateError('Server already starter');
    }

    final startTime = DateTime.now();

    if (beforeStart != null) {
      await beforeStart();
    }

    runningServer = await WinterIo.serve(
      (request) => router.call(request),
      exceptionHandler: (request, error, stackTrac) => exceptionHandler.call(
        request,
        error,
        stackTrac,
      ),
      config.ip,
      config.port,
      allowBodyOnGetMethod: true,
    );

    _winterServer = this;

    if (afterStart != null) {
      await afterStart();
    }

    final endTime = DateTime.now();
    double timeDiff = endTime.difference(startTime).inMilliseconds / 1000;
    print('Server started on port ${runningServer.port} ($timeDiff sec)');

    _isRunning = true;

    return this;
  }

  Future close({bool force = false}) async {
    _isRunning = false;
    _winterServer = null;
    return runningServer.close(force: force);
  }
}
