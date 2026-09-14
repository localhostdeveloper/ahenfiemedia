import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/env.dart';
import '../models/app_notification.dart';
import '../navigation_key.dart';
import '../screens/menu_screen/notifications_screen.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  static const _storageKey = 'ahenfie_notifications';
  static const _maxAgeDays = 7;

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    await _loadFromStorage();

    OneSignal.initialize(Env.oneSignalAppId);
    await OneSignal.Notifications.requestPermission(true);

    // Foreground: save + display
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      _save(event.notification);
      event.notification.display();
    });

    // Tap: save (may already exist) + navigate
    OneSignal.Notifications.addClickListener((event) {
      _save(event.notification);
      _navigateTo(event.notification.notificationId);
    });
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;

      final cutoff =
          DateTime.now().subtract(const Duration(days: _maxAgeDays));
      final list = (jsonDecode(raw) as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .where((n) => n.timestamp.isAfter(cutoff))
          .toList();

      _notifications
        ..clear()
        ..addAll(list);
    } catch (e) {
      debugPrint('NotificationService load error: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode(_notifications.map((n) => n.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('NotificationService persist error: $e');
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  void _save(OSNotification notification) {
    // Avoid duplicates
    if (_notifications.any((n) => n.id == notification.notificationId)) return;

    _notifications.insert(
      0,
      AppNotification(
        id: notification.notificationId,
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        timestamp: DateTime.now(),
        data: notification.additionalData?.cast<String, dynamic>() ?? {},
      ),
    );
    _persist();
  }

  Future<void> markAsRead(String id) async {
    final i = _notifications.indexWhere((n) => n.id == id);
    if (i < 0) return;
    _notifications[i] = _notifications[i].copyWith(isRead: true);
    await _persist();
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _persist();
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await _persist();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _persist();
  }

  // ── Topics (OneSignal tags) ────────────────────────────────────────────────

  Future<void> subscribeToTopic(String topic) async {
    await OneSignal.User.addTagWithKey(topic, 'true');
    OneSignal.User.pushSubscription.optIn();
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await OneSignal.User.removeTag(topic);
    OneSignal.User.pushSubscription.optOut();
  }

  Future<void> setUserTag(String key, String value) async {
    await OneSignal.User.addTagWithKey(key, value);
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _navigateTo([String? id]) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(initialMessageId: id),
      ),
    );
  }
}
