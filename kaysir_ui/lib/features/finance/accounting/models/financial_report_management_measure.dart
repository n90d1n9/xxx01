enum FinancialReportManagementMeasureApprovalStatus {
  draft,
  inReview,
  approved,
  returned,
}

extension FinancialReportManagementMeasureApprovalStatusLabel
    on FinancialReportManagementMeasureApprovalStatus {
  String get label {
    switch (this) {
      case FinancialReportManagementMeasureApprovalStatus.draft:
        return 'Draft';
      case FinancialReportManagementMeasureApprovalStatus.inReview:
        return 'In review';
      case FinancialReportManagementMeasureApprovalStatus.approved:
        return 'Approved';
      case FinancialReportManagementMeasureApprovalStatus.returned:
        return 'Returned';
    }
  }

  bool get isApproved =>
      this == FinancialReportManagementMeasureApprovalStatus.approved;
}

enum FinancialReportManagementMeasureAuditAction {
  saved,
  submittedForReview,
  approved,
  returned,
  removed,
  reset,
}

extension FinancialReportManagementMeasureAuditActionLabel
    on FinancialReportManagementMeasureAuditAction {
  String get label {
    switch (this) {
      case FinancialReportManagementMeasureAuditAction.saved:
        return 'Saved';
      case FinancialReportManagementMeasureAuditAction.submittedForReview:
        return 'Submitted for review';
      case FinancialReportManagementMeasureAuditAction.approved:
        return 'Approved';
      case FinancialReportManagementMeasureAuditAction.returned:
        return 'Returned';
      case FinancialReportManagementMeasureAuditAction.removed:
        return 'Removed';
      case FinancialReportManagementMeasureAuditAction.reset:
        return 'Reset';
    }
  }
}

FinancialReportManagementMeasureApprovalStatus
_managementMeasureApprovalStatusFromName(String? name) {
  for (final status in FinancialReportManagementMeasureApprovalStatus.values) {
    if (status.name == name) {
      return status;
    }
  }
  return FinancialReportManagementMeasureApprovalStatus.draft;
}

FinancialReportManagementMeasureApprovalStatus?
_nullableManagementMeasureApprovalStatusFromName(String? name) {
  if (name == null) {
    return null;
  }
  for (final status in FinancialReportManagementMeasureApprovalStatus.values) {
    if (status.name == name) {
      return status;
    }
  }
  return null;
}

FinancialReportManagementMeasureAuditAction
_managementMeasureAuditActionFromName(String? name) {
  for (final action in FinancialReportManagementMeasureAuditAction.values) {
    if (action.name == name) {
      return action;
    }
  }
  return FinancialReportManagementMeasureAuditAction.saved;
}

class FinancialReportManagementMeasureAdjustment {
  final String label;
  final double amount;
  final double? comparativeAmount;
  final String sourceReference;
  final String? note;

  const FinancialReportManagementMeasureAdjustment({
    required this.label,
    required this.amount,
    this.comparativeAmount,
    required this.sourceReference,
    this.note,
  });

  factory FinancialReportManagementMeasureAdjustment.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportManagementMeasureAdjustment(
      label: json['label']?.toString() ?? '',
      amount: _doubleFromJson(json['amount']) ?? 0,
      comparativeAmount: _doubleFromJson(json['comparativeAmount']),
      sourceReference: json['sourceReference']?.toString() ?? '',
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'amount': amount,
      if (comparativeAmount != null) 'comparativeAmount': comparativeAmount,
      'sourceReference': sourceReference,
      if (note != null) 'note': note,
    };
  }
}

class FinancialReportManagementMeasure {
  final String id;
  final String label;
  final String closestSubtotalLabel;
  final String closestSubtotalShortLabel;
  final double? amountOverride;
  final double? comparativeAmountOverride;
  final List<FinancialReportManagementMeasureAdjustment> adjustments;
  final String owner;
  final FinancialReportManagementMeasureApprovalStatus approvalStatus;
  final DateTime? reviewedAt;
  final String? reviewNote;

  const FinancialReportManagementMeasure({
    required this.id,
    required this.label,
    this.closestSubtotalLabel = 'Profit (loss) before financing and income tax',
    this.closestSubtotalShortLabel = 'Before financing and tax',
    this.amountOverride,
    this.comparativeAmountOverride,
    this.adjustments = const [],
    required this.owner,
    this.approvalStatus = FinancialReportManagementMeasureApprovalStatus.draft,
    this.reviewedAt,
    this.reviewNote,
  });

  const FinancialReportManagementMeasure.defaultOperatingPerformance()
    : this(
        id: 'uktm-operating-performance',
        label: 'management operating performance',
        owner: 'Financial reporting lead',
        reviewNote:
            'Anchored to the PSAK 118 subtotal with no separate management adjustments.',
      );

  factory FinancialReportManagementMeasure.fromJson(Map<String, dynamic> json) {
    return FinancialReportManagementMeasure(
      id: json['id']?.toString() ?? 'uktm-measure',
      label: json['label']?.toString() ?? 'management measure',
      closestSubtotalLabel:
          json['closestSubtotalLabel']?.toString() ??
          'Profit (loss) before financing and income tax',
      closestSubtotalShortLabel:
          json['closestSubtotalShortLabel']?.toString() ??
          'Before financing and tax',
      amountOverride: _doubleFromJson(json['amountOverride']),
      comparativeAmountOverride: _doubleFromJson(
        json['comparativeAmountOverride'],
      ),
      adjustments: _adjustmentsFromJson(json['adjustments']),
      owner: json['owner']?.toString() ?? 'Financial reporting lead',
      approvalStatus: _managementMeasureApprovalStatusFromName(
        json['approvalStatus']?.toString(),
      ),
      reviewedAt: _dateTimeFromJson(json['reviewedAt']),
      reviewNote: json['reviewNote']?.toString(),
    );
  }

