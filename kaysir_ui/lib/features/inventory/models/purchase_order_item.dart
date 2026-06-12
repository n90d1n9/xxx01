class PurchaseOrderItem {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final String? sku;
  //final double? total;

  PurchaseOrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.sku,
  });

  double get total => quantity * unitPrice;
}
