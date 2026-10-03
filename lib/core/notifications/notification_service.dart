import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'Notification permission: ${settings.authorizationStatus}',
    );

    final token = await _messaging.getToken();

    debugPrint('FCM token: $token');

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground notification title: '
          '${message.notification?.title}');
      debugPrint('Foreground notification body: '
          '${message.notification?.body}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Notification tapped: ${message.messageId}');
    });
  }
}