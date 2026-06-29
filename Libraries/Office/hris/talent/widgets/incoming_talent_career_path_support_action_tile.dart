import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_path_support_action_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentCareerPathSupportActionTile extends StatelessWidget {
  final IncomingTalentCareerPathSupportAction action;

  const IncomingTalentCareerPathSupportActionTile({
    super.key,
    required this.action,
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
              const Icon(
                Icons.build_circle_outlined,
                color: HrisColors.primary,
              ),
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
                      action.competencyName,
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
            action.successCriteria,
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
                label: action.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: action.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.build_circle_outlined,
                label: action.actionType.label,
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: action.priority.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(action.dueDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentCareerPathSupportActionStatus status) {
  return switch (status) {
    IncomingTalentCareerPathSupportActionStatus.open => const Color(0xFF2563EB),
    IncomingTalentCareerPathSupportActionStatus.inProgress => const Color(
      0xFFD97706,
    ),
    IncomingTalentCareerPathSupportActionStatus.resolved => const Color(
      0xFF15803D,
    ),
    IncomingTalentCareerPathSupportActionStatus.cancelled => HrisColors.muted,
  };
}
