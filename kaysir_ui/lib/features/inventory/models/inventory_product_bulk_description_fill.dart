import '../../product/models/product.dart';
import '../utils/inventory_formatters.dart';
import '../utils/inventory_label_utils.dart';

const inventoryProductBulkDescriptionDefaultTemplate =
    '{name} - {category} product for POS and inventory operations.';

class InventoryProductBulkDescriptionFillDraft {
  const InventoryProductBulkDescriptionFillDraft({
    this.template = inventoryProductBulkDescriptionDefaultTemplate,
  });

  final String template;

  List<Product> applyAll(Iterable<Product> products) {
    return [for (final product in products) apply(product)];
  }

  Product apply(Product product) {
    return product.copyWith(description: descriptionFor(product));
  }

  String descriptionFor(Product product) {
    return _resolveProductTemplate(template.trim(), product);
  }
}

bool inventoryProductNeedsDescription(Product product) {
  return !_hasText(product.description);
}

String inventoryProductBulkDescriptionPreviewLabel({
  required Product product,
  required String description,
}) {
  return '${inventoryDescriptionLabel(product.description)} -> $description';
}

String? validateInventoryProductBulkDescriptionTemplate(String? value) {
  return (value ?? '').trim().isEmpty ? 'Enter a description template' : null;
}

String _resolveProductTemplate(String template, Product product) {
  final resolved = template
      .replaceAll('{name}', inventoryProductNameLabel(product.name))
      .replaceAll('{sku}', inventorySkuLabel(product.sku))
      .replaceAll('{category}', inventoryCategoryLabel(product.category))
      .replaceAll('{price}', formatInventoryCurrency(product.price))
      .replaceAll(
        '{scanCode}',
        inventoryScanCodeLabel(
          barcode: product.barcode,
          shortcutKey: product.shortcutKey,
        ),
      );

  return resolved.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
