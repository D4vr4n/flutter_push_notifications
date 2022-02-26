import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:l/l.dart';

import 'push_handle_strategy.dart';

/// Определения билдера для стратегий
typedef StrategyBuilder = PushHandleStrategy<dynamic> Function(RemoteMessage data);

/// Базовый фабричный класс для различных event-ов
abstract class PushHandleStrategyFactory {
  PushHandleStrategyFactory();

  /// Ключ event-а отправленный с [Firebase]
  /// Можно изменить в имплементации фабричного класса
  static const String _key = 'type';

  /// Обычное уведомление без стратегий
  StrategyBuilder get defaultStrategy;

  /// Определяем все ивенты которые у нас будут
  Map<String, StrategyBuilder> get map => <String, StrategyBuilder>{};

  /// Возвращает стратегию с полученного уведомления
  PushHandleStrategy<dynamic> createByData(RemoteMessage message) {
    StrategyBuilder? builder;

    try {
      builder = _getStrategy(message.data);
      return builder!(message);
    } on Exception catch (e) {
      l.e('$e - cant found $_key');
      return defaultStrategy(message);
    }
  }

  /// Получаем с Map обьекта [type] если есть, если нет
  /// будет возвращена дефолтная стратегия
  StrategyBuilder? _getStrategy(Map<String, dynamic> data) {
    final StrategyBuilder? value = map[data[_key]];

    if (value != null) {
      return value;
    } else {
      throw Exception('Other type expected');
    }
  }
}
