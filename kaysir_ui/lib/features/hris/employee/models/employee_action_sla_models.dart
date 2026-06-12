import 'employee_action_workflow_models.dart';
import 'employee_next_action_models.dart';

enum EmployeeActionSlaState {
  overdue('Overdue'),
  dueToday('Due today'),
  dueSoon('Due soon'),
  onTrack('On track'),
  closed('Closed');

  final String label;

  const EmployeeActionSlaState(this.label);
}

enum EmployeeActionEscalationLevel {
  none('None'),
  watch('Watch'),
  manager('Manager'),
  leadership('Leadership');

  final String label;

  const EmployeeActionEscalationLevel(this.label);
}

class EmployeeActionSlaSignal {
  final String taskId;
  final String title;
  final String owner;
  final EmployeeNextActionArea area;
  final EmployeeNextActionPriority priority;
  final EmployeeActionTaskStatus taskStatus;
  final String sourceLabel;
  final DateTime dueDate;
  final int daysUntilDue;
  final EmployeeActionSlaState state;
  final EmployeeActionEscalationLevel escalationLevel;
  final String recommendation;

  const EmployeeActionSlaSignal({
    required this.taskId,
    required this.title,
    required this.owner,
    required this.area,
    required this.priority,
    required this.taskStatus,
    required this.sourceLabel,
    required this.dueDate,
    required this.daysUntilDue,
    required this.state,
    required this.escalationLevel,
    required this.recommendation,
  });

  bool get isEscalated {
    return escalationLevel == EmployeeActionEscalationLevel.manager ||
        escalationLevel == EmployeeActionEscalationLevel.leadership;
  }

  bool get needsAttention {
    return isEscalated ||
        state == EmployeeActionSlaState.overdue ||
        state == EmployeeActionSlaState.dueToday;
  }
}

class EmployeeActionOwnerLoad {
  final String owner;
  final int activeCount;
  final int overdueCount;
  final int dueSoonCount;
  final int criticalCount;

  const EmployeeActionOwnerLoad({
    required this.owner,
    required this.activeCount,
    required this.overdueCount,
    required this.dueSoonCount,
    required this.criticalCount,
  });

  bool get needsBalancing {
    return overdueCount > 0 || criticalCount > 1 || activeCount > 3;
  }

  String get recommendation {
    if (overdueCount > 0) {
      return 'Recover overdue owner commitments.';
    }
    if (criticalCount > 1) {
      return 'Rebalance critical actions or add backup ownership.';
    }
    if (activeCount > 3) {
      return 'Review capacity before assigning more actions.';
    }
    return 'Owner load is manageable.';
  }
}

class EmployeeActionSlaProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeActionSlaSignal> signals;
  final List<EmployeeActionOwnerLoad> ownerLoads;

  const EmployeeActionSlaProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.signals,
    required this.ownerLoads,
  });

  List<EmployeeActionSlaSignal> get sortedSignals {
    final sorted = [...signals]..sort((a, b) {
      final stateCompare = _stateRank(a.state).compareTo(_stateRank(b.state));
      if (stateCompare != 0) return stateCompare;

      final escalationCompare = _escalationRank(
        a.escalationLevel,
      ).compareTo(_escalationRank(b.escalationLevel));
      if (escalationCompare != 0) return escalationCompare;

      final priorityCompare = _priorityRank(
        a.priority,
      ).compareTo(_priorityRank(b.priority));
      if (priorityCompare != 0) return priorityCompare;

      return a.dueDate.compareTo(b.dueDate);
    });
    return sorted;
  }

  List<EmployeeActionSlaSignal> get topSignals {
    return sortedSignals.take(5).toList();
  }

  int get overdueCount {
    return signals
        .where((signal) => signal.state == EmployeeActionSlaState.overdue)
        .length;
  }

  int get dueTodayCount {
    return signals
        .where((signal) => signal.state == EmployeeActionSlaState.dueToday)
        .length;
  }

  int get dueSoonCount {
    return signals
        .where((signal) => signal.state == EmployeeActionSlaState.dueSoon)
        .length;
  }

  int get closedCount {
    return signals
        .where((signal) => signal.state == EmployeeActionSlaState.closed)
        .length;
  }

  int get escalatedCount {
    return signals.where((signal) => signal.isEscalated).length;
  }

  int get leadershipEscalationCount {
    return signals
        .where(
          (signal) =>
              signal.escalationLevel ==
              EmployeeActionEscalationLevel.leadership,
        )
        .length;
  }

  int get ownerRiskCount {
    return ownerLoads.where((load) => load.needsBalancing).length;
  }

  String get nextAction {
    if (leadershipEscalationCount > 0) {
      return 'Escalate $leadershipEscalationCount employee SLA risk${leadershipEscalationCount == 1 ? '' : 's'} to HR leadership.';
    }
    if (escalatedCount > 0) {
      return 'Escalate $escalatedCount employee task${escalatedCount == 1 ? '' : 's'} to owner managers.';
    }
    if (overdueCount > 0) {
      return 'Recover $overdueCount overdue employee task${overdueCount == 1 ? '' : 's'}.';
    }
    if (dueTodayCount > 0) {
      return 'Close $dueTodayCount employee task${dueTodayCount == 1 ? '' : 's'} due today.';
    }
    if (dueSoonCount > 0) {
      return 'Confirm $dueSoonCount employee task${dueSoonCount == 1 ? '' : 's'} due soon.';
    }
    return 'Employee action SLAs are on track.';
  }
}

