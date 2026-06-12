import '../models/financial_report_release_archive.dart';
import '../models/financial_report_release_archive_retention.dart';

class FinancialReportReleaseArchiveRetentionService {
  static const defaultReviewWindowDays = 90;
  static const reviewFrequencyYears = 1;

  const FinancialReportReleaseArchiveRetentionService();

  FinancialReportReleaseArchiveRetentionSummary summarize({
    required String periodKey,
    required String periodLabel,
    required FinancialReportReleaseArchiveRecord? record,
    required DateTime asOf,
    Iterable<FinancialReportReleaseArchiveAuditEvent> auditEvents = const [],
    int reviewWindowDays = defaultReviewWindowDays,
  }) {
    final asOfDate = _dateOnly(asOf);
    if (record == null) {
      return FinancialReportReleaseArchiveRetentionSummary(
        periodKey: periodKey,
        periodLabel: periodLabel,
        status: FinancialReportReleaseArchiveRetentionStatus.notArchived,
        record: null,
        asOf: asOfDate,
        retainUntil: null,
        nextReviewDate: null,
        lastReviewAt: null,
        lastReviewActor: null,
        daysRemaining: null,
        daysUntilReview: null,
        reviewWindowDays: reviewWindowDays,
        nextAction:
            'Create the release archive register before retention monitoring starts.',
        checkpoints: const [],
      );
    }

    final retainUntil = _dateOnly(record.retainUntil);
    final daysRemaining = retainUntil.difference(asOfDate).inDays;
    final latestReview = _latestRetentionReview(auditEvents);
    final nextReviewDate = _nextReviewDate(record, asOfDate, latestReview);
    final daysUntilReview = nextReviewDate.difference(asOfDate).inDays;
    final status = _status(
      daysRemaining: daysRemaining,
      daysUntilReview: daysUntilReview,
      reviewWindowDays: reviewWindowDays,
    );

    return FinancialReportReleaseArchiveRetentionSummary(
      periodKey: periodKey,
      periodLabel: periodLabel,
      status: status,
      record: record,
      asOf: asOfDate,
      retainUntil: retainUntil,
      nextReviewDate: nextReviewDate,
      lastReviewAt:
          latestReview == null ? null : _dateOnly(latestReview.occurredAt),
      lastReviewActor: latestReview?.actor,
      daysRemaining: daysRemaining,
      daysUntilReview: daysUntilReview,
      reviewWindowDays: reviewWindowDays,
      nextAction: _nextAction(
        status: status,
        record: record,
        daysRemaining: daysRemaining,
        daysUntilReview: daysUntilReview,
        reviewWindowDays: reviewWindowDays,
      ),
      checkpoints: _checkpoints(
        record: record,
        retainUntil: retainUntil,
        nextReviewDate: nextReviewDate,
        daysRemaining: daysRemaining,
        daysUntilReview: daysUntilReview,
        reviewWindowDays: reviewWindowDays,
        status: status,
      ),
    );
  }

  FinancialReportReleaseArchiveRetentionStatus _status({
    required int daysRemaining,
    required int daysUntilReview,
    required int reviewWindowDays,
  }) {
    if (daysRemaining < 0) {
      return FinancialReportReleaseArchiveRetentionStatus.expired;
    }
    if (daysRemaining <= reviewWindowDays ||
        daysUntilReview <= reviewWindowDays) {
      return FinancialReportReleaseArchiveRetentionStatus.reviewDue;
    }
    return FinancialReportReleaseArchiveRetentionStatus.active;
  }

  String _nextAction({
    required FinancialReportReleaseArchiveRetentionStatus status,
    required FinancialReportReleaseArchiveRecord record,
    required int daysRemaining,
    required int daysUntilReview,
    required int reviewWindowDays,
  }) {
    switch (status) {
      case FinancialReportReleaseArchiveRetentionStatus.notArchived:
        return 'Create the release archive register before retention monitoring starts.';
      case FinancialReportReleaseArchiveRetentionStatus.active:
        return 'Archive custody is current; next retention review is due in $daysUntilReview day(s).';
      case FinancialReportReleaseArchiveRetentionStatus.reviewDue:
        if (daysRemaining <= 0) {
          return '${record.archiveId} reaches the retention deadline today.';
        }
        if (daysRemaining <= reviewWindowDays) {
          return '${record.archiveId} is within $daysRemaining day(s) of the retention deadline.';
        }
        return '${record.archiveId} is due for custody review in $daysUntilReview day(s).';
      case FinancialReportReleaseArchiveRetentionStatus.expired:
        return '${record.archiveId} passed its retention deadline by ${daysRemaining.abs()} day(s). Review disposal or extended hold.';
    }
  }

  List<FinancialReportReleaseArchiveRetentionCheckpoint> _checkpoints({
    required FinancialReportReleaseArchiveRecord record,
    required DateTime retainUntil,
    required DateTime nextReviewDate,
    required int daysRemaining,
    required int daysUntilReview,
    required int reviewWindowDays,
    required FinancialReportReleaseArchiveRetentionStatus status,
  }) {
    return [
      FinancialReportReleaseArchiveRetentionCheckpoint(
        title: 'Custodian',
        value: record.custodian,
        detail: record.storageLocation,
        status: FinancialReportReleaseArchiveRetentionStatus.active,
      ),
      FinancialReportReleaseArchiveRetentionCheckpoint(
        title: 'Next review',
        value: _dateLabel(nextReviewDate),
        detail: '$daysUntilReview day(s) remaining',
        status:
            daysUntilReview <= reviewWindowDays
                ? FinancialReportReleaseArchiveRetentionStatus.reviewDue
                : FinancialReportReleaseArchiveRetentionStatus.active,
      ),
      FinancialReportReleaseArchiveRetentionCheckpoint(
        title: 'Retention deadline',
        value: _dateLabel(retainUntil),
        detail:
            daysRemaining < 0
                ? '${daysRemaining.abs()} day(s) overdue'
                : '$daysRemaining day(s) remaining',
        status: status,
      ),
    ];
  }

  FinancialReportReleaseArchiveAuditEvent? _latestRetentionReview(
    Iterable<FinancialReportReleaseArchiveAuditEvent> auditEvents,
  ) {
    final reviews =
        auditEvents
            .where(
              (event) =>
                  event.action ==
                  FinancialReportReleaseArchiveAuditAction.retentionReviewed,
            )
            .toList()
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return reviews.isEmpty ? null : reviews.first;
  }

  DateTime _nextReviewDate(
    FinancialReportReleaseArchiveRecord record,
    DateTime asOf,
    FinancialReportReleaseArchiveAuditEvent? latestReview,
  ) {
    final reviewBase = latestReview?.occurredAt ?? record.archivedAt;
    var reviewDate = _addYears(_dateOnly(reviewBase), reviewFrequencyYears);
    while (reviewDate.isBefore(asOf)) {
      reviewDate = _addYears(reviewDate, reviewFrequencyYears);
    }
    final retainUntil = _dateOnly(record.retainUntil);
    return reviewDate.isAfter(retainUntil) ? retainUntil : reviewDate;
  }

  DateTime _addYears(DateTime date, int years) {
    final target = DateTime(date.year + years, date.month, date.day);
    if (target.month != date.month) {
      return DateTime(date.year + years, date.month + 1, 0);
    }
    return target;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dateLabel(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
