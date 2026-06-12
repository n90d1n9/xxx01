enum EmployeeJobAssignmentType {
  primary('Primary'),
  acting('Acting'),
  secondment('Secondment'),
  probation('Probation');

  final String label;

  const EmployeeJobAssignmentType(this.label);
}

enum EmployeeEmploymentContractType {
  permanent('Permanent'),
  fixedTerm('Fixed term'),
  probationary('Probationary'),
  intern('Intern'),
  contractor('Contractor');

  final String label;

  const EmployeeEmploymentContractType(this.label);
}

enum EmployeeWorkArrangement {
  onsite('On-site'),
  hybrid('Hybrid'),
  remote('Remote');

  final String label;

  const EmployeeWorkArrangement(this.label);
}

enum EmployeeJobAssignmentStatus {
  active('Active'),
  scheduled('Scheduled'),
  pendingApproval('Pending approval'),
  completed('Completed');

  final String label;

  const EmployeeJobAssignmentStatus(this.label);
}

class EmployeeJobAssignmentImpact {
  final String label;
  final String fromValue;
  final String toValue;

  const EmployeeJobAssignmentImpact({
    required this.label,
    required this.fromValue,
    required this.toValue,
  });

  bool get hasChange => fromValue.trim() != toValue.trim();
}

class EmployeeJobAssignmentRecord {
  final String id;
  final String employeeId;
  final String position;
  final String department;
  final String manager;
  final String location;
  final String costCenter;
  final String grade;
  final EmployeeEmploymentContractType contractType;
  final EmployeeWorkArrangement arrangement;
  final EmployeeJobAssignmentType assignmentType;
  final DateTime startDate;
  final DateTime? endDate;
  final EmployeeJobAssignmentStatus status;
  final String notes;

  const EmployeeJobAssignmentRecord({
    required this.id,
    required this.employeeId,
    required this.position,
    required this.department,
    required this.manager,
    required this.location,
    required this.costCenter,
    required this.grade,
    required this.contractType,
    required this.arrangement,
    required this.assignmentType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.notes,
  });

  bool isActiveOn(DateTime asOfDate) {
    final today = _dateOnly(asOfDate);
    final startsOnOrBeforeToday = !startDate.isAfter(today);
    final hasNotEnded = endDate == null || !endDate!.isBefore(today);
    return status == EmployeeJobAssignmentStatus.active &&
        startsOnOrBeforeToday &&
        hasNotEnded;
  }

  bool get isPendingApproval {
    return status == EmployeeJobAssignmentStatus.pendingApproval;
  }

  bool get canApprove => status == EmployeeJobAssignmentStatus.pendingApproval;

  bool canActivate(DateTime asOfDate) {
    return status == EmployeeJobAssignmentStatus.scheduled &&
        !startDate.isAfter(_dateOnly(asOfDate));
  }

  bool isScheduledSoon(DateTime asOfDate) {
    final today = _dateOnly(asOfDate);
    final soon = today.add(const Duration(days: 14));
    return status == EmployeeJobAssignmentStatus.scheduled &&
        !startDate.isBefore(today) &&
        !startDate.isAfter(soon);
  }

  bool needsAttention(DateTime asOfDate) {
    return isPendingApproval || isScheduledSoon(asOfDate);
  }

  EmployeeJobAssignmentRecord copyWith({
    DateTime? endDate,
    EmployeeJobAssignmentStatus? status,
  }) {
    return EmployeeJobAssignmentRecord(
      id: id,
      employeeId: employeeId,
      position: position,
      department: department,
      manager: manager,
      location: location,
      costCenter: costCenter,
      grade: grade,
      contractType: contractType,
      arrangement: arrangement,
      assignmentType: assignmentType,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      notes: notes,
    );
  }
}

class EmployeeJobAssignmentProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeJobAssignmentRecord> assignments;

  const EmployeeJobAssignmentProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.assignments,
  });

  EmployeeJobAssignmentProfile copyWith({
    List<EmployeeJobAssignmentRecord>? assignments,
  }) {
    return EmployeeJobAssignmentProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      assignments: assignments ?? this.assignments,
    );
  }

  EmployeeJobAssignmentRecord? get currentAssignment {
    final active =
        assignments.where((item) => item.isActiveOn(asOfDate)).toList()
          ..sort((a, b) => b.startDate.compareTo(a.startDate));
    if (active.isEmpty) return null;
    return active.first;
  }

  int get activeCount {
    return assignments.where((item) => item.isActiveOn(asOfDate)).length;
  }

  int get pendingApprovalCount {
    return assignments.where((item) => item.isPendingApproval).length;
  }

  int get scheduledSoonCount {
    return assignments.where((item) => item.isScheduledSoon(asOfDate)).length;
  }

  int get historyCount {
    return assignments
        .where((item) => item.status == EmployeeJobAssignmentStatus.completed)
        .length;
  }

  int get attentionCount => pendingApprovalCount + scheduledSoonCount;

  String get nextAction {
    if (pendingApprovalCount > 0) {
      return 'Review $pendingApprovalCount pending assignment change${pendingApprovalCount == 1 ? '' : 's'}.';
    }
    if (scheduledSoonCount > 0) {
      return 'Activate $scheduledSoonCount assignment change${scheduledSoonCount == 1 ? '' : 's'} due soon.';
    }
    final current = currentAssignment;
    if (current == null) return 'Create an active job assignment.';
    return '${current.position} assignment is current.';
  }
}

class EmployeeJobAssignmentDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String currentPosition;
  final String currentDepartment;
  final String currentManager;
  final String currentLocation;
  final String currentCostCenter;
  final String currentGrade;
  final EmployeeEmploymentContractType currentContractType;
  final EmployeeWorkArrangement currentArrangement;
  final String position;
  final String department;
  final String manager;
  final String location;
  final String costCenter;
  final String grade;
  final EmployeeEmploymentContractType contractType;
  final EmployeeWorkArrangement arrangement;
  final EmployeeJobAssignmentType assignmentType;
  final DateTime? startDate;
  final String notes;

  const EmployeeJobAssignmentDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.currentPosition,
    required this.currentDepartment,
    required this.currentManager,
    required this.currentLocation,
    required this.currentCostCenter,
    required this.currentGrade,
    required this.currentContractType,
    required this.currentArrangement,
    required this.position,
    required this.department,
    required this.manager,
    required this.location,
    required this.costCenter,
    required this.grade,
    required this.contractType,
    required this.arrangement,
    required this.assignmentType,
    required this.startDate,
    required this.notes,
  });

  EmployeeJobAssignmentDraft copyWith({
    String? position,
    String? department,
    String? manager,
    String? location,
    String? costCenter,
    String? grade,
    EmployeeEmploymentContractType? contractType,
    EmployeeWorkArrangement? arrangement,
    EmployeeJobAssignmentType? assignmentType,
    DateTime? startDate,
    String? notes,
  }) {
    return EmployeeJobAssignmentDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      currentPosition: currentPosition,
      currentDepartment: currentDepartment,
      currentManager: currentManager,
      currentLocation: currentLocation,
      currentCostCenter: currentCostCenter,
      currentGrade: currentGrade,
      currentContractType: currentContractType,
      currentArrangement: currentArrangement,
      position: position ?? this.position,
      department: department ?? this.department,
      manager: manager ?? this.manager,
      location: location ?? this.location,
      costCenter: costCenter ?? this.costCenter,
      grade: grade ?? this.grade,
      contractType: contractType ?? this.contractType,
      arrangement: arrangement ?? this.arrangement,
      assignmentType: assignmentType ?? this.assignmentType,
      startDate: startDate ?? this.startDate,
      notes: notes ?? this.notes,
    );
  }

  List<EmployeeJobAssignmentImpact> get impacts {
    return [
      EmployeeJobAssignmentImpact(
        label: 'Position',
        fromValue: currentPosition,
        toValue: position.trim(),
      ),
      EmployeeJobAssignmentImpact(
        label: 'Department',
        fromValue: currentDepartment,
        toValue: department.trim(),
      ),
      EmployeeJobAssignmentImpact(
        label: 'Manager',
        fromValue: currentManager,
        toValue: manager.trim(),
      ),
      EmployeeJobAssignmentImpact(
        label: 'Location',
        fromValue: currentLocation,
        toValue: location.trim(),
      ),
      EmployeeJobAssignmentImpact(
        label: 'Cost center',
        fromValue: currentCostCenter,
        toValue: costCenter.trim(),
      ),
      EmployeeJobAssignmentImpact(
        label: 'Grade',
        fromValue: currentGrade,
        toValue: grade.trim(),
      ),
      EmployeeJobAssignmentImpact(
        label: 'Contract',
        fromValue: currentContractType.label,
        toValue: contractType.label,
      ),
      EmployeeJobAssignmentImpact(
        label: 'Arrangement',
        fromValue: currentArrangement.label,
        toValue: arrangement.label,
      ),
    ];
  }

  List<EmployeeJobAssignmentImpact> get changedImpacts {
    return impacts.where((impact) => impact.hasChange).toList();
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (position.trim().length < 3) {
      errors.add('Position is required');
    }
    if (department.trim().length < 2) {
      errors.add('Department is required');
    }
    if (manager.trim().length < 3) {
      errors.add('Manager is required');
    }
    if (location.trim().length < 2) {
      errors.add('Location is required');
    }
    if (costCenter.trim().length < 2) {
      errors.add('Cost center is required');
    }
    if (grade.trim().isEmpty) {
      errors.add('Grade is required');
    }
    if (startDate == null) {
      errors.add('Start date is required');
    } else if (startDate!.isBefore(asOfDate)) {
      errors.add('Start date cannot be before today');
    }
    if (notes.trim().length < 12) {
      errors.add('Notes must be at least 12 characters');
    }
    if (changedImpacts.isEmpty &&
        assignmentType == EmployeeJobAssignmentType.primary) {
      errors.add('Change at least one assignment field');
    }
    return errors;
  }

  bool get isReadyToSchedule => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          position.trim().length >= 3,
          department.trim().length >= 2,
          manager.trim().length >= 3,
          location.trim().length >= 2,
          costCenter.trim().length >= 2,
          grade.trim().isNotEmpty,
          startDate != null && !startDate!.isBefore(asOfDate),
          notes.trim().length >= 12,
          changedImpacts.isNotEmpty ||
              assignmentType != EmployeeJobAssignmentType.primary,
        ].where((item) => item).length;
    return completed / 9;
  }

  EmployeeJobAssignmentRecord toRecord({required String id}) {
    if (!isReadyToSchedule) {
      throw StateError(validationErrors.first);
    }

    return EmployeeJobAssignmentRecord(
      id: id,
      employeeId: employeeId,
      position: position.trim(),
      department: department.trim(),
      manager: manager.trim(),
      location: location.trim(),
      costCenter: costCenter.trim(),
      grade: grade.trim(),
      contractType: contractType,
      arrangement: arrangement,
      assignmentType: assignmentType,
      startDate: startDate!,
      endDate: null,
      status: EmployeeJobAssignmentStatus.pendingApproval,
      notes: notes.trim(),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
