import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';

void main() {
  test('toneColors resolves container-backed tones', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    final colors = toneColors(
      scheme,
      VisualTone.primary,
      backgroundAlpha: 0.2,
      borderAlpha: 0.1,
    );

    expect(colors.foreground, scheme.primary);
    expect(colors.background, scheme.primaryContainer.withValues(alpha: 0.2));
    expect(colors.border, scheme.primary.withValues(alpha: 0.1));
  });

  test('toneColors can tint from foreground color', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);

    final colors = toneColors(
      scheme,
      VisualTone.success,
      backgroundAlpha: 0.08,
      backgroundSource: ToneBackgroundSource.foreground,
    );

    expect(colors.foreground, scheme.tertiary);
    expect(colors.background, scheme.tertiary.withValues(alpha: 0.08));
    expect(colors.foregroundTint(), scheme.tertiary.withValues(alpha: 0.12));
    expect(
      colors.foregroundTint(alpha: 0.2),
      scheme.tertiary.withValues(alpha: 0.2),
    );
  });

  test('toneColors maps operational warning and danger', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.blue);

    final warning = toneColors(scheme, VisualTone.warning);
    final danger = toneColors(scheme, VisualTone.danger);

    expect(warning.foreground, scheme.secondary);
    expect(danger.foreground, scheme.error);
  });
}
