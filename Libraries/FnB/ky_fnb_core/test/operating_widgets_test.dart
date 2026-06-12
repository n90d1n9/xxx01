import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

void main() {
  testWidgets('metric chip renders compact icon and label', (tester) async {
    await tester.pumpWidget(
      const _WidgetHarness(
        child: FnbMetricChip(
          icon: Icons.schedule_outlined,
          label: '14m average',
        ),
      ),
    );

    expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    expect(find.text('14m average'), findsOneWidget);
  });

  testWidgets('metric chip accepts bordered surface styling', (tester) async {
    await tester.pumpWidget(
      const _WidgetHarness(
        child: FnbMetricChip.outlined(
          icon: Icons.timer_outlined,
          label: '2 late',
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(FnbMetricChip),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;

    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    expect(find.text('2 late'), findsOneWidget);
    expect(decoration.border, isNotNull);
  });

  testWidgets('status badge renders state icon with tooltip', (tester) async {
    await tester.pumpWidget(
      const _WidgetHarness(
        child: FnbStatusBadge(
          icon: Icons.check_circle_outline,
          color: Colors.teal,
          tooltip: 'Review complete',
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    await tester.longPress(find.byType(FnbStatusBadge));
    await tester.pumpAndSettle();

    expect(find.text('Review complete'), findsOneWidget);
  });

  testWidgets('status pill renders compact status copy', (tester) async {
    await tester.pumpWidget(
      const _WidgetHarness(
        child: FnbStatusPill(label: 'Limited', color: Colors.orange),
      ),
    );

    expect(find.text('Limited'), findsOneWidget);
  });

  testWidgets('attention banner renders priority message and icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _WidgetHarness(
        child: FnbAttentionBanner(
          message: 'Batch Sambal: Link to a menu item',
          color: Colors.red,
        ),
      ),
    );

    expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
    expect(find.text('Batch Sambal: Link to a menu item'), findsOneWidget);
  });
}

/// Minimal Material wrapper for shared FnB widget tests.
class _WidgetHarness extends StatelessWidget {
  const _WidgetHarness({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }
}
