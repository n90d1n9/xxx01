import 'package:flutter/material.dart';

import 'tone.dart';

ToneColors tonalChipColors(
  ColorScheme scheme,
  VisualTone tone, {
  double backgroundAlpha = 0.28,
  double borderAlpha = 0.16,
  ToneBackgroundSource backgroundSource = ToneBackgroundSource.container,
}) {
  return toneColors(
    scheme,
    tone,
    backgroundAlpha: backgroundAlpha,
    borderAlpha: borderAlpha,
    backgroundSource: backgroundSource,
  );
}

ToneColors mutedChipColors(ThemeData theme, {double backgroundAlpha = 0.5}) {
  return ToneColors(
    foreground: theme.colorScheme.onSurfaceVariant,
    background: theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: backgroundAlpha,
    ),
    border: theme.dividerColor,
  );
}
