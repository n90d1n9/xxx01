enum EmployeeProfileCompletenessArea {
  personalRecords('Personal records'),
  documentVault('Document vault'),
  workAuthorization('Work authorization'),
  jobAssignment('Job assignment'),
  payroll('Payroll setup'),
  benefits('Benefits'),
  reporting('Reporting line'),
  schedule('Schedule'),
  assetsAccess('Assets and access'),
  compliance('Compliance');

  final String label;

  const EmployeeProfileCompletenessArea(this.label);
}

enum EmployeeProfileCompletenessStatus {
  complete('Complete'),
  inProgress('In progress'),
  actionRequired('Action required'),
  missing('Missing');

  final String label;

  const EmployeeProfileCompletenessStatus(this.label);
}

class EmployeeProfileCompletenessItem {
  final EmployeeProfileCompletenessArea area;
  final EmployeeProfileCompletenessStatus status;
  final int score;
  final String detail;
  final String nextAction;

  const EmployeeProfileCompletenessItem({
    required this.area,
    required this.status,
    required this.score,
    required this.detail,
    required this.nextAction,
  });

  bool get needsAttention {
    return status == EmployeeProfileCompletenessStatus.missing ||
        status == EmployeeProfileCompletenessStatus.actionRequired;
  }

  bool get isOpen {
    return status != EmployeeProfileCompletenessStatus.complete;
  }
}

class EmployeeProfileCompletenessProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeProfileCompletenessItem> items;

  const EmployeeProfileCompletenessProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.items,
  });

  int get score {
    if (items.isEmpty) return 0;
    final total = items.fold<int>(0, (sum, item) => sum + item.score);
    return (total / items.length).round().clamp(0, 100);
  }

  int get completeCount {
    return items
        .where(
          (item) => item.status == EmployeeProfileCompletenessStatus.complete,
        )
        .length;
  }

  int get inProgressCount {
    return items
        .where(
          (item) => item.status == EmployeeProfileCompletenessStatus.inProgress,
        )
        .length;
  }

  int get actionRequiredCount {
    return items
        .where(
          (item) =>
              item.status == EmployeeProfileCompletenessStatus.actionRequired,
        )
        .length;
  }

  int get missingCount {
    return items
        .where(
          (item) => item.status == EmployeeProfileCompletenessStatus.missing,
        )
        .length;
  }

  int get openCount => items.length - completeCount;

  List<EmployeeProfileCompletenessItem> get priorityItems {
    final sorted = [...items]..sort((a, b) {
      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return a.score.compareTo(b.score);
    });
    return sorted;
  }

  String get nextAction {
    if (missingCount > 0) {
      return 'Complete $missingCount missing profile area${missingCount == 1 ? '' : 's'}.';
    }
    if (actionRequiredCount > 0) {
      return 'Resolve $actionRequiredCount profile area${actionRequiredCount == 1 ? '' : 's'} needing action.';
    }
    if (inProgressCount > 0) {
      return 'Finish $inProgressCount in-progress profile area${inProgressCount == 1 ? '' : 's'}.';
    }
    return 'Employee profile is complete.';
  }
}

int _statusRank(EmployeeProfileCompletenessStatus status) {
  return switch (status) {
    EmployeeProfileCompletenessStatus.missing => 0,
    EmployeeProfileCompletenessStatus.actionRequired => 1,
    EmployeeProfileCompletenessStatus.inProgress => 2,
    EmployeeProfileCompletenessStatus.complete => 3,
  };
}
