import 'package:web_socket_channel/web_socket_channel.dart';

import 'noti_service.dart';

void setupWindowsNotifications() {
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://your-nestjs-backend/ws-notifications'),
  );
  channel.stream.listen((message) {
    // Parse message and show local notification
    LocalNotificationService().showNotification(
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
    );
  });
}
