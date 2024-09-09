import '../winter/winter.dart';
import 'custom_exception_handler.dart';
import 'custom_router.dart';

void main() async {
  WinterDI.instance.put('Hello world (from DI)', tag: 'hello-world');

  WinterServer runningServer = await WinterServer(
    config: ServerConfig(port: 9090),
    exceptionHandler: CustomExceptionHandler.exceptionHandler,
    router: CustomRouter.router,
  ).start(
    afterStart: () async {
      print(WinterServer.instance);
    },
  );
}
