import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentMobilityStabilizationTile extends StatelessWidget {
  final IncomingTalentMobilityStabilizationAction action;
  final VoidCallback onStart;
  final VoidCallback onBlock;
  final VoidCallback onComplete;

  const IncomingTalentMobilityStabilizationTile({
    super.key,
    required this.action,
    required this.onStart,
    required this.onBlock,
    required this.onComplete,
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
              const Icon(Icons.add_task_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      action.actionType.label,
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
          const SizedBox(height: 12),
          HrisProgressBar(
            value: action.progressRatio,
            color: color,
            label: '${(action.progressRatio * 100).round()}% action progress',
          ),
          const SizedBox(height: 10),
          Text(
            action.actionSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (action.blockerNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              action.blockerNote,
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
                icon: Icons.apartment_outlined,
                label: action.hostDepartment,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: action.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.shield_outlined,
                label: action.retentionRisk.label,
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
                              IncomingTalentMobilityStabilizationStatus.blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentMobilityStabilizationStatus
                                  .inProgress
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                FilledButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentMobilityStabilizationStatus
                                  .completed
                          ? null
                          : onComplete,
                  icon: const Icon(Icons.task_alt_outlined),
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

Color _statusColor(IncomingTalentMobilityStabilizationStatus status) {
  return switch (status) {
    IncomingTalentMobilityStabilizationStatus.planned => const Color(
      0xFF2563EB,
    ),
    IncomingTalentMobilityStabilizationStatus.inProgress => const Color(
      0xFF059669,
    ),
    IncomingTalentMobilityStabilizationStatus.blocked => const Color(
      0xFFDC2626,
    ),
    IncomingTalentMobilityStabilizationStatus.completed => const Color(
      0xFF15803D,
    ),
  };
}
