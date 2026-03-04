import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Inizializza il plugin notifiche
  static Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: android, iOS: iOS);

    try {
      await _plugin.initialize(settings);
      _initialized = true;
      debugPrint('[Notifications] Inizializzato');
    } catch (e) {
      debugPrint('[Notifications] Errore init: $e');
    }
  }

  /// Richiede permessi notifica su iOS/Android 13+
  static Future<void> requestPermission() async {
    try {
      // iOS
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      // Android 13+
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('[Notifications] Permessi errore: $e');
    }
  }

  /// Mostra notifica alert budget
  static Future<void> showBudgetAlert({
    required String categoryName,
    required double percent,
    required bool isOver,
  }) async {
    if (!_initialized) return;

    final percentStr = '${(percent * 100).toStringAsFixed(0)}%';
    final title = isOver
        ? '🔴 Budget superato – $categoryName'
        : '⚠️ Budget al $percentStr – $categoryName';
    final body = isOver
        ? 'Hai superato il budget per $categoryName ($percentStr). Prova a ridurre le spese.'
        : 'Stai per raggiungere il limite del budget $categoryName ($percentStr).';

    const androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Alert Budget',
      channelDescription: 'Notifiche quando un budget supera la soglia',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iOSDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    try {
      await _plugin.show(
        categoryName.hashCode, // id univoco per categoria
        title,
        body,
        details,
      );
    } catch (e) {
      debugPrint('[Notifications] Errore show: $e');
    }
  }
}

