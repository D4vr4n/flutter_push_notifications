import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:l/l.dart';
import 'package:notifications/src/local_notifications_service.dart';
import 'package:notifications/src/push_navigator_holder.dart';
import 'package:rxdart/subjects.dart';

import 'base_messaging_service.dart';
import 'push_handle_strategy.dart';
import 'push_handle_strategy_factory.dart';

const String pushIdParam = 'push_id_param';

/// Класс для управления уведомлениями
class PushHandler {
  final PushHandleStrategyFactory _strategyFactory;
  final BaseMessagingService _messagingService;
  final LocalNotificationsService _localNotificationsService;

  /// Инициализация уведомлений происходит здесь при создании
  PushHandler(this._messagingService, this._strategyFactory, this._localNotificationsService) {
    initialize();
  }

  /// Возможность получить уведомления напрямую
  final PublishSubject<Map<String, dynamic>> messageSubject = PublishSubject();

  final BehaviorSubject<PushHandleStrategy<dynamic>> selectNotificationSubject = BehaviorSubject();

  late Random random;

  Future<void> initialize() async {
    /// Инициализация сервисов
    await _messagingService.initNotifications(handleMessage);

    await _localNotificationsService.init();

    /// Запрос разрешений на отправку уведомлений
    if (Platform.isIOS) {
      _messagingService.requestPermissions();
    }

    random = Random();
  }

  void handleMessage({
    required RemoteMessage message,
    required MessageHandlerType handlerType,
    bool localNotification = false,
  }) {
    final PushHandleStrategy<dynamic> strategy = _strategyFactory.createByData(message);

    /// Детали уведомлений
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      strategy.notificationChannelId ?? 'Zam Zam Local ID',
      strategy.notificationChannelName ?? 'Zam Zam Local Name',
      icon: strategy.icon,
      priority: Priority.high,
      importance: Importance.high,
      color: strategy.color,
      autoCancel: strategy.autoCancelable,
      playSound: strategy.playSound,
      ongoing: strategy.ongoing,
    );
    const IOSNotificationDetails iosDetails = IOSNotificationDetails();
    final NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    if (!localNotification) {
      messageSubject.add(message.data);
    }

    if (handlerType == MessageHandlerType.onLaunch || handlerType == MessageHandlerType.onResume) {
      strategy.onBackgroundProcess(message.data, PushNavigatorHolder().navigator);
    }

    if (handlerType == MessageHandlerType.onMessage) {
      /// Создаем [id] для показа уведомления
      final int pushId = random.nextInt((pow(2, 31) - 1).toInt());

      final payload = jsonEncode(message.data..addAll({pushIdParam: pushId}));

      /// Показывем уведомление локально
      _localNotificationsService.show(
        pushId,
        strategy.payload.title,
        strategy.payload.body,
        details,
        payload: payload,
        onSelectNotification: (payload) {
          l.d('VALUE SELECTED: $payload');

          selectNotificationSubject.add(strategy);
          strategy.onTapNotification(PushNavigatorHolder().navigator);
        },
      );
    }
  }
}
