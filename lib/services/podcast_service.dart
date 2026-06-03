import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../constants/app_constants.dart';
import '../models/podcast_episode.dart';

class PodcastService {
  static Future<List<PodcastEpisode>> fetchEpisodes() async {
    final response = await http.get(
      Uri.parse(AppConstants.podcastRssUrl),
      headers: {'User-Agent': 'AhenfieMedia/2.0'},
    );
    if (response.statusCode != 200) {
      throw Exception('RSS fetch failed: ${response.statusCode}');
    }
    final doc = XmlDocument.parse(response.body);
    return doc
        .findAllElements('item')
        .map(_parseItem)
        .where((e) => e.audioUrl.isNotEmpty)
        .toList();
  }

  static PodcastEpisode _parseItem(XmlElement item) {
    String text(String tag) =>
        item.findElements(tag).firstOrNull?.innerText.trim() ?? '';

    final enclosure = item.findElements('enclosure').firstOrNull;
    final audioUrl = enclosure?.getAttribute('url') ?? '';

    // itunes:duration may be "HH:MM:SS", "MM:SS", or seconds as int
    final durationEl = item.childElements
        .where((e) => e.name.local == 'duration')
        .firstOrNull;

    return PodcastEpisode(
      guid: text('guid'),
      title: text('title').isNotEmpty ? text('title') : 'Untitled',
      description: text('description').isNotEmpty ? text('description') : null,
      audioUrl: audioUrl,
      pubDate: _parseRfc2822(text('pubDate')),
      duration:
          durationEl != null ? _parseDuration(durationEl.innerText.trim()) : null,
    );
  }

  static DateTime? _parseRfc2822(String s) {
    if (s.isEmpty) return null;
    try {
      const months = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
      };
      final parts = s.trim().split(RegExp(r'\s+'));
      if (parts.length < 5) return null;
      final day = int.parse(parts[1]);
      final month = months[parts[2].toLowerCase()] ?? 1;
      final year = int.parse(parts[3]);
      final tp = parts[4].split(':');
      final hour = int.parse(tp[0]);
      final minute = int.parse(tp[1]);
      final second = tp.length > 2 ? int.parse(tp[2]) : 0;
      return DateTime.utc(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }

  static Duration _parseDuration(String s) {
    final parts = s.split(':');
    if (parts.length == 3) {
      return Duration(
        hours: int.tryParse(parts[0]) ?? 0,
        minutes: int.tryParse(parts[1]) ?? 0,
        seconds: int.tryParse(parts[2]) ?? 0,
      );
    }
    if (parts.length == 2) {
      return Duration(
        minutes: int.tryParse(parts[0]) ?? 0,
        seconds: int.tryParse(parts[1]) ?? 0,
      );
    }
    return Duration(seconds: int.tryParse(s) ?? 0);
  }
}
