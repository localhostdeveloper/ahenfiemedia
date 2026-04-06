// lib/screens/about_screen.dart

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/app_constants.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Main Content (centered vertically)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.info, size: 80, color: accentColor),
                            const SizedBox(height: 20),
                            Text(
                              AppConstants.appTitle,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppConstants.aboutAppDescription,
                              style: const TextStyle(fontSize: 18, height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),

                      // Version & Developer Info
                      FutureBuilder<PackageInfo>(
                        future: _packageInfoFuture,
                        builder: (context, snapshot) {
                          String versionText = '';
                          String buildNumber = '';

                          if (snapshot.hasData) {
                            versionText = snapshot.data!.version;
                            buildNumber = snapshot.data!.buildNumber;
                          } else if (snapshot.hasError) {
                            versionText = 'Error loading version';
                          } else {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              Text(
                                'App Developer: ${AppConstants.appDeveloper}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.9) ??
                                      Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Version: $versionText ($buildNumber)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),

                      // Copyright
                      Text(
                        '© 2025 ${AppConstants.appTitle}. All rights reserved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
