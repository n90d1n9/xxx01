import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionBenchActionTile extends StatelessWidget {
  final IncomingTalentSuccessionBenchAction action;
  final VoidCallback onStart;
  final VoidCallback onResolve;
  final VoidCallback onBlock;

  const IncomingTalentSuccessionBenchActionTile({
    super.key,
    required this.action,
    required this.onStart,
    required this.onResolve,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(action.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.role,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${action.actionType.label} - ${action.checkInHealth.label}',
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
            action.escalationPath,
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
                icon: Icons.person_outline,
                label: action.candidateName,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: action.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: action.priority.label,
              ),
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: action.department,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(action.dueDate),
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
                              IncomingTalentSuccessionBenchActionStatus
                                  .inProgress
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentSuccessionBenchActionStatus.blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                FilledButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentSuccessionBenchActionStatus.resolved
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

Color _statusColor(IncomingTalentSuccessionBenchActionStatus status) {
  return switch (status) {
    IncomingTalentSuccessionBenchActionStatus.planned => const Color(
      0xFF2563EB,
    ),
    IncomingTalentSuccessionBenchActionStatus.inProgress => const Color(
      0xFF059669,
    ),
    IncomingTalentSuccessionBenchActionStatus.resolved => const Color(
      0xFF15803D,
    ),
    IncomingTalentSuccessionBenchActionStatus.blocked => const Color(
      0xFFDC2626,
    ),
  };
}
