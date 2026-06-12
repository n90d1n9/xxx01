enum FinancialReportReleaseSignOffRole { preparer, reviewer, approver }

extension FinancialReportReleaseSignOffRoleLabel
    on FinancialReportReleaseSignOffRole {
  String get label {
    switch (this) {
      case FinancialReportReleaseSignOffRole.preparer:
        return 'Preparer';
      case FinancialReportReleaseSignOffRole.reviewer:
        return 'Reviewer';
      case FinancialReportReleaseSignOffRole.approver:
        return 'Approver';
    }
  }
}

enum FinancialReportReleaseSignOffStatus { signed, returned }

extension FinancialReportReleaseSignOffStatusLabel
    on FinancialReportReleaseSignOffStatus {
  String get label {
    switch (this) {
      case FinancialReportReleaseSignOffStatus.signed:
        return 'Signed';
      case FinancialReportReleaseSignOffStatus.returned:
        return 'Returned';
    }
  }
}

enum FinancialReportReleaseSignOffAuditAction { signed, returned, cleared }

extension FinancialReportReleaseSignOffAuditActionLabel
    on FinancialReportReleaseSignOffAuditAction {
  String get label {
    switch (this) {
      case FinancialReportReleaseSignOffAuditAction.signed:
        return 'Signed';
      case FinancialReportReleaseSignOffAuditAction.returned:
        return 'Returned';
      case FinancialReportReleaseSignOffAuditAction.cleared:
        return 'Cleared';
    }
  }
}

class FinancialReportReleaseSignOffRequirement {
  final String id;
  final FinancialReportReleaseSignOffRole role;
  final String title;
  final String description;
  final String owner;
  final String reference;
  final bool requiredBeforeRelease;

  const FinancialReportReleaseSignOffRequirement({
    required this.id,
    required this.role,
    required this.title,
    required this.description,
    required this.owner,
    required this.reference,
    this.requiredBeforeRelease = true,
  });
}

class FinancialReportReleaseSignOffResolution {
  final String requirementId;
  final FinancialReportReleaseSignOffStatus status;
  final String signer;
  final DateTime signedAt;
  final String note;
  final String? evidenceReference;

  const FinancialReportReleaseSignOffResolution({
    required this.requirementId,
    required this.status,
    required this.signer,
    required this.signedAt,
    required this.note,
    this.evidenceReference,
  });

  factory FinancialReportReleaseSignOffResolution.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportReleaseSignOffResolution(
      requirementId: json['requirementId'] as String,
      status: _statusFromJson(json['status'] as String?),
      signer: json['signer'] as String? ?? '',
      signedAt: _dateTimeFromJson(json['signedAt']) ?? DateTime.now(),
      note: json['note'] as String? ?? '',
      evidenceReference: json['evidenceReference'] as String?,
    );
  }

  bool get clearsRelease =>
      status == FinancialReportReleaseSignOffStatus.signed;

  Map<String, dynamic> toJson() {
    return {
      'requirementId': requirementId,
      'status': status.name,
      'signer': signer,
      'signedAt': signedAt.toIso8601String(),
      'note': note,
      'evidenceReference': evidenceReference,
    };
  }
}

class FinancialReportReleaseSignOffItem {
  final FinancialReportReleaseSignOffRequirement requirement;
  final FinancialReportReleaseSignOffResolution? resolution;

  const FinancialReportReleaseSignOffItem({
    required this.requirement,
    this.resolution,
  });

  String get id => requirement.id;

  FinancialReportReleaseSignOffRole get role => requirement.role;

  bool get isSigned => resolution?.clearsRelease ?? false;

  bool get isReturned =>
      resolution?.status == FinancialReportReleaseSignOffStatus.returned;

  bool get blocksRelease => requirement.requiredBeforeRelease && !isSigned;

  String get statusLabel => resolution?.status.label ?? 'Pending';
}

class FinancialReportReleaseSignOffAuditEvent {
  final String id;
  final String periodKey;
  final String periodLabel;
  final String requirementId;
  final String requirementTitle;
  final FinancialReportReleaseSignOffRole role;
  final FinancialReportReleaseSignOffAuditAction action;
  final DateTime occurredAt;
  final String actor;
  final FinancialReportReleaseSignOffStatus? status;
  final String note;
  final String? evidenceReference;

  const FinancialReportReleaseSignOffAuditEvent({
    required this.id,
    required this.periodKey,
    required this.periodLabel,
    required this.requirementId,
    required this.requirementTitle,
    required this.role,
    required this.action,
    required this.occurredAt,
    required this.actor,
    this.status,
    required this.note,
    this.evidenceReference,
  });

  factory FinancialReportReleaseSignOffAuditEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportReleaseSignOffAuditEvent(
      id: json['id'] as String? ?? '',
      periodKey: json['periodKey'] as String? ?? '',
      periodLabel: json['periodLabel'] as String? ?? '',
      requirementId: json['requirementId'] as String? ?? '',
      requirementTitle: json['requirementTitle'] as String? ?? '',
      role: _roleFromJson(json['role'] as String?),
      action: _auditActionFromJson(json['action'] as String?),
      occurredAt: _dateTimeFromJson(json['occurredAt']) ?? DateTime.now(),
      actor: json['actor'] as String? ?? '',
      status: _nullableStatusFromJson(json['status'] as String?),
      note: json['note'] as String? ?? '',
      evidenceReference: json['evidenceReference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodKey': periodKey,
      'periodLabel': periodLabel,
      'requirementId': requirementId,
      'requirementTitle': requirementTitle,
      'role': role.name,
      'action': action.name,
      'occurredAt': occurredAt.toIso8601String(),
      'actor': actor,
      'status': status?.name,
      'note': note,
      'evidenceReference': evidenceReference,
    };
  }
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value as String);
}

FinancialReportReleaseSignOffRole _roleFromJson(String? value) {
  for (final role in FinancialReportReleaseSignOffRole.values) {
    if (role.name == value) {
      return role;
    }
  }
  return FinancialReportReleaseSignOffRole.preparer;
}

FinancialReportReleaseSignOffStatus _statusFromJson(String? value) {
  return _nullableStatusFromJson(value) ??
      FinancialReportReleaseSignOffStatus.signed;
}

FinancialReportReleaseSignOffStatus? _nullableStatusFromJson(String? value) {
  switch (value) {
    case 'returned':
      return FinancialReportReleaseSignOffStatus.returned;
    case 'signed':
      return FinancialReportReleaseSignOffStatus.signed;
    default:
      return null;
  }
}

FinancialReportReleaseSignOffAuditAction _auditActionFromJson(String? value) {
  switch (value) {
    case 'returned':
      return FinancialReportReleaseSignOffAuditAction.returned;
    case 'cleared':
      return FinancialReportReleaseSignOffAuditAction.cleared;
    case 'signed':
    default:
      return FinancialReportReleaseSignOffAuditAction.signed;
  }
}
