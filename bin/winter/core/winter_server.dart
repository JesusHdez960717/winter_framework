import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'build_context.dart';
import 'server_config.dart';

class WinterServer {
  final BuildContext context;
  final ServerConfig config;

  late final HttpServer runningServer;
  bool hasStarted = false;

  WinterServer({required this.context, required this.config});

  Future<WinterServer> start() async {
    Router _router = await _getRouter();

    final handler =
        Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

    runningServer = await serve(
      handler,
      config.ip,
      config.port,
    );
    hasStarted = true;

    print('Server listening on port ${runningServer.port}');

    return this;
  }

  Future<Router> _getRouter() async {
    Response rootHandler(Request req) {
      return Response.ok('Hello, World!\n');
    }

    Response echoHandler(Request request) {
      final message = request.params['message'];
      return Response.ok('$message\n');
    }

    return Router()
      ..get('/', rootHandler)
      ..get('/echo/<message>', echoHandler);
  }
}
