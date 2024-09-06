import 'winter/winter.dart';

void main() async {
  WinterDI.instance.put('Hello world (from DI)', tag: 'hello-world');

  WinterServer runningServer = await WinterServer(
    config: ServerConfig(port: 9090),
    router: SimpleWinterRouter(
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
                          method: HttpMethod.POST,
                          handler: (request) => ResponseEntity.ok(
                            body:
                                '/{other} query: ${request.queryParams}, path: ${request.pathParams}, body ${request.body}',
                          ),
                        ),
                        WinterRoute(
                          path: '/789',
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
  ).start(
    afterStart: () async {
      print(WinterServer.instance);
    },
  );
}

ResponseEntity _rootHandler(RequestEntity req) {
  return ResponseEntity.ok(body: 'Hello, World!\n');
}
