import 'package:intl/intl.dart';

class Program {

  final String day;

  final String startTime;

  final String endTime;

  final String title;

  final String host;

  final String description;

  final String category;

  final bool isLive;

  final String thumbnail;

  Program({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.host,
    required this.description,
    required this.category,
    required this.isLive,
    required this.thumbnail,
  });

  // =========================
  // CSV FACTORY
  // =========================

  factory Program.fromCSV(
    Map<String, dynamic> data,
  ) {
    return Program(
      day: data['day'] ?? '',

      startTime:
          data['start_time'] ?? '',

      endTime:
          data['end_time'] ?? '',

      title: data['title'] ?? '',

      host: data['host'] ?? '',

      description:
          data['description'] ?? '',

      category:
          data['category'] ?? '',

      isLive:
          (data['is_live'] ?? '')
                  .toString()
                  .toUpperCase() ==
              'TRUE',

      thumbnail:
          data['thumbnail'] ?? '',
    );
  }

  // =========================
  // SUPABASE FACTORY
  // =========================

  factory Program.fromSupabase(Map<String, dynamic> data) => Program(
        day: data['days'] ?? data['day'] ?? '',
        startTime: data['start_time'] ?? '',
        endTime: data['end_time'] ?? '',
        title: data['title'] ?? '',
        host: data['host'] ?? '',
        description: data['description'] ?? '',
        category: data['category'] ?? '',
        isLive: data['is_live'] == true,
        thumbnail: data['thumbnail'] ?? '',
      );

  // =========================
  // LEGACY SUPPORT
  // =========================

  String get time => startTime;


bool isCurrentlyPlaying() {
  try {
    final now = DateTime.now();

    if (day.isNotEmpty) {
      const weekdays = [
        'monday', 'tuesday', 'wednesday',
        'thursday', 'friday', 'saturday', 'sunday',
      ];
      final currentDay = weekdays[now.weekday - 1];
      final programDay = day.trim().toLowerCase();
      // Match full name ("monday") or abbreviation ("mon")
      if (!currentDay.startsWith(programDay) &&
          !programDay.startsWith(currentDay)) {
        return false;
      }
    }

    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    final current = DateTime(
      now.year, now.month, now.day, now.hour, now.minute,
    );

    return current.isAfter(start) && current.isBefore(end);
  } catch (_) {
    return false;
  }
}

DateTime _parseTime(String time) {
  final now = DateTime.now();
  final cleaned = time.trim();

  late DateTime parsed;
  try {
    // Try 12-hour format first (e.g. "09:00 AM")
    parsed = DateFormat('hh:mm a').parse(cleaned);
  } catch (_) {
    // Fall back to 24-hour format (e.g. "14:00")
    parsed = DateFormat('HH:mm').parse(cleaned);
  }

  return DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
}


}