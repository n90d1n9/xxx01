import 'payroll_archive_models.dart';
import 'payroll_control_review_models.dart';
import 'payroll_funding_models.dart';
import 'payroll_journal_models.dart';
import 'payroll_liability_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';
import 'payroll_reconciliation_models.dart';

enum PayrollComplianceMilestoneStatus {
  blocked('Blocked'),
  upcoming('Upcoming'),
  dueSoon('Due soon'),
  overdue('Overdue'),
  complete('Complete');

  final String label;

  const PayrollComplianceMilestoneStatus(this.label);
}

class PayrollComplianceMilestone {
  final String id;
  final String title;
  final String owner;
  final DateTime dueDate;
  final String detail;
  final PayrollComplianceMilestoneStatus status;

  const PayrollComplianceMilestone({
    required this.id,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.detail,
    required this.status,
  });

  bool get isComplete => status == PayrollComplianceMilestoneStatus.complete;

  bool get isBlocked => status == PayrollComplianceMilestoneStatus.blocked;

  bool get isDueSoon => status == PayrollComplianceMilestoneStatus.dueSoon;

  bool get isOverdue => status == PayrollComplianceMilestoneStatus.overdue;
}

class PayrollComplianceCalendarSummary {
  final String periodLabel;
  final DateTime asOfDate;
  final List<PayrollComplianceMilestone> milestones;
  final String nextAction;

  const PayrollComplianceCalendarSummary({
    required this.periodLabel,
    required this.asOfDate,
    required this.milestones,
    required this.nextAction,
  });

  factory PayrollComplianceCalendarSummary.fromRun({
    required DateTime asOfDate,
    required PayrollReconciliationSummary reconciliation,
    required PayrollFundingForecastSummary fundingForecast,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollPayslipPackageSummary payslipPackage,
    required PayrollLiabilitySummary liabilities,
    required PayrollJournalPostingSummary journalPosting,
    required PayrollArchivePackageSummary archivePackage,
    required PayrollControlReviewSummary controlReview,
  }) {
    PayrollComplianceMilestone milestone({
      required String id,
      required String title,
      required String owner,
      required DateTime dueDate,
      required String detail,
      required bool complete,
      required bool blocked,
    }) {
      return PayrollComplianceMilestone(
        id: id,
        title: title,
        owner: owner,
        dueDate: dueDate,
        detail: detail,
        status: _statusFor(
          asOfDate: asOfDate,
          dueDate: dueDate,
          complete: complete,
          blocked: blocked,
        ),
      );
    }

    final milestones = [
      milestone(
        id: 'reconciliation-signoff',
        title: 'Reconciliation sign-off',
        owner: 'Finance Partner',
        dueDate: paymentBatch.payDate.subtract(const Duration(days: 5)),
        detail:
            reconciliation.isReviewed
                ? 'Funding and variance review is signed off.'
                : reconciliation.nextAction,
        complete: reconciliation.isReviewed,
        blocked: !reconciliation.canReview && !reconciliation.isReviewed,
      ),
      milestone(
        id: 'funding-readiness',
        title: 'Funding readiness',
        owner: 'Finance Ops',
        dueDate: paymentBatch.payDate.subtract(const Duration(days: 2)),
        detail: fundingForecast.nextAction,
        complete: fundingForecast.status == PayrollFundingStatus.settled,
        blocked: fundingForecast.status == PayrollFundingStatus.shortfall,
      ),
      milestone(
        id: 'payment-release',
        title: 'Payment release',
        owner: 'Finance Ops',
        dueDate: paymentBatch.payDate,
        detail: paymentBatch.nextAction,
        complete: paymentBatch.pendingCount == 0,
        blocked: !paymentBatch.canRelease && paymentBatch.pendingCount > 0,
      ),
      milestone(
        id: 'payslip-publishing',
        title: 'Payslip publishing',
        owner: 'Payroll Ops',
        dueDate: paymentBatch.payDate.add(const Duration(days: 1)),
        detail: payslipPackage.nextAction,
        complete: payslipPackage.pendingCount == 0,
        blocked: !payslipPackage.canPublish && payslipPackage.pendingCount > 0,
      ),
      milestone(
        id: 'liability-remittance',
        title: 'Liability remittance',
        owner: 'Payroll Tax',
        dueDate: liabilities.nextDueLine?.dueDate ?? liabilities.payDate,
        detail: liabilities.nextAction,
        complete: liabilities.pendingCount == 0,
        blocked: !liabilities.canRemit && liabilities.pendingCount > 0,
      ),
      milestone(
        id: 'journal-posting',
        title: 'Journal posting',
        owner: 'Finance Controller',
        dueDate: paymentBatch.payDate.add(const Duration(days: 2)),
        detail: journalPosting.nextAction,
        complete: journalPosting.status == PayrollJournalPostingStatus.posted,
        blocked: !journalPosting.canPost && !journalPosting.isPosted,
      ),
      milestone(
        id: 'archive-package',
        title: 'Archive package',
        owner: 'Payroll Controller',
        dueDate: paymentBatch.payDate.add(const Duration(days: 5)),
        detail: archivePackage.nextAction,
        complete: archivePackage.status == PayrollArchivePackageStatus.archived,
        blocked: !archivePackage.canArchive && !archivePackage.isArchived,
      ),
      milestone(
        id: 'control-review',
        title: 'Control review',
        owner: 'Payroll Controller',
        dueDate: paymentBatch.payDate.add(const Duration(days: 7)),
        detail: controlReview.nextAction,
        complete: controlReview.status == PayrollControlReviewStatus.reviewed,
        blocked: !controlReview.canReview,
      ),
    ]..sort((left, right) => left.dueDate.compareTo(right.dueDate));

    return PayrollComplianceCalendarSummary(
      periodLabel: paymentBatch.periodLabel,
      asOfDate: asOfDate,
      milestones: milestones,
      nextAction: _nextAction(milestones),
    );
  }

