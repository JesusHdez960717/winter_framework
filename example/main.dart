import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

// Función para iniciar el servidor en un Isolate
Future<void> startServer(SendPort sendPort) async {
  var handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler((Request request) {
    return Response.ok('Hello, world!!!');
  });

  // Crear el servidor HTTP con opción de compartir
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080, shared: true);
  shelf_io.serveRequests(server, handler);
  print('Servidor escuchando en http://${server.address.host}:${server.port} - PID ${pid}');

  // Notificar al Isolate principal que el servidor ha comenzado
  sendPort.send('Servidor iniciado en Isolate con PID ${pid}');
}

// Función principal
Future<void> main() async {
  var numCores = Platform.numberOfProcessors;

  print('Iniciando $numCores instancias del servidor en el mismo puerto');

  var futures = <Future>[];
  for (var i = 0; i < numCores; i++) {
    // Crear un ReceivePort para la comunicación con cada Isolate
    var receivePort = ReceivePort();

    // Iniciar un nuevo Isolate para cada instancia del servidor
    futures.add(Isolate.spawn(startServer, receivePort.sendPort));

    // Escuchar los mensajes del Isolate
    receivePort.listen((message) {
      print(message);
    });
  }

  // Esperar a que todas las instancias del servidor se inicien
  await Future.wait(futures);
  print('Todos los servidores están en ejecución en el puerto 8080');
}
