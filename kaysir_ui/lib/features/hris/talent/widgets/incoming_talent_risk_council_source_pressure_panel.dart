import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_queue_models.dart';
import '../models/incoming_talent_risk_council_source_pressure.dart';
import '../states/incoming_talent_risk_council_source_pressure_provider.dart';
import 'incoming_talent_risk_council_source_pressure_tile.dart';

/// Panel that ranks council source pressure by SLA urgency and workload.
class IncomingTalentRiskCouncilSourcePressurePanel extends ConsumerWidget {
  const IncomingTalentRiskCouncilSourcePressurePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pressures = ref.watch(
      incomingTalentRiskCouncilSourcePressureProvider,
    );

    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Council source pressure',
      subtitle: _subtitle(pressures),
      emptyMessage: 'No council source pressure',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Sources', value: '${pressures.length}'),
            HrisMetricStripItem(
              label: 'Critical',
              value:
                  '${_countByLevel(pressures, IncomingTalentRiskCouncilSourcePressureLevel.critical)}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value:
                  '${pressures.fold<int>(0, (total, item) => total + item.dueSoonCount)}',
            ),
            HrisMetricStripItem(
              label: 'Decisions',
              value:
                  '${pressures.fold<int>(0, (total, item) => total + item.waitingDecisionCount)}',
            ),
          ],
        ),
        if (pressures.isEmpty)
          const HrisListSurface(
            child: Text('No active council SLA pressure by source.'),
          )
        else
          for (final pressure in pressures.take(4))
            IncomingTalentRiskCouncilSourcePressureTile(pressure: pressure),
      ],
    );
  }
}

String _subtitle(List<IncomingTalentRiskCouncilSourcePressure> pressures) {
  if (pressures.isEmpty) return 'Council source pressure is clear.';
  return pressures.first.nextAction;
}

int _countByLevel(
  List<IncomingTalentRiskCouncilSourcePressure> pressures,
  IncomingTalentRiskCouncilSourcePressureLevel level,
) {
  return pressures.where((pressure) => pressure.level == level).length;
}

@Preview(name: 'Talent risk council source pressure panel')
Widget incomingTalentRiskCouncilSourcePressurePanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentRiskCouncilSourcePressureProvider.overrideWithValue(const [
        _previewCriticalPressure,
        _previewWatchPressure,
      ]),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentRiskCouncilSourcePressurePanel(),
        ),
      ),
    ),
  );
}

const _previewCriticalPressure = IncomingTalentRiskCouncilSourcePressure(
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  level: IncomingTalentRiskCouncilSourcePressureLevel.critical,
  totalCount: 3,
  candidateCount: 2,
  blockedCount: 0,
  escalatedCount: 1,
  overdueCount: 1,
  dueSoonCount: 1,
  waitingDecisionCount: 1,
  waitingFollowUpCount: 1,
  activeFollowUpCount: 1,
  nextAction: 'Track 1 escalated promotion resolution review SLA item.',
);

const _previewWatchPressure = IncomingTalentRiskCouncilSourcePressure(
  source: IncomingTalentRiskCouncilQueueSource.developmentFollowUp,
  level: IncomingTalentRiskCouncilSourcePressureLevel.watch,
  totalCount: 2,
  candidateCount: 2,
  blockedCount: 0,
  escalatedCount: 0,
  overdueCount: 0,
  dueSoonCount: 1,
  waitingDecisionCount: 1,
  waitingFollowUpCount: 0,
  activeFollowUpCount: 1,
  nextAction: 'Close 1 development follow-up SLA item due soon.',
);
