import '../models/inventory_movement_record.dart';
import '../models/inventory_stock_movement_report.dart';
import '../utils/inventory_formatters.dart';
import 'movement_direction_visuals.dart';

/// Formats the quantity label for a stock movement report line.
String stockMovementReportQuantityLabel(InventoryStockMovementReportLine line) {
  if (line.direction == InventoryMovementDirection.adjustment) {
    return '${formatInventorySignedNumber(line.signedQuantity)} adjusted';
  }

  return movementDirectionQuantityLabel(line.direction, line.quantity.abs());
}
