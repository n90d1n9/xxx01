import 'employee_directory_models.dart';

enum EmployeeManagerChangeType {
  directManager('Direct manager'),
  matrixManager('Matrix manager'),
  interimManager('Interim manager'),
  skipLevelSponsor('Skip-level sponsor');

  final String label;

  const EmployeeManagerChangeType(this.label);
}

enum EmployeeManagerChangeChecklistType {
  outgoingHandoff('Outgoing handoff'),
  incomingAcknowledgement('Incoming acknowledgement'),
  directReportImpact('Direct report impact'),
  approvalCoverage('Approval coverage'),
  accessOwnership('Access ownership'),
  performanceOwnership('Performance ownership');

  final String label;

  const EmployeeManagerChangeChecklistType(this.label);
}

enum EmployeeManagerChangeChecklistStatus {
  ready('Ready'),
  actionRequired('Action required'),
  blocked('Blocked'),
  waived('Waived');

  final String label;

  const EmployeeManagerChangeChecklistStatus(this.label);
}

enum EmployeeManagerChangeRisk {
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeManagerChangeRisk(this.label);
}

class EmployeeManagerChangeChecklistItem {
  final String id;
  final String employeeId;
  final EmployeeManagerChangeChecklistType type;
  final String title;
  final String owner;
  final DateTime dueDate;
  final EmployeeManagerChangeChecklistStatus status;
  final EmployeeManagerChangeRisk risk;
  final String detail;

  const EmployeeManagerChangeChecklistItem({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.status,
    required this.risk,
    required this.detail,
  });

  bool get isReady {
    return status == EmployeeManagerChangeChecklistStatus.ready ||
        status == EmployeeManagerChangeChecklistStatus.waived;
  }

  bool get isBlocked => status == EmployeeManagerChangeChecklistStatus.blocked;

  bool get needsAttention {
    return status == EmployeeManagerChangeChecklistStatus.actionRequired ||
        status == EmployeeManagerChangeChecklistStatus.blocked;
  }

  bool get isHighRisk => risk == EmployeeManagerChangeRisk.high;

  bool isOverdue(DateTime asOfDate) {
    return !isReady && dueDate.isBefore(_dateOnly(asOfDate));
  }

  EmployeeManagerChangeChecklistItem copyWith({
    EmployeeManagerChangeChecklistType? type,
    String? title,
    String? owner,
    DateTime? dueDate,
    EmployeeManagerChangeChecklistStatus? status,
    EmployeeManagerChangeRisk? risk,
    String? detail,
  }) {
    return EmployeeManagerChangeChecklistItem(
      id: id,
      employeeId: employeeId,
      type: type ?? this.type,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      risk: risk ?? this.risk,
      detail: detail ?? this.detail,
    );
  }
}

class EmployeeManagerChangeReadinessProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeManagerChangeType changeType;
  final String currentManager;
  final String targetManager;
  final DateTime effectiveDate;
  final String reason;
  final List<EmployeeManagerChangeChecklistItem> checklist;

  const EmployeeManagerChangeReadinessProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.changeType,
    required this.currentManager,
    required this.targetManager,
    required this.effectiveDate,
    required this.reason,
    required this.checklist,
  });

  EmployeeManagerChangeReadinessProfile copyWith({
    EmployeeManagerChangeType? changeType,
    String? targetManager,
    DateTime? effectiveDate,
    String? reason,
    List<EmployeeManagerChangeChecklistItem>? checklist,
  }) {
    return EmployeeManagerChangeReadinessProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      changeType: changeType ?? this.changeType,
      currentManager: currentManager,
      targetManager: targetManager ?? this.targetManager,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      reason: reason ?? this.reason,
      checklist: checklist ?? this.checklist,
    );
  }

  List<EmployeeManagerChangeChecklistItem> get sortedChecklist {
    final sorted = [...checklist]..sort((a, b) {
      if (a.isReady != b.isReady) {
        return a.isReady ? 1 : -1;
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

  int get readyCount {
    return checklist
        .where(
          (item) => item.status == EmployeeManagerChangeChecklistStatus.ready,
        )
        .length;
  }

  int get actionRequiredCount {
    return checklist
        .where(
          (item) =>
              item.status ==
              EmployeeManagerChangeChecklistStatus.actionRequired,
        )
        .length;
  }

  int get blockedCount => checklist.where((item) => item.isBlocked).length;

  int get waivedCount {
    return checklist
        .where(
          (item) => item.status == EmployeeManagerChangeChecklistStatus.waived,
        )
        .length;
  }

  int get overdueCount {
    return checklist.where((item) => item.isOverdue(asOfDate)).length;
  }

  int get highRiskOpenCount {
    return checklist.where((item) => item.isHighRisk && !item.isReady).length;
  }

  int get attentionCount {
    return checklist
        .where((item) => item.needsAttention || item.isOverdue(asOfDate))
        .length;
  }

  int get daysUntilEffective {
    return _dateOnly(effectiveDate).difference(_dateOnly(asOfDate)).inDays;
  }

  bool get isEffectiveSoon => daysUntilEffective <= 14;

  bool get targetDiffers {
    return currentManager.trim().toLowerCase() !=
        targetManager.trim().toLowerCase();
  }

  double get readinessRatio {
    if (checklist.isEmpty) return 0;
    return (readyCount + waivedCount) / checklist.length;
  }

  EmployeeManagerChangeChecklistItem? get nextChecklistItem {
    final activeItems = sortedChecklist.where((item) => !item.isReady).toList();
    if (activeItems.isEmpty) return null;
    return activeItems.first;
  }

  String get nextAction {
    if (!targetDiffers) {
      return 'Choose a target manager different from the current manager.';
    }
    if (blockedCount > 0) {
      return 'Clear $blockedCount blocked manager-change item${blockedCount == 1 ? '' : 's'}.';
    }
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue manager-change item${overdueCount == 1 ? '' : 's'}.';
    }
    if (isEffectiveSoon && attentionCount > 0) {
      return 'Finalize $attentionCount manager-change item${attentionCount == 1 ? '' : 's'} before effective date.';
    }
    final item = nextChecklistItem;
    if (item == null) {
      return 'Manager change readiness is clear for $targetManager.';
    }
    return 'Next: ${item.title}.';
  }
}

class EmployeeManagerChangeChecklistDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeManagerChangeChecklistType type;
  final String title;
  final String owner;
  final DateTime? dueDate;
  final EmployeeManagerChangeRisk risk;
  final String detail;

  const EmployeeManagerChangeChecklistDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.risk,
    required this.detail,
  });

  factory EmployeeManagerChangeChecklistDraft.fromMember({
    required EmployeeDirectoryMember member,
    required DateTime asOfDate,
  }) {
    final today = _dateOnly(asOfDate);
    return EmployeeManagerChangeChecklistDraft(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: today,
      type: EmployeeManagerChangeChecklistType.incomingAcknowledgement,
      title: '',
      owner: 'People Operations',
      dueDate: today.add(const Duration(days: 7)),
      risk: EmployeeManagerChangeRisk.medium,
      detail: '',
    );
  }

  EmployeeManagerChangeChecklistDraft copyWith({
    EmployeeManagerChangeChecklistType? type,
    String? title,
    String? owner,
    DateTime? dueDate,
    EmployeeManagerChangeRisk? risk,
    String? detail,
  }) {
    return EmployeeManagerChangeChecklistDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      risk: risk ?? this.risk,
      detail: detail ?? this.detail,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Checklist title must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Checklist owner is required');
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

  EmployeeManagerChangeChecklistItem toItem({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeManagerChangeChecklistItem(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title.trim(),
      owner: owner.trim(),
      dueDate: dueDate!,
      status: EmployeeManagerChangeChecklistStatus.actionRequired,
      risk: risk,
      detail: detail.trim(),
    );
  }
}

int _statusRank(EmployeeManagerChangeChecklistStatus status) {
  return switch (status) {
    EmployeeManagerChangeChecklistStatus.blocked => 0,
    EmployeeManagerChangeChecklistStatus.actionRequired => 1,
    EmployeeManagerChangeChecklistStatus.ready => 2,
    EmployeeManagerChangeChecklistStatus.waived => 3,
  };
}

int _riskRank(EmployeeManagerChangeRisk risk) {
  return switch (risk) {
    EmployeeManagerChangeRisk.high => 0,
    EmployeeManagerChangeRisk.medium => 1,
    EmployeeManagerChangeRisk.low => 2,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
