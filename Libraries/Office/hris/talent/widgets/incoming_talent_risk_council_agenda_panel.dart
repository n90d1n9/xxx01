import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_risk_council_agenda_provider.dart';
import 'incoming_talent_risk_council_agenda_tile.dart';

class IncomingTalentRiskCouncilAgendaPanel extends ConsumerWidget {
  const IncomingTalentRiskCouncilAgendaPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(incomingTalentRiskCouncilAgendaItemsProvider);
    final summary = ref.watch(incomingTalentRiskCouncilAgendaSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.event_note_outlined,
      title: 'Talent risk council agenda',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent risk council agenda sections',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Sections',
              value: '${summary.totalCount}',
            ),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalCount}',
            ),
            HrisMetricStripItem(
              label: 'Minutes',
              value: '${summary.totalTimeboxMinutes}',
            ),
            HrisMetricStripItem(
              label: 'Prep',
              value: '${summary.readinessTaskCount}',
            ),
          ],
        ),
        for (final item in items.take(5))
          IncomingTalentRiskCouncilAgendaTile(item: item),
      ],
    );
  }
}
