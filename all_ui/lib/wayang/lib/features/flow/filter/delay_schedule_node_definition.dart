import 'schedule_type.dart';

class DelayScheduleNodeDefinition {
  final String id;
  final String name;
  final String description;
  final ScheduleType scheduleType;
  final Duration? delay;
  final DateTime? scheduledTime;
  final String? cronExpression;
  final Duration? recurInterval;
  final int? maxRecurrences;
  final Map<String, dynamic> metadata;

  DelayScheduleNodeDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.scheduleType = ScheduleType.delay,
    this.delay,
    this.scheduledTime,
    this.cronExpression,
    this.recurInterval,
    this.maxRecurrences,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'scheduleType': scheduleType.name,
    'delay': delay?.inMilliseconds,
    'scheduledTime': scheduledTime?.toIso8601String(),
    'cronExpression': cronExpression,
    'recurInterval': recurInterval?.inMilliseconds,
    'maxRecurrences': maxRecurrences,
    'metadata': metadata,
  };

  factory DelayScheduleNodeDefinition.fromJson(Map<String, dynamic> json) =>
      DelayScheduleNodeDefinition(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        scheduleType: ScheduleType.values.firstWhere(
          (e) => e.name == json['scheduleType'],
          orElse: () => ScheduleType.delay,
        ),
        delay: json['delay'] != null
            ? Duration(milliseconds: json['delay'])
            : null,
        scheduledTime: json['scheduledTime'] != null
            ? DateTime.parse(json['scheduledTime'])
            : null,
        cronExpression: json['cronExpression'],
        recurInterval: json['recurInterval'] != null
            ? Duration(milliseconds: json['recurInterval'])
            : null,
        maxRecurrences: json['maxRecurrences'],
        metadata: json['metadata'] ?? {},
      );
}
