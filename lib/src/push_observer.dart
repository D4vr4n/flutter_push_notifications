import 'package:flutter/widgets.dart';

import 'push_navigator_holder.dart';

/// Mixin to get navigator context.
class PushObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    PushNavigatorHolder().navigator = navigator;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    PushNavigatorHolder().navigator = navigator;
  }
}
