/// Базовый класс для уведомления
abstract class NotificationPayload {
  NotificationPayload({
    required this.data,
    required this.title,
    required this.body,
    this.imageUrl,
  });

  /// [data] берется с [RemoteNotification.data]
  Map<String, dynamic> data;

  String title;
  String body;
  String? imageUrl;
}
