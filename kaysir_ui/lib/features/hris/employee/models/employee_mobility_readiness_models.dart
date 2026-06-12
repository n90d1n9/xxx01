import 'employee_directory_models.dart';

enum EmployeeMobilityMoveType {
  promotion('Promotion'),
  lateralTransfer('Lateral transfer'),
  managerChange('Manager change'),
  relocation('Relocation'),
  projectAssignment('Project assignment');

  final String label;

  const EmployeeMobilityMoveType(this.label);
}

enum EmployeeMobilityGateType {
  managerAlignment('Manager alignment'),
  compensation('Compensation'),
  access('Access'),
  handover('Handover'),
  location('Location'),
  startDate('Start date');

  final String label;

  const EmployeeMobilityGateType(this.label);
}

enum EmployeeMobilityGateStatus {
  ready('Ready'),
  actionRequired('Action required'),
  blocked('Blocked'),
  waived('Waived');

  final String label;

  const EmployeeMobilityGateStatus(this.label);
}

enum EmployeeMobilityGateRisk {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeMobilityGateRisk(this.label);
}

class EmployeeMobilityGate {
  final String id;
  final String employeeId;
  final EmployeeMobilityGateType type;
  final String title;
  final String owner;
  final DateTime dueDate;
  final EmployeeMobilityGateStatus status;
  final EmployeeMobilityGateRisk risk;
  final String detail;

