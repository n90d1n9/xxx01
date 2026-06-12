import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_touch_quick_button_metrics.dart';

void main() {
  test('touch quick button metrics increase target size by density', () {
    final compact = resolvePOSTouchQuickButtonMetrics(
      density: POSTouchLayoutDensity.compact,
      compactChrome: false,
      minTileExtent: 96,
    );
    final spacious = resolvePOSTouchQuickButtonMetrics(
      density: POSTouchLayoutDensity.spacious,
      compactChrome: false,
      minTileExtent: 96,
    );
    final kiosk = resolvePOSTouchQuickButtonMetrics(
      density: POSTouchLayoutDensity.kiosk,
      compactChrome: false,
      minTileExtent: 96,
    );

    expect(spacious.targetExtent, greaterThan(compact.targetExtent));
    expect(kiosk.mainAxisExtent, greaterThan(spacious.mainAxisExtent));
  });

  test('touch quick button metrics resolve stable column counts', () {
    final metrics = resolvePOSTouchQuickButtonMetrics(
      density: POSTouchLayoutDensity.comfortable,
      compactChrome: false,
      minTileExtent: 96,
    );

    expect(metrics.columnsFor(width: 620, maxColumns: 6), 4);
    expect(metrics.columnsFor(width: 80, maxColumns: 6), 1);
    expect(metrics.columnsFor(width: 2000, maxColumns: 5), 5);
  });
}
