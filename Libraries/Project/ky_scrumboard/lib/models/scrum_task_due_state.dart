import 'scrum_task.dart';

enum ScrumTaskDueStatus { none, planned, dueSoon, overdue }

class ScrumTaskDueState {
  const ScrumTaskDueState({
    required this.status,
    this.dueAt,
    this.daysUntilDue,
  });

  static const none = ScrumTaskDueState(status: ScrumTaskDueStatus.none);

  final ScrumTaskDueStatus status;
  final DateTime? dueAt;
  final int? daysUntilDue;

  bool get shouldRender => status != ScrumTaskDueStatus.none && dueAt != null;

  bool get isUrgent {
    return status == ScrumTaskDueStatus.overdue ||
        status == ScrumTaskDueStatus.dueSoon;
  }

  String get label {
    final dueDate = dueAt;
    if (dueDate == null) return '';

    switch (status) {
      case ScrumTaskDueStatus.none:
        return '';
      case ScrumTaskDueStatus.overdue:
        return 'Overdue';
      case ScrumTaskDueStatus.dueSoon:
        final days = daysUntilDue ?? 0;
        if (days <= 0) return 'Due today';
        if (days == 1) return 'Due in 1d';
        return 'Due in ${days}d';
      case ScrumTaskDueStatus.planned:
        return 'Due ${_shortDate(dueDate)}';
    }
  }

  String get tooltip {
    final dueDate = dueAt;
    if (dueDate == null) return 'No due date';
    final formattedDate = _longDate(dueDate);

    switch (status) {
      case ScrumTaskDueStatus.none:
        return 'No due date';
      case ScrumTaskDueStatus.overdue:
        return 'Overdue since $formattedDate';
      case ScrumTaskDueStatus.dueSoon:
        return 'Due soon on $formattedDate';
      case ScrumTaskDueStatus.planned:
        return 'Due on $formattedDate';
    }
  }

  static ScrumTaskDueState forTask(
    ScrumTask task, {
    DateTime? now,
    int dueSoonDays = 2,
  }) {
    return from(
      dueAt: task.dueAt,
      isDone: task.isDone,
      now: now,
      dueSoonDays: dueSoonDays,
    );
  }

  static ScrumTaskDueState from({
    required DateTime? dueAt,
    required bool isDone,
    DateTime? now,
    int dueSoonDays = 2,
  }) {
    if (dueAt == null) return none;

    final dueDate = _dateOnly(dueAt);
    final currentDate = _dateOnly(now ?? DateTime.now());
    final daysUntilDue = dueDate.difference(currentDate).inDays;

    if (!isDone && daysUntilDue < 0) {
      return ScrumTaskDueState(
        status: ScrumTaskDueStatus.overdue,
        dueAt: dueAt,
        daysUntilDue: daysUntilDue,
      );
    }

    if (!isDone && daysUntilDue <= _normalizedDueSoonDays(dueSoonDays)) {
      return ScrumTaskDueState(
        status: ScrumTaskDueStatus.dueSoon,
        dueAt: dueAt,
        daysUntilDue: daysUntilDue,
      );
    }

    return ScrumTaskDueState(
      status: ScrumTaskDueStatus.planned,
      dueAt: dueAt,
      daysUntilDue: daysUntilDue,
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

int _normalizedDueSoonDays(int days) => days < 0 ? 0 : days;

String _shortDate(DateTime date) => '${date.day}/${date.month}';

String _longDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
