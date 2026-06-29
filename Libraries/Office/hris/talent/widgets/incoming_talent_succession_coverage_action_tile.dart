import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionCoverageActionTile extends StatelessWidget {
  final IncomingTalentSuccessionCoverageAction action;
  final VoidCallback onStart;
  final VoidCallback onResolve;
  final VoidCallback onBlock;

  const IncomingTalentSuccessionCoverageActionTile({
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
                      action.scopeLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${action.actionType.label} - ${action.reviewDecision.label}',
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
                icon: Icons.badge_outlined,
                label: action.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.fact_check_outlined,
                label: '${action.coverageScore}% coverage',
              ),
              TalentMetaLabel(
                icon: Icons.monitor_heart_outlined,
                label: action.coverageHealth.label,
              ),
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: action.departmentScope,
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
                              IncomingTalentSuccessionCoverageActionStatus
                                  .inProgress
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentSuccessionCoverageActionStatus
                                  .blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                FilledButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentSuccessionCoverageActionStatus
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

Color _statusColor(IncomingTalentSuccessionCoverageActionStatus status) {
  return switch (status) {
    IncomingTalentSuccessionCoverageActionStatus.planned => const Color(
      0xFF2563EB,
    ),
    IncomingTalentSuccessionCoverageActionStatus.inProgress => const Color(
      0xFF059669,
    ),
    IncomingTalentSuccessionCoverageActionStatus.resolved => const Color(
      0xFF15803D,
    ),
    IncomingTalentSuccessionCoverageActionStatus.blocked => const Color(
      0xFFDC2626,
    ),
  };
}
