import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_mobility_stabilization_action_provider.dart';
import 'incoming_talent_mobility_stabilization_form.dart';
import 'incoming_talent_mobility_stabilization_tile.dart';

class IncomingTalentMobilityStabilizationPanel extends ConsumerWidget {
  const IncomingTalentMobilityStabilizationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyReviews = ref.watch(
      stabilizationReadyMobilityFirstReviewsProvider,
    );
    final actions = ref.watch(
      filteredIncomingTalentMobilityStabilizationActionsProvider,
    );
    final summary = ref.watch(
      incomingTalentMobilityStabilizationActionSummaryProvider,
    );
    final notifier = ref.read(
      incomingTalentMobilityStabilizationActionsProvider.notifier,
    );

    return HrisSectionPanel(
      icon: Icons.add_task_outlined,
      title: 'Mobility stabilization actions',
      subtitle: summary.nextAction,
      emptyMessage: 'No mobility stabilization actions',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyReviews.length}',
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
        IncomingTalentMobilityStabilizationForm(reviews: readyReviews),
        if (actions.isEmpty)
          const HrisListSurface(
            child: Text('No mobility stabilization actions submitted yet.'),
          )
        else
          for (final action in actions.take(3))
            IncomingTalentMobilityStabilizationTile(
              action: action,
              onStart: () => notifier.start(action.id),
              onBlock: () => notifier.block(action.id),
              onComplete: () => notifier.complete(action.id),
            ),
      ],
    );
  }
}
