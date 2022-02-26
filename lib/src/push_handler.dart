import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:l/l.dart';
import 'package:notifications/src/push_navigator_holder.dart';
import 'package:rxdart/subjects.dart';

import 'base_messaging_service.dart';
import 'push_handle_strategy.dart';
import 'push_handle_strategy_factory.dart';

/// Класс для управления уведомлениями
class PushHandler {
  /// Инициализация уведомлений происходит здесь при создании
  PushHandler(this._messagingService, this._strategyFactory, this._localNotificationsPlugin) {
    initialize();
  }

  /// Возможность получить уведомления напрямую
  final PublishSubject<Map<String, dynamic>> messageSubject = PublishSubject();

  final BehaviorSubject<PushHandleStrategy<dynamic>> selectNotificationSubject = BehaviorSubject();

  final PushHandleStrategyFactory _strategyFactory;
  final BaseMessagingService _messagingService;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  late Random random;

  Future<void> initialize() async {
    /// Игициализация сервиса
    await _messagingService.initNotifications(handleMessage);

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

    /// Настройки уведомлений
    final AndroidInitializationSettings androidInit = AndroidInitializationSettings(
      strategy.icon ?? '@mipmap/ic_launcher_foreground',
    );
    const IOSInitializationSettings iosInit = IOSInitializationSettings();

    /// Детали уведомлений
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      strategy.notificationChannelId ?? 'mak_it_local_id',
      strategy.notificationChannelName ?? 'mak_it_local_name',
      icon: strategy.icon,
      priority: Priority.high,
      importance: Importance.high,
      color: strategy.color,
      autoCancel: strategy.autoCancelable,
      playSound: strategy.playSound,
      ongoing: strategy.ongoing,
    );
    const IOSNotificationDetails iosDetails = IOSNotificationDetails();
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    /// Настройки ициниализации локального показа уведомлений
    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    /// Инициализация локальных уведомлений
    _localNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? value) {
        l.d('VALUE SELECTED: $value');
        selectNotificationSubject.add(strategy);
        strategy.onTapNotification(PushNavigatorHolder().navigator);
      },
    );

    if (!localNotification) {
      messageSubject.add(message.data);
    }

    if (handlerType == MessageHandlerType.onLaunch || handlerType == MessageHandlerType.onResume) {
      strategy.onBackgroundProcess(message.data);
    }

    if (handlerType == MessageHandlerType.onMessage) {
      /// Создаем [id] для показа уведомления
      final int pushId = random.nextInt((pow(2, 31) - 1).toInt());

      /// Показывем уведомление локально
      _localNotificationsPlugin.show(
        pushId,
        strategy.payload.title,
        strategy.payload.body,
        details,
        payload: jsonEncode(message.data),
      );
    }
  }
}
