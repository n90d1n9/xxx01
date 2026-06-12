import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_mobility_cadence_intervention_provider.dart';
import 'incoming_talent_mobility_cadence_intervention_form.dart';
import 'incoming_talent_mobility_cadence_intervention_tile.dart';

class IncomingTalentMobilityCadenceInterventionPanel extends ConsumerWidget {
  const IncomingTalentMobilityCadenceInterventionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyCheckIns = ref.watch(
      interventionReadyMobilityCadenceCheckInsProvider,
    );
    final interventions = ref.watch(
      filteredIncomingTalentMobilityCadenceInterventionsProvider,
    );
    final summary = ref.watch(
      incomingTalentMobilityCadenceInterventionSummaryProvider,
    );
    final notifier = ref.read(
      incomingTalentMobilityCadenceInterventionsProvider.notifier,
    );

    return HrisSectionPanel(
      icon: Icons.medical_services_outlined,
      title: 'Mobility cadence interventions',
      subtitle: summary.nextAction,
      emptyMessage: 'No mobility cadence interventions',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyCheckIns.length}',
            ),
            HrisMetricStripItem(
              label: 'Active',
              value: '${summary.inProgressCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
          ],
        ),
        const IncomingTalentMobilityCadenceInterventionForm(),
        if (interventions.isEmpty)
          const HrisListSurface(
            child: Text('No mobility cadence interventions yet.'),
          )
        else
          for (final intervention in interventions.take(3))
            IncomingTalentMobilityCadenceInterventionTile(
              intervention: intervention,
              onStart: () => notifier.start(intervention.id),
              onBlock: () => notifier.block(intervention.id),
              onResolve: () => notifier.resolve(intervention.id),
            ),
      ],
    );
  }
}
