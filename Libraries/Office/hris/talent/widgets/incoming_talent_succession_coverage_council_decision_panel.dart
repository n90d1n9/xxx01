import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_coverage_council_decision_provider.dart';
import 'incoming_talent_succession_coverage_council_decision_form.dart';
import 'incoming_talent_succession_coverage_council_decision_tile.dart';

class IncomingTalentSuccessionCoverageCouncilDecisionPanel
    extends ConsumerWidget {
  const IncomingTalentSuccessionCoverageCouncilDecisionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyItems = ref.watch(
      decisionReadyCoverageCouncilAgendaItemsProvider,
    );
    final decisions = ref.watch(
      filteredIncomingTalentSuccessionCoverageCouncilDecisionsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionCoverageCouncilDecisionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Coverage council decisions',
      subtitle: summary.nextAction,
      emptyMessage: 'No coverage council decisions',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Ready', value: '${readyItems.length}'),
            HrisMetricStripItem(
              label: 'Sponsor',
              value: '${summary.sponsorAssignedCount}',
            ),
            HrisMetricStripItem(
              label: 'Escalated',
              value: '${summary.escalatedCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionCoverageCouncilDecisionForm(),
        if (decisions.isEmpty)
          const HrisListSurface(
            child: Text('No coverage council decisions recorded yet.'),
          )
        else
          for (final decision in decisions.take(3))
            IncomingTalentSuccessionCoverageCouncilDecisionTile(
              decision: decision,
            ),
      ],
    );
  }
}
