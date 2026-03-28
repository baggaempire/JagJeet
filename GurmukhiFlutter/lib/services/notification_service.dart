import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> scheduleDailySkeleton({
    required String title,
    required String body,
  }) async {
    // Placeholder for exact parity scheduling from iOS.
    // Wire timezone-based multi-slot notifications here.
    final details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_sikh_wisdom',
        'Daily Sikh Wisdom',
        channelDescription: 'Daily reminders with reflection cards',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.show(1, title, body, details);
  }
}
