import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_activation_checkpoint_provider.dart';
import '../states/incoming_talent_activation_provider.dart';
import 'incoming_talent_activation_checkpoint_form.dart';
import 'incoming_talent_activation_checkpoint_tile.dart';

class IncomingTalentActivationCheckpointPanel extends ConsumerWidget {
  const IncomingTalentActivationCheckpointPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(filteredIncomingTalentActivationPlansProvider);
    final checkpoints = ref.watch(
      filteredIncomingTalentActivationCheckpointsProvider,
    );
    final summary = ref.watch(
      incomingTalentActivationCheckpointSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.monitor_heart_outlined,
      title: 'Activation checkpoints',
      subtitle: summary.nextAction,
      emptyMessage: 'No activation checkpoint data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'On track',
              value: '${summary.onTrackCount}',
            ),
            HrisMetricStripItem(label: 'Watch', value: '${summary.watchCount}'),
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
        IncomingTalentActivationCheckpointForm(plans: plans),
        if (checkpoints.isEmpty)
          const HrisListSurface(child: Text('No checkpoints submitted yet.'))
        else
          for (final checkpoint in checkpoints)
            IncomingTalentActivationCheckpointTile(checkpoint: checkpoint),
      ],
    );
  }
}
