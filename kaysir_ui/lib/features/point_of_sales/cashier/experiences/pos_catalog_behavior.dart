import '../../../product/models/product.dart';

class POSCatalogBehavior {
  final String actionLabel;
  final String emptyMessage;
  final bool requirePositivePrice;
  final bool requireStockOnHand;
  final String unavailablePriceMessage;
  final String unavailableStockMessage;

  const POSCatalogBehavior({
    this.actionLabel = 'Add',
    this.emptyMessage = 'No matching products',
    this.requirePositivePrice = false,
    this.requireStockOnHand = false,
    this.unavailablePriceMessage = 'Price required before checkout',
    this.unavailableStockMessage = 'No stock available',
  });

  static const standard = POSCatalogBehavior();

  static const quickCheckout = POSCatalogBehavior(
    actionLabel: 'Quick add',
    emptyMessage: 'No quick checkout items',
    requirePositivePrice: true,
  );

  static const assistedService = POSCatalogBehavior(
    actionLabel: 'Select',
    emptyMessage: 'No service items found',
  );

  POSProductActionState resolveProductAction(Product product) {
    if (requirePositivePrice && product.price <= 0) {
      return POSProductActionState.disabled(
        actionLabel: actionLabel,
        reason: unavailablePriceMessage,
      );
    }

    if (requireStockOnHand && _availableStock(product) <= 0) {
      return POSProductActionState.disabled(
        actionLabel: actionLabel,
        reason: unavailableStockMessage,
      );
    }

    return POSProductActionState.enabled(actionLabel: actionLabel);
  }

  int _availableStock(Product product) {
    return product.stockQuantity ?? product.currentStock;
  }
}

class POSProductActionState {
  final bool canAdd;
  final String actionLabel;
  final String? disabledReason;

  const POSProductActionState({
    required this.canAdd,
    required this.actionLabel,
    this.disabledReason,
  });

  const POSProductActionState.enabled({required this.actionLabel})
    : canAdd = true,
      disabledReason = null;

  const POSProductActionState.disabled({
    required this.actionLabel,
    required String reason,
  }) : canAdd = false,
       disabledReason = reason;
}
