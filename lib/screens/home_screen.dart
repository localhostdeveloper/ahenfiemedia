import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/radio_player_provider.dart';
import 'about_screen.dart';
import 'radio_screen.dart';
import 'tv_screen.dart';
import 'website_screen.dart';
import 'main_menu_screen.dart';

import 'menu_screen/podcast_screen.dart';
import 'menu_screen/social_media_screen.dart';
import 'menu_screen/notifications_screen.dart';
import 'menu_screen/settings_screen.dart';
import 'menu_screen/privacy_policy_screen.dart';
import '../widgets/exit_confirmation_sheet.dart';

enum MenuAction { podcast, social, notifications, settings, privacy }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;

  final List<String> _titles = const [
    'Ahenfie Media',
    'Live Radio',
    'Live TV',
    'Website',
    'About Us',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = [
      MainMenuScreen(onItemSelected: _onItemTapped),
      const RadioScreen(),
      TVScreen(onEnter: () => ref.read(radioPlayerProvider.notifier).stop()),
      const WebsiteScreen(),
      const AboutScreen(),
    ];
  }

  void _onItemTapped(int index) {
    final radio = ref.read(radioPlayerProvider.notifier);

    if (index == 2) radio.stop();
    if (_currentIndex == 1 && index != 1) radio.pause();

    setState(() => _currentIndex = index);
  }

  void _onMenuSelection(MenuAction action) {
    Widget screen;
    switch (action) {
      case MenuAction.podcast:
        screen = const PodcastScreen();
        break;
      case MenuAction.social:
        screen = const SocialMediaScreen();
        break;
      case MenuAction.notifications:
        screen = const NotificationsScreen();
        break;
      case MenuAction.settings:
        screen = const SettingsScreen();
        break;
      case MenuAction.privacy:
        screen = const PrivacyPolicyScreen();
        break;
    }

    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      if (_currentIndex == 1) {
        ref.read(radioPlayerProvider.notifier).pause();
      }
      setState(() => _currentIndex = 0);
      return false;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) => const ExitConfirmationSheet(),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final showNav = _currentIndex != 0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_currentIndex]),
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: _onMenuSelection,
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: MenuAction.podcast,
                  child: Text('Podcasts'),
                ),
                PopupMenuItem(
                  value: MenuAction.social,
                  child: Text('Social Media'),
                ),
                PopupMenuItem(
                  value: MenuAction.notifications,
                  child: Text('Notifications'),
                ),
                PopupMenuItem(
                  value: MenuAction.settings,
                  child: Text('Settings'),
                ),
                PopupMenuItem(
                  value: MenuAction.privacy,
                  child: Text('Privacy Policy'),
                ),
              ],
            ),
          ],
        ),
        body: _tabs[_currentIndex],
        bottomNavigationBar: showNav
            ? BottomNavigationBar(
                currentIndex: _currentIndex - 1,
                onTap: (i) => _onItemTapped(i + 1),
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.radio),
                    label: 'Radio',
                  ),
                  BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'TV'),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.web),
                    label: 'Website',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.info),
                    label: 'About',
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
