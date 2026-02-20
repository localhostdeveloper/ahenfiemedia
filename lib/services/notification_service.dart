// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// APP SPECIFIC IMPORTS
import '../navigation_key.dart';
import '../screens/menu_screen/notifications_screen.dart';
import '../models/app_notification.dart';

// --- Global Background Handler ---
// IMPORTANT: This function must be a top-level function (outside the class).
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Note: To save data here, you must initialize Firebase within this function.
  // We are relying on the app's main process to handle data saving for simplicity.
  // You would typically call Firebase.initializeApp() here if you needed to use
  // Firestore or other services in the background.
}

class NotificationService {
  // Singleton instance
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // 🌟 Storage for the notification history 🌟
  final List<AppNotification> _notifications = [];

  // Public getter for the notifications list
  List<AppNotification> get notifications => _notifications;

  Future<void> initialize() async {
    // Set up the background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permissions (Crucial for iOS/macOS and Android 13+)
    await _requestPermissions();

    // Configure Local Notifications for foreground message display
    await _initLocalNotifications();

    // Set up listeners for messages in all states (Foreground, Background, Terminated)
    _setupMessageListeners();

    // Get and print the initial FCM token (for server side integration)
    await _getFCMToken();
  }

  // --- Utility Methods for Persistence ---

  // Saves notification data to the local list
  void _saveNotification(RemoteMessage message) {
    if (message.notification != null) {
      final newNotification = AppNotification(
        // Use messageId, fall back to timestamp if null
        id:
            message.messageId ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        title: message.notification!.title ?? 'No Title',
        body: message.notification!.body ?? 'No Body',
        timestamp: message.sentTime ?? DateTime.now(),
        data: message.data,
      );
      // Add to the start of the list to show the newest message first
      _notifications.insert(0, newNotification);
      print('Saved new notification: ${newNotification.title}');
      // NOTE: If using Riverpod/Provider, you would need to notify listeners here.
    }
  }

  // --- Core Handlers (Handling permissions and token) ---

  // Request permissions
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    } else {
      print('User declined or has not yet granted permissions');
    }
  }

  // Get FCM Token
  Future<String?> _getFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("FCM Registration Token: $token");
    // TODO: Send this token to your application server
    return token;
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Set up the function to run when the local notification is tapped
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // PASS THE PAYLOAD (messageId) TO THE TAP HANDLER
        _handleNotificationTap(response.payload);
      },
    );
  }

  // --- Message Listener Logic ---

  void _setupMessageListeners() {
    // 1. Handler for messages received while the app is in the FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground Message received: ${message.notification?.title}');
      _saveNotification(message); // SAVE REAL MESSAGE
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // 2. Handler for when the user taps a notification and the app is in the BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
        'Notification Tapped (Opened App from Background): ${message.notification?.title}',
      );
      _saveNotification(message); // SAVE REAL MESSAGE
      // Pass the messageId for navigation lookup
      _handleNotificationTap(message.messageId);
    });

    // 3. Handle initial message that opened the app from terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print(
          'App opened from terminated state by notification: ${message.notification?.title}',
        );
        _saveNotification(message); // SAVE REAL MESSAGE
        // Pass the messageId for navigation lookup
        _handleNotificationTap(message.messageId);
      }
    });

    // 4. CRITICAL FIX: AUTOMATIC TOKEN REFRESH LISTENER
    // This listener automatically captures a new token when the old one expires or is invalidated.
    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      print('FCM Token Refreshed automatically: $newToken');

      // CRITICAL: You must implement a function here to send the new token
      // back to your application server to replace the old token associated
      // with this device. (e.g., sendTokenToServer(newToken);)

      // If you are using FCM Topics, you may also need to resubscribe the device:
      // subscribeToTopic('ahenfie_updates');
    });
  }

  // --- Navigation & Display ---

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
      // Use a unique ID (not 0) if you want multiple notifications to stack.
      message.notification.hashCode,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
      // Use the unique messageId as the payload
      payload: message.messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
    );
  }

  // UPDATED: Accepts an optional messageId
  void _handleNotificationTap([String? messageId]) {
    // Navigate using the global key to the Notifications screen
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          // PASS THE TAPPED MESSAGE ID
          builder: (context) =>
              NotificationsScreen(initialMessageId: messageId),
        ),
      );
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Successfully subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Successfully unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }
}
