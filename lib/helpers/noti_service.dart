import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const WindowsInitializationSettings initializationSettingsWindow =
        WindowsInitializationSettings(
          appName: 'Averra Suite',
          appUserModelId: 'com.vessel.avs',
          guid: 'c299e27a-6b7e-4374-b38a-b67fa5f232d4',
          iconPath: 'assets/icon.ico',
        );

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      windows: initializationSettingsWindow,
    );

    await notificationsPlugin.initialize(initializationSettings);
  }

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      'simple_channel_id', // any unique string
      'Averra Suite', // name shown in settings
      channelDescription: 'A plain notification channel',
      importance: Importance.max,
      priority: Priority.high,
    ),
    windows: WindowsNotificationDetails(),
  );

  Future<void> showNotification(String title, String body) async {
    int uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    return notificationsPlugin.show(
      uniqueId,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
