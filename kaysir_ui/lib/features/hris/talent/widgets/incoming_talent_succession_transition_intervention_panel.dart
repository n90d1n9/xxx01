import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_transition_intervention_provider.dart';
import 'incoming_talent_succession_transition_intervention_form.dart';
import 'incoming_talent_succession_transition_intervention_tile.dart';

class IncomingTalentSuccessionTransitionInterventionPanel
    extends ConsumerWidget {
  const IncomingTalentSuccessionTransitionInterventionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyPulses = ref.watch(
      interventionReadySuccessionTransitionPulsesProvider,
    );
    final interventions = ref.watch(
      filteredIncomingTalentSuccessionTransitionInterventionsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionTransitionInterventionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.healing_outlined,
      title: 'Transition interventions',
      subtitle: summary.nextAction,
      emptyMessage: 'No transition interventions',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Ready', value: '${readyPulses.length}'),
            HrisMetricStripItem(
              label: 'Open',
              value: '${summary.plannedCount + summary.inProgressCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionTransitionInterventionForm(),
        if (interventions.isEmpty)
          const HrisListSurface(child: Text('No transition interventions yet.'))
        else
          for (final intervention in interventions.take(3))
            IncomingTalentSuccessionTransitionInterventionTile(
              intervention: intervention,
              onStart:
                  () => _setStatus(
                    ref,
                    intervention,
                    IncomingTalentSuccessionTransitionInterventionStatus
                        .inProgress,
                  ),
              onComplete:
                  () => _setStatus(
                    ref,
                    intervention,
                    IncomingTalentSuccessionTransitionInterventionStatus
                        .completed,
                  ),
              onBlock:
                  () => _setStatus(
                    ref,
                    intervention,
                    IncomingTalentSuccessionTransitionInterventionStatus
                        .blocked,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentSuccessionTransitionIntervention intervention,
    IncomingTalentSuccessionTransitionInterventionStatus status,
  ) {
    final notifier = ref.read(
      incomingTalentSuccessionTransitionInterventionsProvider.notifier,
    );
    switch (status) {
      case IncomingTalentSuccessionTransitionInterventionStatus.inProgress:
        notifier.start(intervention.id);
      case IncomingTalentSuccessionTransitionInterventionStatus.completed:
        notifier.complete(intervention.id);
      case IncomingTalentSuccessionTransitionInterventionStatus.blocked:
        notifier.block(intervention.id);
      case IncomingTalentSuccessionTransitionInterventionStatus.planned:
        break;
    }
  }
}
