import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Shared severity levels for builder-facing issue rows.
enum KyBuilderIssueSeverity { info, warning }

/// Describes an optional row-level action for a builder issue.
class KyBuilderIssueAction {
  final Key? key;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const KyBuilderIssueAction({
    this.key,
    this.icon = Icons.auto_fix_high,
    required this.label,
    this.onPressed,
  });
}

/// Immutable message model rendered by [KyBuilderIssueList].
class KyBuilderIssueItem {
  final KyBuilderIssueSeverity severity;
  final String message;
  final KyBuilderIssueAction? action;

  const KyBuilderIssueItem({
    required this.severity,
    required this.message,
    this.action,
  });
}

/// Renders builder issue messages with consistent severity styling and actions.
class KyBuilderIssueList extends StatelessWidget {
  final List<KyBuilderIssueItem> issues;
  final double spacing;
  final double iconSize;

  const KyBuilderIssueList({
    super.key,
    required this.issues,
    this.spacing = 6,
    this.iconSize = 18,
  });

  @Preview(name: 'Builder issue list')
  const KyBuilderIssueList.preview({super.key})
    : issues = const [
        KyBuilderIssueItem(
          severity: KyBuilderIssueSeverity.warning,
          message: 'Hero headline is empty.',
        ),
        KyBuilderIssueItem(
          severity: KyBuilderIssueSeverity.info,
          message: 'Add alternate copy before publishing.',
        ),
      ],
      spacing = 6,
      iconSize = 18;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final issue in issues) ...[
          _KyBuilderIssueRow(issue: issue, iconSize: iconSize),
          if (issue != issues.last) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

class _KyBuilderIssueRow extends StatelessWidget {
  final KyBuilderIssueItem issue;
  final double iconSize;

  const _KyBuilderIssueRow({required this.issue, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final action = issue.action;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _issueIcon(issue.severity),
          size: iconSize,
          color: _issueColor(issue.severity, colorScheme),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                issue.message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: 4),
                TextButton.icon(
                  key: action.key,
                  onPressed: action.onPressed,
                  icon: Icon(action.icon, size: 16),
                  label: Text(action.label),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

IconData _issueIcon(KyBuilderIssueSeverity severity) {
  return switch (severity) {
    KyBuilderIssueSeverity.info => Icons.info_outline,
    KyBuilderIssueSeverity.warning => Icons.warning_amber_outlined,
  };
}

Color _issueColor(KyBuilderIssueSeverity severity, ColorScheme colorScheme) {
  return switch (severity) {
    KyBuilderIssueSeverity.info => colorScheme.primary,
    KyBuilderIssueSeverity.warning => colorScheme.error,
  };
}
