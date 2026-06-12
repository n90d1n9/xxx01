import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'tone.dart';

class TextBadge extends StatelessWidget {
  const TextBadge({
    required this.label,
    this.colors,
    this.tone,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.backgroundAlpha = 0.24,
    this.borderAlpha = 0.18,
    this.backgroundSource = ToneBackgroundSource.container,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.fontWeight = FontWeight.w800,
    super.key,
  });

  final String label;
  final ToneColors? colors;
  final VisualTone? tone;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double backgroundAlpha;
  final double borderAlpha;
  final ToneBackgroundSource backgroundSource;
  final EdgeInsetsGeometry padding;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toneColors = _toneColors(theme.colorScheme);
    final effectiveForeground =
        foregroundColor ?? toneColors?.foreground ?? theme.colorScheme.primary;
    final effectiveBackground =
        backgroundColor ??
        toneColors?.background ??
        theme.colorScheme.primaryContainer;
    final effectiveBorder =
        borderColor ?? toneColors?.border ?? theme.colorScheme.outlineVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: effectiveBorder),
      ),
      child: Padding(
        padding: padding,
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
