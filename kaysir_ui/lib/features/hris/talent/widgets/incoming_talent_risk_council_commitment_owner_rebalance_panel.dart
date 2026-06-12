import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_commitment_owner_workload_models.dart';
import '../states/incoming_talent_risk_council_commitment_owner_workload_provider.dart';
import 'incoming_talent_risk_council_commitment_owner_rebalance_tile.dart';

/// Panel that recommends owner relief moves for council commitment actions.
class IncomingTalentRiskCouncilCommitmentOwnerRebalancePanel
    extends ConsumerWidget {
  const IncomingTalentRiskCouncilCommitmentOwnerRebalancePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(
      incomingTalentRiskCouncilCommitmentOwnerRebalancePlanProvider,
    );

    return HrisSectionPanel(
      icon: Icons.balance_outlined,
      title: 'Council owner rebalance',
      subtitle: plan.nextAction,
      emptyMessage: 'No council owner rebalance recommendations',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Relief',
              value: '${plan.availableReliefOwnerCount}',
            ),
            HrisMetricStripItem(
              label: 'Capacity',
              value: '${plan.reliefCapacity}',
            ),
            HrisMetricStripItem(
              label: 'Overloaded',
              value: '${plan.ownersNeedingReliefCount}',
            ),
            HrisMetricStripItem(
              label: 'Moves',
              value: '${plan.suggestedReassignmentCount}',
            ),
          ],
        ),
        if (plan.recommendations.isEmpty)
          HrisListSurface(child: Text(plan.nextAction))
        else
          for (final recommendation in plan.recommendations.take(4))
            IncomingTalentRiskCouncilCommitmentOwnerRebalanceTile(
              recommendation: recommendation,
            ),
      ],
    );
  }
}

@Preview(name: 'Talent risk council owner rebalance panel')
Widget incomingTalentRiskCouncilCommitmentOwnerRebalancePanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentRiskCouncilCommitmentOwnerRebalancePlanProvider
          .overrideWithValue(_previewPlan),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentRiskCouncilCommitmentOwnerRebalancePanel(),
        ),
      ),
    ),
  );
}

const _previewRecommendation =
    IncomingTalentRiskCouncilCommitmentOwnerRebalanceRecommendation(
      sourceOwnerName: 'Ari Talent Partner',
      targetOwnerName: 'Citra HRBP',
      priority:
          IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority.critical,
      suggestedActionCount: 2,
      sourceOpenCount: 4,
      sourceBlockedCount: 1,
      sourceOverdueCount: 1,
      sourceWaitingEvidenceCount: 1,
      reliefCapacity: 1,
      reason: '1 blocked commitment action',
      nextAction:
          'Move 2 urgent actions from Ari Talent Partner to Citra HRBP.',
    );

const _previewPlan = IncomingTalentRiskCouncilCommitmentOwnerRebalancePlan(
  ownerCount: 4,
  ownersNeedingReliefCount: 1,
  availableReliefOwnerCount: 2,
  reliefCapacity: 4,
  suggestedReassignmentCount: 2,
  criticalRecommendationCount: 1,
  nextAction: 'Reassign 2 urgent commitment actions from critical owners.',
  recommendations: [_previewRecommendation],
);
