import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_development_intervention_outcome_follow_up_resolution_provider.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_resolution_form.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_resolution_tile.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionPanel
    extends ConsumerWidget {
  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyFollowUps = ref.watch(
      resolutionReadyDevelopmentInterventionOutcomeFollowUpsProvider,
    );
    final resolutions = ref.watch(
      filteredIncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider,
    );
    final summary = ref.watch(
      incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Follow-up resolution reviews',
      subtitle: summary.nextAction,
      emptyMessage: 'No follow-up resolution reviews',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyFollowUps.length}',
            ),
            HrisMetricStripItem(
              label: 'Closed',
              value: '${summary.closedCount}',
            ),
            HrisMetricStripItem(
              label: 'Sustained',
              value: '${summary.sustainedCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: '${summary.monitorCount + summary.escalateCount}',
            ),
          ],
        ),
        const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionForm(),
        if (resolutions.isEmpty)
          const HrisListSurface(
            child: Text('No follow-up resolution reviews yet.'),
          )
        else
          for (final resolution in resolutions.take(3))
            IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionTile(
              resolution: resolution,
            ),
      ],
    );
  }
}
