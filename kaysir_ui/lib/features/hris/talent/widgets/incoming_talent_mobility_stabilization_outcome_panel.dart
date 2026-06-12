import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_mobility_stabilization_outcome_provider.dart';
import 'incoming_talent_mobility_stabilization_outcome_form.dart';
import 'incoming_talent_mobility_stabilization_outcome_tile.dart';

class IncomingTalentMobilityStabilizationOutcomePanel extends ConsumerWidget {
  const IncomingTalentMobilityStabilizationOutcomePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyActions = ref.watch(
      outcomeReadyMobilityStabilizationActionsProvider,
    );
    final outcomes = ref.watch(
      filteredIncomingTalentMobilityStabilizationOutcomesProvider,
    );
    final summary = ref.watch(
      incomingTalentMobilityStabilizationOutcomeSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.insights_outlined,
      title: 'Mobility stabilization outcomes',
      subtitle: summary.nextAction,
      emptyMessage: 'No mobility stabilization outcomes',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyActions.length}',
            ),
            HrisMetricStripItem(
              label: 'Resolved',
              value: '${summary.resolvedCount + summary.improvedCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: '${summary.attentionCount}',
            ),
            HrisMetricStripItem(
              label: 'Avg',
              value: '${summary.averageConfidenceAfter.toStringAsFixed(1)}/5',
            ),
          ],
        ),
        const IncomingTalentMobilityStabilizationOutcomeForm(),
        if (outcomes.isEmpty)
          const HrisListSurface(child: Text('No mobility outcomes yet.'))
        else
          for (final outcome in outcomes.take(3))
            IncomingTalentMobilityStabilizationOutcomeTile(outcome: outcome),
      ],
    );
  }
}
