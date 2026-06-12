import '../../product/models/product.dart';
import '../utils/inventory_label_utils.dart';
import 'inventory_purchase_order_workspace.dart';
import 'movement_type.dart';
import 'purchase_order.dart';
import 'stock_movement.dart';

enum InventoryPurchaseOrderMovementTone { inbound, outbound, neutral }

class InventoryPurchaseOrderDashboard {
  const InventoryPurchaseOrderDashboard({
    required this.summary,
    required this.lowStockProducts,
    required this.recentMovements,
    required this.receivingOrders,
  });

  final InventoryPurchaseOrderDashboardSummary summary;
  final List<InventoryPurchaseOrderLowStockProduct> lowStockProducts;
  final List<InventoryPurchaseOrderMovementRecord> recentMovements;
  final List<InventoryPurchaseOrderRecord> receivingOrders;
}

class InventoryPurchaseOrderDashboardSummary {
  const InventoryPurchaseOrderDashboardSummary({
    required this.productCount,
    required this.lowStockProductCount,
    required this.totalInventoryValue,
    required this.onHandUnits,
    required this.receivingOrderCount,
    required this.receivingOrderValue,
    required this.recentMovementCount,
  });

  final int productCount;
  final int lowStockProductCount;
  final double totalInventoryValue;
  final int onHandUnits;
  final int receivingOrderCount;
  final double receivingOrderValue;
  final int recentMovementCount;
}

class InventoryPurchaseOrderLowStockProduct {
  const InventoryPurchaseOrderLowStockProduct({
    required this.product,
    required this.threshold,
  });

  final Product product;
  final int threshold;

  String get id => product.id;

  String get productName => inventoryProductNameLabel(product.name);

  String get skuLabel => inventorySkuLabel(product.sku);

  String get categoryLabel => inventoryCategoryLabel(product.category);

  int get currentStock => product.currentStock;

  int get shortageToThreshold {
    final shortage = threshold - currentStock;
    return shortage > 0 ? shortage : 0;
  }

  double get stockValue => product.price * currentStock;
}

class InventoryPurchaseOrderMovementRecord {
  const InventoryPurchaseOrderMovementRecord({
    required this.movement,
    required this.product,
  });

  final StockMovement movement;
  final Product? product;

  String get id => movement.id;

  String get productName => inventoryProductNameLabel(product?.name);

  String get referenceLabel => inventoryReferenceLabel(movement.reference);

  DateTime get date => movement.date;

  int get quantity => movement.quantity;

  String get typeLabel =>
      inventoryPurchaseOrderMovementTypeLabel(movement.type);

  InventoryPurchaseOrderMovementTone get tone =>
      inventoryPurchaseOrderMovementTone(movement.type);

  String get quantityLabel {
    final suffix = quantity == 1 ? 'unit' : 'units';
    switch (tone) {
      case InventoryPurchaseOrderMovementTone.inbound:
        return '+$quantity $suffix';
      case InventoryPurchaseOrderMovementTone.outbound:
        return '-$quantity $suffix';
      case InventoryPurchaseOrderMovementTone.neutral:
        return '$quantity $suffix';
    }
  }
}

InventoryPurchaseOrderDashboard buildInventoryPurchaseOrderDashboard({
  required List<Product> products,
  required List<StockMovement> stockMovements,
  required List<PurchaseOrder> purchaseOrders,
  required DateTime asOfDate,
  int lowStockThreshold = 5,
  int recentMovementLimit = 5,
}) {
  final productsById = {for (final product in products) product.id: product};
  final lowStockProducts = [
    for (final product in products)
      if (product.currentStock <= lowStockThreshold)
        InventoryPurchaseOrderLowStockProduct(
          product: product,
          threshold: lowStockThreshold,
        ),
  ]..sort(_compareLowStockProducts);

  final recentMovements = List<StockMovement>.from(stockMovements)
    ..sort((first, second) => second.date.compareTo(first.date));
  final movementRecords = [
    for (final movement in recentMovements.take(recentMovementLimit))
      InventoryPurchaseOrderMovementRecord(
        movement: movement,
        product: productsById[movement.productId],
      ),
  ];

  final purchaseOrderRecords = buildInventoryPurchaseOrderRecords(
    orders: purchaseOrders,
    asOfDate: asOfDate,
  );
  final receivingOrders = [
    for (final record in purchaseOrderRecords)
      if (record.needsReceiving) record,
  ];

  return InventoryPurchaseOrderDashboard(
    summary: InventoryPurchaseOrderDashboardSummary(
      productCount: products.length,
      lowStockProductCount: lowStockProducts.length,
      totalInventoryValue: products.fold(
        0,
        (total, product) => total + product.price * product.currentStock,
      ),
      onHandUnits: products.fold(
        0,
        (total, product) => total + product.currentStock,
      ),
      receivingOrderCount: receivingOrders.length,
      receivingOrderValue: receivingOrders.fold(
        0,
        (total, record) => total + record.totalAmount,
      ),
      recentMovementCount: movementRecords.length,
    ),
    lowStockProducts: lowStockProducts,
    recentMovements: movementRecords,
    receivingOrders: receivingOrders,
  );
}

String inventoryPurchaseOrderMovementTypeLabel(MovementType type) {
  switch (type) {
    case MovementType.receipt:
      return 'Receipt';
    case MovementType.issue:
      return 'Issue';
    case MovementType.transfer:
      return 'Transfer';
    case MovementType.adjustment:
      return 'Adjustment';
    case MovementType.stockOpname:
      return 'Stock opname';
    case MovementType.purchase:
      return 'Purchase';
    case MovementType.sale:
      return 'Sale';
    case MovementType.inbound:
      return 'Inbound';
    case MovementType.outbound:
      return 'Outbound';
  }
}

InventoryPurchaseOrderMovementTone inventoryPurchaseOrderMovementTone(
  MovementType type,
) {
  switch (type) {
    case MovementType.receipt:
    case MovementType.purchase:
    case MovementType.inbound:
      return InventoryPurchaseOrderMovementTone.inbound;
    case MovementType.issue:
    case MovementType.sale:
    case MovementType.outbound:
      return InventoryPurchaseOrderMovementTone.outbound;
    case MovementType.transfer:
    case MovementType.adjustment:
    case MovementType.stockOpname:
      return InventoryPurchaseOrderMovementTone.neutral;
  }
}

int _compareLowStockProducts(
  InventoryPurchaseOrderLowStockProduct first,
  InventoryPurchaseOrderLowStockProduct second,
) {
  final stockRank = first.currentStock.compareTo(second.currentStock);
  if (stockRank != 0) return stockRank;

  return first.productName.compareTo(second.productName);
}
