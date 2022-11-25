import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

typedef NotificationCallback = void Function(String? payload)?;

abstract class LocalNotificationsService {
  Future<bool?> init();

  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails, {
    String? payload,
    NotificationCallback? onSelectNotification,
  });

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
  });

  Future<void> cancel(int id, {String? tag});

  Future<void> cancelAll();
}
