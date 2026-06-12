import '../models/billing_payment_schedule.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_invoice_terms.dart';

BillingPaymentSchedule buildBillingPaymentSchedule({
  required double total,
  required DateTime issueDate,
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  BillingPaymentScheduleOptions? options,
}) {
  final resolvedOptions =
      options ?? BillingPaymentScheduleOptions.singleDueDate();
  final items = switch (resolvedOptions.strategy) {
    BillingPaymentScheduleStrategy.singleDueDate => [
      BillingPaymentScheduleItem(
        id: 'due',
        label: 'Invoice due',
        amount: total,
        amountRatio: total == 0 ? 0 : 1,
        dueDate: billingIssueDueDate(issueDate, preferences: preferences),
      ),
    ],
    BillingPaymentScheduleStrategy.splitEqual => _splitEqualItems(
      total: total,
      issueDate: issueDate,
      preferences: preferences,
      options: resolvedOptions,
    ),
    BillingPaymentScheduleStrategy.upfrontAndBalance => _upfrontItems(
      total: total,
      issueDate: issueDate,
      preferences: preferences,
      options: resolvedOptions,
    ),
    BillingPaymentScheduleStrategy.milestones => _milestoneItems(
      total: total,
      issueDate: issueDate,
      options: resolvedOptions,
    ),
  };

  return BillingPaymentSchedule(
    strategy: resolvedOptions.strategy,
    total: total,
    items: items,
  );
}

List<BillingPaymentScheduleItem> _splitEqualItems({
  required double total,
  required DateTime issueDate,
  required BillingTenantPreferences preferences,
  required BillingPaymentScheduleOptions options,
}) {
  if (options.installments <= 0) {
    throw StateError('Payment schedule installments must be positive.');
  }

  final intervalDays =
      options.intervalDays ??
      _fallbackIntervalDays(preferences.paymentTermsDays);
  if (intervalDays <= 0) {
    throw StateError('Payment schedule interval days must be positive.');
  }

  final firstDueDate = billingIssueDueDate(issueDate, preferences: preferences);
  final amountPerInstallment = total / options.installments;
  final ratioPerInstallment = total == 0 ? 0.0 : 1 / options.installments;

  return List.generate(options.installments, (index) {
    final isLast = index == options.installments - 1;
    final amount =
        isLast ? total - (amountPerInstallment * index) : amountPerInstallment;
    final ratio =
        total == 0
            ? 0.0
            : isLast
            ? 1 - (ratioPerInstallment * index)
            : ratioPerInstallment;

    return BillingPaymentScheduleItem(
      id: 'installment-${index + 1}',
      label: 'Installment ${index + 1}',
      amount: amount,
      amountRatio: ratio,
      dueDate: firstDueDate.add(Duration(days: intervalDays * index)),
    );
  });
}

List<BillingPaymentScheduleItem> _upfrontItems({
  required double total,
  required DateTime issueDate,
  required BillingTenantPreferences preferences,
  required BillingPaymentScheduleOptions options,
}) {
  if (options.upfrontRatio <= 0 || options.upfrontRatio >= 1) {
    throw StateError('Payment schedule upfront ratio must be between 0 and 1.');
  }

  final upfrontAmount = total * options.upfrontRatio;

  return [
    BillingPaymentScheduleItem(
      id: 'upfront',
      label: 'Upfront',
      amount: upfrontAmount,
      amountRatio: options.upfrontRatio,
      dueDate: issueDate,
    ),
    BillingPaymentScheduleItem(
      id: 'balance',
      label: 'Balance',
      amount: total - upfrontAmount,
      amountRatio: 1 - options.upfrontRatio,
      dueDate: billingIssueDueDate(issueDate, preferences: preferences),
    ),
  ];
}

List<BillingPaymentScheduleItem> _milestoneItems({
  required double total,
  required DateTime issueDate,
  required BillingPaymentScheduleOptions options,
}) {
  if (options.milestones.isEmpty) {
    throw StateError('Payment schedule milestones are required.');
  }

  final totalRatio = options.milestones.fold<double>(
    0,
    (sum, milestone) => sum + milestone.amountRatio,
  );
  if ((totalRatio - 1).abs() > 0.0001) {
    throw StateError('Payment schedule milestone ratios must total 1.');
  }

  return [
    for (final milestone in options.milestones)
      ..._milestoneItem(
        total: total,
        issueDate: issueDate,
        milestone: milestone,
      ),
  ];
}

List<BillingPaymentScheduleItem> _milestoneItem({
  required double total,
  required DateTime issueDate,
  required BillingPaymentScheduleMilestone milestone,
}) {
  final errors = milestone.validationErrors;
  if (errors.isNotEmpty) {
    throw StateError(errors.first);
  }

  return [
    BillingPaymentScheduleItem(
      id: milestone.id,
      label: milestone.label,
      amount: total * milestone.amountRatio,
      amountRatio: milestone.amountRatio,
      dueDate: issueDate.add(Duration(days: milestone.dueAfterDays)),
      attributes: milestone.attributes,
    ),
  ];
}

int _fallbackIntervalDays(int paymentTermsDays) {
  return paymentTermsDays <= 0 ? 30 : paymentTermsDays;
}
