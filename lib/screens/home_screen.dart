import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../constants/env.dart';
import '../core/theme/app_colors.dart';
import '../providers/pip_provider.dart';
import '../providers/radio_player_provider.dart';
import '../providers/tv_player_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/exit_confirmation_sheet.dart';
import 'about_screen.dart';
import 'home_feed_screen.dart';
import 'profile_screen.dart';
import 'radio_screen.dart';
import 'tv_screen.dart';
import 'menu_screen/coming_soon_screen.dart';
import 'menu_screen/contact_screen.dart';
import 'menu_screen/notifications_screen.dart';
import 'menu_screen/podcast_screen.dart';
import 'menu_screen/presenters_screen.dart';
import 'menu_screen/privacy_policy_screen.dart';
import 'menu_screen/settings_screen.dart';
import 'menu_screen/events_screen.dart';
import 'menu_screen/gallery_screen.dart';
import 'menu_screen/news_screen.dart';
import 'menu_screen/shows_screen.dart';
import 'menu_screen/social_media_screen.dart';
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

  // Opens the platform's app if installed, otherwise the browser.
  Future<void> _openExternal(String label, String url) async {
    var opened = false;
    if (url.isNotEmpty) {
      try {
        opened = await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $label right now.')),
      );
    }
  }

  void _onPushSelected(String label) {
    // Social platforms open directly in external browser
    final socialUrls = <String, String>{
      AppConstants.youtubeLabel:   Env.youtubeUrl,
      AppConstants.facebookLabel:  Env.facebookUrl,
      AppConstants.tiktokLabel:    Env.tiktokUrl,
      AppConstants.instagramLabel: Env.instagramUrl,
    };
    if (socialUrls.containsKey(label)) {
      _openExternal(label, socialUrls[label]!);
      return;
    }

    final Widget screen;
    switch (label) {
      case AppConstants.socialMediaLabel:
        screen = const SocialMediaScreen();
      case 'Presenters':
        screen = const PresentersScreen();
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
        screen = const NewsScreen();
      case 'Shows':
        screen = const ShowsScreen();
      case 'Events':
        screen = const EventsScreen();
      case 'Gallery':
        screen = const GalleryScreen();
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
    // In the PiP window only the TV video should show, not the app chrome
    final inPip = ref.watch(pipProvider);
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
        appBar: inPip
            ? null
            : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded),
                color: colors.textMuted,
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: _currentIndex == 0
                  ? Row(
                      children: [
                        Text(
                          AppConstants.appNamePart1,
                          style: TextStyle(
                            color: context.colors.accentText,
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
        bottomNavigationBar: inPip
            ? null
            : NavigationBar(
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
