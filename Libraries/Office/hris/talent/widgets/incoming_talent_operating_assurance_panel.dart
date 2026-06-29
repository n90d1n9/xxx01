import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import '../states/incoming_talent_operating_inbox_provider.dart';
import 'incoming_talent_operating_assurance_tile.dart';

/// Workstream-level audit assurance board for talent operations.
class IncomingTalentOperatingAssurancePanel extends ConsumerWidget {
  const IncomingTalentOperatingAssurancePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workstreams = ref.watch(
      incomingTalentOperatingAssuranceWorkstreamsProvider,
    );
    final summary = ref.watch(incomingTalentOperatingAssuranceSummaryProvider);
    final attentionWorkstreams =
        workstreams.where((workstream) => workstream.needsAttention).toList();

    return HrisSectionPanel(
      icon: Icons.verified_user_outlined,
      title: 'Talent assurance board',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent assurance exposure',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Workstreams',
              value: '${summary.workstreamCount}',
            ),
            HrisMetricStripItem(
              label: 'Exposed',
              value: '${summary.exposedWorkstreamCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueGapCount}',
            ),
            HrisMetricStripItem(
              label: 'Linked',
              value: '${summary.linkedEscalationCount}',
            ),
          ],
        ),
        if (attentionWorkstreams.isEmpty)
          const HrisListSurface(
            child: Text('All talent workstreams are audit-ready.'),
          )
        else
          for (final workstream in attentionWorkstreams.take(4))
            IncomingTalentOperatingAssuranceTile(workstream: workstream),
      ],
    );
  }
}

@Preview(name: 'Talent assurance board panel')
Widget incomingTalentOperatingAssurancePanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentOperatingAssuranceWorkstreamsProvider.overrideWithValue(
        _previewWorkstreams,
      ),
      incomingTalentOperatingAssuranceSummaryProvider.overrideWithValue(
        IncomingTalentOperatingAssuranceSummary.fromWorkstreams(
          _previewWorkstreams,
        ),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentOperatingAssurancePanel(),
        ),
      ),
    ),
  );
}

final _previewWorkstreams = [
  IncomingTalentOperatingAssuranceWorkstream(
    workstreamLabel: 'Risk council',
    level: IncomingTalentOperatingAssuranceLevel.exposed,
    gapCount: 2,
    criticalGapCount: 1,
    highGapCount: 1,
    watchGapCount: 0,
    overdueGapCount: 1,
    dueTodayGapCount: 0,
    linkedEscalationCount: 3,
    ownerCount: 2,
    nextDueDate: DateTime(2026, 6, 10),
    nextAction: 'Recover 1 overdue risk council evidence gap.',
    gapIds: const ['evidence-risk-overdue', 'evidence-risk-today'],
  ),
  IncomingTalentOperatingAssuranceWorkstream(
    workstreamLabel: 'Development',
    level: IncomingTalentOperatingAssuranceLevel.guarded,
    gapCount: 1,
    criticalGapCount: 0,
    highGapCount: 1,
    watchGapCount: 0,
    overdueGapCount: 0,
    dueTodayGapCount: 1,
    linkedEscalationCount: 1,
    ownerCount: 1,
    nextDueDate: DateTime(2026, 6, 11),
    nextAction: 'Close 1 development evidence gap due today.',
    gapIds: const ['evidence-training-today'],
  ),
  const IncomingTalentOperatingAssuranceWorkstream(
    workstreamLabel: 'Succession',
    level: IncomingTalentOperatingAssuranceLevel.ready,
    gapCount: 0,
    criticalGapCount: 0,
    highGapCount: 0,
    watchGapCount: 0,
    overdueGapCount: 0,
    dueTodayGapCount: 0,
    linkedEscalationCount: 0,
    ownerCount: 0,
    nextDueDate: null,
    nextAction: 'Succession assurance is ready.',
    gapIds: [],
  ),
];
