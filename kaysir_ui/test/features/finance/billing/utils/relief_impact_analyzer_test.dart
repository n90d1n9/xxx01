import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/exception_relief_plan.dart';
import 'package:kaysir/features/finance/billing/models/relief_impact_summary.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';
import 'package:kaysir/features/finance/billing/utils/relief_application_packet_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_impact_analyzer.dart';

void main() {
  test(
    'summarizeBillingExceptionReliefImpact builds ready impact summaries',
    () {
      final summary = summarizeBillingExceptionReliefImpact(
        packet: buildBillingExceptionReliefApplicationPacket(
          plan: _readyReliefPlan(),
          requestedBy: 'Ops lead',
          requestedAt: DateTime.utc(2026, 1, 15, 9),
        ),
      );

      expect(summary.isReady, isTrue);
      expect(summary.riskLevel, BillingExceptionReliefImpactRiskLevel.high);
      expect(summary.statusLabel, 'High impact');
      expect(summary.deferredCashAmount, 42600);
      expect(
        summary.estimatedDailyCashDeferral,
        moreOrLessEquals(2028.57, epsilon: 0.01),
      );
      expect(summary.estimatedLateFeeWaiverAmount, 639);
      expect(summary.signalCount, 4);
      expect(
        summary.hasSignalKind(
          BillingExceptionReliefImpactSignalKind.cashDeferral,
        ),
        isTrue,
      );
      expect(
        summary.hasSignalKind(
          BillingExceptionReliefImpactSignalKind.collectionHold,
        ),
        isTrue,
      );
      expect(
        summary.hasSignalKind(
          BillingExceptionReliefImpactSignalKind.lateFeeSuppression,
        ),
        isTrue,
      );
      expect(
        summary.hasSignalKind(
          BillingExceptionReliefImpactSignalKind.recoverySchedule,
        ),
        isTrue,
      );
    },
  );

  test('summarizeBillingExceptionReliefImpact honors custom thresholds', () {
    final summary = summarizeBillingExceptionReliefImpact(
      packet: buildBillingExceptionReliefApplicationPacket(
        plan: _readyReliefPlan(),
        requestedBy: 'Ops lead',
        requestedAt: DateTime.utc(2026, 1, 15, 9),
      ),
      highExposureThreshold: 100000,
      longReliefWindowDays: 60,
    );

    expect(summary.riskLevel, BillingExceptionReliefImpactRiskLevel.medium);
  });

  test('summarizeBillingExceptionReliefImpact blocks unresolved packets', () {
    final summary = summarizeBillingExceptionReliefImpact(
      packet: buildBillingExceptionReliefApplicationPacket(
        plan: planBillingExceptionRelief(
          config: constructionBillingPolicyConfig(),
          kind: BillingExceptionEventKind.forceMajeure,
          affectedInvoiceCount: 12,
          openAmount: 42600,
          reliefDurationDays: 21,
          evidenceCaptured: true,
        ),
        requestedBy: 'Ops lead',
        requestedAt: DateTime.utc(2026, 1, 15, 9),
      ),
    );

    expect(summary.isReady, isFalse);
    expect(summary.riskLevel, BillingExceptionReliefImpactRiskLevel.blocked);
    expect(summary.statusLabel, 'Blocked');
    expect(summary.deferredCashAmount, 0);
    expect(
      summary.blockers,
      contains('Approval must be granted before relief is applied.'),
    );
  });
}

BillingExceptionReliefPlan _readyReliefPlan() {
  return planBillingExceptionRelief(
    config: constructionBillingPolicyConfig(),
    kind: BillingExceptionEventKind.forceMajeure,
    affectedInvoiceCount: 12,
    openAmount: 42600,
    reliefDurationDays: 21,
    approvalGranted: true,
    evidenceCaptured: true,
  );
}
