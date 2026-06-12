enum EmployeeNextActionArea {
  profile('Profile'),
  records('Records'),
  work('Work'),
  growth('Growth'),
  pay('Pay'),
  security('Security');

  final String label;

  const EmployeeNextActionArea(this.label);
}

enum EmployeeNextActionPriority {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeNextActionPriority(this.label);
}

enum EmployeeNextActionStatus {
  blocked('Blocked'),
  dueSoon('Due soon'),
  open('Open'),
  ready('Ready');

  final String label;

  const EmployeeNextActionStatus(this.label);
}

class EmployeeNextAction {
  final String id;
  final EmployeeNextActionArea area;
  final EmployeeNextActionPriority priority;
  final EmployeeNextActionStatus status;
  final String title;
  final String detail;
  final String owner;
  final String sourceLabel;
  final DateTime? dueDate;
  final int impactScore;

  const EmployeeNextAction({
    required this.id,
    required this.area,
    required this.priority,
    required this.status,
    required this.title,
    required this.detail,
    required this.owner,
    required this.sourceLabel,
    required this.dueDate,
    required this.impactScore,
  });

  bool get isUrgent {
    return priority == EmployeeNextActionPriority.critical ||
        priority == EmployeeNextActionPriority.high ||
        status == EmployeeNextActionStatus.blocked;
  }

  bool isDueSoon(DateTime asOfDate) {
    final due = dueDate;
    if (due == null) return false;
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final horizon = today.add(const Duration(days: 7));
    return !due.isBefore(today) && !due.isAfter(horizon);
  }
}

class EmployeeNextActionProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeNextAction> actions;

  const EmployeeNextActionProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.actions,
  });

  List<EmployeeNextAction> get sortedActions {
    final sorted = [...actions]..sort((a, b) {
      final priorityCompare = _priorityRank(
        a.priority,
      ).compareTo(_priorityRank(b.priority));
      if (priorityCompare != 0) return priorityCompare;

      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;

      final dueCompare = _compareNullableDates(a.dueDate, b.dueDate);
      if (dueCompare != 0) return dueCompare;

      return b.impactScore.compareTo(a.impactScore);
    });
    return sorted;
  }

  List<EmployeeNextAction> get topActions {
    return sortedActions.take(5).toList();
  }

  int get urgentCount {
    return actions.where((action) => action.isUrgent).length;
  }

  int get blockedCount {
    return actions
        .where((action) => action.status == EmployeeNextActionStatus.blocked)
        .length;
  }

  int get dueSoonCount {
    return actions.where((action) => action.isDueSoon(asOfDate)).length;
  }

  int get openCount {
    return actions
        .where((action) => action.status == EmployeeNextActionStatus.open)
        .length;
  }

  int get readyCount {
    return actions
        .where((action) => action.status == EmployeeNextActionStatus.ready)
        .length;
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount blocked employee action${blockedCount == 1 ? '' : 's'}.';
    }
    if (urgentCount > 0) {
      return 'Work $urgentCount urgent employee action${urgentCount == 1 ? '' : 's'}.';
    }
    if (dueSoonCount > 0) {
      return 'Complete $dueSoonCount employee action${dueSoonCount == 1 ? '' : 's'} due soon.';
    }
    if (actions.isEmpty) {
      return 'No open employee actions.';
    }
    return 'Review ${actions.length} employee action${actions.length == 1 ? '' : 's'}.';
  }
}

int _priorityRank(EmployeeNextActionPriority priority) {
  return switch (priority) {
    EmployeeNextActionPriority.critical => 0,
    EmployeeNextActionPriority.high => 1,
    EmployeeNextActionPriority.medium => 2,
    EmployeeNextActionPriority.low => 3,
  };
}

int _statusRank(EmployeeNextActionStatus status) {
  return switch (status) {
    EmployeeNextActionStatus.blocked => 0,
    EmployeeNextActionStatus.dueSoon => 1,
    EmployeeNextActionStatus.open => 2,
    EmployeeNextActionStatus.ready => 3,
  };
}

int _compareNullableDates(DateTime? left, DateTime? right) {
  if (left == null && right == null) return 0;
  if (left == null) return 1;
  if (right == null) return -1;
  return left.compareTo(right);
}
