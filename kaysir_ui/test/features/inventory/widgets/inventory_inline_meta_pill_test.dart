import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_inline_meta_pill.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';

void main() {
  testWidgets('inventory inline meta pill renders shared compact metadata', (
    tester,
  ) async {
    const color = Color(0xFF00695C);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryInlineMetaPill(
            label: '12 units',
            icon: Icons.inventory_2_rounded,
            iconColor: color,
          ),
        ),
      ),
    );

    expect(find.byType(InventoryTileSurface), findsOneWidget);
    expect(find.text('12 units'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.inventory_2_rounded));
    expect(icon.size, 16);
    expect(icon.color, color);
  });

  testWidgets('inventory inline meta pill constrains long labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryInlineMetaPill(
            label: 'Very long metadata label that should stay inside the pill',
            icon: Icons.notes_rounded,
            maxWidth: 160,
          ),
        ),
      ),
    );

    final constrainedBoxes = tester.widgetList<ConstrainedBox>(
      find.byType(ConstrainedBox),
    );
    expect(
      constrainedBoxes.any((box) => box.constraints.maxWidth == 160),
      isTrue,
    );
    expect(find.byType(InventoryTileSurface), findsOneWidget);
  });
}
