import 'winter/winter.dart';

void main() async {
  WinterServer runningServer = await WinterServer(
    config: ServerConfig(port: 9090),
    router: WinterRouter(
      config: RouterConfig(onInvalidUrl: IgnoreRoute.base(log: false)),
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
                      body: '/test1 ${request.requestedUri.toString()}',
                    ),
                routes: [
                  WinterRoute(
                      path: '/{test}',
                      method: HttpMethod.GET,
                      handler: (request) => ResponseEntity.ok(
                            body:
                                '/{test} query: ${request.queryParams}, path: ${request.pathParams}',
                          ),
                      routes: [
                        WinterRoute(
                          path: '/{other}',
                          method: HttpMethod.GET,
                          handler: (request) => ResponseEntity.ok(
                            body:
                                '/{other} query: ${request.queryParams}, path: ${request.pathParams}',
                          ),
                        ),
                        WinterRoute(
                          path: '/7 8 9',
                          method: HttpMethod.GET,
                          handler: (request) => ResponseEntity.ok(
                            body:
                                '/789 query: ${request.queryParams}, path: ${request.pathParams}',
                          ),
                        ),
                      ]),
                ]),
            WinterRoute(
              path: '/test2/{param}',
              method: HttpMethod.GET,
              handler: (request) => ResponseEntity.ok(
                body:
                    '/test2/{param} query: ${request.queryParams}, path: ${request.pathParams}',
              ),
            ),
          ],
        ),
      ],
    ),
  ).start();
}

ResponseEntity _rootHandler(RequestEntity req) {
  return ResponseEntity.ok(body: 'Hello, World!\n');
}
