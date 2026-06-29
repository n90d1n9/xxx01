import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_development_intervention_provider.dart';
import 'incoming_talent_development_intervention_form.dart';
import 'incoming_talent_development_intervention_tile.dart';

class IncomingTalentDevelopmentInterventionPanel extends ConsumerWidget {
  const IncomingTalentDevelopmentInterventionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(
      filteredIncomingTalentDevelopmentInterventionsProvider,
    );
    final summary = ref.watch(
      incomingTalentDevelopmentInterventionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.task_alt_outlined,
      title: 'Development interventions',
      subtitle: summary.nextAction,
      emptyMessage: 'No development intervention data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Open', value: '${summary.openCount}'),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalCount}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
            HrisMetricStripItem(
              label: 'Release risk',
              value: '${summary.releaseEvidenceRiskCount}',
            ),
          ],
        ),
        const IncomingTalentDevelopmentInterventionForm(),
        if (actions.isEmpty)
          const HrisListSurface(
            child: Text('No development intervention actions created yet.'),
          )
        else
          for (final action in actions)
            IncomingTalentDevelopmentInterventionTile(action: action),
      ],
    );
  }
}
