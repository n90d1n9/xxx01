import 'package:flutter/material.dart';

import '../logic/survey_response_issue_summary.dart';

/// Renders a compact, tappable overview of response issues by section page.
class SurveyResponseIssueSummaryPanel extends StatelessWidget {
  final SurveyResponseIssueSummary summary;
  final int selectedPageIndex;
  final ValueChanged<int> onIssueSelected;
  final ValueChanged<SurveyResponseIssueSummaryItem>? onIssueItemSelected;

  const SurveyResponseIssueSummaryPanel({
    super.key,
    required this.summary,
    required this.selectedPageIndex,
    required this.onIssueSelected,
    this.onIssueItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!summary.hasIssues) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final firstIssueLabel = summary.firstIssueLabel;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.rule_folder_outlined, color: colorScheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.titleLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary.detailLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                      if (firstIssueLabel != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          firstIssueLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in summary.items)
                  SurveyResponseIssueSummaryChip(
                    item: item,
                    selected: item.pageIndex == selectedPageIndex,
                    onSelected: _selectIssue,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectIssue(SurveyResponseIssueSummaryItem item) {
    onIssueSelected(item.pageIndex);
    onIssueItemSelected?.call(item);
  }
}

/// Shows one section-level response issue shortcut.
class SurveyResponseIssueSummaryChip extends StatelessWidget {
  final SurveyResponseIssueSummaryItem item;
  final bool selected;
  final ValueChanged<SurveyResponseIssueSummaryItem> onSelected;

  const SurveyResponseIssueSummaryChip({
    super.key,
    required this.item,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: item.issueLabel,
      child: FilterChip(
        selected: selected,
        showCheckmark: false,
        avatar: Icon(
          item.requiredIssueCount > 0
              ? Icons.star_rounded
              : Icons.error_outline,
          size: 16,
          color: selected ? colorScheme.onError : colorScheme.error,
        ),
        label: Text(item.pageLabel),
        labelStyle: TextStyle(
          color: selected ? colorScheme.onError : colorScheme.onErrorContainer,
          fontWeight: FontWeight.w800,
        ),
        selectedColor: colorScheme.error,
        backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.36),
        side: BorderSide(color: colorScheme.error.withValues(alpha: 0.28)),
        onSelected: (_) => onSelected(item),
      ),
    );
  }
}
