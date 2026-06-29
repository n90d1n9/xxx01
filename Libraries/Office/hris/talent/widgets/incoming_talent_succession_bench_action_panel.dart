import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_bench_action_provider.dart';
import 'incoming_talent_succession_bench_action_form.dart';
import 'incoming_talent_succession_bench_action_tile.dart';

class IncomingTalentSuccessionBenchActionPanel extends ConsumerWidget {
  const IncomingTalentSuccessionBenchActionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyCheckIns = ref.watch(actionReadySuccessionBenchCheckInsProvider);
    final actions = ref.watch(
      filteredIncomingTalentSuccessionBenchActionsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionBenchActionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.task_alt_outlined,
      title: 'Bench actions',
      subtitle: summary.nextAction,
      emptyMessage: 'No bench actions',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyCheckIns.length}',
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
        const IncomingTalentSuccessionBenchActionForm(),
        if (actions.isEmpty)
          const HrisListSurface(child: Text('No bench actions yet.'))
        else
          for (final action in actions.take(3))
            IncomingTalentSuccessionBenchActionTile(
              action: action,
              onStart:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentSuccessionBenchActionStatus.inProgress,
                  ),
              onResolve:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentSuccessionBenchActionStatus.resolved,
                  ),
              onBlock:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentSuccessionBenchActionStatus.blocked,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentSuccessionBenchAction action,
    IncomingTalentSuccessionBenchActionStatus status,
  ) {
    final notifier = ref.read(
      incomingTalentSuccessionBenchActionsProvider.notifier,
    );
    switch (status) {
      case IncomingTalentSuccessionBenchActionStatus.inProgress:
        notifier.start(action.id);
      case IncomingTalentSuccessionBenchActionStatus.resolved:
        notifier.resolve(action.id);
      case IncomingTalentSuccessionBenchActionStatus.blocked:
        notifier.block(action.id);
      case IncomingTalentSuccessionBenchActionStatus.planned:
        break;
    }
  }
}
