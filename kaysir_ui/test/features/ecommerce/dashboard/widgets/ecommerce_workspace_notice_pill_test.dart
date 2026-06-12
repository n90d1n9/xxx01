import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/notice_pill.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';

void main() {
  testWidgets('NoticePill applies issue pill chrome', (tester) async {
    const foregroundColor = Color(0xFFB91C1C);
    const backgroundColor = Color(0xFFFEE2E2);
    const borderColor = Color(0xFFFCA5A5);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NoticePill(
            icon: Icons.error_outline,
            label: 'Module',
            message: 'Blank module id',
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
    final constrainedBox = tester.widget<ConstrainedBox>(
      find
          .descendant(
            of: find.byType(NoticePill),
            matching: find.byType(ConstrainedBox),
          )
          .first,
    );
    final decoratedBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(NoticePill),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;

    expect(find.text('Module'), findsOneWidget);
    expect(find.text('Blank module id'), findsOneWidget);
    expect(icon.color, foregroundColor);
    expect(constrainedBox.constraints.maxWidth, 420);
    expect(decoration.color, backgroundColor);
    expect(decoration.border?.top.color, borderColor);
  });

  testWidgets('NoticePill can derive issue tone colors', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.red);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(
          body: NoticePill(
            icon: Icons.rule_folder_outlined,
            label: 'Registry',
            message: 'Blank action id',
            tone: VisualTone.danger,
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.rule_folder_outlined));
    final decoratedBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(NoticePill),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final label = tester.widget<Text>(find.text('Registry'));

    expect(icon.color, scheme.error);
    expect(label.style?.color, scheme.error);
    expect(decoration.color, scheme.error.withValues(alpha: 0.08));
    expect(decoration.border?.top.color, scheme.error.withValues(alpha: 0.2));
  });

  testWidgets('NoticeOverflowPill summarizes hidden issues', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NoticeOverflowPill(hiddenCount: 3)),
      ),
    );

    expect(find.text('+3 more'), findsOneWidget);
    expect(find.byType(NoticePill), findsOneWidget);
  });
}
