import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'build_context.dart';
import 'server_config.dart';
import 'winter_router.dart';

import '../http/http.dart';

class WinterServer {
  final BuildContext context;
  final ServerConfig config;
  final WinterRouter router;

  late final HttpServer runningServer;
  bool hasStarted = false;

  WinterServer({
    BuildContext? context,
    ServerConfig? config,
    WinterRouter? router,
  })  : context = context ?? BuildContext(),
        config = config ?? ServerConfig(),
        router = router ?? WinterRouter();

  Future<WinterServer> start() async {
    final startTime = DateTime.now();

    /*final Router shelfRouter = Router();

    for (var element in router.expandedRoutes) {
      shelfRouter.add(
        element.method.name,
        element.path,
        (Request request) async {
          RequestEntity<String> requestEntity =
              await request.toEntity<String>();

          ResponseEntity responseEntity = await element.handler(requestEntity);

          return responseEntity.toResponse();
        },
      );
    }*/

    final handler =
        Pipeline().addMiddleware(logRequests()).addHandler(router.call);

    runningServer = await serve(
      handler,
      config.ip,
      config.port,
    );
    hasStarted = true;

    final endTime = DateTime.now();
    double timeDiff = endTime.difference(startTime).inMilliseconds / 1000;
    print('Server started on port ${runningServer.port} ($timeDiff sec)');

    return this;
  }

  Future close({bool force = false}) async {
    return runningServer.close(force: force);
  }
}
