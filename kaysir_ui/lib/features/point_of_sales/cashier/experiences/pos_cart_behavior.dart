import 'dart:math' as math;

import '../../../product/models/product.dart';
import '../../order/models/order_item.dart';

enum POSLineMergeStrategy { mergeByProduct, alwaysNewLine }

class POSCartBehavior {
  final POSLineMergeStrategy mergeStrategy;
  final int defaultQuantity;
  final int quantityStep;
  final int? maxQuantityPerLine;
  final bool limitQuantityToAvailableStock;
  final String emptyCartTitle;
  final String emptyCartMessage;
  final String quantityLimitMessage;

  const POSCartBehavior({
    this.mergeStrategy = POSLineMergeStrategy.mergeByProduct,
    this.defaultQuantity = 1,
    this.quantityStep = 1,
    this.maxQuantityPerLine,
    this.limitQuantityToAvailableStock = false,
    this.emptyCartTitle = 'No items in cart',
    this.emptyCartMessage =
        'Tap products from the catalog to build this order.',
    this.quantityLimitMessage = 'Maximum quantity reached',
  }) : assert(defaultQuantity > 0),
       assert(quantityStep > 0),
       assert(maxQuantityPerLine == null || maxQuantityPerLine > 0);

  static const standard = POSCartBehavior();

  static const quickCheckout = POSCartBehavior(
    maxQuantityPerLine: 99,
    emptyCartTitle: 'Ready for checkout',
    emptyCartMessage: 'Add fast-moving items to keep the sale moving.',
  );

  static const assistedService = POSCartBehavior(
    mergeStrategy: POSLineMergeStrategy.alwaysNewLine,
    emptyCartTitle: 'Start a service order',
    emptyCartMessage: 'Select catalog items as separate service lines.',
  );

  bool shouldMerge(OrderItem item, Product product) {
    return mergeStrategy == POSLineMergeStrategy.mergeByProduct &&
        item.product.id == product.id;
  }

  int normalizeAddQuantity(int quantity) {
    return quantity > 0 ? quantity : defaultQuantity;
  }

  POSQuantityChange resolveQuantityChange({
    required Product product,
    required int requestedQuantity,
  }) {
    if (requestedQuantity <= 0) {
      return const POSQuantityChange.remove();
    }

    final maxQuantity = maxQuantityForProduct(product);
    if (maxQuantity != null && requestedQuantity > maxQuantity) {
      return POSQuantityChange.capped(
        quantity: maxQuantity,
        message: quantityLimitMessage,
      );
    }

    return POSQuantityChange.accepted(quantity: requestedQuantity);
  }

  int? maxQuantityForProduct(Product product) {
    var maxQuantity = maxQuantityPerLine;

    if (limitQuantityToAvailableStock) {
      final stockOnHand = _availableStock(product);
      maxQuantity =
          maxQuantity == null
              ? stockOnHand
              : math.min(maxQuantity, stockOnHand);
    }

    return maxQuantity;
  }

  int _availableStock(Product product) {
    return product.stockQuantity ?? product.currentStock;
  }
}

class POSQuantityChange {
  final int quantity;
  final bool removesLine;
  final String? message;

  const POSQuantityChange._({
    required this.quantity,
    required this.removesLine,
    this.message,
  });

  const POSQuantityChange.accepted({required int quantity})
    : this._(quantity: quantity, removesLine: false);

  const POSQuantityChange.capped({
    required int quantity,
    required String message,
  }) : this._(quantity: quantity, removesLine: false, message: message);

  const POSQuantityChange.remove() : this._(quantity: 0, removesLine: true);

  bool get wasAdjusted => message != null;
}
