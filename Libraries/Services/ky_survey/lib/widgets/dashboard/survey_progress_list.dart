import 'package:flutter/material.dart';

import '../../models/survey.dart';
import 'survey_read_only_pill.dart';
import 'survey_status_chip.dart';

/// Shows a compact list of surveys ranked by response progress.
class SurveyProgressList extends StatelessWidget {
  final List<Survey> surveys;
  final int limit;
  final ValueChanged<Survey>? onSurveySelected;

  const SurveyProgressList({
    super.key,
    required this.surveys,
    this.limit = 5,
    this.onSurveySelected,
  });

  @override
  Widget build(BuildContext context) {
    final visibleSurveys = surveys.take(limit).toList();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (visibleSurveys.isEmpty) {
      return _EmptyPanel(
        icon: Icons.fact_check_outlined,
        title: 'No surveys yet',
        subtitle: 'Survey queue is empty.',
      );
    }

    return Column(
      children: visibleSurveys.map((survey) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SurveyProgressTile(
            survey: survey,
            onSurveySelected: onSurveySelected,
            surfaceColor: colorScheme.surface,
          ),
        );
      }).toList(),
    );
  }
}

/// Displays one survey's response progress and available interaction state.
class _SurveyProgressTile extends StatelessWidget {
  final Survey survey;
  final ValueChanged<Survey>? onSurveySelected;
  final Color surfaceColor;

  const _SurveyProgressTile({
    required this.survey,
    required this.onSurveySelected,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final target = survey.targetResponses;
    final progress = target == 0
        ? 0.0
        : (survey.responseCount / target).clamp(0, 1).toDouble();
    final isInteractive = onSurveySelected != null;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isInteractive ? () => onSurveySelected!(survey) : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        survey.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SurveyStatusChip(status: survey.status),
                    const SizedBox(width: 8),
                    _ProgressActionIndicator(isInteractive: isInteractive),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  target == 0
                      ? '${survey.responseCount} responses'
                      : '${survey.responseCount} / $target responses',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Signals whether a progress row can be opened or is informational only.
class _ProgressActionIndicator extends StatelessWidget {
  final bool isInteractive;

  const _ProgressActionIndicator({required this.isInteractive});

  @override
  Widget build(BuildContext context) {
    if (!isInteractive) {
      return const SurveyReadOnlyPill(
        tooltip: 'Read-only survey summary',
        compact: true,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Open survey',
      child: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
    );
  }
}

/// Communicates that no surveys are available for the progress list.
class _EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyPanel({
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
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
