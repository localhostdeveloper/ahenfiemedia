import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: colors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('1. Introduction'),
            _body(
              context,
              'Ahenfie Media ("we," "our," or "us") is committed to protecting the privacy of our users. '
              'This Privacy Policy describes how we collect, use, and disclose information when you use our mobile application ("App").',
            ),
            _body(
              context,
              'By using the App, you agree to the collection and use of information in accordance with this policy.',
            ),

            _section('2. Information We Collect'),
            _sub(context, '2.1 Non-Personal Data'),
            _body(
              context,
              'We collect information that your device sends whenever you use our App. This may include your device\'s IP address, '
              'device type, operating system version, time and date of use, and diagnostic data related to streaming quality.',
            ),
            _sub(context, '2.2 Personal Data (Optional)'),
            _body(
              context,
              'We do not require personal information to use our basic services (Radio, TV). If you choose to interact with notifications, '
              'we may collect identifiers necessary to provide those services.',
            ),

            _section('3. Use of Data'),
            _body(context, 'We use collected information to:'),
            _bullet(context, 'Provide and maintain the App service.'),
            _bullet(context, 'Notify you about changes to our service.'),
            _bullet(context, 'Analyse usage to improve performance and streaming quality.'),
            _bullet(context, 'Monitor the App and detect technical issues.'),

            _section('4. Disclosure of Data'),
            _body(
              context,
              'We may share non-personal information with third-party service providers (such as analytics partners like Google Analytics) '
              'to monitor and analyse the use of our App.',
            ),

            _section('5. Security of Data'),
            _body(
              context,
              'The security of your data is important to us. While we strive to use commercially acceptable means to protect your data, '
              'no method of transmission over the Internet is 100% secure.',
            ),

            _section('6. Changes to This Policy'),
            _body(
              context,
              'We may update our Privacy Policy from time to time. We will notify you of changes by posting the new Privacy Policy '
              'in the App. You are advised to review this page periodically.',
            ),

            _section('7. Contact Us'),
            _body(context, 'If you have any questions about this Privacy Policy, contact us:'),
            _bullet(context, 'Email: support@ahenfiemedia.com'),
            _bullet(context, 'Through the "About Us" section in the App.'),

            const SizedBox(height: 24),
            Text(
              'Effective Date: December 6, 2024',
              style: TextStyle(color: colors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryGold,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _sub(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _body(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: context.colors.textSecondary,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _bullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: AppColors.primaryGold, fontSize: 14),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
