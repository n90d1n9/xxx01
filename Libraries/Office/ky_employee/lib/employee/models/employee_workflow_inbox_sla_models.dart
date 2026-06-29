import 'employee_next_action_models.dart';
import 'employee_workflow_inbox_models.dart';

/// SLA state derived from a normalized HR workflow inbox item.
enum EmployeeWorkflowInboxSlaState {
  overdue('Overdue'),
  dueToday('Due today'),
  dueSoon('Due soon'),
  onTrack('On track');

  final String label;

  const EmployeeWorkflowInboxSlaState(this.label);
}

/// Escalation tier recommended for one HR workflow inbox SLA signal.
enum EmployeeWorkflowInboxEscalationLevel {
  none('None'),
  watch('Watch'),
  manager('Manager'),
  leadership('Leadership');

  final String label;

  const EmployeeWorkflowInboxEscalationLevel(this.label);
}

/// SLA signal derived from one active HR workflow inbox item.
class EmployeeWorkflowInboxSlaSignal {
  final String itemId;
  final String sourceRecordId;
  final String title;
  final String owner;
  final EmployeeWorkflowInboxSource source;
  final EmployeeWorkflowInboxAction action;
  final EmployeeNextActionArea area;
  final EmployeeNextActionPriority priority;
  final DateTime dueDate;
  final int daysUntilDue;
  final bool isReady;
  final EmployeeWorkflowInboxSlaState state;
  final EmployeeWorkflowInboxEscalationLevel escalationLevel;
  final String recommendation;

  const EmployeeWorkflowInboxSlaSignal({
    required this.itemId,
    required this.sourceRecordId,
    required this.title,
    required this.owner,
    required this.source,
    required this.action,
    required this.area,
    required this.priority,
    required this.dueDate,
    required this.daysUntilDue,
    required this.isReady,
    required this.state,
    required this.escalationLevel,
    required this.recommendation,
  });

  bool get isPayroll => area == EmployeeNextActionArea.pay;

  bool get isEscalated {
    return escalationLevel == EmployeeWorkflowInboxEscalationLevel.manager ||
        escalationLevel == EmployeeWorkflowInboxEscalationLevel.leadership;
  }

  bool get needsAttention {
    return isReady ||
        isEscalated ||
        state == EmployeeWorkflowInboxSlaState.overdue ||
        state == EmployeeWorkflowInboxSlaState.dueToday;
  }
}

/// Owner load summary for active HR workflow inbox SLA work.
class EmployeeWorkflowInboxSlaOwnerLoad {
  final String owner;
  final int activeCount;
  final int readyCount;
  final int overdueCount;
  final int dueSoonCount;
  final int leadershipCount;

  const EmployeeWorkflowInboxSlaOwnerLoad({
    required this.owner,
    required this.activeCount,
    required this.readyCount,
    required this.overdueCount,
    required this.dueSoonCount,
    required this.leadershipCount,
  });

  bool get needsBalancing {
    return leadershipCount > 0 || overdueCount > 0 || readyCount > 2;
  }

  String get recommendation {
    if (leadershipCount > 0) return 'Escalate leadership-risk workflow items.';
    if (overdueCount > 0) return 'Recover overdue workflow commitments.';
    if (readyCount > 2) return 'Clear ready work before assigning more.';
    if (dueSoonCount > 0) return 'Confirm progress before SLA breach.';
    return 'Owner workflow load is manageable.';
  }
}

/// Aggregated SLA health profile for an employee HR workflow inbox.
class EmployeeWorkflowInboxSlaProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeWorkflowInboxSlaSignal> signals;
  final List<EmployeeWorkflowInboxSlaOwnerLoad> ownerLoads;

  const EmployeeWorkflowInboxSlaProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.signals,
    required this.ownerLoads,
  });

  List<EmployeeWorkflowInboxSlaSignal> get sortedSignals {
    final sorted = [...signals]..sort((a, b) {
      final attentionCompare = _attentionRank(a).compareTo(_attentionRank(b));
      if (attentionCompare != 0) return attentionCompare;

      final escalationCompare = _escalationRank(
        a.escalationLevel,
      ).compareTo(_escalationRank(b.escalationLevel));
      if (escalationCompare != 0) return escalationCompare;

      final stateCompare = _stateRank(a.state).compareTo(_stateRank(b.state));
      if (stateCompare != 0) return stateCompare;

      final priorityCompare = _priorityRank(
        a.priority,
      ).compareTo(_priorityRank(b.priority));
      if (priorityCompare != 0) return priorityCompare;

      return a.dueDate.compareTo(b.dueDate);
    });
    return sorted;
  }

  List<EmployeeWorkflowInboxSlaSignal> get topSignals {
    return sortedSignals.take(4).toList();
  }

  int get totalCount => signals.length;

  int get readyCount => signals.where((signal) => signal.isReady).length;

  int get overdueCount {
    return signals
        .where(
          (signal) => signal.state == EmployeeWorkflowInboxSlaState.overdue,
        )
        .length;
  }

  int get dueTodayCount {
    return signals
        .where(
          (signal) => signal.state == EmployeeWorkflowInboxSlaState.dueToday,
        )
        .length;
  }

  int get dueSoonCount {
    return signals
        .where(
          (signal) => signal.state == EmployeeWorkflowInboxSlaState.dueSoon,
        )
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
              EmployeeWorkflowInboxEscalationLevel.leadership,
        )
        .length;
  }

  int get ownerRiskCount {
    return ownerLoads.where((load) => load.needsBalancing).length;
  }

  String get nextAction {
    if (leadershipEscalationCount > 0) {
      return 'Escalate $leadershipEscalationCount inbox SLA risk${leadershipEscalationCount == 1 ? '' : 's'} to HR leadership.';
    }
    if (escalatedCount > 0) {
      return 'Escalate $escalatedCount inbox item${escalatedCount == 1 ? '' : 's'} to owner managers.';
    }
    if (readyCount > 0) {
      return 'Clear $readyCount ready inbox item${readyCount == 1 ? '' : 's'} before SLA drift.';
    }
    if (overdueCount > 0) {
      return 'Recover $overdueCount overdue inbox item${overdueCount == 1 ? '' : 's'}.';
    }
    if (dueTodayCount > 0) {
      return 'Close $dueTodayCount inbox item${dueTodayCount == 1 ? '' : 's'} due today.';
    }
    if (dueSoonCount > 0) {
      return 'Confirm $dueSoonCount inbox item${dueSoonCount == 1 ? '' : 's'} due soon.';
    }
    return 'Workflow inbox SLAs are on track.';
  }
}

