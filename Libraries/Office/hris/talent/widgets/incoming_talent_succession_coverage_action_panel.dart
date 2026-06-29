import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_coverage_action_provider.dart';
import 'incoming_talent_succession_coverage_action_form.dart';
import 'incoming_talent_succession_coverage_action_tile.dart';

class IncomingTalentSuccessionCoverageActionPanel extends ConsumerWidget {
  const IncomingTalentSuccessionCoverageActionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyReviews = ref.watch(
      actionReadySuccessionCoverageReviewsProvider,
    );
    final actions = ref.watch(
      filteredIncomingTalentSuccessionCoverageActionsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionCoverageActionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.task_alt_outlined,
      title: 'Coverage actions',
      subtitle: summary.nextAction,
      emptyMessage: 'No coverage actions',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyReviews.length}',
            ),
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
        const IncomingTalentSuccessionCoverageActionForm(),
        if (actions.isEmpty)
          const HrisListSurface(child: Text('No coverage actions yet.'))
        else
          for (final action in actions.take(3))
            IncomingTalentSuccessionCoverageActionTile(
              action: action,
              onStart:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentSuccessionCoverageActionStatus.inProgress,
                  ),
              onResolve:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentSuccessionCoverageActionStatus.resolved,
                  ),
              onBlock:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentSuccessionCoverageActionStatus.blocked,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentSuccessionCoverageAction action,
    IncomingTalentSuccessionCoverageActionStatus status,
  ) {
    final notifier = ref.read(
      incomingTalentSuccessionCoverageActionsProvider.notifier,
    );
    switch (status) {
      case IncomingTalentSuccessionCoverageActionStatus.inProgress:
        notifier.start(action.id);
      case IncomingTalentSuccessionCoverageActionStatus.resolved:
        notifier.resolve(action.id);
      case IncomingTalentSuccessionCoverageActionStatus.blocked:
        notifier.block(action.id);
      case IncomingTalentSuccessionCoverageActionStatus.planned:
        break;
    }
  }
}
