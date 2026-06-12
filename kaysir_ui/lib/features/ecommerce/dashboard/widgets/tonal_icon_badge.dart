import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'tone.dart';

class TonalIconBadge extends StatelessWidget {
  const TonalIconBadge({
    required this.icon,
    this.colors,
    this.tone,
    this.foregroundColor,
    this.backgroundColor,
    this.backgroundSource = ToneBackgroundSource.foreground,
    this.backgroundAlpha = 0.12,
    this.size = 34,
    this.iconSize = 19,
    super.key,
  });

  final IconData icon;
  final ToneColors? colors;
  final VisualTone? tone;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final ToneBackgroundSource backgroundSource;
  final double backgroundAlpha;
  final double size;
  final double iconSize;

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
        _backgroundFor(toneColors) ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.72);

    return POSIconBadge(
      icon: icon,
      size: size,
      iconSize: iconSize,
      backgroundColor: effectiveBackground,
      foregroundColor: effectiveForeground,
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
      backgroundSource: backgroundSource,
    );
  }

  Color? _backgroundFor(ToneColors? toneColors) {
    if (toneColors == null) return null;

    return switch (backgroundSource) {
      ToneBackgroundSource.container => toneColors.background,
      ToneBackgroundSource.foreground => toneColors.foregroundTint(
        alpha: backgroundAlpha,
      ),
    };
  }
}
