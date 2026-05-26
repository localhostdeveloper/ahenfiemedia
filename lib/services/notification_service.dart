// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// APP SPECIFIC IMPORTS
import '../navigation_key.dart';
import '../screens/menu_screen/notifications_screen.dart';
import '../models/app_notification.dart';

// --- Global Background Handler ---
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  // Singleton instance
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Storage for the notification history
  final List<AppNotification> _notifications = [];

  // Public getter for the notifications list
  List<AppNotification> get notifications => _notifications;

  Future<void> initialize() async {
    // Set up the background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permissions
    await _requestPermissions();

    // Configure Local Notifications
    await _initLocalNotifications();

    // Set up listeners
    _setupMessageListeners();

    // Get initial token
    await _getFCMToken();
  }

  void _saveNotification(RemoteMessage message) {
    if (message.notification != null) {
      final newNotification = AppNotification(
        id: message.messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: message.notification!.title ?? 'No Title',
        body: message.notification!.body ?? 'No Body',
        timestamp: message.sentTime ?? DateTime.now(),
        data: message.data,
      );
      _notifications.insert(0, newNotification);
    }
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions');
    }
  }

  Future<String?> _getFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    debugPrint("FCM Registration Token: $token");
    return token;
  }

  // --- FIXED: Initialization with correct parameter handling ---
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  void _setupMessageListeners() {
    // 1. Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _saveNotification(message);
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // 2. Background Tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _saveNotification(message);
      _handleNotificationTap(message.messageId);
    });

    // 3. Terminated Tap
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _saveNotification(message);
        _handleNotificationTap(message.messageId);
      }
    });

    // 4. Token Refresh
    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      debugPrint('FCM Token Refreshed: $newToken');
    });
  }

  // --- FIXED: Named arguments for .show() method ---
  void _showLocalNotification(RemoteMessage message) {
    const androidDetails = AndroidNotificationDetails(
      'radio_channel',
      'Radio Broadcasts',
      channelDescription: 'Notifications for live broadcasts and updates.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    _localNotifications.show(
      id: message.notification.hashCode,
      title: message.notification!.title,
      body: message.notification!.body,
      notificationDetails: notificationDetails,
      payload: message.messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
    );
  }

  void _handleNotificationTap([String? messageId]) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => NotificationsScreen(initialMessageId: messageId),
        ),
      );
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('Error subscribing: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('Error unsubscribing: $e');
    }
  }
}