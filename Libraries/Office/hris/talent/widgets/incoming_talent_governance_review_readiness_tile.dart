import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_review_readiness_models.dart';
import 'talent_meta_label.dart';

/// Checklist tile for one executive talent governance review preparation task.
class IncomingTalentGovernanceReviewReadinessTile extends StatelessWidget {
  final IncomingTalentGovernanceReviewReadinessItem item;

  const IncomingTalentGovernanceReviewReadinessTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentGovernanceReviewReadinessStatusColor(
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
                icon: Icons.warning_amber_outlined,
                label:
                    '${item.signalCount} ${_plural(item.signalCount, 'signal')}',
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${item.timeboxMinutes} min',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentGovernanceReviewReadinessStatusColor(
  IncomingTalentGovernanceReviewReadinessStatus status,
) {
  return switch (status) {
    IncomingTalentGovernanceReviewReadinessStatus.ready => const Color(
      0xFF059669,
    ),
    IncomingTalentGovernanceReviewReadinessStatus.needsPrep => const Color(
      0xFFD97706,
    ),
    IncomingTalentGovernanceReviewReadinessStatus.blocked => const Color(
      0xFFDC2626,
    ),
  };
}

IconData _categoryIcon(
  IncomingTalentGovernanceReviewReadinessCategory category,
) {
  return switch (category) {
    IncomingTalentGovernanceReviewReadinessCategory.decisionBrief =>
      Icons.fact_check_outlined,
    IncomingTalentGovernanceReviewReadinessCategory.escalationPrep =>
      Icons.priority_high_outlined,
    IncomingTalentGovernanceReviewReadinessCategory.capacityPlan =>
      Icons.account_tree_outlined,
    IncomingTalentGovernanceReviewReadinessCategory.ownerConfirmation =>
      Icons.assignment_ind_outlined,
    IncomingTalentGovernanceReviewReadinessCategory.evidencePack =>
      Icons.article_outlined,
    IncomingTalentGovernanceReviewReadinessCategory.facilitationPlan =>
      Icons.event_note_outlined,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance review readiness tile')
Widget incomingTalentGovernanceReviewReadinessTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceReviewReadinessTile(item: _previewItem),
      ),
    ),
  );
}

final _previewItem = IncomingTalentGovernanceReviewReadinessItem(
  id: 'talent-governance-review-readiness:review-pack-governance-lane-assurance',
  sourceReviewItemId: 'review-pack-governance-lane-assurance',
  category: IncomingTalentGovernanceReviewReadinessCategory.decisionBrief,
  status: IncomingTalentGovernanceReviewReadinessStatus.blocked,
  title: 'Prepare assurance decision brief',
  detail:
      'What leadership decision removes the assurance blocker today? Evidence required: Gaps 4 with 5 active signals.',
  ownerName: 'People Risk and Assurance',
  evidencePrompt: 'Gaps 4 with 5 active signals.',
  dueDate: DateTime(2026, 6, 11),
  signalCount: 5,
  decisionCount: 3,
  timeboxMinutes: 15,
);
