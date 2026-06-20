import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  // Inicializar después de Firebase.initializeApp()
  Future<void> init(BuildContext context) async {
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await ApiService().saveFcmToken(token);

      FirebaseMessaging.instance.onTokenRefresh.listen((t) => ApiService().saveFcmToken(t));

      FirebaseMessaging.onMessage.listen((msg) {
        final notif = msg.notification;
        if (notif == null || !context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (notif.body != null) Text(notif.body!, style: const TextStyle(fontSize: 12)),
              ],
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    } catch (e) {
      debugPrint('NotificationService: Firebase no inicializado — $e');
    }
  }
}
