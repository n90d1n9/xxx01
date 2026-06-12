import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_command_center_models.dart';
import '../models/incoming_talent_governance_review_pack_models.dart';
import 'talent_meta_label.dart';

/// Decision tile for one item in the talent governance review pack.
class IncomingTalentGovernanceReviewItemTile extends StatelessWidget {
  final IncomingTalentGovernanceReviewItem item;

  const IncomingTalentGovernanceReviewItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentGovernanceReviewItemStatusColor(item.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_decisionIcon(item.decisionKind), color: color),
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
                      item.decisionKind.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.dueLabel, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.decisionQuestion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.recommendedDecision,
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
                label: item.ownerLabel,
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${item.timeboxMinutes} min',
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
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentGovernanceReviewItemStatusColor(
  IncomingTalentGovernanceCommandStatus status,
) {
  return switch (status) {
    IncomingTalentGovernanceCommandStatus.critical => const Color(0xFFDC2626),
    IncomingTalentGovernanceCommandStatus.watch => const Color(0xFFD97706),
    IncomingTalentGovernanceCommandStatus.stable => const Color(0xFF059669),
  };
}

IconData _decisionIcon(IncomingTalentGovernanceReviewDecisionKind kind) {
  return switch (kind) {
    IncomingTalentGovernanceReviewDecisionKind.unblock =>
      Icons.lock_open_outlined,
    IncomingTalentGovernanceReviewDecisionKind.allocate =>
      Icons.account_tree_outlined,
    IncomingTalentGovernanceReviewDecisionKind.approve =>
      Icons.verified_outlined,
    IncomingTalentGovernanceReviewDecisionKind.align => Icons.hub_outlined,
    IncomingTalentGovernanceReviewDecisionKind.monitor =>
      Icons.visibility_outlined,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance review item tile')
Widget incomingTalentGovernanceReviewItemTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceReviewItemTile(item: _previewItem),
      ),
    ),
  );
}

const _previewItem = IncomingTalentGovernanceReviewItem(
  id: 'review-pack-governance-lane-assurance',
  laneType: IncomingTalentGovernanceCommandLaneType.assurance,
  status: IncomingTalentGovernanceCommandStatus.critical,
  decisionKind: IncomingTalentGovernanceReviewDecisionKind.approve,
  title: 'Assurance',
  decisionQuestion:
      'What leadership decision removes the assurance blocker today?',
  recommendedDecision:
      'Approve immediate intervention for assurance: Unblock 1 assurance remediation execution track.',
  ownerLabel: 'People Risk and Assurance',
  evidencePrompt: 'Gaps 4 with 5 active signals.',
  dueLabel: 'Decision today',
  signalCount: 5,
  decisionCount: 3,
  timeboxMinutes: 15,
  pressureRatio: 0.74,
);
