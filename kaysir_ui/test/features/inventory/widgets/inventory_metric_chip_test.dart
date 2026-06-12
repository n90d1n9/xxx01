import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_metric_chip.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';

void main() {
  testWidgets('inventory metric chip renders compact label and value', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryMetricChip(
            label: 'Available',
            value: '42 units',
            icon: Icons.inventory_2_rounded,
            maxValueWidth: 96,
          ),
        ),
      ),
    );

    expect(find.text('Available'), findsOneWidget);
    expect(find.text('42 units'), findsOneWidget);
    expect(find.byType(InventoryTileSurface), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('42 units'),
        matching: find.byType(ConstrainedBox),
      ),
      findsOneWidget,
    );
  });

  testWidgets('inventory metric chip can emphasize attention values', (
    tester,
  ) async {
    final emphasis = Colors.red.shade700;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryMetricChip(
            label: 'Shortage',
            value: 'Needs attention',
            icon: Icons.warning_amber_rounded,
            emphasize: true,
            emphasizeColor: emphasis,
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.warning_amber_rounded));
    final value = tester.widget<Text>(find.text('Needs attention'));

    expect(find.byType(InventoryTileSurface), findsOneWidget);
    expect(icon.color, emphasis);
    expect(value.style?.color, emphasis);
    expect(value.style?.fontWeight, FontWeight.w900);
  });
}
