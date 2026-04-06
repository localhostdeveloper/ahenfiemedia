// lib/screens/menu_screen/notifications_screen.dart

import 'package:flutter/material.dart';
// 🌟 NEW IMPORTS 🌟
import 'notification_detail_screen.dart'; // Target detail page
import '../../services/notification_service.dart';
import '../../models/app_notification.dart';

// --- Utility Function to format time ---
// (Move this outside the class, or use a separate utility file if desired)
String _formatTime(DateTime date) {
  if (date.difference(DateTime.now()).inHours.abs() < 24) {
    return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } else if (date.difference(DateTime.now()).inDays.abs() < 7) {
    // NOTE: You'll need to define 'weekdayName()' utility or replace with 'date.dayOfWeek' string
    // Using a simpler format for now:
    return '${date.month}/${date.day}';
  } else {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// Simple utility to find an item or return null
AppNotification? _findNotificationById(String? id) {
  if (id == null) return null;
  try {
    return NotificationService.instance.notifications.firstWhere(
      (n) => n.id == id,
    );
  } catch (e) {
    return null;
  }
}

class NotificationsScreen extends StatefulWidget {
  // 🌟 UPDATED: Accepts the ID of the notification that caused the tap 🌟
  final String? initialMessageId;
  const NotificationsScreen({super.key, this.initialMessageId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Use the list from the service instance
  List<AppNotification> get notifications =>
      NotificationService.instance.notifications;

  // Simple method to handle navigation to the detail screen
  void _openNotificationDetail(AppNotification notification) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            NotificationDetailScreen(notification: notification),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 🌟 LOGIC TO HANDLE DIRECT OPENING FROM NOTIFICATION TAP 🌟
    if (widget.initialMessageId != null) {
      final tappedNotification = _findNotificationById(widget.initialMessageId);

      if (tappedNotification != null) {
        // Use addPostFrameCallback to ensure the navigation happens after the UI is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _openNotificationDetail(tappedNotification);
        });
      }
    }
  }

  // --- No longer need _markAsRead or _dummyNotifications ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Clear all notifications action
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear All',
            onPressed: () {
              setState(() {
                // Clear the list in the service
                NotificationService.instance.notifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification history cleared')),
              );
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'You have no recent notifications.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return ListTile(
                  leading: const Icon(
                    Icons.notifications_active,
                    color: Colors.blueGrey,
                  ),

                  // Main Content
                  title: Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Timestamp
                  trailing: Text(
                    _formatTime(notification.timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  onTap: () {
                    // 🌟 NAVIGATE TO DETAIL PAGE WHEN TAPPED IN THE LIST 🌟
                    _openNotificationDetail(notification);
                  },
                );
              },
            ),
    );
  }
}
