import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import '../states/incoming_talent_operating_inbox_provider.dart';
import 'incoming_talent_operating_sla_tile.dart';

/// Cross-HRIS SLA monitor for active talent operating work.
class IncomingTalentOperatingSlaPanel extends ConsumerWidget {
  const IncomingTalentOperatingSlaPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(incomingTalentOperatingSlaItemsProvider);
    final summary = ref.watch(incomingTalentOperatingSlaSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.timer_outlined,
      title: 'Talent action SLA monitor',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent operating SLA data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueCount}',
            ),
            HrisMetricStripItem(
              label: 'Today',
              value: '${summary.dueTodayCount}',
            ),
            HrisMetricStripItem(
              label: 'At risk',
              value: '${summary.atRiskCount}',
            ),
            HrisMetricStripItem(
              label: 'On track',
              value: '${summary.onTrackCount}',
            ),
          ],
        ),
        if (items.isEmpty)
          const HrisListSurface(
            child: Text('All talent operating SLAs are clear.'),
          )
        else
          for (final item in items.take(6))
            IncomingTalentOperatingSlaTile(item: item),
      ],
    );
  }
}

@Preview(name: 'Talent action SLA monitor panel')
Widget incomingTalentOperatingSlaPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentOperatingSlaItemsProvider.overrideWithValue(_previewItems),
      incomingTalentOperatingSlaSummaryProvider.overrideWithValue(
        IncomingTalentOperatingSlaSummary.fromItems(_previewItems),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentOperatingSlaPanel(),
        ),
      ),
    ),
  );
}

final _previewItems = [
  IncomingTalentOperatingSlaItem(
    id: 'operating-sla-assurance-preview',
    referenceId: 'assurance-execution-preview',
    source: IncomingTalentOperatingSlaSource.assurance,
    status: IncomingTalentOperatingSlaStatus.overdue,
    title: 'People Operations Talent Partner execution - Risk council',
    subjectName: 'Risk council',
    department: 'Talent assurance',
    ownerName: 'People Operations Talent Partner',
    workstreamLabel: 'Assurance - Risk council',
    priorityLabel: 'Critical',
    nextAction:
        'Unblock linked risk council escalations with People Operations Talent Partner.',
    dueDate: DateTime(2026, 6, 10),
    daysUntilDue: -1,
    slaPressureRatio: 0.82,
    evidenceCount: 3,
    referenceIds: const ['evidence-risk-overdue', 'evidence-risk-linked'],
  ),
  IncomingTalentOperatingSlaItem(
    id: 'operating-sla-training-preview',
    referenceId: 'training-session-preview',
    source: IncomingTalentOperatingSlaSource.training,
    status: IncomingTalentOperatingSlaStatus.dueToday,
    title: 'Confirm training session evidence',
    subjectName: 'Ari Talent',
    department: 'People Operations',
    ownerName: 'Learning Partner',
    workstreamLabel: 'Training',
    priorityLabel: 'Watch',
    nextAction: 'Close due-today training evidence before HRIS cut-off.',
    dueDate: DateTime(2026, 6, 11),
    daysUntilDue: 0,
    slaPressureRatio: 0.58,
    evidenceCount: 0,
    referenceIds: const ['training-session-preview'],
  ),
];
