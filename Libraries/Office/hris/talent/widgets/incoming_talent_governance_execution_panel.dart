import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import '../states/incoming_talent_governance_execution_provider.dart';
import 'incoming_talent_governance_execution_track_tile.dart';
import 'talent_meta_label.dart';

/// Execution tracker for talent governance decisions after publication.
class IncomingTalentGovernanceExecutionPanel extends ConsumerWidget {
  const IncomingTalentGovernanceExecutionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(incomingTalentGovernanceExecutionTracksProvider);
    final summary = ref.watch(incomingTalentGovernanceExecutionSummaryProvider);
    final color = incomingTalentGovernanceExecutionSummaryColor(summary);

    return HrisSectionPanel(
      icon: Icons.task_alt_outlined,
      title: 'Talent governance execution tracker',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent governance execution tracks',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Tracks',
              value: '${summary.totalCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Evidence',
              value: '${summary.evidenceRecoveryCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisProgressBar(
                value: summary.averageProgressRatio,
                color: color,
                label:
                    '${(summary.averageProgressRatio * 100).round()}% execution progress',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TalentMetaLabel(
                    icon: Icons.play_circle_outline,
                    label:
                        '${summary.inProgressCount} in-progress ${_plural(summary.inProgressCount, 'track')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.gavel_outlined,
                    label:
                        '${summary.decisionCount} governance ${_plural(summary.decisionCount, 'decision')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.warning_amber_outlined,
                    label:
                        '${summary.signalCount} active ${_plural(summary.signalCount, 'signal')}',
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final track in tracks.take(5))
          IncomingTalentGovernanceExecutionTrackTile(track: track),
      ],
    );
  }
}

Color incomingTalentGovernanceExecutionSummaryColor(
  IncomingTalentGovernanceExecutionSummary summary,
) {
  if (summary.blockedCount > 0 || summary.overdueCount > 0) {
    return const Color(0xFFDC2626);
  }
  if (summary.awaitingDecisionCount > 0 ||
      summary.evidenceRecoveryCount > 0 ||
      summary.ownerConfirmationCount > 0) {
    return const Color(0xFFD97706);
  }
  return const Color(0xFF059669);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance execution tracker panel')
Widget incomingTalentGovernanceExecutionPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentGovernanceExecutionTracksProvider.overrideWithValue(
        _previewTracks,
      ),
      incomingTalentGovernanceExecutionSummaryProvider.overrideWithValue(
        _previewSummary,
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentGovernanceExecutionPanel(),
        ),
      ),
    ),
  );
}

final _previewTracks = [
  IncomingTalentGovernanceExecutionTrack(
    id:
        'talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-assurance',
    ledgerItemId:
        'talent-governance-decision-ledger:review-pack-governance-lane-assurance',
    status: IncomingTalentGovernanceExecutionStatus.blocked,
    title: 'Execute assurance approval decision',
    actionPlan:
        'Unblock publish assurance approval decision before assigning follow-through.',
    evidenceExpectation:
        'Approve immediate intervention for assurance: Unblock 1 assurance remediation execution track. Evidence: Gaps 4 with 5 active signals.',
    blockerNote:
        'Readiness blockers must be resolved before execution can move.',
    ownerName: 'People Risk and Assurance',
    dueDate: DateTime(2026, 6, 11),
    progressRatio: 0.1,
    signalCount: 5,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: true,
  ),
  IncomingTalentGovernanceExecutionTrack(
    id:
        'talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-action-sla',
    ledgerItemId:
        'talent-governance-decision-ledger:review-pack-governance-lane-action-sla',
    status: IncomingTalentGovernanceExecutionStatus.evidenceRecovery,
    title: 'Execute action SLA unblock decision',
    actionPlan:
        'Attach execution evidence for publish action SLA unblock decision and refresh recovery notes.',
    evidenceExpectation:
        'Keep action SLA on weekly governance watch and confirm the accountable owner. Evidence: SLAs 8 with 3 active signals.',
    blockerNote: 'Execution evidence is missing or not current.',
    ownerName: 'Talent Operations',
    dueDate: DateTime(2026, 6, 14),
    progressRatio: 0.45,
    signalCount: 3,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: false,
  ),
];

const _previewSummary = IncomingTalentGovernanceExecutionSummary(
  totalCount: 2,
  completedCount: 0,
  inProgressCount: 0,
  blockedCount: 1,
  awaitingDecisionCount: 0,
  evidenceRecoveryCount: 1,
  ownerConfirmationCount: 0,
  overdueCount: 1,
  attentionCount: 2,
  signalCount: 8,
  decisionCount: 6,
  averageProgressRatio: 0.275,
  nextAction: 'Unblock 1 governance execution track.',
);
