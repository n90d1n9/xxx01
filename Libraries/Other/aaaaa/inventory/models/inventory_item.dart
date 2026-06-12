class InventoryItem {
  final String id;
  final String productId;
  final String warehouseId;
  final int currentQuantity;
  final int reorderPoint;
  final int reorderQuantity;

  InventoryItem({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.currentQuantity,
    required this.reorderPoint,
    required this.reorderQuantity,
  });

  InventoryItem copyWith({
    String? id,
    String? productId,
    String? warehouseId,
    int? currentQuantity,
    int? reorderPoint,
    int? reorderQuantity,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
    );
  }

  bool get needsReorder => currentQuantity <= reorderPoint;
}
