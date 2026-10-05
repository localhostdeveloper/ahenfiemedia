import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/app_notification.dart';
import '../../services/notification_service.dart';

class NotificationDetailScreen extends StatefulWidget {
  final AppNotification notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends State<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Mark as read as soon as the user opens it
    NotificationService.instance.markAsRead(widget.notification.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final n = widget.notification;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Message'),
        backgroundColor: colors.background,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: colors.textMuted),
            tooltip: 'Delete',
            onPressed: () async {
              await NotificationService.instance
                  .deleteNotification(n.id);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon + title ───────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active_rounded,
                        color: AppColors.primaryGold, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatFull(n.timestamp),
                          style: TextStyle(
                              color: colors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Divider(color: colors.divider),
              const SizedBox(height: 16),

              // ── Body ───────────────────────────────────────────
              Text(
                n.body,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 15,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatFull(DateTime d) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final h = d.hour > 12 ? d.hour - 12 : d.hour == 0 ? 12 : d.hour;
  final m = d.minute.toString().padLeft(2, '0');
  final ampm = d.hour >= 12 ? 'PM' : 'AM';
  return '${months[d.month - 1]} ${d.day}, ${d.year}  •  $h:$m $ampm';
}