  int get completedCount {
    return milestones.where((milestone) => milestone.isComplete).length;
  }

  int get blockedCount {
    return milestones.where((milestone) => milestone.isBlocked).length;
  }

  int get dueSoonCount {
    return milestones.where((milestone) => milestone.isDueSoon).length;
  }

  int get overdueCount {
    return milestones.where((milestone) => milestone.isOverdue).length;
  }
}

PayrollComplianceMilestoneStatus _statusFor({
  required DateTime asOfDate,
  required DateTime dueDate,
  required bool complete,
  required bool blocked,
}) {
  if (complete) return PayrollComplianceMilestoneStatus.complete;
  if (dueDate.isBefore(_dateOnly(asOfDate))) {
    return PayrollComplianceMilestoneStatus.overdue;
  }
  if (blocked) return PayrollComplianceMilestoneStatus.blocked;
  final daysUntilDue = dueDate.difference(_dateOnly(asOfDate)).inDays;
  if (daysUntilDue <= 7) return PayrollComplianceMilestoneStatus.dueSoon;
  return PayrollComplianceMilestoneStatus.upcoming;
}

String _nextAction(List<PayrollComplianceMilestone> milestones) {
  final activeMilestone = milestones.where(
    (milestone) => !milestone.isComplete,
  );
  final next =
      _firstOrNull(activeMilestone.where((milestone) => milestone.isOverdue)) ??
      _firstOrNull(activeMilestone.where((milestone) => milestone.isBlocked)) ??
      _firstOrNull(activeMilestone);
  if (next == null) return 'Payroll compliance calendar is complete.';
  return next.detail;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

PayrollComplianceMilestone? _firstOrNull(
  Iterable<PayrollComplianceMilestone> milestones,
) {
  for (final milestone in milestones) {
    return milestone;
  }
  return null;
}
