import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_panel_decision_provider.dart';
import 'incoming_talent_succession_panel_decision_form.dart';
import 'incoming_talent_succession_panel_decision_tile.dart';

class IncomingTalentSuccessionPanelDecisionPanel extends ConsumerWidget {
  const IncomingTalentSuccessionPanelDecisionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(
      filteredIncomingTalentSuccessionPanelDecisionsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionPanelDecisionSummaryProvider,
    );
    final readyNominations = ref.watch(panelReadySuccessionNominationsProvider);

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Succession panel decisions',
      subtitle: summary.nextAction,
      emptyMessage: 'No panel decisions',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyNominations.length}',
            ),
            HrisMetricStripItem(
              label: 'Approved',
              value: '${summary.approvedCount}',
            ),
            HrisMetricStripItem(
              label: 'Deferred',
              value: '${summary.deferredCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionPanelDecisionForm(),
        if (decisions.isEmpty)
          const HrisListSurface(
            child: Text('No succession panel decisions submitted yet.'),
          )
        else
          for (final decision in decisions.take(3))
            IncomingTalentSuccessionPanelDecisionTile(decision: decision),
      ],
    );
  }
}
