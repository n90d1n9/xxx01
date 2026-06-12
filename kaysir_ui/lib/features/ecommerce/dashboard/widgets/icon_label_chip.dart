import 'package:flutter/material.dart';

import 'chip_surface.dart';
import 'tone.dart';

class IconLabelChip extends StatelessWidget {
  const IconLabelChip({
    required this.icon,
    required this.label,
    this.colors,
    this.tone,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.backgroundAlpha = 0.28,
    this.borderAlpha = 0.16,
    this.backgroundSource = ToneBackgroundSource.container,
    this.iconSize = 14,
    this.gap = 5,
    this.fontWeight = FontWeight.w800,
    super.key,
  });

  final IconData icon;
  final String label;
  final ToneColors? colors;
  final VisualTone? tone;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double backgroundAlpha;
  final double borderAlpha;
  final ToneBackgroundSource backgroundSource;
  final double iconSize;
  final double gap;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toneColors = _toneColors(theme.colorScheme);
    final effectiveForeground =
        foregroundColor ??
        toneColors?.foreground ??
        theme.colorScheme.onSurfaceVariant;
    final effectiveBackground =
        backgroundColor ??
        toneColors?.background ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final effectiveBorder =
        borderColor ?? toneColors?.border ?? theme.dividerColor;

    return ChipSurface(
      backgroundColor: effectiveBackground,
      borderColor: effectiveBorder,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: effectiveForeground),
          SizedBox(width: gap),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: effectiveForeground,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ToneColors? _toneColors(ColorScheme scheme) {
    final existingColors = colors;
    if (existingColors != null) return existingColors;

    final selectedTone = tone;
    if (selectedTone == null) return null;

    return toneColors(
      scheme,
      selectedTone,
      backgroundAlpha: backgroundAlpha,
      borderAlpha: borderAlpha,
      backgroundSource: backgroundSource,
    );
  }
}
