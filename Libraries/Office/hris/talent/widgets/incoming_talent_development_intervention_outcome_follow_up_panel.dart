import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_development_intervention_outcome_follow_up_provider.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_form.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_tile.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpPanel
    extends ConsumerWidget {
  const IncomingTalentDevelopmentInterventionOutcomeFollowUpPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyOutcomes = ref.watch(
      followUpReadyDevelopmentInterventionOutcomesProvider,
    );
    final followUps = ref.watch(
      filteredIncomingTalentDevelopmentInterventionOutcomeFollowUpsProvider,
    );
    final summary = ref.watch(
      incomingTalentDevelopmentInterventionOutcomeFollowUpSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.add_task_outlined,
      title: 'Intervention outcome follow-ups',
      subtitle: summary.nextAction,
      emptyMessage: 'No intervention outcome follow-ups',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyOutcomes.length}',
            ),
            HrisMetricStripItem(label: 'Open', value: '${summary.openCount}'),
            HrisMetricStripItem(label: 'Due', value: '${summary.dueSoonCount}'),
            HrisMetricStripItem(
              label: 'Escalated',
              value: '${summary.escalatedCount}',
            ),
          ],
        ),
        const IncomingTalentDevelopmentInterventionOutcomeFollowUpForm(),
        if (followUps.isEmpty)
          const HrisListSurface(
            child: Text('No intervention outcome follow-ups yet.'),
          )
        else
          for (final followUp in followUps.take(3))
            IncomingTalentDevelopmentInterventionOutcomeFollowUpTile(
              followUp: followUp,
            ),
      ],
    );
  }
}
