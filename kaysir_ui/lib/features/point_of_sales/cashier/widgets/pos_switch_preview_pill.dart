import 'package:flutter/material.dart';

import 'pos_ui.dart';

enum POSSwitchPreviewTone { neutral, positive, warning, danger }

class POSSwitchPreviewPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final POSSwitchPreviewTone tone;

  const POSSwitchPreviewPill({
    super.key,
    required this.icon,
    required this.label,
    this.tone = POSSwitchPreviewTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = POSSwitchPreviewPillColors.resolve(theme.colorScheme, tone);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class POSSwitchPreviewPillColors {
  final Color background;
  final Color foreground;
  final Color border;

  const POSSwitchPreviewPillColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  factory POSSwitchPreviewPillColors.resolve(
    ColorScheme colorScheme,
    POSSwitchPreviewTone tone,
  ) {
    switch (tone) {
      case POSSwitchPreviewTone.positive:
        return POSSwitchPreviewPillColors(
          background: colorScheme.secondaryContainer.withValues(alpha: 0.78),
          foreground: colorScheme.onSecondaryContainer,
          border: colorScheme.secondary.withValues(alpha: 0.18),
        );
      case POSSwitchPreviewTone.warning:
        return POSSwitchPreviewPillColors(
          background: colorScheme.tertiaryContainer.withValues(alpha: 0.76),
          foreground: colorScheme.onTertiaryContainer,
          border: colorScheme.tertiary.withValues(alpha: 0.2),
        );
      case POSSwitchPreviewTone.danger:
        return POSSwitchPreviewPillColors(
          background: colorScheme.errorContainer.withValues(alpha: 0.76),
          foreground: colorScheme.onErrorContainer,
          border: colorScheme.error.withValues(alpha: 0.2),
        );
      case POSSwitchPreviewTone.neutral:
        return POSSwitchPreviewPillColors(
          background: colorScheme.surfaceContainerHighest,
          foreground: colorScheme.onSurfaceVariant,
          border: colorScheme.outlineVariant.withValues(alpha: 0.48),
        );
    }
  }
}
