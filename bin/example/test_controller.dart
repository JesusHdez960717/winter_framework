import '../winter/winter.dart';

class TestController {
  static WinterRoute hw1 = WinterRoute(
    path: '/hw1',
    method: HttpMethod.POST,
    handler: (request) async {
      HiWorld? body = await request.body<HiWorld>();
      print(body);

      return ResponseEntity.ok(
        body: body,
      );
    },
  );
}

class HiWorld {
  String? hi;
}
