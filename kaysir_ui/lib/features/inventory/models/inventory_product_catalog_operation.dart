import '../../product/models/product.dart';
import '../utils/inventory_label_utils.dart';

enum InventoryProductCatalogOperationType {
  productAdded,
  productDuplicated,
  productUpdated,
  productDeleted,
  bulkCategoryUpdated,
  bulkPriceUpdated,
  bulkDescriptionsFilled,
  bulkSkusGenerated,
  bulkShortcutsGenerated,
  bulkDeleted,
}

class InventoryProductCatalogOperationResult {
  const InventoryProductCatalogOperationResult({
    required this.type,
    required this.message,
    this.undo,
    this.undoLabel = 'Undo',
  });

  factory InventoryProductCatalogOperationResult.productAdded(
    Product product, {
    void Function()? undo,
  }) {
    return InventoryProductCatalogOperationResult(
      type: InventoryProductCatalogOperationType.productAdded,
      message: '${inventoryProductNameLabel(product.name)} added to catalog',
      undo: undo,
    );
  }

  factory InventoryProductCatalogOperationResult.productDuplicated({
    required Product source,
    required Product duplicate,
    void Function()? undo,
  }) {
    return InventoryProductCatalogOperationResult(
      type: InventoryProductCatalogOperationType.productDuplicated,
      message:
          '${inventoryProductNameLabel(source.name)} duplicated as ${inventoryProductNameLabel(duplicate.name)}',
      undo: undo,
    );
  }

  factory InventoryProductCatalogOperationResult.productUpdated(
    Product product, {
    void Function()? undo,
  }) {
    return InventoryProductCatalogOperationResult(
      type: InventoryProductCatalogOperationType.productUpdated,
      message: '${inventoryProductNameLabel(product.name)} updated',
      undo: undo,
    );
  }

  factory InventoryProductCatalogOperationResult.productDeleted(
    Product product, {
    void Function()? undo,
  }) {
    return InventoryProductCatalogOperationResult(
      type: InventoryProductCatalogOperationType.productDeleted,
      message: '${inventoryProductNameLabel(product.name)} deleted',
      undo: undo,
    );
  }

  factory InventoryProductCatalogOperationResult.bulkCategoryUpdated({
    required int count,
    required String category,
    void Function()? undo,
  }) {
    return InventoryProductCatalogOperationResult(
      type: InventoryProductCatalogOperationType.bulkCategoryUpdated,
      message:
          '${_productCountLabel(count)} moved to ${inventoryCategoryLabel(category)}',
      undo: undo,
    );
  }

  factory InventoryProductCatalogOperationResult.bulkPriceUpdated(
    int count, {
    void Function()? undo,
  }) {
    return InventoryProductCatalogOperationResult(
      type: InventoryProductCatalogOperationType.bulkPriceUpdated,
      message:
          '${_productCountLabel(count)} ${count == 1 ? 'price' : 'prices'} updated',
      undo: undo,
    );
  }

  factory InventoryProductCatalogOperationResult.bulkDescriptionsFilled(
    int count, {
    void Function()? undo,
  }) {
    return InventoryProductCatalogOperationResult(
      type: InventoryProductCatalogOperationType.bulkDescriptionsFilled,
      message:
          count == 1
              ? '1 product description filled'
              : '$count product descriptions filled',
      undo: undo,
    );
  }

  factory InventoryProductCatalogOperationResult.bulkSkusGenerated(
    int count, {
    void Function()? undo,
  }) {
    return InventoryProductCatalogOperationResult(
      type: InventoryProductCatalogOperationType.bulkSkusGenerated,
      message:
          '${_productCountLabel(count)} assigned ${count == 1 ? 'SKU' : 'SKUs'}',
      undo: undo,
    );
  }

  factory InventoryProductCatalogOperationResult.bulkShortcutsGenerated(
    int count, {
    void Function()? undo,
  }) {
    return InventoryProductCatalogOperationResult(
      type: InventoryProductCatalogOperationType.bulkShortcutsGenerated,
      message:
          '${_productCountLabel(count)} assigned ${count == 1 ? 'shortcut' : 'shortcuts'}',
      undo: undo,
    );
  }

  factory InventoryProductCatalogOperationResult.bulkDeleted(
    int count, {
    void Function()? undo,
  }) {
    return InventoryProductCatalogOperationResult(
      type: InventoryProductCatalogOperationType.bulkDeleted,
      message: '${_productCountLabel(count)} deleted',
      undo: undo,
    );
  }

  final InventoryProductCatalogOperationType type;
  final String message;
  final void Function()? undo;
  final String undoLabel;

  bool get canUndo => undo != null;
}

String _productCountLabel(int count) {
  return '$count ${count == 1 ? 'product' : 'products'}';
}
