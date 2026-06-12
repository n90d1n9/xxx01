import 'package:intl/intl.dart';

import '../models/bank_reconciliation_timing_register.dart';
import '../models/bank_reconciliation_timing_review.dart';

class BankReconciliationTimingReviewEvidenceService {
  const BankReconciliationTimingReviewEvidenceService();

  BankReconciliationTimingReviewSummary summarize({
    required Iterable<BankReconciliationTimingRegisterItem> items,
    required Map<String, BankReconciliationTimingReview> reviews,
  }) {
    return BankReconciliationTimingReviewSummary.fromItems(
      items: items,
      reviews: reviews,
    );
  }

  String sourceLabel({
    required BankReconciliationTimingRegisterItem item,
    BankReconciliationTimingReview? review,
  }) {
    return [
      '${item.bucketLabel} timing difference',
      item.clearanceStatusLabel,
      'Clear by ${_dateLabel(item.clearByDate)}',
      _deadlineLabel(item),
      _reviewLabel(
        review ?? BankReconciliationTimingReview.open(item.reference),
      ),
    ].join(' / ');
  }

  String coverageValue(BankReconciliationTimingReviewSummary summary) {
    return '${summary.coverageLabel} documented / '
        '${summary.resolvedLabel} resolved';
  }

  String gapValue(BankReconciliationTimingReviewSummary summary) {
    return '${summary.unreviewedCount} unreviewed / '
        '${summary.needsOwnerCount} owner gaps / '
        '${summary.unresolvedOverdueCount} overdue unresolved';
  }

  String _reviewLabel(BankReconciliationTimingReview review) {
    return [
      'Review ${review.status.label}',
      'Owner ${review.ownerLabel}',
      if (_hasReviewedAt(review.reviewedAt))
        'Reviewed ${_dateLabel(review.reviewedAt)}',
      review.noteLabel,
    ].join(' / ');
  }

  String _deadlineLabel(BankReconciliationTimingRegisterItem item) {
    if (item.deadlineStatus == BankReconciliationTimingDeadlineStatus.overdue) {
      return item.deadlineStatusLabel;
    }
    return '${item.deadlineStatusLabel} (${item.daysUntilClearByLabel})';
  }

  bool _hasReviewedAt(DateTime reviewedAt) {
    return reviewedAt.isAfter(DateTime.fromMillisecondsSinceEpoch(0));
  }

  String _dateLabel(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
