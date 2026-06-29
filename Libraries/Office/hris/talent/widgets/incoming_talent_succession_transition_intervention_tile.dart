import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionTransitionInterventionTile
    extends StatelessWidget {
  final IncomingTalentSuccessionTransitionIntervention intervention;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onBlock;

  const IncomingTalentSuccessionTransitionInterventionTile({
    super.key,
    required this.intervention,
    required this.onStart,
    required this.onComplete,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(intervention.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.healing_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      intervention.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${intervention.interventionType.label} - ${intervention.pulseWindow.label}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: intervention.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            intervention.interventionPlan,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            intervention.successMetric,
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
                label: intervention.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: intervention.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.monitor_heart_outlined,
                label: intervention.pulseHealth.label,
              ),
              TalentMetaLabel(
                icon: Icons.shield_outlined,
                label: intervention.retentionRisk.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(intervention.dueDate),
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
                      intervention.status ==
                              IncomingTalentSuccessionTransitionInterventionStatus
                                  .inProgress
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      intervention.status ==
                              IncomingTalentSuccessionTransitionInterventionStatus
                                  .blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                FilledButton.icon(
                  onPressed:
                      intervention.status ==
                              IncomingTalentSuccessionTransitionInterventionStatus
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

Color _statusColor(
  IncomingTalentSuccessionTransitionInterventionStatus status,
) {
  return switch (status) {
    IncomingTalentSuccessionTransitionInterventionStatus.planned => const Color(
      0xFF2563EB,
    ),
    IncomingTalentSuccessionTransitionInterventionStatus.inProgress =>
      const Color(0xFF059669),
    IncomingTalentSuccessionTransitionInterventionStatus.completed =>
      const Color(0xFF15803D),
    IncomingTalentSuccessionTransitionInterventionStatus.blocked => const Color(
      0xFFDC2626,
    ),
  };
}
