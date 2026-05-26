import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../providers/radio_player_provider.dart';
import '../providers/tv_player_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/exit_confirmation_sheet.dart';
import 'about_screen.dart';
import 'home_feed_screen.dart';
import 'profile_screen.dart';
import 'radio_screen.dart';
import 'social_platform_screen.dart';
import 'tv_screen.dart';
import 'menu_screen/coming_soon_screen.dart';
import 'menu_screen/contact_screen.dart';
import 'menu_screen/notifications_screen.dart';
import 'menu_screen/podcast_screen.dart';
import 'menu_screen/privacy_policy_screen.dart';
import 'menu_screen/settings_screen.dart';
import 'menu_screen/videos_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<Widget> _tabs;

  static const _titles = [
    AppConstants.appTitle,
    AppConstants.liveRadioTab,
    AppConstants.liveTVTab,
    AppConstants.profileLabel,
  ];

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeFeedScreen(onNavigate: _onTabSelected, onPushSelect: _onPushSelected),
      const RadioScreen(),
      TVScreen(onEnter: () => ref.read(radioPlayerProvider.notifier).stop()),
      const ProfileScreen(),
    ];
  }

  void _onTabSelected(int index) {
    final radio = ref.read(radioPlayerProvider.notifier);
    if (_currentIndex == 2 && index != 2) {
      ref.read(tvPlayerProvider.notifier).pause();
    }
    if (index == 2) {
      radio.stop();
      ref.read(tvPlayerProvider.notifier).resume();
    }
    if (_currentIndex == 1 && index != 1) radio.pause();
    setState(() => _currentIndex = index);
  }

  void _onPushSelected(String label) {
    final Widget screen;
    switch (label) {
      case 'YouTube':
        screen = const SocialPlatformScreen(
          label: 'YouTube',
          icon: FontAwesomeIcons.youtube,
          color: Color(0xFFFF0000),
          url: AppConstants.youtubeUrl,
        );
      case 'Facebook':
        screen = const SocialPlatformScreen(
          label: 'Facebook',
          icon: FontAwesomeIcons.facebook,
          color: Color(0xFF1877F2),
          url: AppConstants.facebookUrl,
        );
      case 'TikTok':
        screen = const SocialPlatformScreen(
          label: 'TikTok',
          icon: FontAwesomeIcons.tiktok,
          color: Color(0xFFEE1D52),
          url: AppConstants.tiktokUrl,
        );
      case 'Instagram':
        screen = const SocialPlatformScreen(
          label: 'Instagram',
          icon: FontAwesomeIcons.instagram,
          color: Color(0xFFE4405F),
          url: AppConstants.instagramUrl,
        );
      case 'Podcasts':
        screen = const PodcastScreen();
      case 'Videos':
        screen = const VideosScreen();
      case 'About Us':
        screen = const AboutScreen();
      case 'Settings':
        screen = const SettingsScreen();
      case 'Privacy Policy':
        screen = const PrivacyPolicyScreen();
      case 'Contact':
        screen = const ContactScreen();
      case 'News':
        screen = const ComingSoonScreen(
          title: 'News',
          icon: Icons.article_rounded,
        );
      case 'Shows':
        screen = const ComingSoonScreen(
          title: 'Shows',
          icon: Icons.live_tv_rounded,
        );
      case 'Events':
        screen = const ComingSoonScreen(
          title: 'Events',
          icon: Icons.event_rounded,
        );
      case 'Gallery':
        screen = const ComingSoonScreen(
          title: 'Gallery',
          icon: Icons.photo_library_rounded,
        );
      default:
        screen = ComingSoonScreen(
          title: label,
          icon: Icons.star_rounded,
        );
    }

    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_currentIndex != 0) {
          if (_currentIndex == 1) {
            ref.read(radioPlayerProvider.notifier).pause();
          }
          setState(() => _currentIndex = 0);
          return;
        }

        final shouldExit = await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          useRootNavigator: true,
          builder: (_) => const ExitConfirmationSheet(),
        );

        if (shouldExit == true) {
          ref.read(radioPlayerProvider.notifier).stop();
          await Future.delayed(const Duration(milliseconds: 150));
          exit(0);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(
          currentIndex: _currentIndex,
          onTabSelect: _onTabSelected,
          onPushSelect: _onPushSelected,
        ),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded),
            color: colors.textMuted,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: _currentIndex == 0
              ? Row(
                  children: [
                    const Text(
                      AppConstants.appNamePart1,
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppConstants.appNamePart2,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                        fontSize: 18,
                      ),
                    ),
                  ],
                )
              : Text(
                  _titles[_currentIndex],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: colors.textMuted,
              onPressed: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              ),
            ),
          ],
        ),
        body: _tabs[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.radio_outlined),
              selectedIcon: Icon(Icons.radio),
              label: 'Radio',
            ),
            NavigationDestination(
              icon: Icon(Icons.tv_outlined),
              selectedIcon: Icon(Icons.tv),
              label: 'TV',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
