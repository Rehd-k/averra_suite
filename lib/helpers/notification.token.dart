import 'dart:io';

import 'package:averra_suite/service/api.service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'noti_service.dart';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  ApiService apiService = ApiService();
  late String userId;

  Future<String?> getToken() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      NotificationSettings settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await FirebaseMessaging.instance.getToken();

        messaging.onTokenRefresh.listen((token) async {
          await registerToken(userId, token);
        });
        return token;
      }
      // Handle background/terminated (Android only, via service)
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } else {}
    return null;
  }

  Future<void> registerToken(String token, String userId) async {
    await apiService.patch('user/$userId', {'fcmToken': token});
  }

  // Handle incoming notifications
  void handleMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotificationService().showNotification(
        message.notification?.title ?? 'No Title',
        message.notification?.body ?? 'No Body',
      );
      // Show in-app alert here (e.g., using SnackBar)
    });
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
  }
}
