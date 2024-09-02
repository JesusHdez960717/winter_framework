import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../http/http.dart';
import 'build_context.dart';
import 'server_config.dart';

class WinterServer {
  final BuildContext context;
  final ServerConfig config;

  late final HttpServer runningServer;
  bool hasStarted = false;

  WinterServer({BuildContext? context, ServerConfig? config})
      : context = context ?? BuildContext(),
        config = config ?? ServerConfig();

  Future<WinterServer> start() async {
    final Router shelfRouter = Router();

    for (var element in context.routes) {
      shelfRouter.add(
        element.method.name,
        element.path,
        (Request request) async {
          RequestEntity<String> requestEntity = RequestEntity(
            method: HttpMethod.valueOf(request.method),
            headers: HttpHeaders(request.headers),
            requestedUri: request.requestedUri,
            url: request.url,
            handlerPath: request.handlerPath,
            protocolVersion: request.protocolVersion,
            body: request.contentLength != null
                ? await request.readAsString()
                : null,
          );

          ResponseEntity responseEntity = await element.handler(requestEntity);

          return Response(
            responseEntity.status.value,
            headers: responseEntity.headers,
            body: responseEntity.body,
            encoding: responseEntity.encoding,
          );
        },
      );
    }

    final handler =
        Pipeline().addMiddleware(logRequests()).addHandler(shelfRouter.call);

    runningServer = await serve(
      handler,
      config.ip,
      config.port,
    );
    hasStarted = true;

    print('Server listening on port ${runningServer.port}');

    return this;
  }

  Future close({bool force = false}) async {
    return runningServer.close(force: force);
  }
}
