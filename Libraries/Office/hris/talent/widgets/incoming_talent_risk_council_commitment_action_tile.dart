import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_commitment_action_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentRiskCouncilCommitmentActionTile extends StatelessWidget {
  final IncomingTalentRiskCouncilCommitmentAction action;
  final VoidCallback onStart;
  final VoidCallback onRequestEvidence;
  final VoidCallback onBlock;
  final VoidCallback onEscalate;
  final VoidCallback onComplete;

  const IncomingTalentRiskCouncilCommitmentActionTile({
    super.key,
    required this.action,
    required this.onStart,
    required this.onRequestEvidence,
    required this.onBlock,
    required this.onEscalate,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentRiskCouncilCommitmentActionStatusColor(
      action.status,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon(action.status), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.type.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      action.sourceStatus.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: action.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            action.actionPlan,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action.evidenceNote.isNotEmpty
                ? action.evidenceNote
                : action.evidenceExpectation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          if (action.blockerNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              action.blockerNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB45309),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: action.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(action.dueDate),
              ),
              TalentMetaLabel(
                icon: Icons.repeat_outlined,
                label: action.followUpCadence,
              ),
              TalentMetaLabel(
                icon: Icons.confirmation_number_outlined,
                label: '${action.sourceCount} signals',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentRiskCouncilCommitmentActionStatus
                                  .inProgress
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentRiskCouncilCommitmentActionStatus
                                  .waitingEvidence
                          ? null
                          : onRequestEvidence,
                  icon: const Icon(Icons.article_outlined),
                  label: const Text('Evidence'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentRiskCouncilCommitmentActionStatus
                                  .blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentRiskCouncilCommitmentActionStatus
                                  .escalated
                          ? null
                          : onEscalate,
                  icon: const Icon(Icons.trending_up_outlined),
                  label: const Text('Escalate'),
                ),
                FilledButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentRiskCouncilCommitmentActionStatus
                                  .completed
                          ? null
                          : onComplete,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Complete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color incomingTalentRiskCouncilCommitmentActionStatusColor(
  IncomingTalentRiskCouncilCommitmentActionStatus status,
) {
  return switch (status) {
    IncomingTalentRiskCouncilCommitmentActionStatus.planned => const Color(
      0xFF2563EB,
    ),
    IncomingTalentRiskCouncilCommitmentActionStatus.inProgress => const Color(
      0xFF059669,
    ),
    IncomingTalentRiskCouncilCommitmentActionStatus.waitingEvidence =>
      const Color(0xFF7C3AED),
    IncomingTalentRiskCouncilCommitmentActionStatus.blocked => const Color(
      0xFFD97706,
    ),
    IncomingTalentRiskCouncilCommitmentActionStatus.escalated => const Color(
      0xFFDC2626,
    ),
    IncomingTalentRiskCouncilCommitmentActionStatus.completed => const Color(
      0xFF15803D,
    ),
  };
}

IconData _statusIcon(IncomingTalentRiskCouncilCommitmentActionStatus status) {
  return switch (status) {
    IncomingTalentRiskCouncilCommitmentActionStatus.planned =>
      Icons.event_note_outlined,
    IncomingTalentRiskCouncilCommitmentActionStatus.inProgress =>
      Icons.play_circle_outline,
    IncomingTalentRiskCouncilCommitmentActionStatus.waitingEvidence =>
      Icons.article_outlined,
    IncomingTalentRiskCouncilCommitmentActionStatus.blocked =>
      Icons.report_problem_outlined,
    IncomingTalentRiskCouncilCommitmentActionStatus.escalated =>
      Icons.trending_up_outlined,
    IncomingTalentRiskCouncilCommitmentActionStatus.completed =>
      Icons.check_circle_outline,
  };
}
