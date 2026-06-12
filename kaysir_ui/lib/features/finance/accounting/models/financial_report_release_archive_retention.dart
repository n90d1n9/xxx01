import 'financial_report_release_archive.dart';

enum FinancialReportReleaseArchiveRetentionStatus {
  notArchived,
  active,
  reviewDue,
  expired,
}

extension FinancialReportReleaseArchiveRetentionStatusLabel
    on FinancialReportReleaseArchiveRetentionStatus {
  String get label {
    switch (this) {
      case FinancialReportReleaseArchiveRetentionStatus.notArchived:
        return 'Not archived';
      case FinancialReportReleaseArchiveRetentionStatus.active:
        return 'Retention active';
      case FinancialReportReleaseArchiveRetentionStatus.reviewDue:
        return 'Review due';
      case FinancialReportReleaseArchiveRetentionStatus.expired:
        return 'Retention expired';
    }
  }
}

class FinancialReportReleaseArchiveRetentionCheckpoint {
  final String title;
  final String value;
  final String detail;
  final FinancialReportReleaseArchiveRetentionStatus status;

  const FinancialReportReleaseArchiveRetentionCheckpoint({
    required this.title,
    required this.value,
    required this.detail,
    required this.status,
  });
}

class FinancialReportReleaseArchiveRetentionSummary {
  final String periodKey;
  final String periodLabel;
  final FinancialReportReleaseArchiveRetentionStatus status;
  final FinancialReportReleaseArchiveRecord? record;
  final DateTime asOf;
  final DateTime? retainUntil;
  final DateTime? nextReviewDate;
  final DateTime? lastReviewAt;
  final String? lastReviewActor;
  final int? daysRemaining;
  final int? daysUntilReview;
  final int reviewWindowDays;
  final String nextAction;
  final List<FinancialReportReleaseArchiveRetentionCheckpoint> checkpoints;

  const FinancialReportReleaseArchiveRetentionSummary({
    required this.periodKey,
    required this.periodLabel,
    required this.status,
    required this.record,
    required this.asOf,
    required this.retainUntil,
    required this.nextReviewDate,
    this.lastReviewAt,
    this.lastReviewActor,
    required this.daysRemaining,
    required this.daysUntilReview,
    required this.reviewWindowDays,
    required this.nextAction,
    required this.checkpoints,
  });

  bool get hasArchive => record != null;

  bool get isCurrent =>
      status == FinancialReportReleaseArchiveRetentionStatus.active ||
      status == FinancialReportReleaseArchiveRetentionStatus.reviewDue;
}
