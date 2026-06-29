import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentMobilityLaunchTile extends StatelessWidget {
  final IncomingTalentMobilityLaunchChecklist checklist;
  final VoidCallback onReady;
  final VoidCallback onBlock;
  final VoidCallback onLaunch;

  const IncomingTalentMobilityLaunchTile({
    super.key,
    required this.checklist,
    required this.onReady,
    required this.onBlock,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(checklist.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checklist.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      checklist.opportunityTitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: checklist.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: checklist.readinessRatio,
            color: color,
            label:
                '${checklist.completedGateCount}/${checklist.totalGateCount} launch gates',
          ),
          const SizedBox(height: 10),
          Text(
            checklist.launchNotes,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (checklist.riskNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              checklist.riskNote,
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
                label: checklist.hostDepartment,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: checklist.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(checklist.launchDate),
              ),
              TalentMetaLabel(
                icon: Icons.update_outlined,
                label: DateFormat('MMM d').format(checklist.firstReviewDate),
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
                      checklist.status ==
                              IncomingTalentMobilityLaunchStatus.blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      checklist.status ==
                              IncomingTalentMobilityLaunchStatus.ready
                          ? null
                          : onReady,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Ready'),
                ),
                FilledButton.icon(
                  onPressed:
                      checklist.status ==
                              IncomingTalentMobilityLaunchStatus.launched
                          ? null
                          : onLaunch,
                  icon: const Icon(Icons.rocket_launch_outlined),
                  label: const Text('Launch'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentMobilityLaunchStatus status) {
  return switch (status) {
    IncomingTalentMobilityLaunchStatus.planned => const Color(0xFF2563EB),
    IncomingTalentMobilityLaunchStatus.ready => const Color(0xFF059669),
    IncomingTalentMobilityLaunchStatus.blocked => const Color(0xFFDC2626),
    IncomingTalentMobilityLaunchStatus.launched => const Color(0xFF15803D),
  };
}
