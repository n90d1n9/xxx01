import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_models.dart';
import '../models/incoming_talent_readiness.dart';
import '../states/incoming_talent_activation_provider.dart';
import 'incoming_talent_activation_form.dart';
import 'incoming_talent_activation_tile.dart';

class IncomingTalentActivationPanel extends ConsumerWidget {
  final List<IncomingTalentReadiness> readiness;

  const IncomingTalentActivationPanel({super.key, required this.readiness});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(filteredIncomingTalentActivationPlansProvider);
    final summary = ref.watch(incomingTalentActivationSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.rocket_launch_outlined,
      title: 'Talent activation',
      subtitle: summary.nextAction,
      emptyMessage: 'No incoming activation data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Planned',
              value: '${summary.plannedCount}',
            ),
            HrisMetricStripItem(
              label: 'Active',
              value: '${summary.activeCount}',
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
        IncomingTalentActivationForm(readiness: readiness),
        if (plans.isEmpty)
          const HrisListSurface(child: Text('No activation plans yet.'))
        else
          for (final plan in plans)
            IncomingTalentActivationPlanTile(
              plan: plan,
              onStart:
                  () => _setStatus(
                    ref,
                    plan,
                    IncomingTalentActivationStatus.active,
                  ),
              onComplete:
                  () => _setStatus(
                    ref,
                    plan,
                    IncomingTalentActivationStatus.completed,
                  ),
              onBlock:
                  () => _setStatus(
                    ref,
                    plan,
                    IncomingTalentActivationStatus.blocked,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentActivationPlan plan,
    IncomingTalentActivationStatus status,
  ) {
    final notifier = ref.read(incomingTalentActivationPlansProvider.notifier);
    switch (status) {
      case IncomingTalentActivationStatus.active:
        notifier.start(plan.id);
      case IncomingTalentActivationStatus.completed:
        notifier.complete(plan.id);
      case IncomingTalentActivationStatus.blocked:
        notifier.block(plan.id);
      case IncomingTalentActivationStatus.planned:
        break;
    }
  }
}
