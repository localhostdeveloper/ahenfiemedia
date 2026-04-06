// lib/screens/website_screen.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lottie/lottie.dart'; // 🌟 NEW: Import the Lottie package 🌟
import '../constants/app_constants.dart';

class WebsiteScreen extends StatefulWidget {
  const WebsiteScreen({super.key});

  @override
  State<WebsiteScreen> createState() => _WebsiteScreenState();
}

class _WebsiteScreenState extends State<WebsiteScreen> {
  // Check if the URL is the placeholder we defined in AppConstants
  final bool _isPlaceholder =
      AppConstants.websiteUrl == "https://placeholder.com";

  late final WebViewController _controller;
  double _loadingProgress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Only initialize the WebView if we have a real URL
    if (!_isPlaceholder) {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _errorMessage = null; // Clear previous errors
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _loadingProgress = 1.0; // Mark as complete
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _errorMessage =
                    'Could not load the website: ${error.description}';
                _loadingProgress = 1.0; // Stop loading indicator
              });
              debugPrint('Web resource error: ${error.description}');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // For now, allow all navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConstants.websiteUrl));
  }

  // 🌟 NEW: Widget for the placeholder screen 🌟
  Widget _buildPlaceholderScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🌟 Use the Lottie animation path provided by the user 🌟
            Lottie.asset(
              'assets/animations/nodata.json',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              'Website Coming Soon!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The official Ahenfie Media website is currently under development. Please check back later!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isPlaceholder
            ? _buildPlaceholderScreen(
                context,
              ) // 🌟 Show placeholder if URL is dummy 🌟
            : Stack(
                children: [
                  // 1. WebView Widget
                  if (_errorMessage == null)
                    WebViewWidget(controller: _controller),

                  // 2. Loading Indicator
                  if (_loadingProgress < 1.0)
                    LinearProgressIndicator(
                      value: _loadingProgress,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ),

                  // 3. Error Overlay (Web View failed)
                  if (_errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.web_asset_off,
                              size: 60,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('RETRY'),
                              onPressed: () {
                                setState(() {
                                  _errorMessage = null;
                                  _loadingProgress = 0.0;
                                  _controller.reload();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
