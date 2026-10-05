import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/app_notification.dart';
import '../../services/notification_service.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final String? initialMessageId;
  const NotificationsScreen({super.key, this.initialMessageId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> get _notifications =>
      NotificationService.instance.notifications;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessageId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final n = _findById(widget.initialMessageId);
        if (n != null) _openDetail(n);
      });
    }
  }

  AppNotification? _findById(String? id) {
    if (id == null) return null;
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _openDetail(AppNotification n) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(notification: n),
      ),
    );
    setState(() {}); // refresh read state after returning
  }

  Future<void> _delete(String id) async {
    await NotificationService.instance.deleteNotification(id);
    setState(() {});
  }

  Future<void> _markAllRead() async {
    await NotificationService.instance.markAllAsRead();
    setState(() {});
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content:
            const Text('This will permanently delete all notification history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await NotificationService.instance.clearAll();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unread = NotificationService.instance.unreadCount;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Row(
          children: [
            const Text('Notifications'),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_notifications.isNotEmpty) ...[
            if (unread > 0)
              IconButton(
                icon: const Icon(Icons.done_all_rounded),
                color: AppColors.primaryGold,
                tooltip: 'Mark all as read',
                onPressed: _markAllRead,
              ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              color: colors.textSecondary,
              tooltip: 'Clear all',
              onPressed: _clearAll,
            ),
          ],
        ],
      ),
      body: SafeArea(
        top: false,
        child: _notifications.isEmpty
            ? _EmptyState()
            : ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final n = _notifications[i];
                  return _NotificationTile(
                    notification: n,
                    onTap: () => _openDetail(n),
                    onDelete: () => _delete(n.id),
                  );
                },
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification tile with swipe-to-delete
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final n = notification;

    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: n.isRead
                ? colors.card
                : AppColors.primaryGold.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: n.isRead
                  ? colors.cardBorder
                  : AppColors.primaryGold.withValues(alpha: 0.3),
              width: n.isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Unread dot / icon ────────────────────────────
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: n.isRead
                          ? AppColors.primaryGold.withValues(alpha: 0.08)
                          : AppColors.primaryGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      n.isRead
                          ? Icons.notifications_outlined
                          : Icons.notifications_active_rounded,
                      color: AppColors.primaryGold,
                      size: 20,
                    ),
                  ),
                  if (!n.isRead)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: colors.background, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // ── Content ──────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: n.isRead
                            ? FontWeight.w500
                            : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Time ─────────────────────────────────────────
              Text(
                _formatTime(n.timestamp),
                style:
                    TextStyle(color: colors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
String _formatTime(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined,
                color: AppColors.primaryGold, size: 32),
          ),
          const SizedBox(height: 16),
          Text('No Notifications',
              style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('You have no recent notifications.',
              style: TextStyle(color: colors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}
