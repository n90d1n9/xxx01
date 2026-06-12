import '../../product/models/product.dart';

enum InventoryProductBulkPriceUpdateMode {
  setFixed,
  increaseByPercent,
  decreaseByPercent,
}

class InventoryProductBulkPriceUpdateDraft {
  const InventoryProductBulkPriceUpdateDraft({
    required this.mode,
    required this.value,
  });

  final InventoryProductBulkPriceUpdateMode mode;
  final double value;

  double priceFor(Product product) {
    final nextPrice = switch (mode) {
      InventoryProductBulkPriceUpdateMode.setFixed => value,
      InventoryProductBulkPriceUpdateMode.increaseByPercent =>
        product.price * (1 + value / 100),
      InventoryProductBulkPriceUpdateMode.decreaseByPercent =>
        product.price * (1 - value / 100),
    };

    return _roundCurrency(nextPrice < 0 ? 0 : nextPrice);
  }

  Product apply(Product product) {
    return product.copyWith(price: priceFor(product));
  }
}

String inventoryProductBulkPriceUpdateModeLabel(
  InventoryProductBulkPriceUpdateMode mode,
) {
  return switch (mode) {
    InventoryProductBulkPriceUpdateMode.setFixed => 'Set price',
    InventoryProductBulkPriceUpdateMode.increaseByPercent => 'Increase',
    InventoryProductBulkPriceUpdateMode.decreaseByPercent => 'Decrease',
  };
}

String inventoryProductBulkPriceUpdateInputLabel(
  InventoryProductBulkPriceUpdateMode mode,
) {
  return switch (mode) {
    InventoryProductBulkPriceUpdateMode.setFixed => 'New unit price',
    InventoryProductBulkPriceUpdateMode.increaseByPercent =>
      'Increase percentage',
    InventoryProductBulkPriceUpdateMode.decreaseByPercent =>
      'Decrease percentage',
  };
}

String inventoryProductBulkPriceUpdateHelperText(
  InventoryProductBulkPriceUpdateMode mode,
) {
  return switch (mode) {
    InventoryProductBulkPriceUpdateMode.setFixed =>
      'Every selected product receives this exact price.',
    InventoryProductBulkPriceUpdateMode.increaseByPercent =>
      'Adds this percentage to each selected product price.',
    InventoryProductBulkPriceUpdateMode.decreaseByPercent =>
      'Subtracts this percentage from each selected product price.',
  };
}

String? validateInventoryProductBulkPriceValue(
  String? value,
  InventoryProductBulkPriceUpdateMode mode,
) {
  final parsed = parseInventoryProductBulkPriceValue(value);
  if (parsed == null) return 'Enter a valid number';

  switch (mode) {
    case InventoryProductBulkPriceUpdateMode.setFixed:
      return parsed <= 0 ? 'Enter a price greater than zero' : null;
    case InventoryProductBulkPriceUpdateMode.increaseByPercent:
      return parsed <= 0 ? 'Enter a percentage greater than zero' : null;
    case InventoryProductBulkPriceUpdateMode.decreaseByPercent:
      if (parsed <= 0 || parsed > 100) {
        return 'Enter a percentage from 1 to 100';
      }
      return null;
  }
}

double? parseInventoryProductBulkPriceValue(String? value) {
  final parsed = double.tryParse((value ?? '').trim());
  if (parsed == null || !parsed.isFinite) return null;

  return parsed;
}

double _roundCurrency(double value) {
  return double.parse(value.toStringAsFixed(2));
}
