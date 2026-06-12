import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_development_intervention_outcome_provider.dart';
import 'incoming_talent_development_intervention_outcome_form.dart';
import 'incoming_talent_development_intervention_outcome_tile.dart';

class IncomingTalentDevelopmentInterventionOutcomePanel extends ConsumerWidget {
  const IncomingTalentDevelopmentInterventionOutcomePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyInterventions = ref.watch(
      outcomeReadyDevelopmentInterventionsProvider,
    );
    final outcomes = ref.watch(
      filteredIncomingTalentDevelopmentInterventionOutcomesProvider,
    );
    final summary = ref.watch(
      incomingTalentDevelopmentInterventionOutcomeSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.verified_outlined,
      title: 'Development intervention outcomes',
      subtitle: summary.nextAction,
      emptyMessage: 'No development intervention outcomes',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyInterventions.length}',
            ),
            HrisMetricStripItem(
              label: 'Improved',
              value: '${summary.improvedCount}',
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
        const IncomingTalentDevelopmentInterventionOutcomeForm(),
        if (outcomes.isEmpty)
          const HrisListSurface(
            child: Text('No development intervention outcomes yet.'),
          )
        else
          for (final outcome in outcomes.take(3))
            IncomingTalentDevelopmentInterventionOutcomeTile(outcome: outcome),
      ],
    );
  }
}
