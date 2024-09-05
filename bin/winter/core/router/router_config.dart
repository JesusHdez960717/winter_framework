import '../core.dart';

class RouterConfig {
  RouterConfig({OnInvalidUrl? onInvalidUrl})
      : onInvalidUrl = onInvalidUrl ?? OnInvalidUrl.ignore();

  final OnInvalidUrl onInvalidUrl;
}

//---------- START: OnInvalidUrl ----------\\
class OnInvalidUrl {
  final void Function(WinterRoute failedRoute) onInvalid;

  OnInvalidUrl(this.onInvalid);

  factory OnInvalidUrl.ignore({bool log = true}) {
    return OnInvalidUrl(
      (failedRoute) {
        if (log) {
          print(
              '${failedRoute.path} is not a valid URL. Excluded from routing config');
        }
      },
    );
  }

  factory OnInvalidUrl.fail() {
    return OnInvalidUrl(
      (failedRoute) {
        throw StateError(
            '${failedRoute.path} is not a valid URL. Failing to start app');
      },
    );
  }
}

//---------- END: OnInvalidUrl ----------\\