EmployeeWorkflowInboxSlaState employeeWorkflowInboxSlaStateForItem({
  required EmployeeWorkflowInboxItem item,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  final dueDate = _dateOnly(item.dueDate);
  final daysUntilDue = dueDate.difference(today).inDays;

  if (daysUntilDue < 0) return EmployeeWorkflowInboxSlaState.overdue;
  if (daysUntilDue == 0) return EmployeeWorkflowInboxSlaState.dueToday;
  if (daysUntilDue <= 3) return EmployeeWorkflowInboxSlaState.dueSoon;
  return EmployeeWorkflowInboxSlaState.onTrack;
}

EmployeeWorkflowInboxEscalationLevel employeeWorkflowInboxEscalationForItem({
  required EmployeeWorkflowInboxItem item,
  required EmployeeWorkflowInboxSlaState state,
}) {
  final highImpact =
      item.priority == EmployeeNextActionPriority.critical ||
      item.priority == EmployeeNextActionPriority.high ||
      item.area == EmployeeNextActionArea.pay;

  if (state == EmployeeWorkflowInboxSlaState.overdue && highImpact) {
    return EmployeeWorkflowInboxEscalationLevel.leadership;
  }
  if (state == EmployeeWorkflowInboxSlaState.overdue ||
      state == EmployeeWorkflowInboxSlaState.dueToday &&
          item.priority == EmployeeNextActionPriority.critical) {
    return EmployeeWorkflowInboxEscalationLevel.manager;
  }
  if ((state == EmployeeWorkflowInboxSlaState.dueSoon || item.isReady) &&
      highImpact) {
    return EmployeeWorkflowInboxEscalationLevel.watch;
  }
  return EmployeeWorkflowInboxEscalationLevel.none;
}

String employeeWorkflowInboxSlaRecommendation({
  required bool isReady,
  required EmployeeWorkflowInboxSlaState state,
  required EmployeeWorkflowInboxEscalationLevel escalation,
}) {
  if (escalation == EmployeeWorkflowInboxEscalationLevel.leadership) {
    return 'Escalate to HR leadership and unblock the owner.';
  }
  if (escalation == EmployeeWorkflowInboxEscalationLevel.manager) {
    return 'Escalate to the owner manager today.';
  }
  if (isReady) {
    return 'Run the ready inbox action before SLA drift.';
  }
  if (escalation == EmployeeWorkflowInboxEscalationLevel.watch) {
    return 'Confirm owner progress before SLA breach.';
  }

  return switch (state) {
    EmployeeWorkflowInboxSlaState.overdue =>
      'Recover the overdue inbox item today.',
    EmployeeWorkflowInboxSlaState.dueToday =>
      'Complete or re-baseline this inbox item today.',
    EmployeeWorkflowInboxSlaState.dueSoon =>
      'Confirm next step and due date with the owner.',
    EmployeeWorkflowInboxSlaState.onTrack =>
      'Keep owner accountable to due date.',
  };
}

int _attentionRank(EmployeeWorkflowInboxSlaSignal signal) {
  return signal.needsAttention ? 0 : 1;
}

int _stateRank(EmployeeWorkflowInboxSlaState state) {
  return switch (state) {
    EmployeeWorkflowInboxSlaState.overdue => 0,
    EmployeeWorkflowInboxSlaState.dueToday => 1,
    EmployeeWorkflowInboxSlaState.dueSoon => 2,
    EmployeeWorkflowInboxSlaState.onTrack => 3,
  };
}

int _escalationRank(EmployeeWorkflowInboxEscalationLevel escalation) {
  return switch (escalation) {
    EmployeeWorkflowInboxEscalationLevel.leadership => 0,
    EmployeeWorkflowInboxEscalationLevel.manager => 1,
    EmployeeWorkflowInboxEscalationLevel.watch => 2,
    EmployeeWorkflowInboxEscalationLevel.none => 3,
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

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
