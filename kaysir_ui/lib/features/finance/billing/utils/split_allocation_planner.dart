import '../models/billing_policy_capability.dart';
import '../models/billing_policy_config.dart';
import '../models/split_allocation_plan.dart';

const _shareTolerance = 0.0001;

/// Builds a reusable split billing allocation plan from policy config.
BillingSplitAllocationPlan planBillingSplitAllocation({
  required BillingPolicyConfig config,
  required double totalAmount,
  required Iterable<BillingSplitAllocationRecipient> recipients,
}) {
  final recipientList = recipients.toList(growable: false);
  final requiredCapabilityIds = {
    BillingPolicyCapabilityId.splitBilling,
    if (recipientList.length > 1) BillingPolicyCapabilityId.multiPayer,
  };
  final missingCapabilityIds = requiredCapabilityIds.where(
    (capabilityId) => !config.isEnabled(capabilityId),
  );
  final issues = [
    ..._capabilityIssues(missingCapabilityIds),
    ..._amountIssues(totalAmount),
    ..._recipientIssues(recipientList, config.maxSplitRecipients),
    ..._shareIssues(recipientList),
  ];

  return BillingSplitAllocationPlan(
    totalAmount: totalAmount,
    maxRecipientCount: config.maxSplitRecipients,
    recipients: recipientList,
    lines: _allocationLines(totalAmount, recipientList),
    requiredCapabilityIds: requiredCapabilityIds,
    missingCapabilityIds: missingCapabilityIds,
    issues: issues,
  );
}

/// Builds equal-share recipients for previews and simple split workflows.
List<BillingSplitAllocationRecipient> equalBillingSplitRecipients({
  required int count,
  String labelPrefix = 'Recipient',
}) {
  if (count <= 0) return const [];

  final share = 1 / count;
  return List.unmodifiable(
    List.generate(
      count,
      (index) => BillingSplitAllocationRecipient(
        id: 'recipient-${index + 1}',
        label: '$labelPrefix ${index + 1}',
        share: share,
      ),
    ),
  );
}

List<BillingSplitAllocationIssue> _capabilityIssues(
  Iterable<BillingPolicyCapabilityId> missingCapabilityIds,
) {
  return [
    for (final capabilityId in missingCapabilityIds)
      BillingSplitAllocationIssue(
        kind:
            capabilityId == BillingPolicyCapabilityId.splitBilling
                ? BillingSplitAllocationIssueKind.splitBillingDisabled
                : BillingSplitAllocationIssueKind.multiPayerDisabled,
        severity: BillingSplitAllocationIssueSeverity.blocker,
        message: '${capabilityId.label} must be enabled for this split.',
      ),
  ];
}

List<BillingSplitAllocationIssue> _amountIssues(double totalAmount) {
  if (totalAmount > 0) return const [];

  return [
    BillingSplitAllocationIssue(
      kind: BillingSplitAllocationIssueKind.invalidAmount,
      severity: BillingSplitAllocationIssueSeverity.blocker,
      message: 'Split billing amount must be greater than zero.',
    ),
  ];
}

List<BillingSplitAllocationIssue> _recipientIssues(
  List<BillingSplitAllocationRecipient> recipients,
  int maxRecipientCount,
) {
  return [
    if (recipients.isEmpty)
      BillingSplitAllocationIssue(
        kind: BillingSplitAllocationIssueKind.missingRecipient,
        severity: BillingSplitAllocationIssueSeverity.blocker,
        message: 'Add at least one split billing recipient.',
      ),
    if (recipients.length > maxRecipientCount)
      BillingSplitAllocationIssue(
        kind: BillingSplitAllocationIssueKind.tooManyRecipients,
        severity: BillingSplitAllocationIssueSeverity.blocker,
        message:
            'Split billing supports up to $maxRecipientCount recipients for this policy.',
      ),
    for (final recipient in recipients)
      if (!recipient.isValid)
        BillingSplitAllocationIssue(
          kind: BillingSplitAllocationIssueKind.invalidRecipient,
          severity: BillingSplitAllocationIssueSeverity.blocker,
          message:
              '${recipient.label.trim().isEmpty ? 'Recipient' : recipient.label} is invalid.',
          details: recipient.validationErrors,
        ),
  ];
}

List<BillingSplitAllocationIssue> _shareIssues(
  List<BillingSplitAllocationRecipient> recipients,
) {
  if (recipients.isEmpty) return const [];
  final shareTotal = recipients.fold<double>(
    0,
    (sum, recipient) => sum + recipient.share,
  );
  if ((shareTotal - 1).abs() <= _shareTolerance) return const [];

  return [
    BillingSplitAllocationIssue(
      kind: BillingSplitAllocationIssueKind.invalidShareTotal,
      severity: BillingSplitAllocationIssueSeverity.blocker,
      message: 'Split billing shares must add up to 100%.',
      details: ['shareTotal=${(shareTotal * 100).toStringAsFixed(2)}%'],
    ),
  ];
}

List<BillingSplitAllocationLine> _allocationLines(
  double totalAmount,
  List<BillingSplitAllocationRecipient> recipients,
) {
  if (totalAmount <= 0 || recipients.isEmpty) return const [];

  final shareTotal = recipients.fold<double>(
    0,
    (sum, recipient) => sum + recipient.share,
  );
  final useRemainderAdjustment = (shareTotal - 1).abs() <= _shareTolerance;
  var allocatedBeforeLast = 0.0;
  return List.unmodifiable([
    for (var index = 0; index < recipients.length; index++)
      _lineForRecipient(
        totalAmount: totalAmount,
        recipient: recipients[index],
        isLast: index == recipients.length - 1,
        useRemainderAdjustment: useRemainderAdjustment,
        allocatedBeforeLast: allocatedBeforeLast,
        onAllocated: (amount) => allocatedBeforeLast += amount,
      ),
  ]);
}

BillingSplitAllocationLine _lineForRecipient({
  required double totalAmount,
  required BillingSplitAllocationRecipient recipient,
  required bool isLast,
  required bool useRemainderAdjustment,
  required double allocatedBeforeLast,
  required void Function(double amount) onAllocated,
}) {
  final requestedAmount = totalAmount * recipient.share;
  final amount =
      useRemainderAdjustment && isLast
          ? totalAmount - allocatedBeforeLast
          : requestedAmount;
  if (!isLast) {
    onAllocated(amount);
  }

  return BillingSplitAllocationLine(
    recipientId: recipient.id,
    label: recipient.label,
    share: recipient.share,
    amount: amount,
  );
}
