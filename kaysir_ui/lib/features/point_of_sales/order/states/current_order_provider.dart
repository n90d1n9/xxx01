import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../product/models/product.dart';
import '../../cashier/experiences/pos_cart_behavior.dart';
import '../../cashier/models/customer.dart';
import '../../cashier/states/terminal_provider.dart';
import '../models/order.dart';
import '../models/order_fulfillment_snapshot.dart';
import '../models/order_item.dart';
import '../../payment/models/payment.dart';

import '../../promotion/models/promotion.dart';
import '../../cashier/models/terminal.dart';
import '../../cashier/services/api_services.dart';
import '../utils/order_payload_envelope.dart';
import 'order_save_outbox_provider.dart';

final currentOrderProvider =
    StateNotifierProvider<CurrentOrderNotifier, Order?>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      final saveOutbox = ref.read(posOrderSaveOutboxProvider.notifier);
      return CurrentOrderNotifier(apiService, saveOutbox);
    });

class CurrentOrderNotifier extends StateNotifier<Order?> {
  final ApiService _apiService;
  final POSOrderSaveOutboxNotifier? _saveOutbox;
  int _itemSequence = 0;

  CurrentOrderNotifier(this._apiService, [this._saveOutbox]) : super(null);

  void createNewOrder(Terminal terminal) {
    state = Order(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      items: [],
      payments: [],
      terminal: terminal,
      appliedPromotions: [],
      createdAt: DateTime.now(),
      status: 'pending',
    );
  }

  void restoreOrder(Order order) {
    state = order;
  }

  void addItem(
    Product product,
    int quantity, {
    POSCartBehavior cartBehavior = POSCartBehavior.standard,
  }) {
    if (state == null) return;

    final addQuantity = cartBehavior.normalizeAddQuantity(quantity);
    final existingItemIndex = state!.items.indexWhere(
      (item) => cartBehavior.shouldMerge(item, product),
    );

    if (existingItemIndex >= 0) {
      // Update existing item quantity
      final items = [...state!.items];
      final existingItem = items[existingItemIndex];
      final quantityChange = cartBehavior.resolveQuantityChange(
        product: existingItem.product,
        requestedQuantity: existingItem.quantity + addQuantity,
      );
      if (quantityChange.quantity <= 0) return;

      final updatedItem = OrderItem(
        id: existingItem.id,
        product: existingItem.product,
        quantity: quantityChange.quantity,
        unitPrice: existingItem.unitPrice,
        discount: existingItem.discount,
      );
      items[existingItemIndex] = updatedItem;

      state = state!.copyWith(items: items);
    } else {
      final quantityChange = cartBehavior.resolveQuantityChange(
        product: product,
        requestedQuantity: addQuantity,
      );
      if (quantityChange.quantity <= 0) return;

      // Add new item
      final newItem = OrderItem(
        id: _newItemId(),
        product: product,
        quantity: quantityChange.quantity,
        unitPrice: product.price,
        discount: 0,
      );

      state = state!.copyWith(items: [...state!.items, newItem]);
    }
  }

  void removeItem(String itemId) {
    if (state == null) return;

    state = state!.copyWith(
      items: state!.items.where((item) => item.id != itemId).toList(),
    );
  }

  void updateItemQuantity(
    String itemId,
    int quantity, {
    POSCartBehavior cartBehavior = POSCartBehavior.standard,
  }) {
    if (state == null) return;

    final items = [...state!.items];
    final index = items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      final item = items[index];
      final quantityChange = cartBehavior.resolveQuantityChange(
        product: item.product,
        requestedQuantity: quantity,
      );

      if (quantityChange.removesLine || quantityChange.quantity <= 0) {
        // Remove item if quantity is 0 or negative
        items.removeAt(index);
      } else {
        // Update quantity
        items[index] = OrderItem(
          id: item.id,
          product: item.product,
          quantity: quantityChange.quantity,
          unitPrice: item.unitPrice,
          discount: item.discount,
        );
      }

      state = state!.copyWith(items: items);
    }
  }

  void setCustomer(Customer customer) {
    if (state == null) return;

    state = state!.copyWith(customer: customer);
  }

  void removeCustomer() {
    if (state == null) return;

    state = state!.copyWith(clearCustomer: true);
  }

  void applyPromotion(Promotion promotion) {
    if (state == null) return;
    if (state!.appliedPromotions.any((item) => item.id == promotion.id)) {
      return;
    }

    state = state!.copyWith(
      appliedPromotions: [...state!.appliedPromotions, promotion],
    );
  }

  void removePromotion(String promotionId) {
    if (state == null) return;

    state = state!.copyWith(
      appliedPromotions:
          state!.appliedPromotions.where((p) => p.id != promotionId).toList(),
    );
  }

  void addPayment(Payment payment) {
    if (state == null) return;

    state = state!.copyWith(payments: [...state!.payments, payment]);
  }

  void setFulfillment(OrderFulfillmentSnapshot? fulfillment) {
    if (state == null) return;

    state = state!.copyWith(
      fulfillment: fulfillment,
      clearFulfillment: fulfillment == null,
    );
  }

  Future<Order?> completeOrder() async {
    if (state == null || !state!.isPaid) return null;

    final completedOrder = state!.copyWith(status: 'completed');
    final envelope = completedOrder.toPOSPayloadEnvelope();

    try {
      state = completedOrder;
      _saveOutbox?.enqueue(envelope);
      _saveOutbox?.retryFailed(envelope.idempotencyKey);
      _saveOutbox?.markSending(envelope.idempotencyKey);

      await _apiService.saveOrder(completedOrder);
      _saveOutbox?.markSent(envelope.idempotencyKey);

      state = null;
      return completedOrder;
    } catch (e) {
      _saveOutbox?.markFailed(envelope.idempotencyKey, e);
      developer.log('Error completing order', name: 'CurrentOrder', error: e);
      return null;
    }
  }

  void cancelOrder() {
    state = null;
  }

  String _newItemId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return 'item_${timestamp}_${_itemSequence++}';
  }
}
