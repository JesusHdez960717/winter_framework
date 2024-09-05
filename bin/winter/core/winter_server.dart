import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'core.dart';

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
  final WinterDI di;

  late final HttpServer runningServer;

  bool get hasStarted => _winterServer != null;

  WinterServer({
    BuildContext? context,
    ServerConfig? config,
    WinterRouter? router,
    WinterDI? di,
  })  : context = context ?? BuildContext(),
        config = config ?? ServerConfig(),
        router = router ?? WinterRouter(),
        di = di ?? WinterDI.instance;

  Future<WinterServer> start() async {
    if (_winterServer != null) {
      throw StateError('Server already starter');
    }

    final startTime = DateTime.now();

    final handler =
        Pipeline().addMiddleware(logRequests()).addHandler(router.call);

    runningServer = await serve(
      handler,
      config.ip,
      config.port,
      poweredByHeader: 'Powered by winter-server',
    );
    _winterServer = this;

    final endTime = DateTime.now();
    double timeDiff = endTime.difference(startTime).inMilliseconds / 1000;
    print('Server started on port ${runningServer.port} ($timeDiff sec)');

    return this;
  }

  Future close({bool force = false}) async {
    _winterServer = null;
    return runningServer.close(force: force);
  }
}
