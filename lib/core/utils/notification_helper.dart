import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. KEMBALIKAN @mipmap/ AGAR ANDROID BISA MENEMUKAN LOGO APLIKASI
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(settings: initializationSettings);
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
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'aquasmart_channel_v2', // 2. KITA GANTI ID CHANNEL AGAR ANDROID ME-RESET PENGATURANNYA
      'AquaSmart Peringatan',
      channelDescription: 'Notifikasi peringatan kondisi akuarium',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      icon:
          '@mipmap/ic_launcher', // 3. PASTIKAN ICON DIPANGGIL SECARA EKSPLISIT DI SINI
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
