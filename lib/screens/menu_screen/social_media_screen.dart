// lib/screens/menu_screen/social_media_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialMediaLink {
  final String title;
  final FaIconData icon;
  final String url;
  final Color color;

  const SocialMediaLink({
    required this.title,
    required this.icon,
    required this.url,
    required this.color,
  });
}

// Fixed Icon names for newer font_awesome_flutter versions
const List<SocialMediaLink> _socialLinks = [
  SocialMediaLink(
    title: 'Facebook',
    icon: FontAwesomeIcons.facebook, 
    url: 'https://facebook.com/AhenfieMedia',
    color: Color(0xFF1877F2),
  ),
  SocialMediaLink(
    title: 'Instagram',
    icon: FontAwesomeIcons.instagram,
    url: 'https://instagram.com/ahenfiemedia',
    color: Color(0xFFE4405F),
  ),
  SocialMediaLink(
    title: 'TikTok',
    icon: FontAwesomeIcons.tiktok,
    url: 'https://tiktok.com/@ahenfiemedia',
    color: Color(0xFF000000),
  ),
  SocialMediaLink(
    title: 'YouTube',
    icon: FontAwesomeIcons.youtube,
    url: 'https://youtube.com/@ahenfiemedia',
    color: Color(0xFFFF0000),
  ),
];

class SocialMediaScreen extends StatelessWidget {
  const SocialMediaScreen({super.key});

  // --- External Link Launcher ---
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    
    try {
      // It is better to use launchUrl directly; canLaunchUrl can be flaky on newer Android/iOS
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      
      if (!launched && context.mounted) {
        _showErrorSnackBar(context, urlString);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, urlString);
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open link: $url')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect with Us'),
        // No need to manually define leading back button if it's a standard push route,
        // but keeping it as per your design.
      ),
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
              // Spread operator with map
              ..._socialLinks.map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildSocialListTile(context, link),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialListTile(BuildContext context, SocialMediaLink link) {
    // Determine appropriate text color based on background luminance
    final textColor = (link.color.computeLuminance() > 0.5)
        ? Colors.black
        : Colors.white;

    return Card(
      color: link.color,
      elevation: 4,
      margin: EdgeInsets.zero, // Card default margins can sometimes mess with Padding
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _launchURL(context, link.url),
        borderRadius: BorderRadius.circular(12.0),
        child: ListTile(
          leading: FaIcon(link.icon, size: 28, color: textColor),
          title: Text(
            link.title,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            link.url.replaceAll('https://', '').split('/').first,
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
          ),
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