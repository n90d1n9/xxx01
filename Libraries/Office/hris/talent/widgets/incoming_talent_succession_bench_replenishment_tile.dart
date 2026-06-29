import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionBenchReplenishmentTile extends StatelessWidget {
  final IncomingTalentSuccessionBenchReplenishment plan;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onBlock;

  const IncomingTalentSuccessionBenchReplenishmentTile({
    super.key,
    required this.plan,
    required this.onStart,
    required this.onComplete,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(plan.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.role,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${plan.priority.label} bench rebuild - ${plan.department}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: plan.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            plan.benchGap,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.sourcingStrategy,
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
                label: plan.candidateName,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: plan.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.insights_outlined,
                label: plan.outcomeDecision.label,
              ),
              TalentMetaLabel(
                icon: Icons.shield_outlined,
                label: plan.residualRisk.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(plan.targetReadyDate),
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
                      plan.status ==
                              IncomingTalentSuccessionBenchReplenishmentStatus
                                  .active
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      plan.status ==
                              IncomingTalentSuccessionBenchReplenishmentStatus
                                  .blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                FilledButton.icon(
                  onPressed:
                      plan.status ==
                              IncomingTalentSuccessionBenchReplenishmentStatus
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

Color _statusColor(IncomingTalentSuccessionBenchReplenishmentStatus status) {
  return switch (status) {
    IncomingTalentSuccessionBenchReplenishmentStatus.planned => const Color(
      0xFF2563EB,
    ),
    IncomingTalentSuccessionBenchReplenishmentStatus.active => const Color(
      0xFF059669,
    ),
    IncomingTalentSuccessionBenchReplenishmentStatus.completed => const Color(
      0xFF15803D,
    ),
    IncomingTalentSuccessionBenchReplenishmentStatus.blocked => const Color(
      0xFFDC2626,
    ),
  };
}
