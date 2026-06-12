import '../../ecommerce/order/order.dart';
import '../../product/models/product.dart';
import '../utils/inventory_form_utils.dart';
import 'purchase_order.dart';
import 'purchase_order_item.dart';

enum InventoryPurchaseOrderCreateIssue { missingSupplier, emptyItems }

enum InventoryPurchaseOrderLineIssue {
  missingProduct,
  invalidQuantity,
  invalidUnitPrice,
}

class InventoryPurchaseOrderCreateDraft {
  const InventoryPurchaseOrderCreateDraft({
    required this.supplierName,
    required this.items,
    this.expectedDeliveryDate,
    this.notes = '',
  });

  final String supplierName;
  final DateTime? expectedDeliveryDate;
  final String notes;
  final List<PurchaseOrderItem> items;

  String get normalizedSupplierName => supplierName.trim();

  String? get normalizedNotes {
    final value = notes.trim();
    return value.isEmpty ? null : value;
  }

  int get itemCount => items.length;

  int get totalQuantity {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return items.fold<double>(0, (sum, item) => sum + item.total);
  }

  bool get canCreate => validateInventoryPurchaseOrderCreateDraft(this) == null;

  PurchaseOrder toPurchaseOrder({
    required String id,
    required DateTime orderDate,
    OrderStatus status = OrderStatus.confirmed,
  }) {
    return PurchaseOrder(
      id: id,
      supplierName: normalizedSupplierName,
      vendorName: normalizedSupplierName,
      orderDate: orderDate,
      expectedDeliveryDate: expectedDeliveryDate,
      status: status,
      items: items,
      totalAmount: totalAmount,
      notes: normalizedNotes,
    );
  }
}

class InventoryPurchaseOrderLineDraft {
  const InventoryPurchaseOrderLineDraft({
    required this.products,
    this.productId,
    this.quantityText = '',
    this.unitPriceText = '',
  });

  final List<Product> products;
  final String? productId;
  final String quantityText;
  final String unitPriceText;

  Product? get selectedProduct {
    for (final product in products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  int? get quantity => parseInventoryInteger(quantityText);

  double? get unitPrice => parseInventoryDecimal(unitPriceText);

  double get total {
    return (quantity ?? 0) * (unitPrice ?? 0);
  }

  PurchaseOrderItem toPurchaseOrderItem() {
    final product = selectedProduct;
    return PurchaseOrderItem(
      id: product!.id,
      name: product.name,
      sku: product.sku,
      quantity: quantity!,
      unitPrice: unitPrice!,
    );
  }
}

InventoryPurchaseOrderCreateIssue? validateInventoryPurchaseOrderCreateDraft(
  InventoryPurchaseOrderCreateDraft draft,
) {
  if (draft.normalizedSupplierName.isEmpty) {
    return InventoryPurchaseOrderCreateIssue.missingSupplier;
  }
  if (draft.items.isEmpty) {
    return InventoryPurchaseOrderCreateIssue.emptyItems;
  }
  return null;
}

InventoryPurchaseOrderLineIssue? validateInventoryPurchaseOrderLineDraft(
  InventoryPurchaseOrderLineDraft draft,
) {
  if (draft.selectedProduct == null) {
    return InventoryPurchaseOrderLineIssue.missingProduct;
  }
  final quantity = draft.quantity;
  if (quantity == null || quantity <= 0) {
    return InventoryPurchaseOrderLineIssue.invalidQuantity;
  }
  final unitPrice = draft.unitPrice;
  if (unitPrice == null || unitPrice <= 0) {
    return InventoryPurchaseOrderLineIssue.invalidUnitPrice;
  }
  return null;
}

String inventoryPurchaseOrderCreateIssueLabel(
  InventoryPurchaseOrderCreateIssue issue,
) {
  switch (issue) {
    case InventoryPurchaseOrderCreateIssue.missingSupplier:
      return 'Enter a supplier before creating the order.';
    case InventoryPurchaseOrderCreateIssue.emptyItems:
      return 'Add at least one item before creating the order.';
  }
}

String inventoryPurchaseOrderLineIssueLabel(
  InventoryPurchaseOrderLineIssue issue,
) {
  switch (issue) {
    case InventoryPurchaseOrderLineIssue.missingProduct:
      return 'Please select a product.';
    case InventoryPurchaseOrderLineIssue.invalidQuantity:
      return 'Enter a valid positive quantity.';
    case InventoryPurchaseOrderLineIssue.invalidUnitPrice:
      return 'Enter a valid positive unit price.';
  }
}

String inventoryPurchaseOrderIdForDate(DateTime date) {
  final millis = date.millisecondsSinceEpoch.toString();
  final suffix =
      millis.length <= 6 ? millis : millis.substring(millis.length - 6);
  return 'PO-$suffix';
}
