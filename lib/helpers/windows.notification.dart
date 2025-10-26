import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import 'noti_service.dart'; // For JSON parsing if needed

void setupWindowsNotifications() {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:3000'),
  ); // Secure wss:// for production

  channel.stream.listen(
    (message) {
      // Parse the message (assuming JSON from backend)
      final data = jsonDecode(message as String);
      final title = data['title'] ?? 'New Update';
      final body = data['body'] ?? 'Details here';

      // Show local notification
      LocalNotificationService().showNotification(
        title ?? 'No Title',
        body ?? 'No Body',
      );
    },
    onError: (error) {
      // Handle errors, e.g., reconnect logic
      print('WebSocket error: $error');
    },
    onDone: () {
      // Reconnect if connection closes
      setupWindowsNotifications();
    },
  );

  // Optional: Send authentication on connect if using auth
  channel.sink.add(jsonEncode({'auth': 'your-token-or-user-id'}));
}
