// ignore_for_file: one_member_abstracts

import 'package:firebase_messaging/firebase_messaging.dart';

/// Базовое управления уведомлением
typedef HandleMessageFunction = void Function({
  required RemoteMessage message,
  required MessageHandlerType handlerType,
});

/// Типы уведомлений
enum MessageHandlerType {
  onMessage,
  onLaunch,
  onResume,
}

/// Базовый класс для имплементации сервиса уведомлений
abstract class BaseMessagingService {
  /// Инициализируем и определяем типы уведомлений
  Future<void> initNotifications(HandleMessageFunction handleMessage);

  /// Запрашиваем разрешение на отправку уведомлений [Platform.isIOS]
  Future<bool?> requestPermissions();
}
