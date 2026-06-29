import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import '../states/incoming_talent_operating_inbox_provider.dart';
import 'incoming_talent_operating_evidence_gap_tile.dart';

/// Audit board for missing proof across active talent operating work.
class IncomingTalentOperatingEvidenceGapPanel extends ConsumerWidget {
  const IncomingTalentOperatingEvidenceGapPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gaps = ref.watch(incomingTalentOperatingEvidenceGapsProvider);
    final summary = ref.watch(
      incomingTalentOperatingEvidenceGapSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.plagiarism_outlined,
      title: 'Talent evidence gaps',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent evidence gaps',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Gaps', value: '${summary.totalCount}'),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueCount}',
            ),
            HrisMetricStripItem(
              label: 'Linked',
              value: '${summary.linkedEscalationCount}',
            ),
          ],
        ),
        if (gaps.isEmpty)
          const HrisListSurface(
            child: Text('No active talent evidence gaps need review.'),
          )
        else
          for (final gap in gaps.take(6))
            IncomingTalentOperatingEvidenceGapTile(gap: gap),
      ],
    );
  }
}

@Preview(name: 'Talent evidence gap panel')
Widget incomingTalentOperatingEvidenceGapPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentOperatingEvidenceGapsProvider.overrideWithValue(
        _previewGaps,
      ),
      incomingTalentOperatingEvidenceGapSummaryProvider.overrideWithValue(
        IncomingTalentOperatingEvidenceGapSummary.fromItems(_previewGaps),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentOperatingEvidenceGapPanel(),
        ),
      ),
    ),
  );
}

final _previewGaps = [
  IncomingTalentOperatingEvidenceGap(
    id: 'evidence-risk-overdue',
    type: IncomingTalentOperatingEvidenceGapType.riskCouncilEvidence,
    risk: IncomingTalentOperatingEvidenceGapRisk.critical,
    title: 'Risk council evidence: Ari Talent',
    subjectName: 'Ari Talent',
    ownerName: 'People Operations Talent Partner',
    workstreamLabel: 'Risk council',
    statusLabel: 'Blocked',
    evidenceRequest:
        'Attach decision notes, owner commitment, and follow-up acceptance.',
    nextAction: 'Recover overdue risk council evidence for Ari Talent.',
    dueDate: DateTime(2026, 6, 10),
    daysUntilDue: -1,
    overdue: true,
    dueToday: false,
    linkedEscalationCount: 2,
    pressureRatio: 0.91,
    referenceIds: const ['risk-overdue'],
  ),
  IncomingTalentOperatingEvidenceGap(
    id: 'evidence-training-today',
    type: IncomingTalentOperatingEvidenceGapType.learningEvidence,
    risk: IncomingTalentOperatingEvidenceGapRisk.high,
    title: 'Learning evidence: Bima Talent',
    subjectName: 'Bima Talent',
    ownerName: 'Learning Partner',
    workstreamLabel: 'Development',
    statusLabel: 'Pending proof',
    evidenceRequest:
        'Attach attendance, completion proof, and learner feedback.',
    nextAction: 'Close learning evidence for Bima Talent today.',
    dueDate: DateTime(2026, 6, 11),
    daysUntilDue: 0,
    overdue: false,
    dueToday: true,
    linkedEscalationCount: 1,
    pressureRatio: 0.73,
    referenceIds: const ['training-today'],
  ),
];
