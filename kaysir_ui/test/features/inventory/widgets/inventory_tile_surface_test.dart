import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';

void main() {
  testWidgets('inventory tile surface renders shared chrome', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryTileSurface(child: Text('Warehouse tile')),
        ),
      ),
    );

    expect(find.text('Warehouse tile'), findsOneWidget);
    expect(find.byType(DecoratedBox), findsOneWidget);

    final padding = tester.widget<Padding>(find.byType(Padding).last);
    expect(padding.padding, const EdgeInsets.all(12));
  });

  testWidgets('inventory tile surface accepts custom surface colors', (
    tester,
  ) async {
    const background = Color(0xFFE8F5E9);
    const border = Color(0xFF2E7D32);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryTileSurface(
            backgroundColor: background,
            borderColor: border,
            borderRadius: 6,
            padding: EdgeInsets.all(8),
            child: Text('Low stock tile'),
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final decoration = decoratedBox.decoration as BoxDecoration;
    final shape = decoration.border as Border;

    expect(decoration.color, background);
    expect(shape.top.color, border);
    expect(decoration.borderRadius, BorderRadius.circular(6));
    expect(
      tester.widget<Padding>(find.byType(Padding).last).padding,
      const EdgeInsets.all(8),
    );
  });
}
