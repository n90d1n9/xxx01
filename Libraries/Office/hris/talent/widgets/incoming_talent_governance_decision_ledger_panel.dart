import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_decision_ledger_models.dart';
import '../states/incoming_talent_governance_decision_ledger_provider.dart';
import 'incoming_talent_governance_decision_ledger_tile.dart';
import 'talent_meta_label.dart';

/// Executive ledger for publishing talent governance decisions and commitments.
class IncomingTalentGovernanceDecisionLedgerPanel extends ConsumerWidget {
  const IncomingTalentGovernanceDecisionLedgerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(
      incomingTalentGovernanceDecisionLedgerItemsProvider,
    );
    final summary = ref.watch(
      incomingTalentGovernanceDecisionLedgerSummaryProvider,
    );
    final color = incomingTalentGovernanceDecisionLedgerSummaryColor(summary);

    return HrisSectionPanel(
      icon: Icons.assignment_turned_in_outlined,
      title: 'Talent governance decision ledger',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent governance decisions',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ledger',
              value: '${summary.totalCount}',
            ),
            HrisMetricStripItem(
              label: 'Decision',
              value: '${summary.needsDecisionCount}',
            ),
            HrisMetricStripItem(
              label: 'Evidence',
              value: '${summary.needsEvidenceCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisProgressBar(
                value: summary.publishableRatio,
                color: color,
                label:
                    '${(summary.publishableRatio * 100).round()}% publish-ready',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TalentMetaLabel(
                    icon: Icons.warning_amber_outlined,
                    label:
                        '${summary.signalCount} active ${_plural(summary.signalCount, 'signal')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.gavel_outlined,
                    label:
                        '${summary.decisionCount} governance ${_plural(summary.decisionCount, 'decision')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.timer_outlined,
                    label:
                        '${summary.totalTimeboxMinutes} review ${_plural(summary.totalTimeboxMinutes, 'minute')}',
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final item in items.take(5))
          IncomingTalentGovernanceDecisionLedgerTile(item: item),
      ],
    );
  }
}

Color incomingTalentGovernanceDecisionLedgerSummaryColor(
  IncomingTalentGovernanceDecisionLedgerSummary summary,
) {
  if (summary.blockedCount > 0 || summary.needsDecisionCount > 0) {
    return const Color(0xFFDC2626);
  }
  if (summary.needsEvidenceCount > 0 || summary.needsOwnerCount > 0) {
    return const Color(0xFFD97706);
  }
  return const Color(0xFF059669);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance decision ledger panel')
Widget incomingTalentGovernanceDecisionLedgerPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentGovernanceDecisionLedgerItemsProvider.overrideWithValue(
        _previewItems,
      ),
      incomingTalentGovernanceDecisionLedgerSummaryProvider.overrideWithValue(
        _previewSummary,
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentGovernanceDecisionLedgerPanel(),
        ),
      ),
    ),
  );
}

final _previewItems = [
  IncomingTalentGovernanceDecisionLedgerItem(
    id: 'talent-governance-decision-ledger:review-pack-governance-lane-assurance',
    reviewItemId: 'review-pack-governance-lane-assurance',
    type: IncomingTalentGovernanceDecisionLedgerType.approvalDecision,
    status: IncomingTalentGovernanceDecisionLedgerStatus.blocked,
    title: 'Publish assurance approval decision',
    decisionRecord:
        'What leadership decision removes the assurance blocker today?',
    commitment: 'Capture the approval decision and conditions for closure.',
    evidenceExpectation:
        'Approve immediate intervention for assurance: Unblock 1 assurance remediation execution track. Evidence: Gaps 4 with 5 active signals.',
    ownerName: 'People Risk and Assurance',
    dueDate: DateTime(2026, 6, 11),
    signalCount: 5,
    decisionCount: 3,
    timeboxMinutes: 15,
    readinessTaskIds: const [
      'talent-governance-review-readiness:review-pack-governance-lane-assurance',
    ],
  ),
  IncomingTalentGovernanceDecisionLedgerItem(
    id:
        'talent-governance-decision-ledger:review-pack-governance-lane-action-sla',
    reviewItemId: 'review-pack-governance-lane-action-sla',
    type: IncomingTalentGovernanceDecisionLedgerType.executiveUnblock,
    status: IncomingTalentGovernanceDecisionLedgerStatus.needsEvidence,
    title: 'Publish action SLA unblock decision',
    decisionRecord:
        'Which owner and evidence keep action SLA on track this week?',
    commitment:
        'Capture the unblock decision, accountable owner, and recovery date.',
    evidenceExpectation:
        'Keep action SLA on weekly governance watch and confirm the accountable owner. Evidence: SLAs 8 with 3 active signals.',
    ownerName: 'Talent Operations',
    dueDate: DateTime(2026, 6, 14),
    signalCount: 3,
    decisionCount: 3,
    timeboxMinutes: 10,
    readinessTaskIds: const [
      'talent-governance-review-readiness:review-pack-governance-lane-action-sla',
    ],
  ),
];

const _previewSummary = IncomingTalentGovernanceDecisionLedgerSummary(
  totalCount: 2,
  clearCount: 0,
  readyToPublishCount: 0,
  blockedCount: 1,
  needsDecisionCount: 0,
  needsEvidenceCount: 1,
  needsOwnerCount: 0,
  attentionCount: 2,
  decisionCount: 6,
  signalCount: 8,
  totalTimeboxMinutes: 25,
  publishableRatio: 0,
  nextAction: 'Resolve 1 blocked governance decision before publishing.',
);
