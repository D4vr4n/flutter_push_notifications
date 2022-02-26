import 'package:flutter/material.dart';
import 'package:notifications/src/notification_payload.dart';

/// Базовый класс для управления различными event-ами
abstract class PushHandleStrategy<P extends NotificationPayload> {
  PushHandleStrategy(this.payload);

  /// Данные уведомления
  final P payload;

  /// Android notification channel id.
  String? notificationChannelId;

  /// Android notification channel name
  String? notificationChannelName;

  /// Push id.
  int pushId = 0;

  /// Auto close notification.
  bool autoCancelable = true;

  /// Color of icon
  Color? color;

  /// Path to string resource notification icons
  String? icon;

  /// Non-removable notification.
  /// Android only.
  bool ongoing = false;

  /// Indicates if a sound should be played when the notification is displayed.
  bool playSound = true;

  /// Display an alert when the notification is triggered while app is in the
  /// foreground.
  /// iOS 10+ only.
  bool presentAlert = true;

  @override
  String toString() {
    return 'PushHandleStrategy{notificationChannelId: $notificationChannelId,'
        ' notificationChannelName: $notificationChannelName, pushId: $pushId,'
        ' autoCancelable: $autoCancelable, color: $color, icon: $icon, ongoing:'
        ' $ongoing, playSound: $playSound, presentAlert: $presentAlert,'
        ' payload: $payload}';
  }

  /// Function that is called to process notification clicks.
  void onTapNotification(NavigatorState? navigator);

  /// Function that is called to process notification background.
  void onBackgroundProcess(Map<String, dynamic> message);
}
