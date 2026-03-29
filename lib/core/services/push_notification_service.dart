import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level background message handler for Firebase Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifs = FlutterLocalNotificationsPlugin();

  void Function(String route)? onNotificationNavigated;

  Future<void> init() async {
    // 1. Request permissions (Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // 2. Setup Local Notifications for Foreground
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    await _localNotifs.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onTapLocalNotification,
    );

    // Creates an Android Notification Channel for Heads-up notifications
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'presentra_high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifs
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. Register Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        _showLocalNotification(message, channel);
      }
    });

    // 5. Handle clicks on push notifications when app is in background but not killed
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationRoute(message.data);
    });

    // 6. Handle clicks if the app was completely killed and launched by clicking the push notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Delay to let UI build first
      Future.delayed(const Duration(seconds: 2), () {
        _handleNotificationRoute(initialMessage.data);
      });
    }
  }

  void _showLocalNotification(RemoteMessage message, AndroidNotificationChannel channel) {
    _localNotifs.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onTapLocalNotification(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationRoute(data);
      } catch (e) {
        if (kDebugMode) print("Error parsing notification payload: $e");
      }
    }
  }

  void _handleNotificationRoute(Map<String, dynamic> data) {
    if (kDebugMode) print("Notification clicked with data: $data");
    // You can inject routing logic here
    if (data.containsKey('route') && onNotificationNavigated != null) {
      onNotificationNavigated!(data['route']);
    }
  }
}
