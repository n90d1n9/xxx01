import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionCoverageCouncilAgendaTile
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageCouncilAgendaItem item;

  const IncomingTalentSuccessionCoverageCouncilAgendaTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(item.priority);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_2_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.scopeLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${item.lane.label} - ${item.stage.label}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.priority.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: item.coverageRatio,
            color: color,
            label: '${item.coverageScore}% coverage',
          ),
          const SizedBox(height: 10),
          Text(
            item.decisionQuestion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.discussionPrompt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.preReadSummary,
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
                icon: Icons.apartment_outlined,
                label: item.departmentScope,
              ),
              TalentMetaLabel(
                icon: Icons.policy_outlined,
                label: item.riskLevel.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_note_outlined,
                label: DateFormat('MMM d').format(item.councilDate),
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(item.dueDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _priorityColor(
  IncomingTalentSuccessionCoverageCouncilAgendaPriority priority,
) {
  return switch (priority) {
    IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent => const Color(
      0xFFDC2626,
    ),
    IncomingTalentSuccessionCoverageCouncilAgendaPriority.high => const Color(
      0xFFEA580C,
    ),
    IncomingTalentSuccessionCoverageCouncilAgendaPriority.normal => const Color(
      0xFFD97706,
    ),
    IncomingTalentSuccessionCoverageCouncilAgendaPriority.watch => const Color(
      0xFF2563EB,
    ),
  };
}
