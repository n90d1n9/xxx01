import 'payroll_adjustment_models.dart';
import 'payroll_compliance_models.dart';
import 'payroll_exception_models.dart';
import 'payroll_funding_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_reconciliation_models.dart';

enum PayrollRiskSeverity {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const PayrollRiskSeverity(this.label);
}

enum PayrollRiskCategory {
  exception('Exception'),
  approval('Approval'),
  funding('Funding'),
  compliance('Compliance'),
  release('Release');

  final String label;

  const PayrollRiskCategory(this.label);
}

class PayrollRiskRegisterItem {
  final String id;
  final String title;
  final PayrollRiskCategory category;
  final PayrollRiskSeverity severity;
  final String owner;
  final DateTime dueDate;
  final String action;
  final String sourceLabel;

  const PayrollRiskRegisterItem({
    required this.id,
    required this.title,
    required this.category,
    required this.severity,
    required this.owner,
    required this.dueDate,
    required this.action,
    required this.sourceLabel,
  });
}

class PayrollRiskRegisterSummary {
  final String periodLabel;
  final DateTime asOfDate;
  final List<PayrollRiskRegisterItem> items;
  final String nextAction;

  const PayrollRiskRegisterSummary({
    required this.periodLabel,
    required this.asOfDate,
    required this.items,
    required this.nextAction,
  });

  factory PayrollRiskRegisterSummary.fromRun({
    required DateTime asOfDate,
    required PayrollReconciliationSummary reconciliation,
    required PayrollFundingForecastSummary fundingForecast,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollComplianceCalendarSummary complianceCalendar,
    required List<PayrollExceptionItem> exceptions,
    required List<PayrollAdjustmentRequest> adjustments,
  }) {
    final items = <PayrollRiskRegisterItem>[
      for (final exception in exceptions.where((exception) => exception.isOpen))
        PayrollRiskRegisterItem(
          id: exception.id,
          title: exception.title,
          category: PayrollRiskCategory.exception,
          severity: _exceptionSeverity(exception.severity),
          owner: exception.owner,
          dueDate: exception.dueDate,
          action: exception.action,
          sourceLabel: exception.employeeName,
        ),
      for (final adjustment in adjustments.where(
        (adjustment) => adjustment.isPending,
      ))
        PayrollRiskRegisterItem(
          id: adjustment.id,
          title: '${adjustment.type.label} approval pending',
          category: PayrollRiskCategory.approval,
          severity: PayrollRiskSeverity.high,
          owner: 'Payroll Manager',
          dueDate: adjustment.effectiveDate,
          action: 'Approve or reject ${adjustment.id} before payroll lock.',
          sourceLabel: adjustment.employeeName,
        ),
      if (fundingForecast.status == PayrollFundingStatus.shortfall)
        PayrollRiskRegisterItem(
          id: 'funding-shortfall',
          title: 'Payroll funding shortfall',
          category: PayrollRiskCategory.funding,
          severity: PayrollRiskSeverity.critical,
          owner: 'Finance Ops',
          dueDate: paymentBatch.payDate.subtract(const Duration(days: 2)),
          action: fundingForecast.nextAction,
          sourceLabel: fundingForecast.accountLabel,
        ),
      if (reconciliation.hasReviewVariance)
        PayrollRiskRegisterItem(
          id: 'variance-review',
          title: 'Payroll variance outside tolerance',
          category: PayrollRiskCategory.compliance,
          severity: PayrollRiskSeverity.critical,
          owner: 'Finance Partner',
          dueDate: paymentBatch.payDate.subtract(const Duration(days: 5)),
          action: reconciliation.nextAction,
          sourceLabel: reconciliation.baselinePeriodLabel,
        ),
      if (paymentBatch.blockedRecipientCount > 0)
        PayrollRiskRegisterItem(
          id: 'blocked-recipients',
          title: 'Payment recipients blocked',
          category: PayrollRiskCategory.release,
          severity: PayrollRiskSeverity.high,
          owner: 'Finance Ops',
          dueDate: paymentBatch.payDate,
          action: paymentBatch.nextAction,
          sourceLabel: paymentBatch.batchId,
        ),
      for (final milestone in complianceCalendar.milestones.where(
        (milestone) =>
            milestone.status == PayrollComplianceMilestoneStatus.overdue,
      ))
        PayrollRiskRegisterItem(
          id: 'overdue-${milestone.id}',
          title: '${milestone.title} overdue',
          category: PayrollRiskCategory.compliance,
          severity: PayrollRiskSeverity.critical,
          owner: milestone.owner,
          dueDate: milestone.dueDate,
          action: milestone.detail,
          sourceLabel: complianceCalendar.periodLabel,
        ),
    ]..sort(_compareRiskItems);

    return PayrollRiskRegisterSummary(
      periodLabel: paymentBatch.periodLabel,
      asOfDate: asOfDate,
      items: items,
      nextAction:
          items.isEmpty ? 'No active payroll close risks.' : items.first.action,
    );
  }

  int get criticalCount {
    return items
        .where((item) => item.severity == PayrollRiskSeverity.critical)
        .length;
  }

  int get highCount {
    return items
        .where((item) => item.severity == PayrollRiskSeverity.high)
        .length;
  }

  int get dueTodayCount {
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    return items.where((item) {
      final dueDate = DateTime(
        item.dueDate.year,
        item.dueDate.month,
        item.dueDate.day,
      );
      return dueDate == today;
    }).length;
  }
}

PayrollRiskSeverity _exceptionSeverity(PayrollExceptionSeverity severity) {
  return switch (severity) {
    PayrollExceptionSeverity.critical => PayrollRiskSeverity.critical,
    PayrollExceptionSeverity.warning => PayrollRiskSeverity.high,
    PayrollExceptionSeverity.info => PayrollRiskSeverity.low,
  };
}

int _compareRiskItems(
  PayrollRiskRegisterItem left,
  PayrollRiskRegisterItem right,
) {
  final severity = _severityRank(
    left.severity,
  ).compareTo(_severityRank(right.severity));
  if (severity != 0) return severity;
  return left.dueDate.compareTo(right.dueDate);
}

int _severityRank(PayrollRiskSeverity severity) {
  return switch (severity) {
    PayrollRiskSeverity.critical => 0,
    PayrollRiskSeverity.high => 1,
    PayrollRiskSeverity.medium => 2,
    PayrollRiskSeverity.low => 3,
  };
}
