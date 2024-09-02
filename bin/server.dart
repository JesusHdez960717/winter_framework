import 'winter/winter.dart';

void main() async {
  WinterServer runningServer = await WinterServer(
    router: WinterRouter(
      routes: [
        WinterRoute(
          path: '/',
          method: HttpMethod.GET,
          handler: _rootHandler,
          routes: [
            WinterRoute(
              path: '/test1',
              method: HttpMethod.GET,
              handler: (request) => ResponseEntity.ok(
                body: request.requestedUri.toString(),
              ),
              routes: [
                WinterRoute(
                  path: '/abc',
                  method: HttpMethod.GET,
                  handler: (request) => ResponseEntity.ok(
                    body: request.requestedUri.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
        WinterRoute(
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
