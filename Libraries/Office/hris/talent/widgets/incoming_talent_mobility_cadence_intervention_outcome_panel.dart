import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_mobility_cadence_intervention_outcome_provider.dart';
import 'incoming_talent_mobility_cadence_intervention_outcome_form.dart';
import 'incoming_talent_mobility_cadence_intervention_outcome_tile.dart';

class IncomingTalentMobilityCadenceInterventionOutcomePanel
    extends ConsumerWidget {
  const IncomingTalentMobilityCadenceInterventionOutcomePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyInterventions = ref.watch(
      outcomeReadyMobilityCadenceInterventionsProvider,
    );
    final outcomes = ref.watch(
      filteredIncomingTalentMobilityCadenceInterventionOutcomesProvider,
    );
    final summary = ref.watch(
      incomingTalentMobilityCadenceInterventionOutcomeSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.verified_outlined,
      title: 'Mobility intervention outcomes',
      subtitle: summary.nextAction,
      emptyMessage: 'No mobility intervention outcomes',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyInterventions.length}',
            ),
            HrisMetricStripItem(
              label: 'Recovered',
              value: '${summary.recoveredCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: '${summary.attentionCount}',
            ),
            HrisMetricStripItem(
              label: 'Avg',
              value: '${summary.averageHostConfidence.toStringAsFixed(1)}/5',
            ),
          ],
        ),
        const IncomingTalentMobilityCadenceInterventionOutcomeForm(),
        if (outcomes.isEmpty)
          const HrisListSurface(
            child: Text('No mobility intervention outcomes yet.'),
          )
        else
          for (final outcome in outcomes.take(3))
            IncomingTalentMobilityCadenceInterventionOutcomeTile(
              outcome: outcome,
            ),
      ],
    );
  }
}
