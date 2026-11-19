import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are handled by the system tray when notification payload is present.
  debugPrint('FCM background message: ${message.messageId}');
}

class FcmNotificationService {
  FcmNotificationService(this._apiClient);

  final ApiClient _apiClient;
  bool _initialized = false;

  Future<void> initialize({
    void Function(String title, String body)? onForegroundMessage,
    void Function(String? eventId)? onNotificationTap,
  }) async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _registerTokenWithBackend(token);
      }

      messaging.onTokenRefresh.listen(_registerTokenWithBackend);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? 'Campus Event Update';
        final body = message.notification?.body ?? '';
        onForegroundMessage?.call(title, body);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        onNotificationTap?.call(message.data['event_id']?.toString());
      });

      _initialized = true;
    } catch (e) {
      // Gracefully skip if google-services.json is not yet configured in workshop setup
      debugPrint('FCM initialization skipped (not configured): $e');
    }
  }

  Future<void> _registerTokenWithBackend(String fcmToken) async {
    try {
      await _apiClient.post(
        ApiConstants.deviceToken,
        body: {'fcm_token': fcmToken, 'platform': 'android'},
      );
    } catch (e) {
      debugPrint('Failed to sync FCM token: $e');
    }
  }
}
