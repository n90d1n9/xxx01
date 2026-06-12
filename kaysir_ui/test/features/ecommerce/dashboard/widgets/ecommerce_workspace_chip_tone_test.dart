import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/chip_tone.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';

void main() {
  test('tonalChipColors uses container-backed defaults', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.blue);

    final colors = tonalChipColors(scheme, VisualTone.secondary);

    expect(colors.foreground, scheme.secondary);
    expect(
      colors.background,
      scheme.secondaryContainer.withValues(alpha: 0.28),
    );
    expect(colors.border, scheme.secondary.withValues(alpha: 0.16));
  });

  test('tonalChipColors can use foreground tints', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.green);

    final colors = tonalChipColors(
      scheme,
      VisualTone.primary,
      backgroundAlpha: 0.1,
      borderAlpha: 0.18,
      backgroundSource: ToneBackgroundSource.foreground,
    );

    expect(colors.foreground, scheme.primary);
    expect(colors.background, scheme.primary.withValues(alpha: 0.1));
    expect(colors.border, scheme.primary.withValues(alpha: 0.18));
  });

  test('mutedChipColors uses neutral chip chrome', () {
    final theme = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
    );

    final colors = mutedChipColors(theme, backgroundAlpha: 0.55);

    expect(colors.foreground, theme.colorScheme.onSurfaceVariant);
    expect(
      colors.background,
      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
    );
    expect(colors.border, theme.dividerColor);
  });
}
