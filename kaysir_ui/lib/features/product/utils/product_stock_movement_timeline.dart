import '../../inventory/models/movement_type.dart';
import '../../inventory/models/stock_movement.dart';
import '../models/product.dart';
import 'product_stock_adjustment.dart';
import 'product_stock_movement_display.dart';

class ProductStockMovementTimeline {
  const ProductStockMovementTimeline({
    required this.entries,
    required this.summary,
  });

  final List<ProductStockMovementTimelineEntry> entries;
  final ProductStockMovementSummary summary;
}

class ProductStockMovementTimelineEntry {
  const ProductStockMovementTimelineEntry({
    required this.movement,
    required this.display,
    this.product,
  });

  final StockMovement movement;
  final ProductStockMovementDisplay display;
  final Product? product;

  String get productName {
    final name = product?.name.trim();
    return name == null || name.isEmpty ? 'Unknown product' : name;
  }

  String get skuLabel {
    final sku = product?.sku?.trim();
    return sku == null || sku.isEmpty ? 'No SKU' : sku;
  }

  String get categoryLabel {
    final category = product?.category?.trim();
    return category == null || category.isEmpty ? 'Uncategorized' : category;
  }

  String get referenceLabel {
    final reference = movement.reference.trim();
    return reference.isEmpty ? 'No reference' : reference;
  }

  bool matchesQuery(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return [
      productName,
      skuLabel,
      categoryLabel,
      referenceLabel,
      movement.notes,
      display.typeLabel,
      movement.productId,
    ].any((value) => value.toLowerCase().contains(normalizedQuery));
  }
}

class ProductStockMovementSummary {
  const ProductStockMovementSummary({
    required this.totalMovements,
    required this.inboundUnits,
    required this.outboundUnits,
    required this.neutralMovements,
    this.latestMovementAt,
  });

  final int totalMovements;
  final int inboundUnits;
  final int outboundUnits;
  final int neutralMovements;
  final DateTime? latestMovementAt;

  bool get isEmpty => totalMovements == 0;
}

ProductStockMovementTimeline buildProductStockMovementTimeline({
  required List<StockMovement> movements,
  required List<Product> products,
  String query = '',
  MovementType? type,
}) {
  final productsById = {
    for (final product in products)
      if (product.id.trim().isNotEmpty) product.id: product,
  };

  final entries =
      movements
          .map(
            (movement) => ProductStockMovementTimelineEntry(
              movement: movement,
              product: productsById[movement.productId],
              display: ProductStockMovementDisplay.fromMovement(movement),
            ),
          )
          .where((entry) => type == null || entry.movement.type == type)
          .where((entry) => entry.matchesQuery(query))
          .toList()
        ..sort(
          (left, right) => right.movement.date.compareTo(left.movement.date),
        );

  return ProductStockMovementTimeline(
    entries: entries,
    summary: _summarize(entries),
  );
}

ProductStockMovementSummary _summarize(
  List<ProductStockMovementTimelineEntry> entries,
) {
  var inboundUnits = 0;
  var outboundUnits = 0;
  var neutralMovements = 0;

  for (final entry in entries) {
    final delta = productStockDeltaForMovement(
      entry.movement.type,
      entry.movement.quantity,
    );

    if (delta > 0) {
      inboundUnits += delta;
    } else if (delta < 0) {
      outboundUnits += delta.abs();
    } else {
      neutralMovements += 1;
    }
  }

  return ProductStockMovementSummary(
    totalMovements: entries.length,
    inboundUnits: inboundUnits,
    outboundUnits: outboundUnits,
    neutralMovements: neutralMovements,
    latestMovementAt: entries.isEmpty ? null : entries.first.movement.date,
  );
}