  const EmployeeMobilityGate({
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

  bool get isComplete {
    return status == EmployeeMobilityGateStatus.ready ||
        status == EmployeeMobilityGateStatus.waived;
  }

  bool get isBlocked => status == EmployeeMobilityGateStatus.blocked;

  bool get needsAttention {
    return status == EmployeeMobilityGateStatus.actionRequired ||
        status == EmployeeMobilityGateStatus.blocked;
  }

  bool get isHighRisk {
    return risk == EmployeeMobilityGateRisk.critical ||
        risk == EmployeeMobilityGateRisk.high;
  }

  bool isOverdue(DateTime asOfDate) {
    return !isComplete && dueDate.isBefore(_dateOnly(asOfDate));
  }

  EmployeeMobilityGate copyWith({
    EmployeeMobilityGateType? type,
    String? title,
    String? owner,
    DateTime? dueDate,
    EmployeeMobilityGateStatus? status,
    EmployeeMobilityGateRisk? risk,
    String? detail,
  }) {
    return EmployeeMobilityGate(
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

class EmployeeMobilityReadinessProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeMobilityMoveType moveType;
  final String currentRole;
  final String currentDepartment;
  final String currentManager;
  final String targetRole;
  final String targetDepartment;
  final String targetManager;
  final DateTime effectiveDate;
  final List<EmployeeMobilityGate> gates;

  const EmployeeMobilityReadinessProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.moveType,
    required this.currentRole,
    required this.currentDepartment,
    required this.currentManager,
    required this.targetRole,
    required this.targetDepartment,
    required this.targetManager,
    required this.effectiveDate,
    required this.gates,
  });

  EmployeeMobilityReadinessProfile copyWith({
    EmployeeMobilityMoveType? moveType,
    String? targetRole,
    String? targetDepartment,
    String? targetManager,
    DateTime? effectiveDate,
    List<EmployeeMobilityGate>? gates,
  }) {
    return EmployeeMobilityReadinessProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      moveType: moveType ?? this.moveType,
      currentRole: currentRole,
      currentDepartment: currentDepartment,
      currentManager: currentManager,
      targetRole: targetRole ?? this.targetRole,
      targetDepartment: targetDepartment ?? this.targetDepartment,
      targetManager: targetManager ?? this.targetManager,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      gates: gates ?? this.gates,
    );
  }

  List<EmployeeMobilityGate> get sortedGates {
    final sorted = [...gates]..sort((a, b) {
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

  int get readyCount {
    return gates
        .where((gate) => gate.status == EmployeeMobilityGateStatus.ready)
        .length;
  }

  int get actionRequiredCount {
    return gates
        .where(
          (gate) => gate.status == EmployeeMobilityGateStatus.actionRequired,
        )
        .length;
  }

  int get blockedCount => gates.where((gate) => gate.isBlocked).length;

  int get waivedCount {
    return gates
        .where((gate) => gate.status == EmployeeMobilityGateStatus.waived)
        .length;
  }

  int get overdueCount {
    return gates.where((gate) => gate.isOverdue(asOfDate)).length;
  }

  int get highRiskOpenCount {
    return gates.where((gate) => gate.isHighRisk && !gate.isComplete).length;
  }

  int get attentionCount {
    return gates
        .where((gate) => gate.needsAttention || gate.isOverdue(asOfDate))
        .length;
  }

  int get daysUntilEffective {
    return _dateOnly(effectiveDate).difference(_dateOnly(asOfDate)).inDays;
  }

  bool get isEffectiveSoon => daysUntilEffective <= 21;

  double get readinessRatio {
    if (gates.isEmpty) return 0;
    return (readyCount + waivedCount) / gates.length;
  }

  EmployeeMobilityGate? get nextGate {
    final activeGates = sortedGates.where((gate) => !gate.isComplete).toList();
    if (activeGates.isEmpty) return null;
    return activeGates.first;
  }

  String get targetSummary {
    return '$targetRole in $targetDepartment under $targetManager';
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Clear $blockedCount blocked mobility gate${blockedCount == 1 ? '' : 's'}.';
    }
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue mobility gate${overdueCount == 1 ? '' : 's'}.';
    }
    if (isEffectiveSoon && attentionCount > 0) {
      return 'Finalize $attentionCount mobility gate${attentionCount == 1 ? '' : 's'} before effective date.';
    }
    final gate = nextGate;
    if (gate == null) {
      return 'Mobility readiness is clear for $targetRole.';
    }
    return 'Next: ${gate.title}.';
  }
}

class EmployeeMobilityGateDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeMobilityGateType type;
  final String title;
  final String owner;
  final DateTime? dueDate;
  final EmployeeMobilityGateRisk risk;
  final String detail;

  const EmployeeMobilityGateDraft({
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

  factory EmployeeMobilityGateDraft.fromMember({
    required EmployeeDirectoryMember member,
    required DateTime asOfDate,
  }) {
    final today = _dateOnly(asOfDate);
    return EmployeeMobilityGateDraft(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: today,
      type: EmployeeMobilityGateType.managerAlignment,
      title: '',
      owner: 'People Operations',
      dueDate: today.add(const Duration(days: 7)),
      risk: EmployeeMobilityGateRisk.medium,
      detail: '',
    );
  }

  EmployeeMobilityGateDraft copyWith({
    EmployeeMobilityGateType? type,
    String? title,
    String? owner,
    DateTime? dueDate,
    EmployeeMobilityGateRisk? risk,
    String? detail,
  }) {
    return EmployeeMobilityGateDraft(
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
      errors.add('Gate title must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Gate owner is required');
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

  EmployeeMobilityGate toGate({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeMobilityGate(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title.trim(),
      owner: owner.trim(),
      dueDate: dueDate!,
      status: EmployeeMobilityGateStatus.actionRequired,
      risk: risk,
      detail: detail.trim(),
    );
  }
}

int _statusRank(EmployeeMobilityGateStatus status) {
  return switch (status) {
    EmployeeMobilityGateStatus.blocked => 0,
    EmployeeMobilityGateStatus.actionRequired => 1,
    EmployeeMobilityGateStatus.ready => 2,
    EmployeeMobilityGateStatus.waived => 3,
  };
}

int _riskRank(EmployeeMobilityGateRisk risk) {
  return switch (risk) {
    EmployeeMobilityGateRisk.critical => 0,
    EmployeeMobilityGateRisk.high => 1,
    EmployeeMobilityGateRisk.medium => 2,
    EmployeeMobilityGateRisk.low => 3,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
