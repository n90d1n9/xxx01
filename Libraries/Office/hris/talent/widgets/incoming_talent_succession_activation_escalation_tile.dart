import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionActivationEscalationTile extends StatelessWidget {
  final IncomingTalentSuccessionActivationEscalation escalation;
  final VoidCallback onStart;
  final VoidCallback onResolve;
  final VoidCallback onBlock;

  const IncomingTalentSuccessionActivationEscalationTile({
    super.key,
    required this.escalation,
    required this.onStart,
    required this.onResolve,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(escalation.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.escalator_warning_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      escalation.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${escalation.priority.label} - ${escalation.targetRole}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: escalation.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            escalation.decisionNeeded,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            escalation.escalationReason,
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
                icon: Icons.apartment_outlined,
                label: escalation.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: escalation.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.trending_up_outlined,
                label: escalation.checkInTrend.label,
              ),
              TalentMetaLabel(
                icon: Icons.speed_outlined,
                label: '${escalation.confidenceScore}/5',
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(escalation.dueDate),
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
                      escalation.status ==
                              IncomingTalentSuccessionActivationEscalationStatus
                                  .inProgress
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      escalation.status ==
                              IncomingTalentSuccessionActivationEscalationStatus
                                  .blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                FilledButton.icon(
                  onPressed:
                      escalation.status ==
                              IncomingTalentSuccessionActivationEscalationStatus
                                  .resolved
                          ? null
                          : onResolve,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Resolve'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentSuccessionActivationEscalationStatus status) {
  return switch (status) {
    IncomingTalentSuccessionActivationEscalationStatus.opened => const Color(
      0xFF2563EB,
    ),
    IncomingTalentSuccessionActivationEscalationStatus.inProgress =>
      const Color(0xFF059669),
    IncomingTalentSuccessionActivationEscalationStatus.resolved => const Color(
      0xFF15803D,
    ),
    IncomingTalentSuccessionActivationEscalationStatus.blocked => const Color(
      0xFFDC2626,
    ),
  };
}
