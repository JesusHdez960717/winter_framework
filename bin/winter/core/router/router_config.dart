import '../winter_router.dart';

class RouterConfig {
  RouterConfig({OnInvalidUrl? onInvalidUrl})
      : onInvalidUrl = onInvalidUrl ?? IgnoreRoute.base();

  final OnInvalidUrl onInvalidUrl;
}

//---------- START: OnInvalidUrl ----------\\
typedef RouteConsumer = void Function(WinterRoute failedRoute);

abstract class OnInvalidUrl {
  final RouteConsumer onInvalid;

  OnInvalidUrl(this.onInvalid);
}

class IgnoreRoute extends OnInvalidUrl {
  IgnoreRoute(super.onInvalid);

  factory IgnoreRoute.base({bool log = true}) {
    return IgnoreRoute(
      (failedRoute) {
        if (log) {
          print(
              '${failedRoute.path} is not a valid URL. Excluded from routing config');
        }
      },
    );
  }
}

class FailRoute extends OnInvalidUrl {
  FailRoute(super.onInvalid);

  factory FailRoute.base() {
    return FailRoute(
      (failedRoute) {
        throw StateError(
            '${failedRoute.path} is not a valid URL. Failing to start app');
      },
    );
  }
}

//---------- END: OnInvalidUrl ----------\\
