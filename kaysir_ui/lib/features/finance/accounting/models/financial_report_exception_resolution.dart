import 'financial_report_review_exception.dart';

enum FinancialReportExceptionResolutionStatus { adjusted, approved, deferred }

extension FinancialReportExceptionResolutionStatusLabel
    on FinancialReportExceptionResolutionStatus {
  String get label {
    switch (this) {
      case FinancialReportExceptionResolutionStatus.adjusted:
        return 'Adjusted';
      case FinancialReportExceptionResolutionStatus.approved:
        return 'Approved';
      case FinancialReportExceptionResolutionStatus.deferred:
        return 'Deferred';
    }
  }
}

class FinancialReportExceptionResolution {
  final String exceptionId;
  final FinancialReportExceptionResolutionStatus status;
  final String reviewer;
  final DateTime resolvedAt;
  final String note;
  final String? adjustmentReference;
  final String? adjustmentPostingId;

  const FinancialReportExceptionResolution({
    required this.exceptionId,
    required this.status,
    required this.reviewer,
    required this.resolvedAt,
    required this.note,
    this.adjustmentReference,
    this.adjustmentPostingId,
  });

  factory FinancialReportExceptionResolution.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportExceptionResolution(
      exceptionId: json['exceptionId'] as String,
      status: _statusFromJson(json['status'] as String?),
      reviewer: json['reviewer'] as String? ?? '',
      resolvedAt: _dateTimeFromJson(json['resolvedAt']) ?? DateTime.now(),
      note: json['note'] as String? ?? '',
      adjustmentReference: json['adjustmentReference'] as String?,
      adjustmentPostingId: json['adjustmentPostingId'] as String?,
    );
  }

  bool get clearsCloseBlocker {
    if (status == FinancialReportExceptionResolutionStatus.approved) {
      return true;
    }
    if (status == FinancialReportExceptionResolutionStatus.adjusted) {
      return adjustmentPostingId?.trim().isNotEmpty ?? false;
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'exceptionId': exceptionId,
      'status': status.name,
      'reviewer': reviewer,
      'resolvedAt': resolvedAt.toIso8601String(),
      'note': note,
      'adjustmentReference': adjustmentReference,
      'adjustmentPostingId': adjustmentPostingId,
    };
  }
}

class FinancialReportExceptionReviewItem {
  final FinancialReportReviewException exception;
  final FinancialReportExceptionResolution? resolution;
  final bool adjustmentEvidenceIsPosted;

  const FinancialReportExceptionReviewItem({
    required this.exception,
    this.resolution,
    this.adjustmentEvidenceIsPosted = true,
  });

  String get id => exception.id;

  String get sourceComplianceId => exception.sourceComplianceId;

  bool get isResolved {
    final resolution = this.resolution;
    if (resolution == null) {
      return false;
    }
    if (resolution.status ==
        FinancialReportExceptionResolutionStatus.adjusted) {
      return resolution.clearsCloseBlocker && adjustmentEvidenceIsPosted;
    }
    return resolution.clearsCloseBlocker;
  }

  bool get blocksClose => exception.blocksClose && !isResolved;

  FinancialReportReviewExceptionSeverity get severity => exception.severity;
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String);
}

FinancialReportExceptionResolutionStatus _statusFromJson(String? value) {
  switch (value) {
    case 'adjusted':
      return FinancialReportExceptionResolutionStatus.adjusted;
    case 'deferred':
      return FinancialReportExceptionResolutionStatus.deferred;
    case 'approved':
    default:
      return FinancialReportExceptionResolutionStatus.approved;
  }
}
