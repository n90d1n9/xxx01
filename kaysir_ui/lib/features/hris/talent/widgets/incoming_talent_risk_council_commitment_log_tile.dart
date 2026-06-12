import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_commitment_log_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentRiskCouncilCommitmentLogTile extends StatelessWidget {
  final IncomingTalentRiskCouncilCommitmentLogItem item;

  const IncomingTalentRiskCouncilCommitmentLogTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentRiskCouncilCommitmentLogStatusColor(
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
                icon: Icons.confirmation_number_outlined,
                label: '${item.sourceCount} signals',
              ),
              TalentMetaLabel(
                icon: Icons.checklist_outlined,
                label: '${item.readinessTaskIds.length} prep tasks',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentRiskCouncilCommitmentLogStatusColor(
  IncomingTalentRiskCouncilCommitmentLogStatus status,
) {
  return switch (status) {
    IncomingTalentRiskCouncilCommitmentLogStatus.clear => const Color(
      0xFF15803D,
    ),
    IncomingTalentRiskCouncilCommitmentLogStatus.blocked => const Color(
      0xFFD97706,
    ),
    IncomingTalentRiskCouncilCommitmentLogStatus.needsDecision => const Color(
      0xFFDC2626,
    ),
    IncomingTalentRiskCouncilCommitmentLogStatus.needsEvidence => const Color(
      0xFF7C3AED,
    ),
    IncomingTalentRiskCouncilCommitmentLogStatus.needsOwner => const Color(
      0xFF2563EB,
    ),
    IncomingTalentRiskCouncilCommitmentLogStatus.readyToPublish => const Color(
      0xFF15803D,
    ),
  };
}

IconData _typeIcon(IncomingTalentRiskCouncilCommitmentLogType type) {
  return switch (type) {
    IncomingTalentRiskCouncilCommitmentLogType.clear =>
      Icons.event_available_outlined,
    IncomingTalentRiskCouncilCommitmentLogType.leadershipDecision =>
      Icons.priority_high_outlined,
    IncomingTalentRiskCouncilCommitmentLogType.recoveryAction =>
      Icons.restore_outlined,
    IncomingTalentRiskCouncilCommitmentLogType.decisionRecord =>
      Icons.fact_check_outlined,
    IncomingTalentRiskCouncilCommitmentLogType.followUpPlan =>
      Icons.next_plan_outlined,
    IncomingTalentRiskCouncilCommitmentLogType.ownerUpdate =>
      Icons.assignment_ind_outlined,
    IncomingTalentRiskCouncilCommitmentLogType.executionEvidence =>
      Icons.article_outlined,
    IncomingTalentRiskCouncilCommitmentLogType.publishCloseout =>
      Icons.publish_outlined,
  };
}
