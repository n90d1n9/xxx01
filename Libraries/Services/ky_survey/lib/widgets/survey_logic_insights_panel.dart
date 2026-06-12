import 'package:flutter/material.dart';

import '../analytics/survey_logic_insights.dart';
import '../models/survey.dart';

class SurveyLogicInsightsPanel extends StatelessWidget {
  final Survey survey;

  const SurveyLogicInsightsPanel({super.key, required this.survey});

  @override
  Widget build(BuildContext context) {
    final insights = SurveyLogicInsights(survey);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree_outlined, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Logic Map',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _IssueBadge(insights: insights),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  icon: Icons.visibility_off_outlined,
                  label:
                      '${insights.conditionalQuestionCount} conditional questions',
                ),
                _MetricChip(
                  icon: Icons.rule_folder_outlined,
                  label: '${insights.totalVisibilityRules} rules',
                ),
                _MetricChip(
                  icon: Icons.stairs_outlined,
                  label: '${insights.maxDependencyDepth} levels deep',
                ),
                _MetricChip(
                  icon: Icons.anchor_outlined,
                  label: '${insights.rootQuestionCount} root questions',
                ),
              ],
            ),
            if (insights.sectionSummaries.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionLogicList(summaries: insights.sectionSummaries),
            ],
            if (insights.issues.isNotEmpty) ...[
              const SizedBox(height: 16),
              _IssueList(issues: insights.issues.take(4).toList()),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                insights.totalVisibilityRules == 0
                    ? 'No display logic yet.'
                    : 'Display logic looks consistent.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IssueBadge extends StatelessWidget {
  final SurveyLogicInsights insights;

  const _IssueBadge({required this.insights});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final blockerCount = insights.issues
        .where((issue) => issue.severity == SurveyLogicIssueSeverity.blocker)
        .length;
    final warningCount = insights.issues.length - blockerCount;

    if (blockerCount > 0) {
      return Chip(
        avatar: Icon(Icons.error_outline, color: colorScheme.error, size: 18),
        label: Text('$blockerCount blockers'),
      );
    }

    if (warningCount > 0) {
      return Chip(
        avatar: Icon(
          Icons.warning_amber_outlined,
          color: colorScheme.tertiary,
          size: 18,
        ),
        label: Text('$warningCount warnings'),
      );
    }

    return const Chip(
      avatar: Icon(Icons.task_alt_outlined, size: 18),
      label: Text('Clean'),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _SectionLogicList extends StatelessWidget {
  final List<SurveyLogicSectionSummary> summaries;

  const _SectionLogicList({required this.summaries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Section Complexity',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final summary in summaries)
              InputChip(
                avatar: Icon(
                  summary.issueCount > 0
                      ? Icons.error_outline
                      : Icons.segment_outlined,
                  size: 18,
                  color: summary.issueCount > 0 ? colorScheme.error : null,
                ),
                label: Text(
                  '${summary.title}: ${summary.conditionalQuestionCount}/${summary.questionCount} conditional',
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _IssueList extends StatelessWidget {
  final List<SurveyLogicIssue> issues;

  const _IssueList({required this.issues});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Needs Attention',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  issue.severity == SurveyLogicIssueSeverity.blocker
                      ? Icons.error_outline
                      : Icons.warning_amber_outlined,
                  color: issue.severity == SurveyLogicIssueSeverity.blocker
                      ? colorScheme.error
                      : colorScheme.tertiary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    issue.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
