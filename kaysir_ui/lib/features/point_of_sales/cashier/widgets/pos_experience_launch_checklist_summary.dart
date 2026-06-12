import 'package:flutter/material.dart';

import '../experiences/pos_experience_launch_checklist.dart';
import 'pos_ui.dart';

class POSExperienceLaunchChecklistSummary extends StatelessWidget {
  final POSExperienceLaunchChecklist checklist;

  const POSExperienceLaunchChecklistSummary({
    super.key,
    required this.checklist,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _statusColors(theme.colorScheme, checklist);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(POSUiTokens.radius),
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(_statusIcon(checklist), color: colors.foreground),
                const SizedBox(width: POSUiTokens.gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checklist.statusLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _summaryText(checklist),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.foreground.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: POSUiTokens.gap),
        Column(
          children:
              checklist.items
                  .map((item) => _LaunchCheckRow(item: item))
                  .toList(),
        ),
      ],
    );
  }

  String _summaryText(POSExperienceLaunchChecklist checklist) {
    return '${checklist.failureCount} blockers / ${checklist.warningCount} review items';
  }

  IconData _statusIcon(POSExperienceLaunchChecklist checklist) {
    if (checklist.failureCount > 0) return Icons.error_outline;
    if (checklist.warningCount > 0) return Icons.info_outline;
    return Icons.verified_outlined;
  }

  _LaunchChecklistColors _statusColors(
    ColorScheme colorScheme,
    POSExperienceLaunchChecklist checklist,
  ) {
    if (checklist.failureCount > 0) {
      return _LaunchChecklistColors(
        background: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
        border: colorScheme.error.withValues(alpha: 0.24),
      );
    }

    if (checklist.warningCount > 0) {
      return _LaunchChecklistColors(
        background: colorScheme.tertiaryContainer,
        foreground: colorScheme.onTertiaryContainer,
        border: colorScheme.tertiary.withValues(alpha: 0.24),
      );
    }

    return _LaunchChecklistColors(
      background: colorScheme.secondaryContainer,
      foreground: colorScheme.onSecondaryContainer,
      border: colorScheme.secondary.withValues(alpha: 0.22),
    );
  }
}

class _LaunchCheckRow extends StatelessWidget {
  final POSExperienceLaunchCheckItem item;

  const _LaunchCheckRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _rowColors(theme.colorScheme);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          border: Border.all(color: colors.border),
          color: colors.background,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon(), size: 18, color: colors.foreground),
              const SizedBox(width: POSUiTokens.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.foreground.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon() {
    switch (item.status) {
      case POSLaunchCheckStatus.passed:
        return Icons.check_circle_outline;
      case POSLaunchCheckStatus.warning:
        return Icons.info_outline;
      case POSLaunchCheckStatus.failed:
        return Icons.error_outline;
    }
  }

  _LaunchChecklistColors _rowColors(ColorScheme colorScheme) {
    switch (item.status) {
      case POSLaunchCheckStatus.passed:
        return _LaunchChecklistColors(
          background: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.42,
          ),
          foreground: colorScheme.onSurfaceVariant,
          border: colorScheme.outlineVariant,
        );
      case POSLaunchCheckStatus.warning:
        return _LaunchChecklistColors(
          background: colorScheme.tertiaryContainer.withValues(alpha: 0.42),
          foreground: colorScheme.onTertiaryContainer,
          border: colorScheme.tertiary.withValues(alpha: 0.18),
        );
      case POSLaunchCheckStatus.failed:
        return _LaunchChecklistColors(
          background: colorScheme.errorContainer.withValues(alpha: 0.42),
          foreground: colorScheme.onErrorContainer,
          border: colorScheme.error.withValues(alpha: 0.18),
        );
    }
  }
}

class _LaunchChecklistColors {
  final Color background;
  final Color foreground;
  final Color border;

  const _LaunchChecklistColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}
