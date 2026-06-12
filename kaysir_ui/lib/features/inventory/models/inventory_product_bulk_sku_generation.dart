import '../../product/models/product.dart';

class InventoryProductBulkSkuGenerationDraft {
  const InventoryProductBulkSkuGenerationDraft({this.prefix = ''});

  final String prefix;

  List<Product> applyAll(
    Iterable<Product> products, {
    required Iterable<Product> existingProducts,
  }) {
    final selectedProducts = products.toList();
    final selectedIds = {for (final product in selectedProducts) product.id};
    final usedSkus = {
      for (final product in existingProducts)
        if (!selectedIds.contains(product.id) && _hasText(product.sku))
          product.sku!.trim().toUpperCase(),
    };

    return [
      for (final product in selectedProducts)
        product.copyWith(sku: _nextSkuFor(product, usedSkus)),
    ];
  }

  String _nextSkuFor(Product product, Set<String> usedSkus) {
    final normalizedPrefix = _normalizeSkuToken(prefix);
    final normalizedName = _normalizeSkuToken(product.name);
    final base =
        normalizedPrefix.isEmpty
            ? normalizedName
            : normalizedName.isEmpty
            ? normalizedPrefix
            : '$normalizedPrefix-$normalizedName';
    final fallbackBase = base.isEmpty ? 'ITEM' : base;
    var candidate = fallbackBase;
    var suffix = 2;

    while (usedSkus.contains(candidate.toUpperCase())) {
      candidate = '$fallbackBase-$suffix';
      suffix += 1;
    }

    usedSkus.add(candidate.toUpperCase());
    return candidate;
  }
}

String inventoryProductBulkSkuPreviewLabel({
  required Product product,
  required String sku,
}) {
  final currentSku = _hasText(product.sku) ? product.sku!.trim() : 'No SKU';
  return '$currentSku -> $sku';
}

bool inventoryProductNeedsSku(Product product) {
  return !_hasText(product.sku);
}

String _normalizeSkuToken(String value) {
  final buffer = StringBuffer();
  var lastWasSeparator = false;

  for (final codeUnit in value.trim().toUpperCase().codeUnits) {
    final isDigit = codeUnit >= 48 && codeUnit <= 57;
    final isLetter = codeUnit >= 65 && codeUnit <= 90;
    if (isDigit || isLetter) {
      buffer.writeCharCode(codeUnit);
      lastWasSeparator = false;
      continue;
    }
    if (buffer.isNotEmpty && !lastWasSeparator) {
      buffer.write('-');
      lastWasSeparator = true;
    }
  }

  return buffer.toString().replaceFirst(RegExp(r'-$'), '');
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
