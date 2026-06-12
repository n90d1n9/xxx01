import '../../models/scrum_task_status.dart';

/// Default lanes shown by task editor controls.
const defaultTaskEditorStatuses = [
  ScrumTaskStatus.backlog,
  ScrumTaskStatus.todo,
  ScrumTaskStatus.inProgress,
  ScrumTaskStatus.review,
  ScrumTaskStatus.done,
];

/// Validates required task-editor text fields.
String? requiredTaskEditorText(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  return null;
}

/// Validates the task estimate field stored as story points.
String? validateTaskEditorEstimate(String? value) {
  final points = int.tryParse(value?.trim() ?? '');
  if (points == null || points <= 0) return 'Enter a positive number';
  if (points > 99) return 'Use 99 or less';
  return null;
}

/// Validates an optional due date in ISO local-date form.
String? validateTaskEditorDueDate(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  if (parseTaskEditorDueDate(text) == null) {
    return 'Use YYYY-MM-DD';
  }
  return null;
}

/// Parses an optional local due date from `YYYY-MM-DD` text.
DateTime? parseTaskEditorDueDate(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) return null;

  final parsed = DateTime.tryParse(text);
  if (parsed == null) return null;
  final date = DateTime(parsed.year, parsed.month, parsed.day);
  return formatTaskEditorDueDate(date) == text ? date : null;
}

/// Formats an optional due date as `YYYY-MM-DD` text.
String formatTaskEditorDueDate(DateTime? value) {
  if (value == null) return '';
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Generates a lightweight local task id for editor-created tasks.
String newTaskEditorId() => 'task-${DateTime.now().microsecondsSinceEpoch}';

/// Normalizes available editor lanes while preserving the selected lane.
List<ScrumTaskStatus> normalizeTaskEditorStatuses(
  List<ScrumTaskStatus> statuses,
  ScrumTaskStatus selectedStatus,
) {
  final normalized = <ScrumTaskStatus>[];
  for (final status in statuses) {
    if (!normalized.contains(status)) normalized.add(status);
  }
  if (!normalized.contains(selectedStatus)) normalized.add(selectedStatus);
  return normalized.isEmpty ? defaultTaskEditorStatuses : normalized;
}
