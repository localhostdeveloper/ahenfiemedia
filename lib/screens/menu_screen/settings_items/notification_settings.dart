// lib/screens/menu_screen/settings_items/notification_settings.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ❌ REMOVED: import 'package:audioplayers/audioplayers.dart';
import '../../../constants/app_constants.dart';
import '../../../services/notification_service.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _receiveNotifications = true;
  bool _soundAlerts = false;
  late SharedPreferences _prefs;

  // ❌ REMOVED: Audio player instance
  // final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // ❌ REMOVED: dispose() method for the audio player
  @override
  void dispose() {
    // _audioPlayer.dispose(); // No longer needed
    super.dispose();
  }

  // --- Persistence and Loading ---

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _receiveNotifications =
          _prefs.getBool(AppConstants.keyReceiveNotifications) ?? true;
      _soundAlerts = _prefs.getBool(AppConstants.keySoundAlerts) ?? false;
    });
    _toggleNotificationSubscription(_receiveNotifications);
  }

  Future<void> _savePreference(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  void _toggleNotificationSubscription(bool enable) {
    if (enable) {
      // Subscribe to a general topic for all users
      NotificationService.instance.subscribeToTopic('general_updates');
    } else {
      // Unsubscribe when disabled
      NotificationService.instance.unsubscribeFromTopic('general_updates');
    }
  }

  // ❌ REMOVED: Method to play a local asset sound
  // void _playConfirmationSound() {
  //   _audioPlayer.play(AssetSource('sounds/chime.mp3'));
  // }

  // --- UI Build ---

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Notifications'),
        ListTile(
          title: const Text('Receive Notifications'),
          subtitle: const Text('Alerts for new content and broadcasts.'),
          trailing: Switch(
            value: _receiveNotifications,
            onChanged: (bool newValue) {
              setState(() {
                _receiveNotifications = newValue;
                _savePreference(AppConstants.keyReceiveNotifications, newValue);
                _toggleNotificationSubscription(newValue);
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Sound Alerts'),
          subtitle: const Text('Play a sound when a notification arrives.'),
          trailing: Switch(
            value: _soundAlerts,
            onChanged: (bool newValue) {
              setState(() {
                _soundAlerts = newValue;
                _savePreference(AppConstants.keySoundAlerts, newValue);

                // ❌ REMOVED: Sound confirmation logic
                // if (newValue) {
                //   _playConfirmationSound();
                // }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 8.0,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