  FinancialReportManagementMeasure copyWith({
    String? id,
    String? label,
    String? closestSubtotalLabel,
    String? closestSubtotalShortLabel,
    double? amountOverride,
    double? comparativeAmountOverride,
    List<FinancialReportManagementMeasureAdjustment>? adjustments,
    String? owner,
    FinancialReportManagementMeasureApprovalStatus? approvalStatus,
    DateTime? reviewedAt,
    String? reviewNote,
    bool clearAmountOverride = false,
    bool clearComparativeAmountOverride = false,
    bool clearReviewedAt = false,
    bool clearReviewNote = false,
  }) {
    return FinancialReportManagementMeasure(
      id: id ?? this.id,
      label: label ?? this.label,
      closestSubtotalLabel: closestSubtotalLabel ?? this.closestSubtotalLabel,
      closestSubtotalShortLabel:
          closestSubtotalShortLabel ?? this.closestSubtotalShortLabel,
      amountOverride:
          clearAmountOverride ? null : amountOverride ?? this.amountOverride,
      comparativeAmountOverride:
          clearComparativeAmountOverride
              ? null
              : comparativeAmountOverride ?? this.comparativeAmountOverride,
      adjustments: adjustments ?? this.adjustments,
      owner: owner ?? this.owner,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      reviewedAt: clearReviewedAt ? null : reviewedAt ?? this.reviewedAt,
      reviewNote: clearReviewNote ? null : reviewNote ?? this.reviewNote,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'closestSubtotalLabel': closestSubtotalLabel,
      'closestSubtotalShortLabel': closestSubtotalShortLabel,
      if (amountOverride != null) 'amountOverride': amountOverride,
      if (comparativeAmountOverride != null)
        'comparativeAmountOverride': comparativeAmountOverride,
      'adjustments':
          adjustments.map((adjustment) => adjustment.toJson()).toList(),
      'owner': owner,
      'approvalStatus': approvalStatus.name,
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
      if (reviewNote != null) 'reviewNote': reviewNote,
    };
  }
}

class FinancialReportManagementMeasureReconciliation {
  final FinancialReportManagementMeasure measure;
  final double subtotalAmount;
  final double? comparativeSubtotalAmount;
  final double measureAmount;
  final double? comparativeMeasureAmount;
  final double adjustmentTotal;
  final double? comparativeAdjustmentTotal;

  const FinancialReportManagementMeasureReconciliation({
    required this.measure,
    required this.subtotalAmount,
    this.comparativeSubtotalAmount,
    required this.measureAmount,
    this.comparativeMeasureAmount,
    required this.adjustmentTotal,
    this.comparativeAdjustmentTotal,
  });

  double get variance => measureAmount - subtotalAmount - adjustmentTotal;

  double? get comparativeVariance {
    final comparativeSubtotal = comparativeSubtotalAmount;
    final comparativeMeasure = comparativeMeasureAmount;
    final comparativeAdjustments = comparativeAdjustmentTotal;
    if (comparativeSubtotal == null ||
        comparativeMeasure == null ||
        comparativeAdjustments == null) {
      return null;
    }
    return comparativeMeasure - comparativeSubtotal - comparativeAdjustments;
  }

  bool get isBalanced => variance.abs() < 0.01;

  bool get hasOpenVariance =>
      !isBalanced || ((comparativeVariance?.abs() ?? 0) >= 0.01);

  bool get isApproved => measure.approvalStatus.isApproved;
}

class FinancialReportManagementMeasureAuditEvent {
  final String id;
  final String periodKey;
  final String periodLabel;
  final String measureId;
  final String measureLabel;
  final FinancialReportManagementMeasureAuditAction action;
  final DateTime occurredAt;
  final String actor;
  final FinancialReportManagementMeasureApprovalStatus? status;
  final String note;

  const FinancialReportManagementMeasureAuditEvent({
    required this.id,
    required this.periodKey,
    required this.periodLabel,
    required this.measureId,
    required this.measureLabel,
    required this.action,
    required this.occurredAt,
    required this.actor,
    this.status,
    required this.note,
  });

  factory FinancialReportManagementMeasureAuditEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportManagementMeasureAuditEvent(
      id: json['id']?.toString() ?? '',
      periodKey: json['periodKey']?.toString() ?? '',
      periodLabel: json['periodLabel']?.toString() ?? '',
      measureId: json['measureId']?.toString() ?? '',
      measureLabel: json['measureLabel']?.toString() ?? '',
      action: _managementMeasureAuditActionFromName(json['action']?.toString()),
      occurredAt: _dateTimeFromJson(json['occurredAt']) ?? DateTime.now(),
      actor: json['actor']?.toString() ?? '',
      status: _nullableManagementMeasureApprovalStatusFromName(
        json['status']?.toString(),
      ),
      note: json['note']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodKey': periodKey,
      'periodLabel': periodLabel,
      'measureId': measureId,
      'measureLabel': measureLabel,
      'action': action.name,
      'occurredAt': occurredAt.toIso8601String(),
      'actor': actor,
      if (status != null) 'status': status!.name,
      'note': note,
    };
  }
}

List<FinancialReportManagementMeasureAdjustment> _adjustmentsFromJson(
  Object? value,
) {
  if (value is! Iterable) {
    return const [];
  }
  return [
    for (final item in value)
      if (_asJsonMap(item) case final json?)
        FinancialReportManagementMeasureAdjustment.fromJson(json),
  ];
}

double? _doubleFromJson(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

Map<String, dynamic>? _asJsonMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}
