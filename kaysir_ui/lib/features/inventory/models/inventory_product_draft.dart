import '../../product/models/product.dart';

enum InventoryProductDraftIssue {
  missingName,
  missingSku,
  missingCategory,
  invalidPrice,
}

class InventoryProductDraft {
  const InventoryProductDraft({
    required this.name,
    required this.sku,
    required this.category,
    this.description = '',
    this.barcode = '',
    this.shortcutKey = '',
    this.price,
  });

  final String name;
  final String sku;
  final String category;
  final String description;
  final String barcode;
  final String shortcutKey;
  final double? price;

  factory InventoryProductDraft.fromProduct(Product product) {
    return InventoryProductDraft(
      name: product.name,
      sku: product.sku ?? '',
      category: product.category ?? '',
      description: product.description ?? '',
      barcode: product.barcode ?? '',
      shortcutKey: product.shortcutKey,
      price: product.price,
    );
  }

  String get normalizedName => name.trim();

  String get normalizedSku => sku.trim();

  String get normalizedCategory => category.trim();

  String? get normalizedDescription {
    final value = description.trim();
    return value.isEmpty ? null : value;
  }

  String? get normalizedBarcode {
    final value = barcode.trim();
    return value.isEmpty ? null : value;
  }

  String get normalizedShortcutKey => shortcutKey.trim();

  Product toProduct({required String id}) {
    return Product(
      id: id,
      name: normalizedName,
      sku: normalizedSku,
      category: normalizedCategory,
      price: price ?? 0,
      description: normalizedDescription,
      barcode: normalizedBarcode,
      shortcutKey: normalizedShortcutKey,
    );
  }

  Product apply(Product product) {
    return Product(
      id: product.id,
      name: normalizedName,
      sku: normalizedSku,
      category: normalizedCategory,
      price: price ?? 0,
      description: normalizedDescription,
      barcode: normalizedBarcode,
      shortcutKey: normalizedShortcutKey,
      image: product.image,
      unit: product.unit,
      isliked: product.isliked,
      isSelected: product.isSelected,
      stockQuantity: product.stockQuantity,
      quantity: product.quantity,
      actualStock: product.actualStock,
      currentStock: product.currentStock,
      systemStock: product.systemStock,
      notes: product.notes,
      lastChecked: product.lastChecked,
    );
  }
}

InventoryProductDraftIssue? validateInventoryProductDraft(
  InventoryProductDraft draft,
) {
  if (draft.normalizedName.isEmpty) {
    return InventoryProductDraftIssue.missingName;
  }
  if (draft.normalizedSku.isEmpty) {
    return InventoryProductDraftIssue.missingSku;
  }
  if (draft.normalizedCategory.isEmpty) {
    return InventoryProductDraftIssue.missingCategory;
  }
  final price = draft.price;
  if (price == null || price <= 0) {
    return InventoryProductDraftIssue.invalidPrice;
  }
  return null;
}

String inventoryProductDraftIssueLabel(InventoryProductDraftIssue issue) {
  switch (issue) {
    case InventoryProductDraftIssue.missingName:
      return 'Enter a product name.';
    case InventoryProductDraftIssue.missingSku:
      return 'Enter a SKU.';
    case InventoryProductDraftIssue.missingCategory:
      return 'Enter a category.';
    case InventoryProductDraftIssue.invalidPrice:
      return 'Enter a valid positive unit price.';
  }
}

String inventoryProductIdForDate(DateTime date) {
  final millis = date.millisecondsSinceEpoch.toString();
  final suffix =
      millis.length <= 6 ? millis : millis.substring(millis.length - 6);
  return 'PRD-$suffix';
}
