import 'package:flutter/material.dart';

import '../../models/survey.dart';
import '../../models/survey_status.dart';
import 'survey_dashboard_shared.dart';
import 'survey_lifecycle_panel.dart';
import 'survey_progress_list.dart';

class SurveyBuilderSection extends StatelessWidget {
  final List<Survey> surveys;
  final ValueChanged<Survey> onEditSurvey;
  final SurveyStatusChanged onStatusChanged;

  const SurveyBuilderSection({
    super.key,
    required this.surveys,
    required this.onEditSurvey,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final draftSurveys = surveys
        .where(
          (survey) =>
              survey.status == SurveyStatus.draft ||
              survey.status == SurveyStatus.review,
        )
        .toList();

    return SurveySectionStack(
      children: [
        const SurveySectionHeader(title: 'Builder System'),
        const _BlueprintGrid(),
        const SurveySectionHeader(title: 'Lifecycle Controls'),
        SurveyLifecyclePanel(
          surveys: surveys,
          onStatusChanged: onStatusChanged,
        ),
        const SurveySectionHeader(title: 'Draft Queue'),
        SurveyProgressList(
          surveys: draftSurveys,
          onSurveySelected: onEditSurvey,
        ),
      ],
    );
  }
}

class _BlueprintGrid extends StatelessWidget {
  const _BlueprintGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          childAspectRatio: isWide ? 1.25 : 1.05,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _BlueprintTile(
              icon: Icons.schema_outlined,
              title: 'Structure',
              subtitle: 'Sections, pages, and question groups',
            ),
            _BlueprintTile(
              icon: Icons.account_tree_outlined,
              title: 'Logic',
              subtitle: 'Branching, skip rules, and scoring',
            ),
            _BlueprintTile(
              icon: Icons.verified_outlined,
              title: 'Validation',
              subtitle: 'Required fields, limits, and format checks',
            ),
            _BlueprintTile(
              icon: Icons.publish_outlined,
              title: 'Publishing',
              subtitle: 'Audience, status, and collection targets',
            ),
          ],
        );
      },
    );
  }
}

class _BlueprintTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BlueprintTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
