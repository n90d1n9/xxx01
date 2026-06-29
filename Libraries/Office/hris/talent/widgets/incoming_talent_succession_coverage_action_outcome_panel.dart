import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_coverage_action_outcome_provider.dart';
import 'incoming_talent_succession_coverage_action_outcome_form.dart';
import 'incoming_talent_succession_coverage_action_outcome_tile.dart';

class IncomingTalentSuccessionCoverageActionOutcomePanel
    extends ConsumerWidget {
  const IncomingTalentSuccessionCoverageActionOutcomePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyActions = ref.watch(
      outcomeReadySuccessionCoverageActionsProvider,
    );
    final outcomes = ref.watch(
      filteredIncomingTalentSuccessionCoverageActionOutcomesProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionCoverageActionOutcomeSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.insights_outlined,
      title: 'Coverage outcomes',
      subtitle: summary.nextAction,
      emptyMessage: 'No coverage outcomes',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyActions.length}',
            ),
            HrisMetricStripItem(
              label: 'Validated',
              value: '${summary.validatedCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: '${summary.attentionCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionCoverageActionOutcomeForm(),
        if (outcomes.isEmpty)
          const HrisListSurface(child: Text('No coverage outcomes yet.'))
        else
          for (final outcome in outcomes.take(3))
            IncomingTalentSuccessionCoverageActionOutcomeTile(outcome: outcome),
      ],
    );
  }
}
