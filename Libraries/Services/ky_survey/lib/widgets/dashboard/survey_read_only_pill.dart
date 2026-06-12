import 'package:flutter/material.dart';

/// Shows a compact dashboard state with consistent pill styling.
class SurveyDashboardStatePill extends StatelessWidget {
  final String label;
  final String tooltip;
  final IconData icon;
  final bool compact;

  const SurveyDashboardStatePill({
    super.key,
    required this.label,
    required this.tooltip,
    required this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconSize = compact ? 16.0 : 17.0;
    final horizontalPadding = compact ? 9.0 : 10.0;
    final verticalPadding = compact ? 6.0 : 7.0;
    final gap = compact ? 6.0 : 7.0;
    final textStyle = compact
        ? theme.textTheme.labelSmall
        : theme.textTheme.labelMedium;

    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.onSurfaceVariant, size: iconSize),
              SizedBox(width: gap),
              Text(
                label,
                style: textStyle?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a consistent read-only affordance across embedded survey dashboards.
class SurveyReadOnlyPill extends StatelessWidget {
  final String label;
  final String tooltip;
  final IconData icon;
  final bool compact;

  const SurveyReadOnlyPill({
    super.key,
    this.label = 'View only',
    required this.tooltip,
    this.icon = Icons.visibility_outlined,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyDashboardStatePill(
      label: label,
      tooltip: tooltip,
      icon: icon,
      compact: compact,
    );
  }
}
