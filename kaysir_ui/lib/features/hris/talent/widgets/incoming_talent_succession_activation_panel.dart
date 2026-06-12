import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_activation_provider.dart';
import 'incoming_talent_succession_activation_form.dart';
import 'incoming_talent_succession_activation_tile.dart';

class IncomingTalentSuccessionActivationPanel extends ConsumerWidget {
  const IncomingTalentSuccessionActivationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(
      filteredIncomingTalentSuccessionActivationPlansProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionActivationSummaryProvider,
    );
    final readyDecisions = ref.watch(
      activationReadySuccessionPanelDecisionsProvider,
    );

    return HrisSectionPanel(
      icon: Icons.rocket_launch_outlined,
      title: 'Succession activation',
      subtitle: summary.nextAction,
      emptyMessage: 'No activation plans',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyDecisions.length}',
            ),
            HrisMetricStripItem(
              label: 'Active',
              value: '${summary.inProgressCount}',
            ),
            HrisMetricStripItem(
              label: 'At risk',
              value: '${summary.atRiskCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionActivationForm(),
        if (plans.isEmpty)
          const HrisListSurface(
            child: Text('No succession activation plans submitted yet.'),
          )
        else
          for (final plan in plans.take(3))
            IncomingTalentSuccessionActivationTile(plan: plan),
      ],
    );
  }
}
