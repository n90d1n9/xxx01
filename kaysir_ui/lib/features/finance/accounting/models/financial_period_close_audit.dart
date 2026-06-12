enum FinancialPeriodCloseAuditAction { closed, reopened }

extension FinancialPeriodCloseAuditActionLabel
    on FinancialPeriodCloseAuditAction {
  String get label {
    switch (this) {
      case FinancialPeriodCloseAuditAction.closed:
        return 'Closed';
      case FinancialPeriodCloseAuditAction.reopened:
        return 'Reopened';
    }
  }
}

class FinancialPeriodCloseAuditEvent {
  final String id;
  final String periodKey;
  final String periodLabel;
  final FinancialPeriodCloseAuditAction action;
  final DateTime occurredAt;
  final String actor;
  final String? reason;
  final double checklistReadinessRatio;
  final int blockerCount;
  final String? reportPackageHash;
  final String? reportPackageHashAlgorithm;
  final String? closingEntryPostingId;
  final String? closingEntryReference;
  final DateTime? closingEntryPostedAt;

  const FinancialPeriodCloseAuditEvent({
    required this.id,
    required this.periodKey,
    required this.periodLabel,
    required this.action,
    required this.occurredAt,
    required this.actor,
    required this.reason,
    required this.checklistReadinessRatio,
    required this.blockerCount,
    this.reportPackageHash,
    this.reportPackageHashAlgorithm,
    this.closingEntryPostingId,
    this.closingEntryReference,
    this.closingEntryPostedAt,
  });

  factory FinancialPeriodCloseAuditEvent.fromJson(Map<String, dynamic> json) {
    return FinancialPeriodCloseAuditEvent(
      id: json['id'] as String,
      periodKey: json['periodKey'] as String,
      periodLabel: json['periodLabel'] as String,
      action: _actionFromJson(json['action'] as String?),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      actor: json['actor'] as String? ?? 'Unknown',
      reason: json['reason'] as String?,
      checklistReadinessRatio:
          (json['checklistReadinessRatio'] as num?)?.toDouble() ?? 0,
      blockerCount: (json['blockerCount'] as num?)?.toInt() ?? 0,
      reportPackageHash: json['reportPackageHash'] as String?,
      reportPackageHashAlgorithm: json['reportPackageHashAlgorithm'] as String?,
      closingEntryPostingId: json['closingEntryPostingId'] as String?,
      closingEntryReference: json['closingEntryReference'] as String?,
      closingEntryPostedAt: _dateTimeFromJson(json['closingEntryPostedAt']),
    );
  }

  String? get reportPackageShortHash {
    final hash = reportPackageHash;
    if (hash == null || hash.isEmpty) {
      return null;
    }
    if (hash.length <= 12) {
      return hash.toUpperCase();
    }
    return hash.substring(0, 12).toUpperCase();
  }

  String? get closingEntryEvidenceLabel {
    final reference = closingEntryReference;
    if (reference != null && reference.trim().isNotEmpty) {
      return reference;
    }
    final postingId = closingEntryPostingId;
    if (postingId != null && postingId.trim().isNotEmpty) {
      return postingId;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodKey': periodKey,
      'periodLabel': periodLabel,
      'action': action.name,
      'occurredAt': occurredAt.toIso8601String(),
      'actor': actor,
      'reason': reason,
      'checklistReadinessRatio': checklistReadinessRatio,
      'blockerCount': blockerCount,
      'reportPackageHash': reportPackageHash,
      'reportPackageHashAlgorithm': reportPackageHashAlgorithm,
      'closingEntryPostingId': closingEntryPostingId,
      'closingEntryReference': closingEntryReference,
      'closingEntryPostedAt': closingEntryPostedAt?.toIso8601String(),
    };
  }
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String);
}

FinancialPeriodCloseAuditAction _actionFromJson(String? value) {
  switch (value) {
    case 'reopened':
      return FinancialPeriodCloseAuditAction.reopened;
    case 'closed':
    default:
      return FinancialPeriodCloseAuditAction.closed;
  }
}
