import 'package:flutter/widgets.dart';

/// Global navigator context storage.
class PushNavigatorHolder {
  factory PushNavigatorHolder() => _instance;

  PushNavigatorHolder._internal();

  static final PushNavigatorHolder _instance = PushNavigatorHolder._internal();

  NavigatorState? navigator;

  static PushNavigatorHolder get instance => _instance;
}
