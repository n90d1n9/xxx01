import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_decision_ledger_models.dart';
import 'talent_meta_label.dart';

/// Tile for one publishable executive talent governance decision.
class IncomingTalentGovernanceDecisionLedgerTile extends StatelessWidget {
  final IncomingTalentGovernanceDecisionLedgerItem item;

  const IncomingTalentGovernanceDecisionLedgerTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentGovernanceDecisionLedgerStatusColor(
      item.status,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_typeIcon(item.type), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.type.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.commitment,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.evidenceExpectation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: item.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(item.dueDate),
              ),
              TalentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label:
                    '${item.signalCount} ${_plural(item.signalCount, 'signal')}',
              ),
              TalentMetaLabel(
                icon: Icons.gavel_outlined,
                label:
                    '${item.decisionCount} ${_plural(item.decisionCount, 'decision')}',
              ),
              TalentMetaLabel(
                icon: Icons.checklist_outlined,
                label:
                    '${item.readinessTaskIds.length} prep ${_plural(item.readinessTaskIds.length, 'task')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentGovernanceDecisionLedgerStatusColor(
  IncomingTalentGovernanceDecisionLedgerStatus status,
) {
  return switch (status) {
    IncomingTalentGovernanceDecisionLedgerStatus.clear => const Color(
      0xFF059669,
    ),
    IncomingTalentGovernanceDecisionLedgerStatus.blocked => const Color(
      0xFFDC2626,
    ),
    IncomingTalentGovernanceDecisionLedgerStatus.needsDecision => const Color(
      0xFFD97706,
    ),
    IncomingTalentGovernanceDecisionLedgerStatus.needsEvidence => const Color(
      0xFF7C3AED,
    ),
    IncomingTalentGovernanceDecisionLedgerStatus.needsOwner => const Color(
      0xFF2563EB,
    ),
    IncomingTalentGovernanceDecisionLedgerStatus.readyToPublish => const Color(
      0xFF059669,
    ),
  };
}

IconData _typeIcon(IncomingTalentGovernanceDecisionLedgerType type) {
  return switch (type) {
    IncomingTalentGovernanceDecisionLedgerType.clear =>
      Icons.event_available_outlined,
    IncomingTalentGovernanceDecisionLedgerType.executiveUnblock =>
      Icons.lock_open_outlined,
    IncomingTalentGovernanceDecisionLedgerType.capacityCommitment =>
      Icons.account_tree_outlined,
    IncomingTalentGovernanceDecisionLedgerType.approvalDecision =>
      Icons.verified_outlined,
    IncomingTalentGovernanceDecisionLedgerType.ownerAlignment =>
      Icons.assignment_ind_outlined,
    IncomingTalentGovernanceDecisionLedgerType.monitoringRecord =>
      Icons.visibility_outlined,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance decision ledger tile')
Widget incomingTalentGovernanceDecisionLedgerTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceDecisionLedgerTile(item: _previewItem),
      ),
    ),
  );
}

final _previewItem = IncomingTalentGovernanceDecisionLedgerItem(
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
);
