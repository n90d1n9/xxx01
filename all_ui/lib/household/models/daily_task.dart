enum TaskPriority { low, medium, high }

class DailyTask {
  final String id;
  final String title;
  final bool completed;
  final DateTime date;
  final String? notes;
  final TaskPriority priority;
  final String? assignedTo;

  DailyTask({
    required this.id,
    required this.title,
    required this.completed,
    required this.date,
    this.notes,
    this.priority = TaskPriority.medium,
    this.assignedTo,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
    'date': date.toIso8601String(),
    'notes': notes,
    'priority': priority.index,
    'assignedTo': assignedTo,
  };

  factory DailyTask.fromJson(Map<String, dynamic> json) => DailyTask(
    id: json['id'],
    title: json['title'],
    completed: json['completed'],
    date: DateTime.parse(json['date']),
    notes: json['notes'],
    priority: TaskPriority.values[json['priority'] ?? 1],
    assignedTo: json['assignedTo'],
  );

  DailyTask copyWith({
    String? title,
    bool? completed,
    DateTime? date,
    String? notes,
    TaskPriority? priority,
    String? assignedTo,
  }) {
    return DailyTask(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}
