import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_career_path_support_outcome_provider.dart';
import 'incoming_talent_career_path_support_outcome_form.dart';
import 'incoming_talent_career_path_support_outcome_tile.dart';

class IncomingTalentCareerPathSupportOutcomePanel extends ConsumerWidget {
  const IncomingTalentCareerPathSupportOutcomePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyActions = ref.watch(
      careerPathSupportOutcomeReadyActionsProvider,
    );
    final outcomes = ref.watch(
      filteredIncomingTalentCareerPathSupportOutcomesProvider,
    );
    final summary = ref.watch(
      incomingTalentCareerPathSupportOutcomeSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.insights_outlined,
      title: 'Career support outcomes',
      subtitle: summary.nextAction,
      emptyMessage: 'No career support outcome data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyActions.length}',
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
              label: 'Avg level',
              value: summary.averageVerifiedLevel.toStringAsFixed(1),
            ),
          ],
        ),
        const IncomingTalentCareerPathSupportOutcomeForm(),
        if (outcomes.isEmpty)
          const HrisListSurface(
            child: Text('No career support outcomes recorded yet.'),
          )
        else
          for (final outcome in outcomes.take(3))
            IncomingTalentCareerPathSupportOutcomeTile(outcome: outcome),
      ],
    );
  }
}
