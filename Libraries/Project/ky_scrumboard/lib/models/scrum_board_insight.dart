import 'scrum_task_status.dart';

enum ScrumBoardInsightSeverity { positive, info, warning, critical }

class ScrumBoardInsight {
  const ScrumBoardInsight({
    required this.key,
    required this.title,
    required this.description,
    required this.severity,
    this.relatedStatus,
  });

  final String key;
  final String title;
  final String description;
  final ScrumBoardInsightSeverity severity;
  final ScrumTaskStatus? relatedStatus;
}
