enum HrActionType {
  newHire('New hire'),
  promotion('Promotion'),
  transfer('Transfer'),
  compensationChange('Compensation change'),
  leaveChange('Leave change'),
  offboarding('Offboarding');

  final String label;

  const HrActionType(this.label);
}

enum HrActionPriority {
  standard('Standard'),
  urgent('Urgent'),
  critical('Critical');

  final String label;

  const HrActionPriority(this.label);
}

enum HrActionStatus {
  submitted('Submitted'),
  inReview('In review'),
  approved('Approved'),
  blocked('Blocked');

  final String label;

  const HrActionStatus(this.label);
}

class HrActionRequest {
  final String id;
  final String employeeName;
  final String department;
  final HrActionType actionType;
  final String targetRole;
  final DateTime effectiveDate;
  final String managerName;
  final String ownerName;
  final String reason;
  final bool payrollReviewRequired;
  final HrActionPriority priority;
  final HrActionStatus status;
  final DateTime createdAt;

  const HrActionRequest({
    required this.id,
    required this.employeeName,
    required this.department,
    required this.actionType,
    required this.targetRole,
    required this.effectiveDate,
    required this.managerName,
    required this.ownerName,
    required this.reason,
    required this.payrollReviewRequired,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  bool get isOpen => status != HrActionStatus.approved;

  bool get needsAttention {
    return status == HrActionStatus.blocked ||
        priority != HrActionPriority.standard ||
        payrollReviewRequired;
  }

  int daysUntilEffective(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final effective = DateTime(
      effectiveDate.year,
      effectiveDate.month,
      effectiveDate.day,
    );
    return effective.difference(start).inDays;
  }

  HrActionRequest copyWith({
    HrActionStatus? status,
    HrActionPriority? priority,
    bool? payrollReviewRequired,
  }) {
    return HrActionRequest(
      id: id,
      employeeName: employeeName,
      department: department,
      actionType: actionType,
      targetRole: targetRole,
      effectiveDate: effectiveDate,
      managerName: managerName,
      ownerName: ownerName,
      reason: reason,
      payrollReviewRequired:
          payrollReviewRequired ?? this.payrollReviewRequired,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

class HrActionFormDraft {
  final String employeeName;
  final String department;
  final HrActionType actionType;
  final String targetRole;
  final DateTime? effectiveDate;
  final String managerName;
  final String ownerName;
  final String reason;
  final bool payrollReviewRequired;
  final HrActionPriority priority;
  final DateTime asOfDate;

  const HrActionFormDraft({
    required this.employeeName,
    required this.department,
    required this.actionType,
    required this.targetRole,
    required this.effectiveDate,
    required this.managerName,
    required this.ownerName,
    required this.reason,
    required this.payrollReviewRequired,
    required this.priority,
    required this.asOfDate,
  });

  factory HrActionFormDraft.empty(DateTime asOfDate) {
    return HrActionFormDraft(
      employeeName: '',
      department: '',
      actionType: HrActionType.newHire,
      targetRole: '',
      effectiveDate: null,
      managerName: '',
      ownerName: '',
      reason: '',
      payrollReviewRequired: false,
      priority: HrActionPriority.standard,
      asOfDate: asOfDate,
    );
  }

  HrActionFormDraft copyWith({
    String? employeeName,
    String? department,
    HrActionType? actionType,
    String? targetRole,
    DateTime? effectiveDate,
    String? managerName,
    String? ownerName,
    String? reason,
    bool? payrollReviewRequired,
    HrActionPriority? priority,
    DateTime? asOfDate,
    bool clearEffectiveDate = false,
  }) {
    return HrActionFormDraft(
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      actionType: actionType ?? this.actionType,
      targetRole: targetRole ?? this.targetRole,
      effectiveDate:
          clearEffectiveDate ? null : effectiveDate ?? this.effectiveDate,
      managerName: managerName ?? this.managerName,
      ownerName: ownerName ?? this.ownerName,
      reason: reason ?? this.reason,
      payrollReviewRequired:
          payrollReviewRequired ?? this.payrollReviewRequired,
      priority: priority ?? this.priority,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          employeeName.trim().isNotEmpty,
          department.trim().isNotEmpty,
          targetRole.trim().isNotEmpty,
          effectiveDate != null,
          managerName.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          reason.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 7;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final validations = [
      validateRequired(employeeName, 'an employee name'),
      validateRequired(department, 'a department'),
      validateRequired(targetRole, 'a role or target change'),
      validateEffectiveDate(effectiveDate, asOfDate),
      validateRequired(managerName, 'a manager'),
      validateRequired(ownerName, 'an HR owner'),
      validateReason(reason),
    ];

    for (final validation in validations) {
      if (validation != null) errors.add(validation);
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  HrActionRequest toRequest({required String id, required DateTime createdAt}) {
    return HrActionRequest(
      id: id,
      employeeName: employeeName.trim(),
      department: department.trim(),
      actionType: actionType,
      targetRole: targetRole.trim(),
      effectiveDate: effectiveDate!,
      managerName: managerName.trim(),
      ownerName: ownerName.trim(),
      reason: reason.trim(),
      payrollReviewRequired: payrollReviewRequired,
      priority: priority,
      status: HrActionStatus.submitted,
      createdAt: createdAt,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateEffectiveDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Please select an effective date';

    final effective = DateTime(value.year, value.month, value.day);
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    if (effective.isBefore(today)) {
      return 'Effective date cannot be in the past';
    }
    return null;
  }

  static String? validateReason(String? value) {
    final requiredError = validateRequired(value, 'a reason');
    if (requiredError != null) return requiredError;

    if (value!.trim().length < 12) {
      return 'Reason must be at least 12 characters';
    }
    return null;
  }
}

class HrActionQueueSummary {
  final int totalCount;
  final int openCount;
  final int blockedCount;
  final int payrollReviewCount;
  final int urgentCount;
  final int dueThisWeekCount;
  final String nextAction;

  const HrActionQueueSummary({
    required this.totalCount,
    required this.openCount,
    required this.blockedCount,
    required this.payrollReviewCount,
    required this.urgentCount,
    required this.dueThisWeekCount,
    required this.nextAction,
  });

  factory HrActionQueueSummary.fromRequests({
    required List<HrActionRequest> requests,
    required DateTime asOfDate,
  }) {
    final openRequests = requests.where((request) => request.isOpen).toList();
    final blockedCount =
        requests
            .where((request) => request.status == HrActionStatus.blocked)
            .length;
    final payrollReviewCount =
        openRequests.where((request) => request.payrollReviewRequired).length;
    final urgentCount =
        openRequests
            .where((request) => request.priority != HrActionPriority.standard)
            .length;
    final dueThisWeekCount =
        openRequests
            .where((request) => request.daysUntilEffective(asOfDate) <= 7)
            .length;

    return HrActionQueueSummary(
      totalCount: requests.length,
      openCount: openRequests.length,
      blockedCount: blockedCount,
      payrollReviewCount: payrollReviewCount,
      urgentCount: urgentCount,
      dueThisWeekCount: dueThisWeekCount,
      nextAction: _nextQueueAction(
        blockedCount: blockedCount,
        dueThisWeekCount: dueThisWeekCount,
        payrollReviewCount: payrollReviewCount,
      ),
    );
  }
}

String _nextQueueAction({
  required int blockedCount,
  required int dueThisWeekCount,
  required int payrollReviewCount,
}) {
  if (blockedCount > 0) {
    return 'Resolve blocked HR action before payroll cutoff.';
  }
  if (dueThisWeekCount > 0) {
    return 'Review effective dates due this week.';
  }
  if (payrollReviewCount > 0) {
    return 'Validate payroll-impacting actions.';
  }
  return 'Queue is ready for People Ops review.';
}
