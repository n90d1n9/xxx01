import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import '../states/incoming_talent_operating_inbox_provider.dart';
import 'incoming_talent_operating_escalation_tile.dart';

/// Cross-module escalation board for talent operating risk.
class IncomingTalentOperatingEscalationBoardPanel extends ConsumerWidget {
  const IncomingTalentOperatingEscalationBoardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escalations = ref.watch(incomingTalentOperatingEscalationsProvider);
    final summary = ref.watch(incomingTalentOperatingEscalationSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.crisis_alert_outlined,
      title: 'Talent escalation board',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent operating escalations',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Escalations',
              value: '${summary.totalCount}',
            ),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueCount}',
            ),
            HrisMetricStripItem(
              label: 'Relief',
              value: '${summary.ownerReliefCount}',
            ),
          ],
        ),
        if (escalations.isEmpty)
          const HrisListSurface(
            child: Text('No active escalation signals need review.'),
          )
        else
          for (final item in escalations.take(6))
            IncomingTalentOperatingEscalationTile(item: item),
      ],
    );
  }
}

@Preview(name: 'Talent escalation board panel')
Widget incomingTalentOperatingEscalationBoardPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentOperatingEscalationsProvider.overrideWithValue(
        _previewEscalations,
      ),
      incomingTalentOperatingEscalationSummaryProvider.overrideWithValue(
        IncomingTalentOperatingEscalationSummary.fromItems(_previewEscalations),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentOperatingEscalationBoardPanel(),
        ),
      ),
    ),
  );
}

final _previewEscalations = [
  IncomingTalentOperatingEscalationItem(
    source: IncomingTalentOperatingEscalationSource.cadence,
    severity: IncomingTalentOperatingEscalationSeverity.critical,
    title: 'Overdue talent cadence',
    detail: '2 items across 2 owners and 2 workstreams',
    nextAction: 'Recover 2 overdue talent cadence items.',
    signalCount: 4,
    dueDate: DateTime(2026, 6, 10),
    overdue: true,
    dueToday: false,
    ownerName: null,
    workstreamLabel: null,
    pressureRatio: 0.75,
    referenceIds: const ['risk-overdue', 'career-overdue'],
  ),
  const IncomingTalentOperatingEscalationItem(
    source: IncomingTalentOperatingEscalationSource.ownerRebalance,
    severity: IncomingTalentOperatingEscalationSeverity.high,
    title: 'Relieve People Operations Talent Partner',
    detail: 'Move 2 items to Engineering HRBP',
    nextAction:
        'Move 2 urgent talent items from People Operations Talent Partner to Engineering HRBP.',
    signalCount: 3,
    dueDate: null,
    overdue: false,
    dueToday: false,
    ownerName: 'People Operations Talent Partner',
    workstreamLabel: null,
    pressureRatio: 0.62,
    referenceIds: [],
  ),
];
