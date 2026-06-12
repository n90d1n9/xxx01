import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';

void main() {
  testWidgets('TextBadge applies compact label chrome', (tester) async {
    const foregroundColor = Color(0xFF0F766E);
    const backgroundColor = Color(0xFFCCFBF1);
    const borderColor = Color(0xFF5EEAD4);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TextBadge(
            label: 'Required',
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(TextBadge),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final text = tester.widget<Text>(find.text('Required'));

    expect(decoration.color, backgroundColor);
    expect(decoration.border?.top.color, borderColor);
    expect(text.style?.color, foregroundColor);
    expect(text.style?.fontWeight, FontWeight.w900);
  });

  testWidgets('TextBadge can derive tonal colors', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(
          body: TextBadge(
            label: 'Review playbook',
            tone: VisualTone.primary,
            backgroundAlpha: 0.42,
            borderAlpha: 0.16,
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(TextBadge),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final text = tester.widget<Text>(find.text('Review playbook'));

    expect(decoration.color, scheme.primaryContainer.withValues(alpha: 0.42));
    expect(
      decoration.border?.top.color,
      scheme.primary.withValues(alpha: 0.16),
    );
    expect(text.style?.color, scheme.primary);
  });

  testWidgets('TextBadge accepts precomputed colors', (tester) async {
    const colors = ToneColors(
      foreground: Color(0xFF7C2D12),
      background: Color(0xFFFFEDD5),
      border: Color(0xFFFDBA74),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TextBadge(
            label: '5 rules',
            colors: colors,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(TextBadge),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final text = tester.widget<Text>(find.text('5 rules'));

    expect(decoration.color, colors.background);
    expect(decoration.border?.top.color, colors.border);
    expect(text.style?.color, colors.foreground);
    expect(text.style?.fontWeight, FontWeight.w900);
  });
}
