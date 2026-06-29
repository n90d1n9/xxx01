import 'employee_directory_models.dart';

enum EmployeeExitType {
  voluntary('Voluntary exit'),
  involuntary('Involuntary exit'),
  contractEnd('Contract end'),
  internalTransfer('Internal transfer');

  final String label;

  const EmployeeExitType(this.label);
}

enum EmployeeExitClearanceCategory {
  knowledgeTransfer('Knowledge transfer'),
  access('Access'),
  assets('Assets'),
  payroll('Payroll'),
  documents('Documents'),
  compliance('Compliance');

  final String label;

  const EmployeeExitClearanceCategory(this.label);
}

enum EmployeeExitClearanceStatus {
  open('Open'),
  inProgress('In progress'),
  blocked('Blocked'),
  waived('Waived'),
  complete('Complete');

  final String label;

  const EmployeeExitClearanceStatus(this.label);
}

enum EmployeeExitRisk {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeExitRisk(this.label);
}

class EmployeeExitClearanceItem {
  final String id;
  final String employeeId;
  final String title;
  final String owner;
  final EmployeeExitClearanceCategory category;
  final EmployeeExitClearanceStatus status;
  final EmployeeExitRisk risk;
  final DateTime dueDate;
  final String note;

  const EmployeeExitClearanceItem({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.owner,
    required this.category,
    required this.status,
    required this.risk,
    required this.dueDate,
    this.note = '',
  });

  bool get isComplete {
    return status == EmployeeExitClearanceStatus.complete ||
        status == EmployeeExitClearanceStatus.waived;
  }

  bool get isBlocked => status == EmployeeExitClearanceStatus.blocked;

  bool get isHighRisk {
    return risk == EmployeeExitRisk.critical || risk == EmployeeExitRisk.high;
  }

  bool get needsAttention {
    return status == EmployeeExitClearanceStatus.open ||
        status == EmployeeExitClearanceStatus.inProgress ||
        status == EmployeeExitClearanceStatus.blocked;
  }

  bool isOverdue(DateTime asOfDate) {
    return !isComplete && dueDate.isBefore(_dateOnly(asOfDate));
  }

  EmployeeExitClearanceItem copyWith({
    String? title,
    String? owner,
    EmployeeExitClearanceCategory? category,
    EmployeeExitClearanceStatus? status,
    EmployeeExitRisk? risk,
    DateTime? dueDate,
    String? note,
  }) {
    return EmployeeExitClearanceItem(
      id: id,
      employeeId: employeeId,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      category: category ?? this.category,
      status: status ?? this.status,
      risk: risk ?? this.risk,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
    );
  }
}

class EmployeeExitReadinessProfile {
  final String employeeId;
  final String employeeName;
  final String manager;
  final DateTime asOfDate;
  final EmployeeExitType exitType;
  final DateTime finalWorkday;
  final List<EmployeeExitClearanceItem> items;

  const EmployeeExitReadinessProfile({
    required this.employeeId,
    required this.employeeName,
    required this.manager,
    required this.asOfDate,
    required this.exitType,
    required this.finalWorkday,
    required this.items,
  });

