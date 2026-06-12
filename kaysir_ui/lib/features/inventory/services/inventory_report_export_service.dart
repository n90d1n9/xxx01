import 'package:intl/intl.dart';

import '../models/inventory_low_stock_report.dart';
import '../models/inventory_stock_movement_report.dart';
import '../models/inventory_valuation_report.dart';
import '../models/inventory_warehouse_capacity_report.dart';

class InventoryReportCsvDocument {
  const InventoryReportCsvDocument({
    required this.fileName,
    required this.contents,
    required this.dataRowCount,
  });

  final String fileName;
  final String contents;
  final int dataRowCount;
}

InventoryReportCsvDocument buildInventoryValuationCsvDocument({
  required List<InventoryValuationLine> lines,
  required DateTime asOfDate,
}) {
  return InventoryReportCsvDocument(
    fileName: 'inventory-valuation-${_dateStamp(asOfDate)}.csv',
    dataRowCount: lines.length,
    contents: _buildCsv([
      [
        'Inventory Item ID',
        'Product ID',
        'Product',
        'SKU',
        'Category',
        'Warehouse ID',
        'Warehouse',
        'Branch',
        'Location',
        'Quantity',
        'Unit Price',
        'Total Value',
      ],
      for (final line in lines)
        [
          line.inventoryItemId,
          line.productId,
          line.productName,
          line.skuLabel,
          line.categoryLabel,
          line.warehouseId,
          line.warehouseName,
          line.warehouseBranch,
          line.warehouseLocation,
          line.quantity,
          _moneyValue(line.unitPrice),
          _moneyValue(line.totalValue),
        ],
    ]),
  );
}

InventoryReportCsvDocument buildWarehouseCapacityCsvDocument({
  required List<InventoryWarehouseCapacityLine> lines,
  required DateTime asOfDate,
}) {
  return InventoryReportCsvDocument(
    fileName: 'warehouse-capacity-${_dateStamp(asOfDate)}.csv',
    dataRowCount: lines.length,
    contents: _buildCsv([
      [
        'Warehouse ID',
        'Warehouse',
        'Branch',
        'Location',
        'Used Units',
        'Capacity',
        'Available Units',
        'Utilization Percent',
        'Product Count',
        'Status',
      ],
      for (final line in lines)
        [
          line.warehouseId,
          line.warehouseName,
          line.branchLabel,
          line.locationLabel,
          line.usedUnits,
          line.hasTrackedCapacity ? _numberValue(line.capacity!) : '',
          line.availableUnits == null ? '' : _numberValue(line.availableUnits!),
          _percentValue(line.utilizationPercent),
          line.productCount,
          inventoryWarehouseCapacityStatusLabel(line.status),
        ],
    ]),
  );
}

InventoryReportCsvDocument buildLowStockCsvDocument({
  required List<InventoryLowStockReportLine> lines,
  required DateTime asOfDate,
}) {
  return InventoryReportCsvDocument(
    fileName: 'low-stock-${_dateStamp(asOfDate)}.csv',
    dataRowCount: lines.length,
    contents: _buildCsv([
      [
        'Inventory Item ID',
        'Product ID',
        'Product',
        'SKU',
        'Category',
        'Warehouse ID',
        'Warehouse',
        'Branch',
        'Location',
        'Current Quantity',
        'Reorder Point',
        'Shortage',
        'Reorder Quantity',
        'Suggested Quantity',
        'Projected Quantity',
        'Unit Price',
        'Estimated Cost',
        'Status',
      ],
      for (final line in lines)
        [
          line.inventoryItemId,
          line.productId,
          line.productName,
          line.skuLabel,
          line.categoryLabel,
          line.warehouseId,
          line.warehouseName,
          line.warehouseBranch,
          line.warehouseLocation,
          line.currentQuantity,
          line.reorderPoint,
          line.shortage,
          line.reorderQuantity,
          line.suggestedQuantity,
          line.projectedQuantity,
          _moneyValue(line.unitPrice),
          _moneyValue(line.estimatedCost),
          inventoryLowStockReportStatusLabel(line.status),
        ],
    ]),
  );
}

InventoryReportCsvDocument buildStockMovementCsvDocument({
  required List<InventoryStockMovementReportLine> lines,
  required DateTime asOfDate,
}) {
  return InventoryReportCsvDocument(
    fileName: 'stock-movement-${_dateStamp(asOfDate)}.csv',
    dataRowCount: lines.length,
    contents: _buildCsv([
      [
        'Movement ID',
        'Date',
        'Product ID',
        'Product',
        'SKU',
        'Type',
        'Direction',
        'Quantity',
        'Signed Quantity',
        'Source Warehouse ID',
        'Source Warehouse',
        'Source Branch',
        'Destination Warehouse ID',
        'Destination Warehouse',
        'Destination Branch',
        'Reference',
        'Unit Price',
        'Movement Value',
        'Notes',
      ],
      for (final line in lines)
        [
          line.id,
          _dateTimeValue(line.movementDate),
          line.productId,
          line.productName,
          line.skuLabel,
          line.typeLabel,
          line.direction.name,
          line.quantity,
          line.signedQuantity,
          line.sourceWarehouseId,
          line.sourceWarehouseName,
          line.sourceBranchLabel,
          line.destinationWarehouseId ?? '',
          line.destinationWarehouseName == 'No destination'
              ? ''
              : line.destinationWarehouseName,
          line.destinationBranchLabel ?? '',
          line.referenceLabel,
          _moneyValue(line.unitPrice),
          _moneyValue(line.movementValue),
          line.notesLabel == 'No notes' ? '' : line.notesLabel,
        ],
    ]),
  );
}

String _buildCsv(List<List<Object?>> rows) {
  return rows.map((row) => row.map(_csvCell).join(',')).join('\n');
}

String _csvCell(Object? value) {
  final text = value?.toString() ?? '';
  final escaped = text.replaceAll('"', '""');
  final needsQuotes =
      escaped.contains(',') ||
      escaped.contains('"') ||
      escaped.contains('\n') ||
      escaped.contains('\r');

  return needsQuotes ? '"$escaped"' : escaped;
}

String _dateStamp(DateTime value) {
  return DateFormat('yyyy-MM-dd').format(value);
}

String _dateTimeValue(DateTime value) {
  return DateFormat('yyyy-MM-dd HH:mm').format(value);
}

String _moneyValue(num value) {
  return value.toStringAsFixed(2);
}

String _numberValue(num value) {
  final asDouble = value.toDouble();
  if (value is int || asDouble == asDouble.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

String _percentValue(double value) {
  return value.toStringAsFixed(1);
}
