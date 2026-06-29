import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_readiness_checklist_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentRiskCouncilReadinessChecklistTile extends StatelessWidget {
  final IncomingTalentRiskCouncilReadinessChecklistItem item;

  const IncomingTalentRiskCouncilReadinessChecklistTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentRiskCouncilReadinessChecklistStatusColor(
      item.status,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_categoryIcon(item.category), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.category.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
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
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(item.dueDate),
              ),
              TalentMetaLabel(
                icon: Icons.confirmation_number_outlined,
                label: '${item.sourceCount} signals',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentRiskCouncilReadinessChecklistStatusColor(
  IncomingTalentRiskCouncilReadinessChecklistStatus status,
) {
  return switch (status) {
    IncomingTalentRiskCouncilReadinessChecklistStatus.ready => const Color(
      0xFF15803D,
    ),
    IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep => const Color(
      0xFF2563EB,
    ),
    IncomingTalentRiskCouncilReadinessChecklistStatus.blocked => const Color(
      0xFFD97706,
    ),
    IncomingTalentRiskCouncilReadinessChecklistStatus.overdue => const Color(
      0xFFDC2626,
    ),
  };
}

IconData _categoryIcon(
  IncomingTalentRiskCouncilReadinessChecklistCategory category,
) {
  return switch (category) {
    IncomingTalentRiskCouncilReadinessChecklistCategory.councilPack =>
      Icons.summarize_outlined,
    IncomingTalentRiskCouncilReadinessChecklistCategory.decisionPrep =>
      Icons.fact_check_outlined,
    IncomingTalentRiskCouncilReadinessChecklistCategory.escalationPrep =>
      Icons.trending_up_outlined,
    IncomingTalentRiskCouncilReadinessChecklistCategory.followUpPlanning =>
      Icons.next_plan_outlined,
    IncomingTalentRiskCouncilReadinessChecklistCategory.evidenceReview =>
      Icons.article_outlined,
    IncomingTalentRiskCouncilReadinessChecklistCategory.ownerConfirmation =>
      Icons.assignment_ind_outlined,
  };
}
