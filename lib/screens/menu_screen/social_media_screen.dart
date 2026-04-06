// lib/screens/menu_screen/social_media_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Define the social media links structure
class SocialMediaLink {
  final String title;
  final IconData icon;
  final String url;
  final Color color;

  const SocialMediaLink({
    required this.title,
    required this.icon,
    required this.url,
    required this.color,
  });
}

// 🌟 NOTE: Replace these placeholder URLs with your actual Ahenfie Media links! 🌟
const List<SocialMediaLink> _socialLinks = [
  SocialMediaLink(
    title: 'Facebook',
    icon: FontAwesomeIcons.facebook,
    url: 'https://facebook.com/AhenfieMedia',
    color: Color(0xFF1877F2), // Facebook Blue
  ),
  SocialMediaLink(
    title: 'Instagram',
    icon: FontAwesomeIcons.instagram,
    url: 'https://instagram.com/ahenfiemedia',
    color: Color(0xFFE4405F), // Instagram Pink/Red
  ),
  SocialMediaLink(
    title: 'TikTok',
    icon: FontAwesomeIcons.tiktok, // Added TikTok icon
    url: 'https://tiktok.com/@ahenfiemedia',
    color: Color(0xFF000000), // Black
  ),
  SocialMediaLink(
    title: 'YouTube',
    icon: FontAwesomeIcons.youtube,
    url: 'https://youtube.com/@ahenfiemedia',
    color: Color(0xFFFF0000), // YouTube Red
  ),
];

class SocialMediaScreen extends StatelessWidget {
  const SocialMediaScreen({super.key});

  // --- External Link Launcher ---
  void _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect with Us'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // 🌟 FIX: Ensuring safe area and scrollability 🌟
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: Text(
                  "Follow us on social media for live updates, behind-the-scenes content, and community interaction.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

              // 🌟 REPLACED GRID WITH VERTICAL LIST (ListView.builder) 🌟
              ..._socialLinks
                  .map(
                    (link) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildSocialListTile(context, link),
                    ),
                  )
                  ,
            ],
          ),
        ),
      ),
    );
  }

  // --- New Widget for a single social media LIST TILE ---
  Widget _buildSocialListTile(BuildContext context, SocialMediaLink link) {
    // Determine appropriate text color for the background
    final textColor = (link.color.computeLuminance() > 0.5)
        ? Colors.black
        : Colors.white;

    return Card(
      color: link.color,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _launchURL(context, link.url),
        borderRadius: BorderRadius.circular(12.0),
        child: ListTile(
          // Leading icon
          leading: FaIcon(link.icon, size: 30, color: textColor),
          // Title
          title: Text(
            link.title,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Subtitle
          subtitle: Text(
            link.url
                .replaceAll('https://', '')
                .split('/')
                .first, // Show the base domain
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
          ),
          // Trailing arrow
          trailing: Icon(Icons.chevron_right, color: textColor),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
        ),
      ),
    );
  }
}
