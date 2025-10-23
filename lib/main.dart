import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import 'helpers/noti_service.dart';
import 'helpers/theme.dart';
import 'helpers/theme_provider.dart';
import 'service/navigation.service.dart';

// Add this to your main.dart or a separate file
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await LocalNotificationService().initNotification();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: ToastificationWrapper(child: const MyApp()),
    ),
  );
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      final win = appWindow;
      win.maximize();
      win.title = "Averra Suite";
      win.show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
      routerConfig: NavigationService.router.config(),
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