  EmployeeExitReadinessProfile copyWith({
    EmployeeExitType? exitType,
    DateTime? finalWorkday,
    List<EmployeeExitClearanceItem>? items,
  }) {
    return EmployeeExitReadinessProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      manager: manager,
      asOfDate: asOfDate,
      exitType: exitType ?? this.exitType,
      finalWorkday: finalWorkday ?? this.finalWorkday,
      items: items ?? this.items,
    );
  }

  List<EmployeeExitClearanceItem> get sortedItems {
    final sorted = [...items]..sort((a, b) {
      if (a.isComplete != b.isComplete) {
        return a.isComplete ? 1 : -1;
      }

      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;

      final riskCompare = _riskRank(a.risk).compareTo(_riskRank(b.risk));
      if (riskCompare != 0) return riskCompare;

      return a.dueDate.compareTo(b.dueDate);
    });
    return sorted;
  }

  int get openCount {
    return items
        .where((item) => item.status == EmployeeExitClearanceStatus.open)
        .length;
  }

  int get inProgressCount {
    return items
        .where((item) => item.status == EmployeeExitClearanceStatus.inProgress)
        .length;
  }

  int get blockedCount => items.where((item) => item.isBlocked).length;

  int get overdueCount {
    return items.where((item) => item.isOverdue(asOfDate)).length;
  }

  int get waivedCount {
    return items
        .where((item) => item.status == EmployeeExitClearanceStatus.waived)
        .length;
  }

  int get completeCount {
    return items
        .where((item) => item.status == EmployeeExitClearanceStatus.complete)
        .length;
  }

  int get highRiskOpenCount {
    return items.where((item) => item.isHighRisk && item.needsAttention).length;
  }

  int get attentionCount {
    return items
        .where((item) => item.needsAttention || item.isOverdue(asOfDate))
        .length;
  }

  int get daysUntilExit {
    return _dateOnly(finalWorkday).difference(_dateOnly(asOfDate)).inDays;
  }

  bool get isExitImminent => daysUntilExit <= 14;

  double get clearanceRatio {
    if (items.isEmpty) return 0;
    return (completeCount + waivedCount) / items.length;
  }

  EmployeeExitClearanceItem? get nextItem {
    final activeItems = sortedItems.where((item) => !item.isComplete).toList();
    if (activeItems.isEmpty) return null;
    return activeItems.first;
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Clear $blockedCount blocked exit clearance item${blockedCount == 1 ? '' : 's'}.';
    }
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue exit clearance item${overdueCount == 1 ? '' : 's'}.';
    }
    if (isExitImminent && attentionCount > 0) {
      return 'Finalize $attentionCount exit clearance item${attentionCount == 1 ? '' : 's'} before final workday.';
    }
    final item = nextItem;
    if (item == null) {
      return 'Exit readiness is clear for ${exitType.label.toLowerCase()}.';
    }
    return 'Next: ${item.title}.';
  }
}

class EmployeeExitClearanceDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String title;
  final String owner;
  final EmployeeExitClearanceCategory category;
  final DateTime? dueDate;
  final EmployeeExitRisk risk;
  final String note;

  const EmployeeExitClearanceDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.title,
    required this.owner,
    required this.category,
    required this.dueDate,
    required this.risk,
    required this.note,
  });

  factory EmployeeExitClearanceDraft.fromMember({
    required EmployeeDirectoryMember member,
    required DateTime asOfDate,
  }) {
    final today = _dateOnly(asOfDate);
    return EmployeeExitClearanceDraft(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: today,
      title: '',
      owner: 'People Operations',
      category: EmployeeExitClearanceCategory.knowledgeTransfer,
      dueDate: today.add(const Duration(days: 7)),
      risk: EmployeeExitRisk.medium,
      note: '',
    );
  }

  EmployeeExitClearanceDraft copyWith({
    String? title,
    String? owner,
    EmployeeExitClearanceCategory? category,
    DateTime? dueDate,
    EmployeeExitRisk? risk,
    String? note,
  }) {
    return EmployeeExitClearanceDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      risk: risk ?? this.risk,
      note: note ?? this.note,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Clearance title must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    final due = dueDate;
    if (due == null) {
      errors.add('Due date is required');
    } else if (due.isBefore(asOfDate)) {
      errors.add('Due date cannot be before today');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var completed = 0;
    if (title.trim().length >= 4) completed++;
    if (owner.trim().length >= 3) completed++;
    final due = dueDate;
    if (due != null && !due.isBefore(asOfDate)) completed++;
    return completed / 3;
  }

  EmployeeExitClearanceItem toItem({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeExitClearanceItem(
      id: id,
      employeeId: employeeId,
      title: title.trim(),
      owner: owner.trim(),
      category: category,
      status: EmployeeExitClearanceStatus.open,
      risk: risk,
      dueDate: dueDate!,
      note: note.trim(),
    );
  }
}

int _statusRank(EmployeeExitClearanceStatus status) {
  return switch (status) {
    EmployeeExitClearanceStatus.blocked => 0,
    EmployeeExitClearanceStatus.open => 1,
    EmployeeExitClearanceStatus.inProgress => 2,
    EmployeeExitClearanceStatus.waived => 3,
    EmployeeExitClearanceStatus.complete => 4,
  };
}

int _riskRank(EmployeeExitRisk risk) {
  return switch (risk) {
    EmployeeExitRisk.critical => 0,
    EmployeeExitRisk.high => 1,
    EmployeeExitRisk.medium => 2,
    EmployeeExitRisk.low => 3,
  };
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
