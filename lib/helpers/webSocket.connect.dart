// websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'noti_service.dart';

/// ---------------------------------------------------------------------------
/// 1. Public API – use these methods from anywhere in the app
/// ---------------------------------------------------------------------------
class WebSocketService {
  // ────── Singleton ──────
  WebSocketService._privateConstructor();
  static final WebSocketService _instance =
      WebSocketService._privateConstructor();
  factory WebSocketService() => _instance;

  // ────── Public fields ──────
  bool get isConnected => _socket?.connected ?? false;
  StreamController<Map<String, dynamic>> get privateMessageStream =>
      _privateMessageController;
  StreamController<Map<String, dynamic>> get notificationStream =>
      _notificationController;

  final localNotificationService = LocalNotificationService();

  // ────── Private state ──────
  IO.Socket? _socket;
  String? _userId;
  final _privateMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Re-connection logic
  Timer? _reconnectTimer;
  static const _reconnectDelay = Duration(seconds: 3);

  // ────── Init (call once after login) ──────
  void init(String userId) {
    if (_userId == userId && isConnected) return; // already good
    _userId = userId;
    _connect();
  }

  // ────── Core connection ──────
  void _connect() {
    // Clean any previous socket
    _socket?.dispose();
    _socket = null;

    _socket = IO.io(
      'http://192.168.1.180:3000', // <-- replace with prod URL
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': _userId!})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(1000)
          .build(),
    );

    // ────── Event listeners (once per connection) ──────
    _socket!
      ..onConnect((_) {
        print('WebSocket connected – user: $_userId');
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
      })
      ..onConnectError((err) => print('Connect error: $err'))
      ..onError((err) => print('Socket error: $err'))
      ..onDisconnect((_) {
        print('WebSocket disconnected');
        _scheduleReconnect();
      })
      ..onReconnect((attempt) => print('Reconnected (attempt $attempt)'))
      ..onReconnectError((err) => print('Reconnect error: $err'))
      ..onReconnectFailed((_) => print('Reconnect failed permanently'));

    // ────── Custom events ──────
    _socket!
      ..on('privateMessage', (data) {
        final map = _safeJson(data);
        _privateMessageController.add(map);
        print('Private msg from ${map['from']}: ${map['message']}');
      })
      ..on('notification', (data) {
        final map = _safeJson(data);
        _notificationController.add(map);
        localNotificationService.showNotification(
          map['title'],
          map['payload']['body'],
        );
        print('Notification: ${map['title'] ?? ''}');
      });
  }

  // ────── Reconnect helper ──────
  void _scheduleReconnect() {
    if (_reconnectTimer != null) return;
    _reconnectTimer = Timer(_reconnectDelay, () {
      print('Attempting reconnect...');
      _socket?.connect();
    });
  }

  // ────── Public send methods ──────
  /// Send a private chat message
  void sendPrivateMessage(String toUserId, String message) {
    if (!isConnected) {
      print('Socket not connected – message queued');
      // optional: queue in memory / local DB
      return;
    }
    _socket!.emit('privateMessage', {
      'from': _userId,
      'to': toUserId,
      'message': message,
    });
  }

  /// Send a generic notification (server must emit `notification` back to others)
  void sendNotification({
    required List<String> toUserIds,
    required String title,
    Map<String, dynamic> payload = const {},
  }) {
    if (!isConnected) return;
    _socket!.emit('notification', {
      'to': toUserIds,
      'title': title,
      'payload': payload,
    });
  }

  // ────── Lifecycle ──────
  void disconnect() {
    _reconnectTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    print('WebSocket service disposed');
  }

  // ────── Helper ──────
  Map<String, dynamic> _safeJson(dynamic data) {
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    return (data as Map).cast<String, dynamic>();
  }
}
