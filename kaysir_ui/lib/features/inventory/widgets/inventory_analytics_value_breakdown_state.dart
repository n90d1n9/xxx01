import '../models/inventory_analytics_dashboard.dart';
import '../utils/inventory_formatters.dart';

/// Presentation state for one value breakdown row in analytics.
class InventoryAnalyticsValueBreakdownRowState {
  const InventoryAnalyticsValueBreakdownRowState({
    required this.label,
    required this.valueLabel,
    required this.helper,
    required this.percent,
    required this.colorIndex,
  });

  final String label;
  final String valueLabel;
  final String helper;
  final double percent;
  final int colorIndex;
}

/// Presentation state for an analytics value breakdown panel.
class InventoryAnalyticsValueBreakdownPanelState {
  const InventoryAnalyticsValueBreakdownPanelState({
    required this.statusLabel,
    required this.rows,
  });

  final String statusLabel;
  final List<InventoryAnalyticsValueBreakdownRowState> rows;

  bool get hasRows => rows.isNotEmpty;
}

/// Builds value breakdown row state for product categories.
InventoryAnalyticsValueBreakdownPanelState
inventoryAnalyticsCategoryValueBreakdownState(
  List<InventoryAnalyticsCategoryValue> values,
) {
  final totalValue = _totalBreakdownValue(values.map((value) => value.value));

  return InventoryAnalyticsValueBreakdownPanelState(
    statusLabel: '${values.length} categories',
    rows: [
      for (var index = 0; index < values.length; index += 1)
        _categoryRow(values[index], totalValue, index),
    ],
  );
}

/// Builds value breakdown row state for branches.
InventoryAnalyticsValueBreakdownPanelState
inventoryAnalyticsBranchValueBreakdownState(
  List<InventoryAnalyticsBranchValue> values,
) {
  final totalValue = _totalBreakdownValue(values.map((value) => value.value));

  return InventoryAnalyticsValueBreakdownPanelState(
    statusLabel: '${values.length} branches',
    rows: [
      for (var index = 0; index < values.length; index += 1)
        _branchRow(values[index], totalValue, index + 1),
    ],
  );
}

/// Builds value breakdown row state for warehouses.
InventoryAnalyticsValueBreakdownPanelState
inventoryAnalyticsWarehouseValueBreakdownState(
  List<InventoryAnalyticsWarehouseValue> values,
) {
  final totalValue = _totalBreakdownValue(values.map((value) => value.value));

  return InventoryAnalyticsValueBreakdownPanelState(
    statusLabel: '${values.length} locations',
    rows: [
      for (var index = 0; index < values.length; index += 1)
        _warehouseRow(values[index], totalValue, index + 2),
    ],
  );
}

double _totalBreakdownValue(Iterable<double> values) {
  return values.fold<double>(0, (sum, value) => sum + value);
}

double _breakdownPercent(double value, double totalValue) {
  if (totalValue <= 0) return 0;
  return value / totalValue;
}

InventoryAnalyticsValueBreakdownRowState _categoryRow(
  InventoryAnalyticsCategoryValue value,
  double totalValue,
  int colorIndex,
) {
  return InventoryAnalyticsValueBreakdownRowState(
    label: value.category,
    valueLabel: formatInventoryCurrency(value.value),
    helper:
        '${formatInventoryNumber(value.quantity)} units | '
        '${formatInventoryNumber(value.productCount)} products',
    percent: _breakdownPercent(value.value, totalValue),
    colorIndex: colorIndex,
  );
}

InventoryAnalyticsValueBreakdownRowState _branchRow(
  InventoryAnalyticsBranchValue value,
  double totalValue,
  int colorIndex,
) {
  return InventoryAnalyticsValueBreakdownRowState(
    label: value.branchName,
    valueLabel: formatInventoryCurrency(value.value),
    helper:
        '${formatInventoryNumber(value.quantity)} units | '
        '${formatInventoryNumber(value.warehouseCount)} warehouses | '
        '${formatInventoryNumber(value.productCount)} products',
    percent: _breakdownPercent(value.value, totalValue),
    colorIndex: colorIndex,
  );
}

InventoryAnalyticsValueBreakdownRowState _warehouseRow(
  InventoryAnalyticsWarehouseValue value,
  double totalValue,
  int colorIndex,
) {
  return InventoryAnalyticsValueBreakdownRowState(
    label: value.warehouseName,
    valueLabel: formatInventoryCurrency(value.value),
    helper:
        '${formatInventoryNumber(value.quantity)} units | '
        '${formatInventoryNumber(value.productCount)} products',
    percent: _breakdownPercent(value.value, totalValue),
    colorIndex: colorIndex,
  );
}
