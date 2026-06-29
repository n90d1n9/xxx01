import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_framework_level_models.dart';
import 'talent_meta_label.dart';

/// Career-framework level tile with scope, criteria, and evidence signals.
class IncomingTalentCareerFrameworkLevelTile extends StatelessWidget {
  final IncomingTalentCareerFrameworkLevel level;

  const IncomingTalentCareerFrameworkLevelTile({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentCareerFrameworkLevelStatusColor(level.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_scopeIcon(level.scope), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.roleTitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${level.familyName} · ${level.levelCode}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: level.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            level.successCriteria,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            level.evidenceRequirement,
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
                label: level.department,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: level.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.work_outline,
                label: level.scope.label,
              ),
              TalentMetaLabel(
                icon: Icons.psychology_outlined,
                label: level.competencyName,
              ),
              TalentMetaLabel(
                icon: Icons.event_repeat_outlined,
                label: level.reviewCadence.label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentCareerFrameworkLevelStatusColor(
  IncomingTalentCareerFrameworkLevelStatus status,
) {
  return switch (status) {
    IncomingTalentCareerFrameworkLevelStatus.draft => const Color(0xFF2563EB),
    IncomingTalentCareerFrameworkLevelStatus.active => const Color(0xFF059669),
    IncomingTalentCareerFrameworkLevelStatus.review => const Color(0xFFD97706),
    IncomingTalentCareerFrameworkLevelStatus.archived => const Color(
      0xFF64748B,
    ),
  };
}

IconData _scopeIcon(IncomingTalentCareerFrameworkLevelScope scope) {
  return switch (scope) {
    IncomingTalentCareerFrameworkLevelScope.individualContributor =>
      Icons.person_outline,
    IncomingTalentCareerFrameworkLevelScope.peopleLeadership =>
      Icons.groups_outlined,
    IncomingTalentCareerFrameworkLevelScope.specialist =>
      Icons.workspace_premium_outlined,
  };
}

@Preview(name: 'Talent career framework level tile')
Widget incomingTalentCareerFrameworkLevelTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentCareerFrameworkLevelTile(level: _previewLevel),
      ),
    ),
  );
}

final _previewLevel = IncomingTalentCareerFrameworkLevel(
  id: 'career-framework-preview',
  sourceCareerPathId: 'career-path-preview',
  department: 'Engineering',
  familyName: 'Backend Engineer family',
  levelCode: 'L5',
  roleTitle: 'Lead Backend Engineer',
  scope: IncomingTalentCareerFrameworkLevelScope.peopleLeadership,
  status: IncomingTalentCareerFrameworkLevelStatus.active,
  ownerName: 'Engineering HRBP',
  competencyName: 'Technical leadership',
  successCriteria:
      'Leads cross-team architecture decisions with clear tradeoffs.',
  evidenceRequirement:
      'Submit architecture decision records and peer feedback.',
  reviewCadence: IncomingTalentCareerFrameworkReviewCadence.quarterly,
  createdAt: DateTime(2026, 6, 9),
);
