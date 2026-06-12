import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_policy_capability.dart';
import 'package:kaysir/features/finance/billing/models/split_allocation_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/split_allocation_planner.dart';

void main() {
  test('planBillingSplitAllocation builds ready split plans', () {
    final plan = planBillingSplitAllocation(
      config: constructionBillingPolicyConfig(),
      totalAmount: 1000,
      recipients: const [
        BillingSplitAllocationRecipient(
          id: 'owner',
          label: 'Owner',
          share: 0.6,
        ),
        BillingSplitAllocationRecipient(
          id: 'partner',
          label: 'Partner',
          share: 0.4,
        ),
      ],
    );

    expect(plan.isActionable, isTrue);
    expect(plan.isBalanced, isTrue);
    expect(plan.lines.map((line) => line.amount), [600, 400]);
    expect(plan.summaryLabel, '2 recipients share 100% of the billed amount.');
  });

  test('planBillingSplitAllocation blocks disabled split capability', () {
    final plan = planBillingSplitAllocation(
      config: agnosticBillingPolicyConfig(),
      totalAmount: 1000,
      recipients: const [
        BillingSplitAllocationRecipient(id: 'owner', label: 'Owner', share: 1),
      ],
    );

    expect(plan.isConfigured, isFalse);
    expect(plan.isActionable, isFalse);
    expect(
      plan.missingCapabilityIds,
      contains(BillingPolicyCapabilityId.splitBilling),
    );
    expect(
      plan.hasIssueKind(BillingSplitAllocationIssueKind.splitBillingDisabled),
      isTrue,
    );
  });

  test('planBillingSplitAllocation blocks multi-payer when needed', () {
    final config = agnosticBillingPolicyConfig().enable(
      BillingPolicyCapabilityId.splitBilling,
    );
    final plan = planBillingSplitAllocation(
      config: config,
      totalAmount: 1000,
      recipients: equalBillingSplitRecipients(count: 2),
    );

    expect(
      plan.missingCapabilityIds,
      contains(BillingPolicyCapabilityId.multiPayer),
    );
    expect(
      plan.hasIssueKind(BillingSplitAllocationIssueKind.multiPayerDisabled),
      isTrue,
    );
  });

  test('planBillingSplitAllocation blocks over-limit recipient sets', () {
    final plan = planBillingSplitAllocation(
      config: commerceBillingPolicyConfig().copyWith(maxSplitRecipients: 2),
      totalAmount: 1000,
      recipients: equalBillingSplitRecipients(count: 3),
    );

    expect(plan.isWithinRecipientLimit, isFalse);
    expect(
      plan.hasIssueKind(BillingSplitAllocationIssueKind.tooManyRecipients),
      isTrue,
    );
  });

  test('planBillingSplitAllocation blocks unbalanced shares', () {
    final plan = planBillingSplitAllocation(
      config: constructionBillingPolicyConfig(),
      totalAmount: 1000,
      recipients: const [
        BillingSplitAllocationRecipient(
          id: 'owner',
          label: 'Owner',
          share: 0.4,
        ),
        BillingSplitAllocationRecipient(
          id: 'partner',
          label: 'Partner',
          share: 0.4,
        ),
      ],
    );

    expect(plan.isBalanced, isFalse);
    expect(plan.lines.map((line) => line.amount), [400, 400]);
    expect(plan.allocatedAmount, 800);
    expect(
      plan.hasIssueKind(BillingSplitAllocationIssueKind.invalidShareTotal),
      isTrue,
    );
  });
}
