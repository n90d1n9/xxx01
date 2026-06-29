class JourneyTask {
  final String id;
  final String label;
  final int score;
  final int value;
  final String section;
  final String task;
  final List<String> actors; // Add actors field

  JourneyTask({
    required this.id,
    required this.label,
    required this.score,
    required this.value,
    required this.section,
    required this.task,
    this.actors = const [], // Initialize with empty list
  });

  JourneyTask copyWith({
    String? id,
    String? label,
    int? score,
    int? value,
    String? section,
    String? task,
    List<String>? actors,
  }) {
    return JourneyTask(
      id: id ?? this.id,
      label: label ?? this.label,
      score: score ?? this.score,
      value: value ?? this.value,
      section: section ?? this.section,
      task: task ?? this.task,
      actors: actors ?? this.actors,
    );
  }

  @override
  String toString() {
    return 'JourneyTask(id: $id, label: $label, score: $score, value: $value, section: $section, task: $task, actors: $actors)';
  }
}
