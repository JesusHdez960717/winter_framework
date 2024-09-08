import '../winter/winter.dart';

class CustomRouter {
  static SimpleWinterRouter router = SimpleWinterRouter(
    config: RouterConfig(
      onInvalidUrl: OnInvalidUrl.fail(),
    ),
    routes: [
      WinterRoute(
        path: '/hw1',
        method: HttpMethod.GET,
        handler: (request) => ResponseEntity.ok(
          body: WinterDI.instance.find<String>(tag: 'hello-world'),
        ),
      ),
      WinterRoute(
        path: '/hw2',
        method: HttpMethod.GET,
        handler: (request) => ResponseEntity.ok(
          body: WinterServer.instance.di.find<String>(tag: 'hello-world'),
        ),
      ),
      WinterRoute(
        path: '/',
        method: HttpMethod.GET,
        handler: (RequestEntity req) {
          return ResponseEntity.ok(body: 'Hello, World!\n');
        },
        routes: [
          WinterRoute(
            path: '/test1',
            method: HttpMethod.GET,
            handler: (request) async {
              String body = (await request.body())!;
              String body2 = (await request.body())!;
              String body3 = (await request.body())!;
              return ResponseEntity.ok(
                body: '$body $body2 $body3',
              );
            },
          ),
          WinterRoute(
            path: '/test2',
            method: HttpMethod.GET,
            handler: (request) async {
              throw Exception('Fuck this shit');
              return ResponseEntity.ok();
            },
          ),
        ],
      ),
    ],
  );
}
