import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/notice_tone.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';

void main() {
  test('noticeIssueColors uses foreground issue tints', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.red);

    final colors = noticeIssueColors(scheme, VisualTone.danger);

    expect(colors.foreground, scheme.error);
    expect(colors.background, scheme.error.withValues(alpha: 0.08));
    expect(colors.border, scheme.error.withValues(alpha: 0.2));
  });

  test('noticeIssueColors preserves module review tone', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);

    final colors = noticeIssueColors(scheme, VisualTone.success);

    expect(colors.foreground, scheme.tertiary);
    expect(colors.background, scheme.tertiary.withValues(alpha: 0.08));
    expect(colors.border, scheme.tertiary.withValues(alpha: 0.2));
  });

  test('noticeIssueColors accepts custom density', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.amber);

    final colors = noticeIssueColors(
      scheme,
      VisualTone.secondary,
      backgroundAlpha: 0.12,
      borderAlpha: 0.24,
    );

    expect(colors.background, scheme.secondary.withValues(alpha: 0.12));
    expect(colors.border, scheme.secondary.withValues(alpha: 0.24));
  });
}
