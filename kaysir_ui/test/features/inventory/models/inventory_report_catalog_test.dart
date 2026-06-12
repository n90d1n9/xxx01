import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_report_catalog.dart';

void main() {
  test('report hub stats tracks ready report count from available data', () {
    final stats = buildInventoryReportHubStats(
      productCount: 2,
      stockLineCount: 3,
      movementCount: 0,
      lowStockCount: 1,
      warehouseCount: 2,
    );

    expect(stats.readyReportCount, 3);
    expect(stats.canGenerate(InventoryReportType.valuation), isTrue);
    expect(stats.canGenerate(InventoryReportType.movementHistory), isFalse);
    expect(stats.canGenerate(InventoryReportType.lowStock), isTrue);
    expect(stats.canGenerate(InventoryReportType.warehouseCapacity), isTrue);
  });

  test('report labels explain data and readiness gaps', () {
    const stats = InventoryReportHubStats(
      productCount: 0,
      stockLineCount: 0,
      movementCount: 0,
      lowStockCount: 0,
      warehouseCount: 0,
    );

    expect(
      stats.readinessLabelFor(InventoryReportType.valuation),
      'Needs stock data',
    );
    expect(
      stats.readinessLabelFor(InventoryReportType.movementHistory),
      'Needs movements',
    );
    expect(
      stats.readinessLabelFor(InventoryReportType.warehouseCapacity),
      'Needs warehouses',
    );
    expect(stats.dataLabelFor(InventoryReportType.lowStock), '0 alerts');
  });
}
