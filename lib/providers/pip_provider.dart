// lib/providers/pip_provider.dart
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Picture-in-picture for Live TV (Android only; see MainActivity.kt).
/// State is true while the app is shrunk into the PiP window.
class PipNotifier extends Notifier<bool> {
  static const _channel = MethodChannel('com.localcode.ahenfiemedia/pip');

  bool _autoEnter = false;

  @override
  bool build() {
    if (Platform.isAndroid) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'pipChanged') state = call.arguments as bool;
      });
    }
    return false;
  }

  /// Arms PiP so leaving the app (home gesture) shrinks TV into a window.
  Future<void> setAutoEnter(bool enabled) async {
    if (!Platform.isAndroid || enabled == _autoEnter) return;
    _autoEnter = enabled;
    try {
      await _channel.invokeMethod('setAutoEnter', enabled);
    } on PlatformException catch (_) {}
  }

  Future<bool> enter() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('enter') ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }
}

final pipProvider = NotifierProvider<PipNotifier, bool>(PipNotifier.new);

/// Whether this device can do PiP (Android 8+ with the system feature).
final pipSupportedProvider = FutureProvider<bool>((ref) async {
  if (!Platform.isAndroid) return false;
  try {
    return await const MethodChannel('com.localcode.ahenfiemedia/pip')
            .invokeMethod<bool>('isSupported') ??
        false;
  } on PlatformException catch (_) {
    return false;
  }
});
