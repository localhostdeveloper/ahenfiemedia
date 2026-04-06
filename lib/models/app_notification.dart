// lib/models/app_notification.dart

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic> data; // Custom data from FCM

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.data = const {},
  });
}
