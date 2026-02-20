// lib/screens/menu_screen/notification_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/app_notification.dart';

// 🌟 Target page that opens when a notification is tapped 🌟
class NotificationDetailScreen extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              notification.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Received: ${notification.timestamp.toString().substring(0, 19)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const Divider(height: 30),
            Text(
              notification.body,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            // Display custom data (if any)
            if (notification.data.isNotEmpty) ...[
              const Divider(height: 30),
              Text(
                'Custom Data Payload:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                notification.data.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
