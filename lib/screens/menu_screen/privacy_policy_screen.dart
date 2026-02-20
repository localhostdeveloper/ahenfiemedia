// lib/screens/privacy_policy_screen.dart

import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        // Back button since this screen is accessed via the overflow menu
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Introduction ---
            _buildSectionTitle(context, '1. Introduction'),
            _buildPolicyText(
              'Ahenfie Media ("we," "our," or "us") is committed to protecting the privacy of our users. This Privacy Policy describes how we collect, use, and disclose information when you use our mobile application ("App").',
            ),
            const SizedBox(height: 10),
            _buildPolicyText(
              'By using the App, you agree to the collection and use of information in accordance with this policy.',
            ),

            // --- Information We Collect ---
            _buildDivider(),
            _buildSectionTitle(context, '2. Information We Collect'),

            _buildSubtitle('2.1 Non-Personal Data'),
            _buildPolicyText(
              'We collect information that your device sends whenever you use our App. This usage data may include information such as your device\'s IP address, device type, operating system version, the time and date of your use, and diagnostic data related to streaming quality and connection performance.',
            ),

            _buildSubtitle('2.2 Personal Data (Optional)'),
            _buildPolicyText(
              'We do not require personal information (like email, name, or phone number) to use our basic services (Radio, TV). If you choose to interact with features like notifications or comments, we may collect identifiers necessary to provide those services.',
            ),

            // --- How We Use Your Information ---
            _buildDivider(),
            _buildSectionTitle(context, '3. Use of Data'),
            _buildPolicyText(
              'We use the collected information for various purposes:',
            ),
            _buildBulletPoint('To provide and maintain the App service.'),
            _buildBulletPoint('To notify you about changes to our service.'),
            _buildBulletPoint(
              'To analyze usage so that we can improve the App\'s performance and streaming quality.',
            ),
            _buildBulletPoint(
              'To monitor the usage of the App and detect and address technical issues.',
            ),

            // --- Disclosure of Data ---
            _buildDivider(),
            _buildSectionTitle(context, '4. Disclosure of Data'),
            _buildPolicyText(
              'We may share your non-personal information with third-party service providers (such as analytics partners like Google Analytics or crash reporting tools) to monitor and analyze the use of our App.',
            ),

            // --- Security of Data ---
            _buildDivider(),
            _buildSectionTitle(context, '5. Security of Data'),
            _buildPolicyText(
              'The security of your data is important to us, but remember that no method of transmission over the Internet is 100% secure. While we strive to use commercially acceptable means to protect your data, we cannot guarantee its absolute security.',
            ),

            // --- Changes to this Policy ---
            _buildDivider(),
            _buildSectionTitle(context, '6. Changes to this Privacy Policy'),
            _buildPolicyText(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy in the App and updating the "effective date" at the bottom of this page. You are advised to review this Privacy Policy periodically for any changes.',
            ),

            // --- Contact Us ---
            _buildDivider(),
            _buildSectionTitle(context, '7. Contact Us'),
            _buildPolicyText(
              'If you have any questions about this Privacy Policy, please contact us:',
            ),
            _buildBulletPoint('By email: support@ahenfiemedia.com'),
            _buildBulletPoint('Through the "About Us" section in the App.'),

            const SizedBox(height: 20),
            Text(
              'Effective Date: December 6, 2024',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPolicyText(String text) {
    return Text(text, style: const TextStyle(fontSize: 15, height: 1.5));
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('• ', style: TextStyle(fontSize: 15, height: 1.5)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Divider(),
    );
  }
}
