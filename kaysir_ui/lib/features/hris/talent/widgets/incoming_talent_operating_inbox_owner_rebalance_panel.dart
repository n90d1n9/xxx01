import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import '../states/incoming_talent_operating_inbox_provider.dart';
import 'incoming_talent_operating_inbox_owner_rebalance_tile.dart';

/// Panel that recommends owner relief moves for the talent operating inbox.
class IncomingTalentOperatingInboxOwnerRebalancePanel extends ConsumerWidget {
  const IncomingTalentOperatingInboxOwnerRebalancePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(
      incomingTalentOperatingInboxOwnerRebalancePlanProvider,
    );

    return HrisSectionPanel(
      icon: Icons.balance_outlined,
      title: 'Talent owner rebalance',
      subtitle: plan.nextAction,
      emptyMessage: 'No talent owner rebalance recommendations',
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
            IncomingTalentOperatingInboxOwnerRebalanceTile(
              recommendation: recommendation,
            ),
      ],
    );
  }
}

@Preview(name: 'Talent owner rebalance panel')
Widget incomingTalentOperatingInboxOwnerRebalancePanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentOperatingInboxOwnerRebalancePlanProvider.overrideWithValue(
        _previewPlan,
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentOperatingInboxOwnerRebalancePanel(),
        ),
      ),
    ),
  );
}

const _previewRecommendation =
    IncomingTalentOperatingInboxOwnerRebalanceRecommendation(
      sourceOwnerName: 'People Operations Talent Partner',
      targetOwnerName: 'Engineering HRBP',
      priority: IncomingTalentOperatingInboxOwnerRebalancePriority.critical,
      suggestedItemCount: 2,
      sourceItemCount: 4,
      sourceCriticalCount: 2,
      sourceOverdueCount: 1,
      sourceDueSoonCount: 1,
      sourceWorkstreamCount: 2,
      reliefCapacity: 1,
      reason: '1 overdue talent inbox item',
      nextAction:
          'Move 2 urgent talent items from People Operations Talent Partner to Engineering HRBP.',
    );

const _previewPlan = IncomingTalentOperatingInboxOwnerRebalancePlan(
  ownerCount: 4,
  ownersNeedingReliefCount: 1,
  availableReliefOwnerCount: 2,
  reliefCapacity: 4,
  suggestedReassignmentCount: 2,
  criticalRecommendationCount: 1,
  nextAction: 'Reassign 2 urgent talent inbox items from critical owners.',
  recommendations: [_previewRecommendation],
);
