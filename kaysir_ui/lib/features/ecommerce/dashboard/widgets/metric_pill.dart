import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'tone.dart';

class MetricPill extends StatelessWidget {
  const MetricPill({
    required this.label,
    this.icon,
    this.value,
    this.colors,
    this.tone,
    this.backgroundColor,
    this.foregroundColor,
    this.backgroundSource = ToneBackgroundSource.foreground,
    this.backgroundAlpha = 0.12,
    super.key,
  });

  final Widget? icon;
  final String label;
  final String? value;
  final ToneColors? colors;
  final VisualTone? tone;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final ToneBackgroundSource backgroundSource;
  final double backgroundAlpha;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toneColors = _toneColors(theme.colorScheme);

    return POSMetricPill(
      icon: icon,
      label: label,
      value: value,
      backgroundColor: backgroundColor ?? _backgroundFor(toneColors),
      foregroundColor: foregroundColor ?? toneColors?.foreground,
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
