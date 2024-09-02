import 'winter/winter.dart';

void main() async {
  WinterServer runningServer = await WinterServer(
    context: BuildContext()
      ..routes.addAll(
        [
          RequestRoute(
            path: '/test',
            method: HttpMethod.GET,
            handler: (request) => ResponseEntity.ok(
              body: 'Hello world ---- test',
            ),
          ),
          RequestRoute(
            path: '/',
            method: HttpMethod.GET,
            handler: _rootHandler,
          ),
        ],
      ),
  ).start();
}

ResponseEntity _rootHandler(RequestEntity req) {
  return ResponseEntity.ok(body: 'Hello, World!\n');
}
