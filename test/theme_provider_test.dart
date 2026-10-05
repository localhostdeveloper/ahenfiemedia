import 'package:ahenfie_media/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeKey = 'userThemeMode';

// Reads the provider, then lets the async SharedPreferences load complete.
Future<ProviderContainer> _loadedContainer() async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(themeProvider);
  await Future<void>.delayed(Duration.zero);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to system theme when nothing is saved', () async {
    SharedPreferences.setMockInitialValues({});
    final container = await _loadedContainer();

    expect(container.read(themeProvider), ThemeMode.system);
  });

  test('restores a saved theme', () async {
    SharedPreferences.setMockInitialValues({_themeKey: ThemeMode.light.index});
    final container = await _loadedContainer();

    expect(container.read(themeProvider), ThemeMode.light);
  });

  test('ignores an out-of-range saved index', () async {
    SharedPreferences.setMockInitialValues({_themeKey: 99});
    final container = await _loadedContainer();

    expect(container.read(themeProvider), ThemeMode.system);
  });

  test('setTheme updates state and persists the choice', () async {
    SharedPreferences.setMockInitialValues({});
    final container = await _loadedContainer();

    await container.read(themeProvider.notifier).setTheme(ThemeMode.dark);

    expect(container.read(themeProvider), ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(_themeKey), ThemeMode.dark.index);
  });

  test('can switch back to following the system theme', () async {
    SharedPreferences.setMockInitialValues({_themeKey: ThemeMode.dark.index});
    final container = await _loadedContainer();

    await container.read(themeProvider.notifier).setTheme(ThemeMode.system);

    expect(container.read(themeProvider), ThemeMode.system);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(_themeKey), ThemeMode.system.index);
  });
}
