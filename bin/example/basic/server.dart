import '../../winter/winter.dart';

void main() => WinterServer(
      config: ServerConfig(port: 9090),
      router: SimpleWinterRouter(
        config: RouterConfig(
          onInvalidUrl: OnInvalidUrl.fail(),
        ),
        routes: [
          WinterRoute(
            path: '/test',
            method: HttpMethod.GET,
            handler: (request) => ResponseEntity.ok(
              body: 'hello-world',
            ),
          ),
          WinterRoute(
            path: '/object',
            method: HttpMethod.POST,
            handler: (request) async {
              HiWorldRequest? body = await request.body<HiWorldRequest>();

              body?.validate();

              return ResponseEntity.ok(
                body: HiWorldResponse(body!.hi),
              );
            },
          ),
        ],
      ),
    ).start();

class HiWorldRequest {
  @NotEmpty()
  @NotBlank()
  String? hi;

  HiWorldRequest();

  @override
  String toString() {
    return 'HiWorldRequest{hi: $hi}';
  }
}

class HiWorldResponse {
  String? hi;

  HiWorldResponse(this.hi);

  @override
  String toString() {
    return 'HiWorldResponse{hi: $hi}';
  }
}
