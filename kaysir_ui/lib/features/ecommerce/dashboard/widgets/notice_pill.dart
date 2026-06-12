import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'notice_tone.dart';
import 'tone.dart';

class NoticePill extends StatelessWidget {
  const NoticePill({
    required this.message,
    this.colors,
    this.tone,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.icon,
    this.label,
    this.backgroundAlpha = 0.08,
    this.borderAlpha = 0.2,
    this.maxWidth = 420,
    this.messageMaxLines = 2,
    this.messageFontWeight = FontWeight.w700,
    super.key,
  });

  final String message;
  final IconData? icon;
  final String? label;
  final ToneColors? colors;
  final VisualTone? tone;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double backgroundAlpha;
  final double borderAlpha;
  final double maxWidth;
  final int messageMaxLines;
  final FontWeight messageFontWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = this.icon;
    final label = this.label;
    final toneColors = _toneColors(theme.colorScheme);
    final effectiveForeground =
        foregroundColor ??
        toneColors?.foreground ??
        theme.colorScheme.onSurfaceVariant;
    final effectiveBackground =
        backgroundColor ??
        toneColors?.background ??
        theme.colorScheme.surface.withValues(alpha: 0.62);
    final effectiveBorder =
        borderColor ?? toneColors?.border ?? theme.dividerColor;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: effectiveBackground,
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          border: Border.all(color: effectiveBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: effectiveForeground),
                const SizedBox(width: POSUiTokens.gap),
              ],
              if (label != null) ...[
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: effectiveForeground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: POSUiTokens.gap),
              ],
              Flexible(
                child: Text(
                  message,
                  maxLines: messageMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: messageFontWeight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ToneColors? _toneColors(ColorScheme scheme) {
    final existingColors = colors;
    if (existingColors != null) return existingColors;

    final selectedTone = tone;
    if (selectedTone == null) return null;

    return noticeIssueColors(
      scheme,
      selectedTone,
      backgroundAlpha: backgroundAlpha,
      borderAlpha: borderAlpha,
    );
  }
}

class NoticeOverflowPill extends StatelessWidget {
  const NoticeOverflowPill({required this.hiddenCount, super.key});

  final int hiddenCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NoticePill(
      message: '+$hiddenCount more',
      foregroundColor: theme.colorScheme.onSurfaceVariant,
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.62),
      borderColor: theme.dividerColor,
      maxWidth: 140,
      messageMaxLines: 1,
      messageFontWeight: FontWeight.w800,
    );
  }
}
