import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_intervention_models.dart';
import 'incoming_talent_development_intervention_status_actions.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentInterventionTile extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionAction action;

  const IncomingTalentDevelopmentInterventionTile({
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
              const Icon(Icons.task_alt_outlined, color: HrisColors.primary),
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
                      action.action,
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
            action.successCriteria,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (action.resolutionNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              action.resolutionNote,
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
                label: action.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: action.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.category_outlined,
                label: action.actionType.label,
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: action.priority.label,
              ),
              TalentMetaLabel(
                icon: Icons.account_tree_outlined,
                label: action.source.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(action.dueDate),
              ),
              if (action.releaseEvidenceCount > 0)
                TalentMetaLabel(
                  icon: Icons.workspace_premium_outlined,
                  label: '${action.releaseEvidenceCount} evidence signals',
                ),
              if (action.programCompletionExtensionCount > 0)
                TalentMetaLabel(
                  icon: Icons.report_problem_outlined,
                  label: '${action.programCompletionExtensionCount} extensions',
                ),
            ],
          ),
          const SizedBox(height: 12),
          IncomingTalentDevelopmentInterventionStatusActions(action: action),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentDevelopmentInterventionStatus status) {
  return switch (status) {
    IncomingTalentDevelopmentInterventionStatus.open => const Color(0xFF2563EB),
    IncomingTalentDevelopmentInterventionStatus.inProgress => const Color(
      0xFF059669,
    ),
    IncomingTalentDevelopmentInterventionStatus.resolved => const Color(
      0xFF15803D,
    ),
    IncomingTalentDevelopmentInterventionStatus.cancelled => const Color(
      0xFFD97706,
    ),
  };
}
