import 'employee_directory_models.dart';

enum EmployeeRecordActionType {
  promotion('Promote'),
  transfer('Transfer'),
  managerChange('Change manager');

  final String label;

  const EmployeeRecordActionType(this.label);
}

enum EmployeeRecordActionStatus {
  submitted('Submitted'),
  approved('Approved'),
  applied('Applied');

  final String label;

  const EmployeeRecordActionStatus(this.label);
}

class EmployeeRecordActionImpact {
  final String label;
  final String fromValue;
  final String toValue;

  const EmployeeRecordActionImpact({
    required this.label,
    required this.fromValue,
    required this.toValue,
  });

  bool get hasChange => fromValue.trim() != toValue.trim();
}

class EmployeeRecordActionDraft {
  final String employeeId;
  final String employeeName;
  final EmployeeRecordActionType actionType;
  final String currentPosition;
  final String currentDepartment;
  final String currentManager;
  final String targetPosition;
  final String targetDepartment;
  final String targetManager;
  final DateTime? effectiveDate;
  final String reason;
  final DateTime asOfDate;

  const EmployeeRecordActionDraft({
    required this.employeeId,
    required this.employeeName,
    required this.actionType,
    required this.currentPosition,
    required this.currentDepartment,
    required this.currentManager,
    required this.targetPosition,
    required this.targetDepartment,
    required this.targetManager,
    required this.effectiveDate,
    required this.reason,
    required this.asOfDate,
  });

  factory EmployeeRecordActionDraft.fromMember({
    required EmployeeDirectoryMember member,
    required DateTime asOfDate,
  }) {
    return EmployeeRecordActionDraft(
      employeeId: member.id,
      employeeName: member.name,
      actionType: EmployeeRecordActionType.promotion,
      currentPosition: member.position,
      currentDepartment: member.department,
      currentManager: member.manager,
      targetPosition: member.position,
      targetDepartment: member.department,
      targetManager: member.manager,
      effectiveDate: null,
      reason: '',
      asOfDate: asOfDate,
    );
  }

  EmployeeRecordActionDraft copyWith({
    EmployeeRecordActionType? actionType,
    String? targetPosition,
    String? targetDepartment,
    String? targetManager,
    DateTime? effectiveDate,
    String? reason,
    bool clearEffectiveDate = false,
  }) {
    return EmployeeRecordActionDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      actionType: actionType ?? this.actionType,
      currentPosition: currentPosition,
      currentDepartment: currentDepartment,
      currentManager: currentManager,
      targetPosition: targetPosition ?? this.targetPosition,
      targetDepartment: targetDepartment ?? this.targetDepartment,
      targetManager: targetManager ?? this.targetManager,
      effectiveDate:
          clearEffectiveDate ? null : effectiveDate ?? this.effectiveDate,
      reason: reason ?? this.reason,
      asOfDate: asOfDate,
    );
  }

  List<EmployeeRecordActionImpact> get impacts {
    final items = <EmployeeRecordActionImpact>[];

    if (actionType == EmployeeRecordActionType.promotion ||
        actionType == EmployeeRecordActionType.transfer) {
      items.add(
        EmployeeRecordActionImpact(
          label: 'Position',
          fromValue: currentPosition,
          toValue: targetPosition.trim(),
        ),
      );
    }

    if (actionType == EmployeeRecordActionType.transfer) {
      items.add(
        EmployeeRecordActionImpact(
          label: 'Department',
          fromValue: currentDepartment,
          toValue: targetDepartment.trim(),
        ),
      );
    }

    if (actionType == EmployeeRecordActionType.transfer ||
        actionType == EmployeeRecordActionType.managerChange) {
      items.add(
        EmployeeRecordActionImpact(
          label: 'Manager',
          fromValue: currentManager,
          toValue: targetManager.trim(),
        ),
      );
    }

    return items;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final validations = [
      _validateRequired(targetPosition, 'a target position'),
      if (actionType == EmployeeRecordActionType.transfer)
        _validateRequired(targetDepartment, 'a target department'),
      if (actionType == EmployeeRecordActionType.transfer ||
          actionType == EmployeeRecordActionType.managerChange)
        _validateRequired(targetManager, 'a target manager'),
      _validateEffectiveDate(effectiveDate, asOfDate),
      _validateReason(reason),
      _validateHasImpact(),
    ];

    for (final validation in validations) {
      if (validation != null) errors.add(validation);
    }

    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          impacts.any((impact) => impact.hasChange),
          effectiveDate != null,
          reason.trim().length >= 12,
        ].where((item) => item).length;
    return completed / 3;
  }

  EmployeeRecordActionRequest toRequest({
    required String id,
    required DateTime createdAt,
  }) {
    return EmployeeRecordActionRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      actionType: actionType,
      currentPosition: currentPosition,
      currentDepartment: currentDepartment,
      currentManager: currentManager,
      targetPosition: targetPosition.trim(),
      targetDepartment: targetDepartment.trim(),
      targetManager: targetManager.trim(),
      effectiveDate: effectiveDate!,
      reason: reason.trim(),
      status: EmployeeRecordActionStatus.submitted,
      createdAt: createdAt,
    );
  }

  String? _validateHasImpact() {
    if (!impacts.any((impact) => impact.hasChange)) {
      return 'Change at least one employee record field';
    }
    return null;
  }
}

class EmployeeRecordActionRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeRecordActionType actionType;
  final String currentPosition;
  final String currentDepartment;
  final String currentManager;
  final String targetPosition;
  final String targetDepartment;
  final String targetManager;
  final DateTime effectiveDate;
  final String reason;
  final EmployeeRecordActionStatus status;
  final DateTime createdAt;

  const EmployeeRecordActionRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.actionType,
    required this.currentPosition,
    required this.currentDepartment,
    required this.currentManager,
    required this.targetPosition,
    required this.targetDepartment,
    required this.targetManager,
    required this.effectiveDate,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  List<EmployeeRecordActionImpact> get impacts {
    return [
      EmployeeRecordActionImpact(
        label: 'Position',
        fromValue: currentPosition,
        toValue: targetPosition,
      ),
      EmployeeRecordActionImpact(
        label: 'Department',
        fromValue: currentDepartment,
        toValue: targetDepartment,
      ),
      EmployeeRecordActionImpact(
        label: 'Manager',
        fromValue: currentManager,
        toValue: targetManager,
      ),
    ].where((impact) => impact.hasChange).toList();
  }

  bool get canApprove => status == EmployeeRecordActionStatus.submitted;

  bool get canApply => status == EmployeeRecordActionStatus.approved;

  EmployeeRecordActionRequest copyWith({EmployeeRecordActionStatus? status}) {
    return EmployeeRecordActionRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      actionType: actionType,
      currentPosition: currentPosition,
      currentDepartment: currentDepartment,
      currentManager: currentManager,
      targetPosition: targetPosition,
      targetDepartment: targetDepartment,
      targetManager: targetManager,
      effectiveDate: effectiveDate,
      reason: reason,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  EmployeeDirectoryMember applyTo(EmployeeDirectoryMember member) {
    return member.copyWith(
      position: targetPosition,
      department: targetDepartment,
      manager: targetManager,
    );
  }
}

class EmployeeRecordActionSummary {
  final int totalCount;
  final int submittedCount;
  final int approvedCount;
  final int appliedCount;
  final String nextAction;

  const EmployeeRecordActionSummary({
    required this.totalCount,
    required this.submittedCount,
    required this.approvedCount,
    required this.appliedCount,
    required this.nextAction,
  });

  factory EmployeeRecordActionSummary.fromRequests(
    List<EmployeeRecordActionRequest> requests,
  ) {
    final submittedCount =
        requests
            .where(
              (request) =>
                  request.status == EmployeeRecordActionStatus.submitted,
            )
            .length;
    final approvedCount =
        requests
            .where(
              (request) =>
                  request.status == EmployeeRecordActionStatus.approved,
            )
            .length;
    final appliedCount =
        requests
            .where(
              (request) => request.status == EmployeeRecordActionStatus.applied,
            )
            .length;

    return EmployeeRecordActionSummary(
      totalCount: requests.length,
      submittedCount: submittedCount,
      approvedCount: approvedCount,
      appliedCount: appliedCount,
      nextAction: _nextAction(
        submittedCount: submittedCount,
        approvedCount: approvedCount,
      ),
    );
  }
}

String _nextAction({required int submittedCount, required int approvedCount}) {
  if (approvedCount > 0) return 'Apply approved employee record changes.';
  if (submittedCount > 0) return 'Review submitted employee record changes.';
  return 'No employee record changes are waiting.';
}

String? _validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? _validateEffectiveDate(DateTime? value, DateTime asOfDate) {
  if (value == null) return 'Please select an effective date';

  final effective = DateTime(value.year, value.month, value.day);
  final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  if (effective.isBefore(today)) {
    return 'Effective date cannot be in the past';
  }
  return null;
}

String? _validateReason(String? value) {
  final requiredError = _validateRequired(value, 'a reason');
  if (requiredError != null) return requiredError;

  if (value!.trim().length < 12) {
    return 'Reason must be at least 12 characters';
  }
  return null;
}
