class PresenterProgram {
  final String name;
  final String days;
  final String time;
  final String type; // 'tv' or 'radio'

  const PresenterProgram({
    required this.name,
    required this.days,
    required this.time,
    this.type = 'tv',
  });

  factory PresenterProgram.fromMap(Map<String, dynamic> map) => PresenterProgram(
        name: map['name'] ?? '',
        days: map['days'] ?? '',
        time: map['time'] ?? '',
        type: map['type'] ?? 'tv',
      );
}

class Presenter {
  final String id;
  final String name;
  final String title;
  final String bio;
  final String? imageUrl;
  final int order;
  final List<PresenterProgram> programs;

  const Presenter({
    required this.id,
    required this.name,
    required this.title,
    required this.bio,
    this.imageUrl,
    this.order = 0,
    this.programs = const [],
  });

  factory Presenter.fromJson(Map<String, dynamic> json) {
    final rawPrograms = json['programs'] as List? ?? [];
    return Presenter(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      bio: json['bio'] ?? '',
      imageUrl: json['image_url'] as String?,
      order: (json['display_order'] as num?)?.toInt() ?? 0,
      programs: rawPrograms
          .map((p) => PresenterProgram.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList(),
    );
  }
}
