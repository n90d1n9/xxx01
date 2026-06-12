import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_value_bar_row.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';

void main() {
  testWidgets('analytics value bar row renders value copy and progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryAnalyticsValueBarRow(
            label: 'Electronics',
            valueLabel: r'$12,500.00',
            helper: '32 units | 8 products',
            percent: 0.72,
            color: Colors.teal.shade700,
          ),
        ),
      ),
    );

    expect(find.byType(InventoryTileSurface), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text(r'$12,500.00'), findsOneWidget);
    expect(find.text('32 units | 8 products'), findsOneWidget);

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, 0.72);
  });

  testWidgets('analytics value bar row clamps progress values', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryAnalyticsValueBarRow(
            label: 'Overflow',
            valueLabel: r'$9,100.00',
            helper: '120 units',
            percent: 1.4,
            color: Colors.indigo.shade700,
          ),
        ),
      ),
    );

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, 1);
  });
}
