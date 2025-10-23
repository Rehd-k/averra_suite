import 'dart:io';

import 'package:averra_suite/service/api.service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'noti_service.dart';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  ApiService apiService = ApiService();

  Future<String?> getToken() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await FirebaseMessaging.instance.getToken();
        return token;
      }
    } else {
      print("FCM not supported on this platform");
    }
    return null;
  }

  Future<void> registerToken(String token, String userId) async {
    // Call this on login
    try {
      await apiService.patch('user/$userId', {'fcmToken': token});
    } catch (e) {
      print('Error sending token: $e');
    }
  }

  // Handle incoming notifications
  void handleMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotificationService().showNotification(
        message.notification?.title ?? 'No Title',
        message.notification?.body ?? 'No Body',
      );
      print('Got a message: ${message.notification?.title}');
      // Show in-app alert here (e.g., using SnackBar)
    });
  }
}
