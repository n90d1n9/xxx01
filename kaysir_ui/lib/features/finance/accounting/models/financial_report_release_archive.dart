enum FinancialReportReleaseArchiveStatus { blocked, ready, archived }

extension FinancialReportReleaseArchiveStatusLabel
    on FinancialReportReleaseArchiveStatus {
  String get label {
    switch (this) {
      case FinancialReportReleaseArchiveStatus.blocked:
        return 'Evidence incomplete';
      case FinancialReportReleaseArchiveStatus.ready:
        return 'Ready to archive';
      case FinancialReportReleaseArchiveStatus.archived:
        return 'Archived';
    }
  }
}

enum FinancialReportReleaseArchiveAuditAction {
  archived,
  retentionReviewed,
  disposalReviewRequested,
  cleared,
}

extension FinancialReportReleaseArchiveAuditActionLabel
    on FinancialReportReleaseArchiveAuditAction {
  String get label {
    switch (this) {
      case FinancialReportReleaseArchiveAuditAction.archived:
        return 'Archived';
      case FinancialReportReleaseArchiveAuditAction.retentionReviewed:
        return 'Retention reviewed';
      case FinancialReportReleaseArchiveAuditAction.disposalReviewRequested:
        return 'Disposal review requested';
      case FinancialReportReleaseArchiveAuditAction.cleared:
        return 'Cleared';
    }
  }
}

class FinancialReportReleaseArchiveRecord {
  final String periodKey;
  final String periodLabel;
  final String archiveId;
  final DateTime archivedAt;
  final String archivedBy;
  final String custodian;
  final String storageLocation;
  final String retentionPolicy;
  final DateTime retainUntil;
  final String packageFingerprint;
  final String packageFingerprintAlgorithm;
  final int evidenceItemCount;
  final String note;

  const FinancialReportReleaseArchiveRecord({
    required this.periodKey,
    required this.periodLabel,
    required this.archiveId,
    required this.archivedAt,
    required this.archivedBy,
    required this.custodian,
    required this.storageLocation,
    required this.retentionPolicy,
    required this.retainUntil,
    required this.packageFingerprint,
    required this.packageFingerprintAlgorithm,
    required this.evidenceItemCount,
    required this.note,
  });

  factory FinancialReportReleaseArchiveRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportReleaseArchiveRecord(
      periodKey: json['periodKey'] as String? ?? '',
      periodLabel: json['periodLabel'] as String? ?? '',
      archiveId: json['archiveId'] as String? ?? '',
      archivedAt: _dateTimeFromJson(json['archivedAt']) ?? DateTime.now(),
      archivedBy: json['archivedBy'] as String? ?? '',
      custodian: json['custodian'] as String? ?? '',
      storageLocation: json['storageLocation'] as String? ?? '',
      retentionPolicy: json['retentionPolicy'] as String? ?? '',
      retainUntil: _dateTimeFromJson(json['retainUntil']) ?? DateTime.now(),
      packageFingerprint: json['packageFingerprint'] as String? ?? '',
      packageFingerprintAlgorithm:
          json['packageFingerprintAlgorithm'] as String? ?? '',
      evidenceItemCount: (json['evidenceItemCount'] as num?)?.toInt() ?? 0,
      note: json['note'] as String? ?? '',
    );
  }

  String get shortFingerprint {
    if (packageFingerprint.length <= 12) {
      return packageFingerprint.toUpperCase();
    }
    return packageFingerprint.substring(0, 12).toUpperCase();
  }

  bool isRetentionActive(DateTime asOf) {
    return !asOf.isAfter(retainUntil);
  }

  Map<String, dynamic> toJson() {
    return {
      'periodKey': periodKey,
      'periodLabel': periodLabel,
      'archiveId': archiveId,
      'archivedAt': archivedAt.toIso8601String(),
      'archivedBy': archivedBy,
      'custodian': custodian,
      'storageLocation': storageLocation,
      'retentionPolicy': retentionPolicy,
      'retainUntil': retainUntil.toIso8601String(),
      'packageFingerprint': packageFingerprint,
      'packageFingerprintAlgorithm': packageFingerprintAlgorithm,
      'evidenceItemCount': evidenceItemCount,
      'note': note,
    };
  }
}

