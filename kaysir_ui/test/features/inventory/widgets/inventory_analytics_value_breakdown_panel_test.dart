import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_preview_data.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_value_breakdown_panel.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_value_breakdown_state.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

void main() {
  testWidgets('value breakdown panel renders rows from state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryAnalyticsValueBreakdownPanel(
            title: 'Inventory by Category',
            subtitle: 'Stock value concentration across product groups',
            leadingIcon: Icons.category_rounded,
            statusIcon: Icons.pie_chart_rounded,
            emptyTitle: 'No category value yet',
            emptyMessage:
                'Add stocked products to populate category analytics.',
            emptyIcon: Icons.category_outlined,
            state: inventoryAnalyticsCategoryValueBreakdownState(
              inventoryAnalyticsPreviewCategoryValues(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Inventory by Category'), findsOneWidget);
    expect(find.text('3 categories'), findsOneWidget);
    expect(find.byType(InventoryTileSurface), findsNWidgets(3));
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text(r'$12,500.00'), findsOneWidget);
  });

  testWidgets('value breakdown panel renders empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryAnalyticsValueBreakdownPanel(
            title: 'Inventory by Category',
            subtitle: 'Stock value concentration across product groups',
            leadingIcon: Icons.category_rounded,
            statusIcon: Icons.pie_chart_rounded,
            emptyTitle: 'No category value yet',
            emptyMessage:
                'Add stocked products to populate category analytics.',
            emptyIcon: Icons.category_outlined,
            state: InventoryAnalyticsValueBreakdownPanelState(
              statusLabel: '0 categories',
              rows: [],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No category value yet'), findsOneWidget);
    expect(find.text('0 categories'), findsNothing);
  });
}
