import 'package:flutter/material.dart';

import '../../models/scrum_task.dart';
import '../../models/scrum_task_age_state.dart';
import '../../models/scrum_task_due_state.dart';
import '../../models/scrum_task_status.dart';
import 'scrum_due_date_badge.dart';
import 'scrum_task_age_badge.dart';

class ScrumTaskSignalBadges extends StatelessWidget {
  const ScrumTaskSignalBadges({
    super.key,
    required this.task,
    this.dueSoonDays = 2,
    this.reviewAgeWarningDays = 3,
    this.statusStartedAt,
    this.statusLabel,
    this.now,
  });

  final ScrumTask task;
  final int dueSoonDays;
  final int reviewAgeWarningDays;
  final DateTime? statusStartedAt;
  final String? statusLabel;
  final DateTime? now;

  static bool hasSignalsFor(
    ScrumTask task, {
    int dueSoonDays = 2,
    int reviewAgeWarningDays = 3,
    DateTime? statusStartedAt,
    DateTime? now,
  }) {
    final dueState = ScrumTaskDueState.forTask(
      task,
      dueSoonDays: dueSoonDays,
      now: now,
    );
    final ageState = ScrumTaskAgeState.forTask(
      task,
      statusStartedAt: statusStartedAt ?? task.createdAt,
      reviewAgeWarningDays: reviewAgeWarningDays,
      now: now,
    );
    return dueState.shouldRender || ageState.shouldRender;
  }

  @override
  Widget build(BuildContext context) {
    final dueState = ScrumTaskDueState.forTask(
      task,
      dueSoonDays: dueSoonDays,
      now: now,
    );
    final ageState = ScrumTaskAgeState.forTask(
      task,
      statusStartedAt: statusStartedAt ?? task.createdAt,
      reviewAgeWarningDays: reviewAgeWarningDays,
      now: now,
    );
    if (!dueState.shouldRender && !ageState.shouldRender) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (ageState.shouldRender)
          ScrumTaskAgeBadge(
            ageState: ageState,
            statusLabel: statusLabel ?? task.status.label,
          ),
        if (dueState.shouldRender) ScrumDueDateBadge(dueState: dueState),
      ],
    );
  }
}
