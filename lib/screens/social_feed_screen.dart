import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/theme/app_colors.dart';

const _kKentePattern =
    'assets/images/b92f2e77-722f-4236-9b18-6d31266aa9dd 2.jpg';

// ─── Platform definitions ─────────────────────────────────────
class _Platform {
  final String label;
  final FaIconData icon;
  final Color color;
  final String url;

  const _Platform({
    required this.label,
    required this.icon,
    required this.color,
    required this.url,
  });
}

const _platforms = [
  _Platform(
    label: 'YouTube',
    icon: FontAwesomeIcons.youtube,
    color: Color(0xFFFF0000),
    url: 'https://m.youtube.com/@AhenfieMediagh/videos',
  ),
  _Platform(
    label: 'Facebook',
    icon: FontAwesomeIcons.facebook,
    color: Color(0xFF1877F2),
    url: 'https://m.facebook.com/people/Ahenfie-1061-FM/61585644356322/',
  ),
  _Platform(
    label: 'TikTok',
    icon: FontAwesomeIcons.tiktok,
    color: Color(0xFFEE1D52),
    url: 'https://www.tiktok.com/@ahenfie1061fm',
  ),
  _Platform(
    label: 'Instagram',
    icon: FontAwesomeIcons.instagram,
    color: Color(0xFFE4405F),
    url: 'https://www.instagram.com/ahenfie106.1fm',
  ),
];

// ─── Screen ───────────────────────────────────────────────────
class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _platforms.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 44,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Kente pattern header — intentional brand design
                  ShaderMask(
                    blendMode: BlendMode.multiply,
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF5A3800), Color(0xFF2E1C00)],
                    ).createShader(bounds),
                    child: Image.asset(_kKentePattern, fit: BoxFit.cover),
                  ),
                  Container(color: const Color(0x99000000)),
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'nokor3 y3 baako p3',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: '  ·  Akan',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: colors.surface,
              child: TabBar(
                controller: _tab,
                isScrollable: false,
                indicatorColor: AppColors.primaryGold,
                indicatorWeight: 3,
                labelColor: AppColors.primaryGold,
                unselectedLabelColor: colors.textMuted,
                dividerColor: Colors.transparent,
                tabs: _platforms
                    .map(
                      (p) => Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(p.icon, size: 15),
                            const SizedBox(width: 6),
                            Text(
                              p.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: _platforms
            .map((p) => _PlatformWebView(platform: p))
            .toList(),
      ),
    );
  }
}

// ─── Per-platform WebView ──────────────────────────────────────
class _PlatformWebView extends StatefulWidget {
  final _Platform platform;

  const _PlatformWebView({required this.platform});

  @override
  State<_PlatformWebView> createState() => _PlatformWebViewState();
}

class _PlatformWebViewState extends State<_PlatformWebView>
    with AutomaticKeepAliveClientMixin {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController(
      onPermissionRequest: (request) => request.deny(),
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (_) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(widget.platform.url));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          Container(
            color: colors.background,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    widget.platform.icon,
                    color: widget.platform.color,
                    size: 40,
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: AppColors.primaryGold),
                  const SizedBox(height: 14),
                  Text(
                    'Loading ${widget.platform.label}...',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
