import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_report_catalog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_report_hub_components.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('report hub summary renders reusable metrics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InventoryReportHubSummary(stats: _readyStats)),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Stock Lines'), findsOneWidget);
    expect(find.text('Movements'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);
  });

  testWidgets('report catalog panel renders cards and launches ready report', (
    tester,
  ) async {
    InventoryReportType? generatedType;

    await tester.binding.setSurfaceSize(const Size(1000, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryReportCatalogPanel(
            stats: _readyStats,
            onGenerate: (type) => generatedType = type,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryReportCard), findsNWidgets(4));
    expect(find.text('Inventory Valuation'), findsOneWidget);
    expect(find.text('Warehouse Capacity'), findsOneWidget);

    await tester.tap(find.text('Inventory Valuation'));

    expect(generatedType, InventoryReportType.valuation);
  });

  testWidgets('report card disables reports without required data', (
    tester,
  ) async {
    var launches = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InventoryReportCatalogPanel(
              stats: _emptyStats,
              onGenerate: (_) => launches += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Needs movements'), findsOneWidget);

    await tester.tap(find.text('Stock Movement History'));
    await tester.pump();

    expect(launches, 0);
  });
}

const _readyStats = InventoryReportHubStats(
  productCount: 4,
  stockLineCount: 8,
  movementCount: 6,
  lowStockCount: 2,
  warehouseCount: 3,
);

const _emptyStats = InventoryReportHubStats(
  productCount: 0,
  stockLineCount: 0,
  movementCount: 0,
  lowStockCount: 0,
  warehouseCount: 0,
);
