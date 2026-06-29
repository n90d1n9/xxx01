import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_bench_replenishment_provider.dart';
import 'incoming_talent_succession_bench_replenishment_form.dart';
import 'incoming_talent_succession_bench_replenishment_tile.dart';

class IncomingTalentSuccessionBenchReplenishmentPanel extends ConsumerWidget {
  const IncomingTalentSuccessionBenchReplenishmentPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyReviews = ref.watch(
      benchReadySuccessionTransitionOutcomeReviewsProvider,
    );
    final plans = ref.watch(
      filteredIncomingTalentSuccessionBenchReplenishmentsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionBenchReplenishmentSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Bench replenishment',
      subtitle: summary.nextAction,
      emptyMessage: 'No bench replenishment plans',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyReviews.length}',
            ),
            HrisMetricStripItem(
              label: 'Open',
              value: '${summary.plannedCount + summary.activeCount}',
            ),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionBenchReplenishmentForm(),
        if (plans.isEmpty)
          const HrisListSurface(
            child: Text('No bench replenishment plans yet.'),
          )
        else
          for (final plan in plans.take(3))
            IncomingTalentSuccessionBenchReplenishmentTile(
              plan: plan,
              onStart:
                  () => _setStatus(
                    ref,
                    plan,
                    IncomingTalentSuccessionBenchReplenishmentStatus.active,
                  ),
              onComplete:
                  () => _setStatus(
                    ref,
                    plan,
                    IncomingTalentSuccessionBenchReplenishmentStatus.completed,
                  ),
              onBlock:
                  () => _setStatus(
                    ref,
                    plan,
                    IncomingTalentSuccessionBenchReplenishmentStatus.blocked,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentSuccessionBenchReplenishment plan,
    IncomingTalentSuccessionBenchReplenishmentStatus status,
  ) {
    final notifier = ref.read(
      incomingTalentSuccessionBenchReplenishmentsProvider.notifier,
    );
    switch (status) {
      case IncomingTalentSuccessionBenchReplenishmentStatus.active:
        notifier.start(plan.id);
      case IncomingTalentSuccessionBenchReplenishmentStatus.completed:
        notifier.complete(plan.id);
      case IncomingTalentSuccessionBenchReplenishmentStatus.blocked:
        notifier.block(plan.id);
      case IncomingTalentSuccessionBenchReplenishmentStatus.planned:
        break;
    }
  }
}
