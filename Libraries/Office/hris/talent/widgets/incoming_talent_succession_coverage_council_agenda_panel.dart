import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_coverage_council_agenda_provider.dart';
import 'incoming_talent_succession_coverage_council_agenda_tile.dart';

class IncomingTalentSuccessionCoverageCouncilAgendaPanel
    extends ConsumerWidget {
  const IncomingTalentSuccessionCoverageCouncilAgendaPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(
      incomingTalentSuccessionCoverageCouncilAgendaItemsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionCoverageCouncilAgendaSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.groups_2_outlined,
      title: 'Coverage council agenda',
      subtitle: summary.nextAction,
      emptyMessage: 'No coverage council agenda items',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Items', value: '${summary.totalItems}'),
            HrisMetricStripItem(
              label: 'Urgent',
              value: '${summary.urgentCount}',
            ),
            HrisMetricStripItem(
              label: 'Exec',
              value: '${summary.executiveDecisionCount}',
            ),
          ],
        ),
        if (items.isEmpty)
          const HrisListSurface(
            child: Text('No open coverage governance items for council.'),
          )
        else
          for (final item in items.take(4))
            IncomingTalentSuccessionCoverageCouncilAgendaTile(item: item),
      ],
    );
  }
}
