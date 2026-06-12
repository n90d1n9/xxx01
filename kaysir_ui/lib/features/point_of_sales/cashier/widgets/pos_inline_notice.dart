import 'package:flutter/material.dart';

import 'pos_ui.dart';

enum POSInlineNoticeTone { info, success, warning, danger }

class POSInlineNotice extends StatelessWidget {
  final POSInlineNoticeTone tone;
  final IconData icon;
  final String title;
  final String message;
  final Widget? trailing;
  final Widget? footer;

  const POSInlineNotice({
    super.key,
    required this.tone,
    required this.icon,
    required this.title,
    required this.message,
    this.trailing,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _palette(theme.colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: palette.iconBackground,
                borderRadius: BorderRadius.circular(POSUiTokens.radius),
              ),
              child: Icon(icon, color: palette.foreground, size: 18),
            ),
            const SizedBox(width: POSUiTokens.gapLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: palette.foreground,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.messageForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (footer != null) ...[
                    const SizedBox(height: POSUiTokens.gap),
                    footer!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: POSUiTokens.gapLarge),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  _POSInlineNoticePalette _palette(ColorScheme colorScheme) {
    switch (tone) {
      case POSInlineNoticeTone.info:
        return _POSInlineNoticePalette(
          background: colorScheme.secondaryContainer.withValues(alpha: 0.55),
          border: colorScheme.secondary.withValues(alpha: 0.24),
          iconBackground: colorScheme.secondary.withValues(alpha: 0.14),
          foreground: colorScheme.onSecondaryContainer,
          messageForeground: colorScheme.onSurfaceVariant,
        );
      case POSInlineNoticeTone.success:
        return _POSInlineNoticePalette(
          background: colorScheme.primaryContainer.withValues(alpha: 0.45),
          border: colorScheme.primary.withValues(alpha: 0.22),
          iconBackground: colorScheme.primary.withValues(alpha: 0.13),
          foreground: colorScheme.onPrimaryContainer,
          messageForeground: colorScheme.onSurfaceVariant,
        );
      case POSInlineNoticeTone.warning:
        return _POSInlineNoticePalette(
          background: colorScheme.tertiaryContainer.withValues(alpha: 0.52),
          border: colorScheme.tertiary.withValues(alpha: 0.24),
          iconBackground: colorScheme.tertiary.withValues(alpha: 0.14),
          foreground: colorScheme.onTertiaryContainer,
          messageForeground: colorScheme.onSurfaceVariant,
        );
      case POSInlineNoticeTone.danger:
        return _POSInlineNoticePalette(
          background: colorScheme.errorContainer.withValues(alpha: 0.56),
          border: colorScheme.error.withValues(alpha: 0.28),
          iconBackground: colorScheme.error.withValues(alpha: 0.14),
          foreground: colorScheme.onErrorContainer,
          messageForeground: colorScheme.onSurfaceVariant,
        );
    }
  }
}

class _POSInlineNoticePalette {
  final Color background;
  final Color border;
  final Color iconBackground;
  final Color foreground;
  final Color messageForeground;

  const _POSInlineNoticePalette({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.foreground,
    required this.messageForeground,
  });
}
