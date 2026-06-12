import 'package:flutter/material.dart';

enum VisualTone { primary, secondary, success, warning, danger }

enum ToneBackgroundSource { container, foreground }

class ToneColors {
  const ToneColors({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;

  Color foregroundTint({double alpha = 0.12}) {
    return foreground.withValues(alpha: alpha);
  }
}

ToneColors toneColors(
  ColorScheme scheme,
  VisualTone tone, {
  double backgroundAlpha = 0.24,
  double borderAlpha = 0.18,
  ToneBackgroundSource backgroundSource = ToneBackgroundSource.container,
}) {
  final colors = _baseToneColors(scheme, tone);
  final backgroundBase = switch (backgroundSource) {
    ToneBackgroundSource.container => colors.container,
    ToneBackgroundSource.foreground => colors.foreground,
  };

  return ToneColors(
    foreground: colors.foreground,
    background: backgroundBase.withValues(alpha: backgroundAlpha),
    border: colors.foreground.withValues(alpha: borderAlpha),
  );
}

({Color foreground, Color container}) _baseToneColors(
  ColorScheme scheme,
  VisualTone tone,
) {
  return switch (tone) {
    VisualTone.primary => (
      foreground: scheme.primary,
      container: scheme.primaryContainer,
    ),
    VisualTone.secondary => (
      foreground: scheme.secondary,
      container: scheme.secondaryContainer,
    ),
    VisualTone.success => (
      foreground: scheme.tertiary,
      container: scheme.tertiaryContainer,
    ),
    VisualTone.warning => (
      foreground: scheme.secondary,
      container: scheme.secondaryContainer,
    ),
    VisualTone.danger => (
      foreground: scheme.error,
      container: scheme.errorContainer,
    ),
  };
}