class FinancialReportReleaseArchiveSummary {
  final String periodKey;
  final String periodLabel;
  final FinancialReportReleaseArchiveStatus status;
  final FinancialReportReleaseArchiveRecord? record;
  final bool evidenceReady;
  final int evidenceItemCount;
  final int readyEvidenceCount;
  final String nextAction;

  const FinancialReportReleaseArchiveSummary({
    required this.periodKey,
    required this.periodLabel,
    required this.status,
    required this.record,
    required this.evidenceReady,
    required this.evidenceItemCount,
    required this.readyEvidenceCount,
    required this.nextAction,
  });

  bool get isArchived => record != null;

  bool get canArchive =>
      status == FinancialReportReleaseArchiveStatus.ready && record == null;
}

class FinancialReportReleaseArchiveAuditEvent {
  final String id;
  final String periodKey;
  final String periodLabel;
  final String? archiveId;
  final FinancialReportReleaseArchiveAuditAction action;
  final DateTime occurredAt;
  final String actor;
  final String? custodian;
  final String? storageLocation;
  final String? retentionPolicy;
  final DateTime? retainUntil;
  final DateTime? nextReviewDate;
  final String? packageFingerprint;
  final String note;

  const FinancialReportReleaseArchiveAuditEvent({
    required this.id,
    required this.periodKey,
    required this.periodLabel,
    required this.archiveId,
    required this.action,
    required this.occurredAt,
    required this.actor,
    this.custodian,
    this.storageLocation,
    this.retentionPolicy,
    this.retainUntil,
    this.nextReviewDate,
    this.packageFingerprint,
    required this.note,
  });

  factory FinancialReportReleaseArchiveAuditEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportReleaseArchiveAuditEvent(
      id: json['id'] as String? ?? '',
      periodKey: json['periodKey'] as String? ?? '',
      periodLabel: json['periodLabel'] as String? ?? '',
      archiveId: json['archiveId'] as String?,
      action: _auditActionFromJson(json['action'] as String?),
      occurredAt: _dateTimeFromJson(json['occurredAt']) ?? DateTime.now(),
      actor: json['actor'] as String? ?? '',
      custodian: json['custodian'] as String?,
      storageLocation: json['storageLocation'] as String?,
      retentionPolicy: json['retentionPolicy'] as String?,
      retainUntil: _dateTimeFromJson(json['retainUntil']),
      nextReviewDate: _dateTimeFromJson(json['nextReviewDate']),
      packageFingerprint: json['packageFingerprint'] as String?,
      note: json['note'] as String? ?? '',
    );
  }

  String get shortFingerprint {
    final fingerprint = packageFingerprint;
    if (fingerprint == null || fingerprint.isEmpty) {
      return '';
    }
    if (fingerprint.length <= 12) {
      return fingerprint.toUpperCase();
    }
    return fingerprint.substring(0, 12).toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodKey': periodKey,
      'periodLabel': periodLabel,
      'archiveId': archiveId,
      'action': action.name,
      'occurredAt': occurredAt.toIso8601String(),
      'actor': actor,
      'custodian': custodian,
      'storageLocation': storageLocation,
      'retentionPolicy': retentionPolicy,
      'retainUntil': retainUntil?.toIso8601String(),
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'packageFingerprint': packageFingerprint,
      'note': note,
    };
  }
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value as String);
}

FinancialReportReleaseArchiveAuditAction _auditActionFromJson(String? value) {
  switch (value) {
    case 'retentionReviewed':
      return FinancialReportReleaseArchiveAuditAction.retentionReviewed;
    case 'disposalReviewRequested':
      return FinancialReportReleaseArchiveAuditAction.disposalReviewRequested;
    case 'cleared':
      return FinancialReportReleaseArchiveAuditAction.cleared;
    case 'archived':
    default:
      return FinancialReportReleaseArchiveAuditAction.archived;
  }
}
