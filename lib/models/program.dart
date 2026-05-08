import 'package:cloud_firestore/cloud_firestore.dart';

class Program {
  final String id;
  final String time;
  final String title;
  final String host;
  final String description;
  final bool isLive;

  Program({
    required this.id,
    required this.time,
    required this.title,
    required this.host,
    required this.description,
    this.isLive = false,
  });

  // Professional factory method to parse Firestore data
  factory Program.fromFirestore(DocumentSnapshot doc) {
    // Safely cast data as a Map
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Program(
      id: doc.id,
      time: data['time'] ?? '00:00',
      title: data['title'] ?? 'Scheduled Program',
      host: data['host'] ?? 'Guest Host',
      description: data['description'] ?? 'Join us for this segment.',
      isLive: data['isLive'] ?? false,
    );
  }
}