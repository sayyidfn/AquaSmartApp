import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: initSettingsAndroid);

    await _notificationsPlugin.initialize(settings: initSettings);
  }

  static Future<void> requestPermission() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'aquasmart_channel_v2',
      'AquaSmart Peringatan',
      channelDescription: 'Notifikasi peringatan kondisi akuarium',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }
}
