import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/widgets/component_inspector_controls.dart';

void main() {
  testWidgets('section header invokes reset action', (tester) async {
    var resetCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComponentInspectorSectionHeader(
            title: 'Grid position',
            resetTooltip: 'Snap to grid rules',
            onReset: () => resetCount++,
          ),
        ),
      ),
    );

    expect(find.text('Grid position'), findsOneWidget);
    expect(find.byTooltip('Snap to grid rules'), findsOneWidget);

    await tester.tap(find.byTooltip('Snap to grid rules'));
    await tester.pump();

    expect(resetCount, 1);
  });

  testWidgets('field pair stacks fields in narrow panels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            child: ComponentInspectorFieldPair(
              first: Text('Col'),
              second: Text('Row'),
            ),
          ),
        ),
      ),
    );

    final colTop = tester.getTopLeft(find.text('Col'));
    final rowTop = tester.getTopLeft(find.text('Row'));

    expect(rowTop.dy, greaterThan(colTop.dy));
  });

  testWidgets('chip renders compact icon label summary', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ComponentInspectorChip(icon: Icons.grid_on, label: 'C2 R3'),
        ),
      ),
    );

    expect(find.byIcon(Icons.grid_on), findsOneWidget);
    expect(find.text('C2 R3'), findsOneWidget);
  });
}
