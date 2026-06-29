import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_activation_escalation_provider.dart';
import 'incoming_talent_succession_activation_escalation_form.dart';
import 'incoming_talent_succession_activation_escalation_tile.dart';

class IncomingTalentSuccessionActivationEscalationPanel extends ConsumerWidget {
  const IncomingTalentSuccessionActivationEscalationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyCheckIns = ref.watch(
      escalationReadySuccessionActivationCheckInsProvider,
    );
    final escalations = ref.watch(
      filteredIncomingTalentSuccessionActivationEscalationsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionActivationEscalationSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.escalator_warning_outlined,
      title: 'Activation escalations',
      subtitle: summary.nextAction,
      emptyMessage: 'No activation escalations',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyCheckIns.length}',
            ),
            HrisMetricStripItem(
              label: 'Urgent',
              value: '${summary.urgentCount + summary.executiveCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionActivationEscalationForm(),
        if (escalations.isEmpty)
          const HrisListSurface(child: Text('No escalation actions yet.'))
        else
          for (final escalation in escalations.take(3))
            IncomingTalentSuccessionActivationEscalationTile(
              escalation: escalation,
              onStart:
                  () => _setStatus(
                    ref,
                    escalation,
                    IncomingTalentSuccessionActivationEscalationStatus
                        .inProgress,
                  ),
              onResolve:
                  () => _setStatus(
                    ref,
                    escalation,
                    IncomingTalentSuccessionActivationEscalationStatus.resolved,
                  ),
              onBlock:
                  () => _setStatus(
                    ref,
                    escalation,
                    IncomingTalentSuccessionActivationEscalationStatus.blocked,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentSuccessionActivationEscalation escalation,
    IncomingTalentSuccessionActivationEscalationStatus status,
  ) {
    final notifier = ref.read(
      incomingTalentSuccessionActivationEscalationsProvider.notifier,
    );
    switch (status) {
      case IncomingTalentSuccessionActivationEscalationStatus.inProgress:
        notifier.start(escalation.id);
      case IncomingTalentSuccessionActivationEscalationStatus.resolved:
        notifier.resolve(escalation.id);
      case IncomingTalentSuccessionActivationEscalationStatus.blocked:
        notifier.block(escalation.id);
      case IncomingTalentSuccessionActivationEscalationStatus.opened:
        break;
    }
  }
}
