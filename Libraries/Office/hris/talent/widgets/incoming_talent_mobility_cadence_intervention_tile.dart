import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentMobilityCadenceInterventionTile extends StatelessWidget {
  final IncomingTalentMobilityCadenceIntervention intervention;
  final VoidCallback onStart;
  final VoidCallback onBlock;
  final VoidCallback onResolve;

  const IncomingTalentMobilityCadenceInterventionTile({
    super.key,
    required this.intervention,
    required this.onStart,
    required this.onBlock,
    required this.onResolve,
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
              const Icon(
                Icons.medical_services_outlined,
                color: HrisColors.primary,
              ),
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
                      '${intervention.interventionType.label} - ${intervention.priority.label}',
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
          const SizedBox(height: 12),
          HrisProgressBar(
            value: intervention.progressRatio,
            color: color,
            label: '${(intervention.progressRatio * 100).round()}% progress',
          ),
          const SizedBox(height: 10),
          Text(
            intervention.interventionSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (intervention.blockerNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              intervention.blockerNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: intervention.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: intervention.hostDepartment,
              ),
              TalentMetaLabel(
                icon: Icons.shield_outlined,
                label: intervention.residualRisk.label,
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
                              IncomingTalentMobilityCadenceInterventionStatus
                                  .blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      intervention.status ==
                              IncomingTalentMobilityCadenceInterventionStatus
                                  .inProgress
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                FilledButton.icon(
                  onPressed:
                      intervention.status ==
                              IncomingTalentMobilityCadenceInterventionStatus
                                  .resolved
                          ? null
                          : onResolve,
                  icon: const Icon(Icons.task_alt_outlined),
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

Color _statusColor(IncomingTalentMobilityCadenceInterventionStatus status) {
  return switch (status) {
    IncomingTalentMobilityCadenceInterventionStatus.planned => const Color(
      0xFF2563EB,
    ),
    IncomingTalentMobilityCadenceInterventionStatus.inProgress => const Color(
      0xFF059669,
    ),
    IncomingTalentMobilityCadenceInterventionStatus.blocked => const Color(
      0xFFDC2626,
    ),
    IncomingTalentMobilityCadenceInterventionStatus.resolved => const Color(
      0xFF15803D,
    ),
  };
}
