import '../../product/models/product.dart';

class InventoryProductBulkShortcutGenerationDraft {
  const InventoryProductBulkShortcutGenerationDraft({this.prefix = 'K'});

  final String prefix;

  List<Product> applyAll(
    Iterable<Product> products, {
    required Iterable<Product> existingProducts,
  }) {
    final selectedProducts = products.toList();
    final selectedIds = {for (final product in selectedProducts) product.id};
    final usedShortcuts = {
      for (final product in existingProducts)
        if (!selectedIds.contains(product.id) && _hasText(product.shortcutKey))
          product.shortcutKey.trim().toUpperCase(),
    };

    return [
      for (final product in selectedProducts)
        product.copyWith(shortcutKey: _nextShortcutFor(usedShortcuts)),
    ];
  }

  String _nextShortcutFor(Set<String> usedShortcuts) {
    final normalizedPrefix = _normalizeShortcutPrefix(prefix);
    final base = normalizedPrefix.isEmpty ? 'K' : normalizedPrefix;
    var index = 1;
    var candidate = '$base$index';

    while (usedShortcuts.contains(candidate.toUpperCase())) {
      index += 1;
      candidate = '$base$index';
    }

    usedShortcuts.add(candidate.toUpperCase());
    return candidate;
  }
}

String inventoryProductBulkShortcutPreviewLabel({
  required Product product,
  required String shortcutKey,
}) {
  final currentScanCode =
      _hasText(product.barcode)
          ? product.barcode!.trim()
          : _hasText(product.shortcutKey)
          ? product.shortcutKey.trim()
          : 'No scan code';
  return '$currentScanCode -> $shortcutKey';
}

bool inventoryProductNeedsScanCode(Product product) {
  return !_hasText(product.barcode) && !_hasText(product.shortcutKey);
}

String _normalizeShortcutPrefix(String value) {
  final buffer = StringBuffer();

  for (final codeUnit in value.trim().toUpperCase().codeUnits) {
    final isDigit = codeUnit >= 48 && codeUnit <= 57;
    final isLetter = codeUnit >= 65 && codeUnit <= 90;
    if (isDigit || isLetter) {
      buffer.writeCharCode(codeUnit);
    }
  }

  return buffer.toString();
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
