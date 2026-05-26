import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/theme/app_colors.dart';

const _kKentePattern =
    'assets/images/b92f2e77-722f-4236-9b18-6d31266aa9dd 2.jpg';

class SocialPlatformScreen extends StatefulWidget {
  final String label;
  final FaIconData icon;
  final Color color;
  final String url;

  const SocialPlatformScreen({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.url,
  });

  @override
  State<SocialPlatformScreen> createState() => _SocialPlatformScreenState();
}

class _SocialPlatformScreenState extends State<SocialPlatformScreen> {
  late final WebViewController _controller;
  bool _loading = true;

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
          onPageFinished: (url) {
            setState(() => _loading = false);
            _controller.runJavaScript(
              'if(navigator.mediaDevices){'
              'navigator.mediaDevices.getUserMedia='
              '()=>Promise.reject(new DOMException("NotAllowedError"));'
              'navigator.mediaDevices.enumerateDevices'
              '=()=>Promise.resolve([]);'
              '}',
            );
          },
          onNavigationRequest: (_) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(widget.icon, size: 16, color: widget.color),
            const SizedBox(width: 8),
            Text(widget.label),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Kente background — intentional brand design, keep as-is
          ShaderMask(
            blendMode: BlendMode.multiply,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF5A3800), Color(0xFF2E1C00)],
            ).createShader(bounds),
            child: Image.asset(_kKentePattern, fit: BoxFit.cover),
          ),
          Container(color: const Color(0xBB000000)),
          WebViewWidget(controller: _controller),
          if (_loading)
            Stack(
              fit: StackFit.expand,
              children: [
                ShaderMask(
                  blendMode: BlendMode.multiply,
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF5A3800), Color(0xFF2E1C00)],
                  ).createShader(bounds),
                  child: Image.asset(_kKentePattern, fit: BoxFit.cover),
                ),
                Container(color: const Color(0xCC000000)),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(widget.icon, color: widget.color, size: 44),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(
                        color: AppColors.primaryGold,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading ${widget.label}...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
