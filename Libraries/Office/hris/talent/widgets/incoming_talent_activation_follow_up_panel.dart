import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_follow_up_models.dart';
import '../states/incoming_talent_activation_checkpoint_provider.dart';
import '../states/incoming_talent_activation_follow_up_provider.dart';
import 'incoming_talent_activation_follow_up_form.dart';
import 'incoming_talent_activation_follow_up_tile.dart';

class IncomingTalentActivationFollowUpPanel extends ConsumerWidget {
  const IncomingTalentActivationFollowUpPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkpoints = ref.watch(
      filteredIncomingTalentActivationCheckpointsProvider,
    );
    final actions = ref.watch(
      filteredIncomingTalentActivationFollowUpActionsProvider,
    );
    final summary = ref.watch(incomingTalentActivationFollowUpSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.task_alt_outlined,
      title: 'Activation follow-up',
      subtitle: summary.nextAction,
      emptyMessage: 'No activation follow-up data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Planned',
              value: '${summary.plannedCount}',
            ),
            HrisMetricStripItem(
              label: 'Progress',
              value: '${summary.inProgressCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Evidence',
              value: '${summary.evidenceBackedCount}',
            ),
          ],
        ),
        IncomingTalentActivationFollowUpForm(checkpoints: checkpoints),
        if (actions.isEmpty)
          const HrisListSurface(child: Text('No follow-up actions yet.'))
        else
          for (final action in actions)
            IncomingTalentActivationFollowUpTile(
              action: action,
              onStart:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentActivationFollowUpStatus.inProgress,
                  ),
              onComplete:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentActivationFollowUpStatus.completed,
                  ),
              onBlock:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentActivationFollowUpStatus.blocked,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentActivationFollowUpAction action,
    IncomingTalentActivationFollowUpStatus status,
  ) {
    final notifier = ref.read(
      incomingTalentActivationFollowUpActionsProvider.notifier,
    );
    switch (status) {
      case IncomingTalentActivationFollowUpStatus.inProgress:
        notifier.start(action.id);
      case IncomingTalentActivationFollowUpStatus.completed:
        notifier.complete(action.id);
      case IncomingTalentActivationFollowUpStatus.blocked:
        notifier.block(action.id);
      case IncomingTalentActivationFollowUpStatus.planned:
        break;
    }
  }
}
