enum FinancialPeriodCloseStatus { open, closed, reopened }

extension FinancialPeriodCloseStatusLabel on FinancialPeriodCloseStatus {
  String get label {
    switch (this) {
      case FinancialPeriodCloseStatus.open:
        return 'Open';
      case FinancialPeriodCloseStatus.closed:
        return 'Closed';
      case FinancialPeriodCloseStatus.reopened:
        return 'Reopened';
    }
  }
}

class FinancialPeriodCloseRecord {
  final String periodKey;
  final String periodLabel;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final FinancialPeriodCloseStatus status;
  final DateTime? closedAt;
  final String? closedBy;
  final DateTime? reopenedAt;
  final String? reopenedBy;
  final String? reopenReason;
  final double checklistReadinessRatio;
  final int blockerCount;
  final DateTime reportGeneratedAt;
  final String? reportPackageHash;
  final String? reportPackageHashAlgorithm;
  final String? closingEntryPostingId;
  final String? closingEntryReference;
  final DateTime? closingEntryPostedAt;

  const FinancialPeriodCloseRecord({
    required this.periodKey,
    required this.periodLabel,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.closedAt,
    required this.closedBy,
    required this.reopenedAt,
    required this.reopenedBy,
    required this.reopenReason,
    required this.checklistReadinessRatio,
    required this.blockerCount,
    required this.reportGeneratedAt,
    this.reportPackageHash,
    this.reportPackageHashAlgorithm,
    this.closingEntryPostingId,
    this.closingEntryReference,
    this.closingEntryPostedAt,
  });

  factory FinancialPeriodCloseRecord.fromJson(Map<String, dynamic> json) {
    return FinancialPeriodCloseRecord(
      periodKey: json['periodKey'] as String,
      periodLabel: json['periodLabel'] as String,
      periodStart: _dateTimeFromJson(json['periodStart']),
      periodEnd: _dateTimeFromJson(json['periodEnd']),
      status: _statusFromJson(json['status'] as String?),
      closedAt: _dateTimeFromJson(json['closedAt']),
      closedBy: json['closedBy'] as String?,
      reopenedAt: _dateTimeFromJson(json['reopenedAt']),
      reopenedBy: json['reopenedBy'] as String?,
      reopenReason: json['reopenReason'] as String?,
      checklistReadinessRatio:
          (json['checklistReadinessRatio'] as num?)?.toDouble() ?? 0,
      blockerCount: (json['blockerCount'] as num?)?.toInt() ?? 0,
      reportGeneratedAt:
          _dateTimeFromJson(json['reportGeneratedAt']) ?? DateTime.now(),
      reportPackageHash: json['reportPackageHash'] as String?,
      reportPackageHashAlgorithm: json['reportPackageHashAlgorithm'] as String?,
      closingEntryPostingId: json['closingEntryPostingId'] as String?,
      closingEntryReference: json['closingEntryReference'] as String?,
      closingEntryPostedAt: _dateTimeFromJson(json['closingEntryPostedAt']),
    );
  }

  bool get isClosed => status == FinancialPeriodCloseStatus.closed;

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

  bool covers(DateTime date) {
    final startsAfter = periodStart == null || !date.isBefore(periodStart!);
    final endsBefore =
        periodEnd == null ||
        date.isBefore(periodEnd!.add(const Duration(days: 1)));
    return startsAfter && endsBefore;
  }

  FinancialPeriodCloseRecord copyWith({
    DateTime? periodStart,
    DateTime? periodEnd,
    FinancialPeriodCloseStatus? status,
    DateTime? closedAt,
    String? closedBy,
    DateTime? reopenedAt,
    String? reopenedBy,
    String? reopenReason,
    double? checklistReadinessRatio,
    int? blockerCount,
    DateTime? reportGeneratedAt,
    String? reportPackageHash,
    String? reportPackageHashAlgorithm,
    String? closingEntryPostingId,
    String? closingEntryReference,
    DateTime? closingEntryPostedAt,
  }) {
    return FinancialPeriodCloseRecord(
      periodKey: periodKey,
      periodLabel: periodLabel,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      status: status ?? this.status,
      closedAt: closedAt ?? this.closedAt,
      closedBy: closedBy ?? this.closedBy,
      reopenedAt: reopenedAt ?? this.reopenedAt,
      reopenedBy: reopenedBy ?? this.reopenedBy,
      reopenReason: reopenReason ?? this.reopenReason,
      checklistReadinessRatio:
          checklistReadinessRatio ?? this.checklistReadinessRatio,
      blockerCount: blockerCount ?? this.blockerCount,
      reportGeneratedAt: reportGeneratedAt ?? this.reportGeneratedAt,
      reportPackageHash: reportPackageHash ?? this.reportPackageHash,
      reportPackageHashAlgorithm:
          reportPackageHashAlgorithm ?? this.reportPackageHashAlgorithm,
      closingEntryPostingId:
          closingEntryPostingId ?? this.closingEntryPostingId,
      closingEntryReference:
          closingEntryReference ?? this.closingEntryReference,
      closingEntryPostedAt: closingEntryPostedAt ?? this.closingEntryPostedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodKey': periodKey,
      'periodLabel': periodLabel,
      'periodStart': periodStart?.toIso8601String(),
      'periodEnd': periodEnd?.toIso8601String(),
      'status': status.name,
      'closedAt': closedAt?.toIso8601String(),
      'closedBy': closedBy,
      'reopenedAt': reopenedAt?.toIso8601String(),
      'reopenedBy': reopenedBy,
      'reopenReason': reopenReason,
      'checklistReadinessRatio': checklistReadinessRatio,
      'blockerCount': blockerCount,
      'reportGeneratedAt': reportGeneratedAt.toIso8601String(),
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

FinancialPeriodCloseStatus _statusFromJson(String? value) {
  switch (value) {
    case 'closed':
      return FinancialPeriodCloseStatus.closed;
    case 'reopened':
      return FinancialPeriodCloseStatus.reopened;
    case 'open':
    default:
      return FinancialPeriodCloseStatus.open;
  }
}
