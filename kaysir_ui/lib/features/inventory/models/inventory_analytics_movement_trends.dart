import 'inventory_movement.dart';
import 'movement_type.dart';

/// Seven-day movement quantity summary for one inventory analytics date.
class InventoryAnalyticsMovementTrend {
  const InventoryAnalyticsMovementTrend({
    required this.date,
    required this.inboundQuantity,
    required this.outboundQuantity,
  });

  final DateTime date;
  final int inboundQuantity;
  final int outboundQuantity;

  int get netQuantityChange => inboundQuantity - outboundQuantity;
}

/// Builds the seven-day stock movement trend window used by analytics.
List<InventoryAnalyticsMovementTrend> buildInventoryAnalyticsMovementTrends(
  List<InventoryMovement> movements, {
  required DateTime asOfDate,
}) {
  final endDate = _dateOnly(asOfDate);
  final startDate = endDate.subtract(const Duration(days: 6));
  final trendsByDate = <DateTime, _MovementTrendBuilder>{};

  for (var index = 0; index < 7; index += 1) {
    final date = startDate.add(Duration(days: index));
    trendsByDate[date] = _MovementTrendBuilder(date);
  }

  for (final movement in movements) {
    final date = _dateOnly(movement.date);
    final trend = trendsByDate[date];
    if (trend == null) continue;
    trend.add(movement);
  }

  return [for (final trend in trendsByDate.values) trend.toTrend()];
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

class _MovementTrendBuilder {
  _MovementTrendBuilder(this.date);

  final DateTime date;
  var inboundQuantity = 0;
  var outboundQuantity = 0;

  void add(InventoryMovement movement) {
    final quantity = movement.quantity.abs();
    switch (movement.type) {
      case MovementType.purchase:
      case MovementType.receipt:
      case MovementType.inbound:
        inboundQuantity += quantity;
      case MovementType.sale:
      case MovementType.issue:
      case MovementType.outbound:
        outboundQuantity += quantity;
      case MovementType.adjustment:
        if (movement.quantity >= 0) {
          inboundQuantity += quantity;
        } else {
          outboundQuantity += quantity;
        }
      case MovementType.transfer:
      case MovementType.stockOpname:
        break;
    }
  }

  InventoryAnalyticsMovementTrend toTrend() {
    return InventoryAnalyticsMovementTrend(
      date: date,
      inboundQuantity: inboundQuantity,
      outboundQuantity: outboundQuantity,
    );
  }
}
