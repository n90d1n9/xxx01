import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/billing_policy_capability.dart';
import 'package:kaysir/features/finance/billing/models/exception_relief_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';

void main() {
  test('planBillingExceptionRelief builds ready relief workflows', () {
    final plan = planBillingExceptionRelief(
      config: constructionBillingPolicyConfig(),
      kind: BillingExceptionEventKind.forceMajeure,
      affectedInvoiceCount: 4,
      openAmount: 1200,
      reliefDurationDays: 14,
      approvalGranted: true,
      evidenceCaptured: true,
    );

    expect(plan.isActionable, isTrue);
    expect(plan.statusLabel, 'Ready');
    expect(plan.operationalActionCount, 4);
    expect(plan.readyOperationalActionCount, 4);
    expect(
      plan.actions.map((action) => action.kind),
      contains(BillingExceptionReliefActionKind.pauseDueDates),
    );
    expect(plan.summaryLabel, contains('4 actions across 4 invoices'));
  });

  test('planBillingExceptionRelief blocks missing governance', () {
    final plan = planBillingExceptionRelief(
      config: constructionBillingPolicyConfig(),
      kind: BillingExceptionEventKind.forceMajeure,
      affectedInvoiceCount: 2,
      openAmount: 900,
      reliefDurationDays: 7,
      evidenceCaptured: true,
    );

    expect(plan.isActionable, isFalse);
    expect(plan.statusLabel, 'Needs governance');
    expect(
      plan.hasIssueKind(BillingExceptionReliefIssueKind.approvalRequired),
      isTrue,
    );
    expect(
      plan.governanceActions
          .firstWhere(
            (action) =>
                action.kind == BillingExceptionReliefActionKind.requestApproval,
          )
          .statusLabel,
      'Required',
    );
  });

  test(
    'planBillingExceptionRelief blocks missing force majeure capability',
    () {
      final config = constructionBillingPolicyConfig().disable(
        BillingPolicyCapabilityId.forceMajeureRelief,
      );
      final plan = planBillingExceptionRelief(
        config: config,
        kind: BillingExceptionEventKind.forceMajeure,
        affectedInvoiceCount: 2,
        openAmount: 900,
        reliefDurationDays: 7,
        approvalGranted: true,
        evidenceCaptured: true,
      );

      expect(plan.isActionable, isFalse);
      expect(plan.statusLabel, 'Needs capability');
      expect(
        plan.issues
            .where(
              (issue) =>
                  issue.capabilityId ==
                  BillingPolicyCapabilityId.forceMajeureRelief,
            )
            .length,
        1,
      );
    },
  );

  test('planBillingExceptionRelief validates operational context', () {
    final plan = planBillingExceptionRelief(
      config: constructionBillingPolicyConfig(),
      kind: BillingExceptionEventKind.forceMajeure,
      affectedInvoiceCount: 0,
      openAmount: 0,
      reliefDurationDays: 0,
      approvalGranted: true,
      evidenceCaptured: true,
    );

    expect(plan.isActionable, isFalse);
    expect(plan.statusLabel, 'Needs context');
    expect(
      plan.hasIssueKind(
        BillingExceptionReliefIssueKind.invalidAffectedInvoiceCount,
      ),
      isTrue,
    );
    expect(
      plan.hasIssueKind(BillingExceptionReliefIssueKind.invalidOpenAmount),
      isTrue,
    );
    expect(
      plan.hasIssueKind(BillingExceptionReliefIssueKind.invalidReliefDuration),
      isTrue,
    );
  });

  test('planBillingExceptionRelief blocks unconfigured policies', () {
    final plan = planBillingExceptionRelief(
      config: constructionBillingPolicyConfig().copyWith(
        exceptionPolicies: const [],
      ),
      kind: BillingExceptionEventKind.forceMajeure,
      affectedInvoiceCount: 2,
      openAmount: 900,
      reliefDurationDays: 7,
      approvalGranted: true,
      evidenceCaptured: true,
    );

    expect(plan.isActionable, isFalse);
    expect(plan.statusLabel, 'Not configured');
    expect(
      plan.hasIssueKind(BillingExceptionReliefIssueKind.policyNotConfigured),
      isTrue,
    );
  });
}
