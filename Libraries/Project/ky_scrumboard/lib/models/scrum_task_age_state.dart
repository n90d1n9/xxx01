import 'scrum_task.dart';
import 'scrum_task_status.dart';

enum ScrumTaskAgeSeverity { neutral, warning }

class ScrumTaskAgeState {
  const ScrumTaskAgeState({
    required this.status,
    required this.daysInStatus,
    required this.severity,
    required this.shouldRender,
  });

  static const none = ScrumTaskAgeState(
    status: ScrumTaskStatus.todo,
    daysInStatus: 0,
    severity: ScrumTaskAgeSeverity.neutral,
    shouldRender: false,
  );

  final ScrumTaskStatus status;
  final int daysInStatus;
  final ScrumTaskAgeSeverity severity;
  final bool shouldRender;

  bool get isWarning => severity == ScrumTaskAgeSeverity.warning;

  String get durationLabel {
    if (daysInStatus <= 0) return 'Today';
    if (daysInStatus == 1) return '1d';
    return '${daysInStatus}d';
  }

  static ScrumTaskAgeState forTask(
    ScrumTask task, {
    required DateTime statusStartedAt,
    DateTime? now,
    int reviewAgeWarningDays = 3,
  }) {
    if (task.isDone) return none;

    final daysInStatus = _dateOnly(
      now ?? DateTime.now(),
    ).difference(_dateOnly(statusStartedAt)).inDays;
    final visible =
        daysInStatus > 0 &&
        (task.status == ScrumTaskStatus.inProgress ||
            task.status == ScrumTaskStatus.review);
    final warning =
        task.status == ScrumTaskStatus.review &&
        daysInStatus >= _normalizedWarningDays(reviewAgeWarningDays);

    return ScrumTaskAgeState(
      status: task.status,
      daysInStatus: daysInStatus < 0 ? 0 : daysInStatus,
      severity: warning
          ? ScrumTaskAgeSeverity.warning
          : ScrumTaskAgeSeverity.neutral,
      shouldRender: visible,
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

int _normalizedWarningDays(int days) => days <= 0 ? 1 : days;
