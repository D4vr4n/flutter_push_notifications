import 'dart:collection';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications/notifications.dart';
import 'package:timezone/timezone.dart';

typedef NotificationCallback = void Function(String? payload)?;

class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin localNotifications;

  LocalNotificationsService({required this.localNotifications});

  Map<int, NotificationCallback> callbackMap = HashMap<int, NotificationCallback>();

  /// Настройки уведомлений
  AndroidInitializationSettings androidInit = const AndroidInitializationSettings(
    '@mipmap/ic_launcher_foreground',
  );
  IOSInitializationSettings iosInit = const IOSInitializationSettings();

  /// Настройки ициниализации локального показа уведомлений
  late InitializationSettings initializationSettings =
      InitializationSettings(android: androidInit, iOS: iosInit);

  Future<bool?> init() {
    return localNotifications.initialize(initializationSettings, onSelectNotification: (payload) {
      if (payload != null) {
        final tmpPayload = jsonDecode(payload);

        final pushId = tmpPayload![pushIdParam]! as int;

        final onSelectNotification = callbackMap[pushId];

        callbackMap.remove(pushId);

        onSelectNotification?.call(payload);
      }
    });
  }

  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails, {
    String? payload,
    NotificationCallback? onSelectNotification,
  }) {
    callbackMap[id] = onSelectNotification;

    return localNotifications.show(id, title, body, notificationDetails, payload: payload);
  }

  Future<void> schedule(
    int id,
    String? title,
    String? body,
    TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required UILocalNotificationDateInterpretation uiLocalNotificationDateInterpretation,
    required bool androidAllowWhileIdle,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) =>
      localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation: uiLocalNotificationDateInterpretation,
        androidAllowWhileIdle: androidAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      );

  Future<void> cancel(int id, {String? tag}) => localNotifications.cancel(id, tag: tag);

  Future<void> cancelAll() => localNotifications.cancelAll();
}
