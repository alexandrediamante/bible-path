class ListenDay {
  const ListenDay({
    required this.day,
    required this.title,
    required this.passage,
    required this.durationSeconds,
    this.description,
  });

  final int day;
  final String title;
  final String passage;
  final int durationSeconds;
  final String? description;

  int get roundedMinutes => (durationSeconds / 60).ceil();

  String get durationDisplay {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes > 0 && seconds > 0) {
      return '${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  factory ListenDay.fromJson(Map<String, dynamic> json) {
    return ListenDay(
      day: (json['day'] as num).toInt(),
      title: json['title'] as String,
      passage: json['passage'] as String,
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'title': title,
    'passage': passage,
    'durationSeconds': durationSeconds,
    'description': description,
  };
}
