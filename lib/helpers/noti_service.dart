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
          appUserModelId: '',
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
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'urlLauActionId',
          'Action 1',
          icon: DrawableResourceAndroidBitmap('food'),
          contextual: true,
        ),
        AndroidNotificationAction(
          'id_2',
          'Action 2',
          titleColor: Color.fromARGB(255, 255, 0, 0),
          icon: DrawableResourceAndroidBitmap('secondary_icon'),
        ),
        AndroidNotificationAction(
          'navigationActionId',
          'Action 3',
          icon: DrawableResourceAndroidBitmap('secondary_icon'),
          showsUserInterface: true,
          // By default, Android plugin will dismiss the notification when the
          // user tapped on a action (this mimics the behavior on iOS).
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'read',
          'Mark as read',
          semanticAction: SemanticAction.markAsRead,
          invisible: true,
        ),
      ],
    ),
    windows: WindowsNotificationDetails(),
  );

  Future<void> showNotification(String title, String body) async {
    int uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    print('Showing notification: $uniqueId');
    return notificationsPlugin.show(
      uniqueId,
      title,
      body,
      platformChannelSpecifics
    );
  }
}