EmployeeActionSlaState employeeActionSlaStateForTask({
  required EmployeeActionTask task,
  required DateTime asOfDate,
}) {
  if (task.isClosed) return EmployeeActionSlaState.closed;

  final today = _dateOnly(asOfDate);
  final dueDate = _dateOnly(task.dueDate);
  final daysUntilDue = dueDate.difference(today).inDays;

  if (daysUntilDue < 0) return EmployeeActionSlaState.overdue;
  if (daysUntilDue == 0) return EmployeeActionSlaState.dueToday;
  if (daysUntilDue <= 3) return EmployeeActionSlaState.dueSoon;
  return EmployeeActionSlaState.onTrack;
}

EmployeeActionEscalationLevel employeeActionEscalationForTask({
  required EmployeeActionTask task,
  required EmployeeActionSlaState state,
}) {
  if (task.isClosed) return EmployeeActionEscalationLevel.none;

  final highImpact =
      task.priority == EmployeeNextActionPriority.critical ||
      task.priority == EmployeeNextActionPriority.high;

  if (state == EmployeeActionSlaState.overdue && highImpact) {
    return EmployeeActionEscalationLevel.leadership;
  }
  if (state == EmployeeActionSlaState.overdue ||
      state == EmployeeActionSlaState.dueToday &&
          task.priority == EmployeeNextActionPriority.critical) {
    return EmployeeActionEscalationLevel.manager;
  }
  if (state == EmployeeActionSlaState.dueSoon && highImpact) {
    return EmployeeActionEscalationLevel.watch;
  }
  return EmployeeActionEscalationLevel.none;
}

String employeeActionSlaRecommendation({
  required EmployeeActionSlaState state,
  required EmployeeActionEscalationLevel escalation,
}) {
  if (escalation == EmployeeActionEscalationLevel.leadership) {
    return 'Escalate to HR leadership and unblock the owner.';
  }
  if (escalation == EmployeeActionEscalationLevel.manager) {
    return 'Escalate to the owner manager today.';
  }
  if (escalation == EmployeeActionEscalationLevel.watch) {
    return 'Confirm owner progress before SLA breach.';
  }

  return switch (state) {
    EmployeeActionSlaState.overdue => 'Recover the overdue task today.',
    EmployeeActionSlaState.dueToday => 'Complete or re-baseline today.',
    EmployeeActionSlaState.dueSoon => 'Confirm next step and due date.',
    EmployeeActionSlaState.onTrack => 'Keep owner accountable to due date.',
    EmployeeActionSlaState.closed => 'No SLA action needed.',
  };
}

int _stateRank(EmployeeActionSlaState state) {
  return switch (state) {
    EmployeeActionSlaState.overdue => 0,
    EmployeeActionSlaState.dueToday => 1,
    EmployeeActionSlaState.dueSoon => 2,
    EmployeeActionSlaState.onTrack => 3,
    EmployeeActionSlaState.closed => 4,
  };
}

int _escalationRank(EmployeeActionEscalationLevel escalation) {
  return switch (escalation) {
    EmployeeActionEscalationLevel.leadership => 0,
    EmployeeActionEscalationLevel.manager => 1,
    EmployeeActionEscalationLevel.watch => 2,
    EmployeeActionEscalationLevel.none => 3,
  };
}

int _priorityRank(EmployeeNextActionPriority priority) {
  return switch (priority) {
    EmployeeNextActionPriority.critical => 0,
    EmployeeNextActionPriority.high => 1,
    EmployeeNextActionPriority.medium => 2,
    EmployeeNextActionPriority.low => 3,
  };
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
