import '../../order/utils/order_save_outbox_sync_behavior.dart';
import 'pos_cart_behavior.dart';
import 'pos_catalog_behavior.dart';
import 'pos_checkout_behavior.dart';
import 'pos_payment_behavior.dart';

class POSBehaviorSet {
  final POSCatalogBehavior catalog;
  final POSCartBehavior cart;
  final POSCheckoutBehavior checkout;
  final POSPaymentBehavior payment;
  final POSOrderSaveOutboxSyncBehavior orderSync;

  const POSBehaviorSet({
    this.catalog = POSCatalogBehavior.standard,
    this.cart = POSCartBehavior.standard,
    this.checkout = POSCheckoutBehavior.standard,
    this.payment = POSPaymentBehavior.standard,
    this.orderSync = POSOrderSaveOutboxSyncBehavior.standard,
  });

  static const standard = POSBehaviorSet();

  static const quickCheckout = POSBehaviorSet(
    catalog: POSCatalogBehavior.quickCheckout,
    cart: POSCartBehavior.quickCheckout,
    checkout: POSCheckoutBehavior.quickCheckout,
    payment: POSPaymentBehavior.quickCheckout,
    orderSync: POSOrderSaveOutboxSyncBehavior.quickCheckout,
  );

  static const assistedService = POSBehaviorSet(
    catalog: POSCatalogBehavior.assistedService,
    cart: POSCartBehavior.assistedService,
    checkout: POSCheckoutBehavior.assistedService,
    payment: POSPaymentBehavior.assistedService,
    orderSync: POSOrderSaveOutboxSyncBehavior.assistedService,
  );

  POSBehaviorSet copyWith({
    POSCatalogBehavior? catalog,
    POSCartBehavior? cart,
    POSCheckoutBehavior? checkout,
    POSPaymentBehavior? payment,
    POSOrderSaveOutboxSyncBehavior? orderSync,
  }) {
    return POSBehaviorSet(
      catalog: catalog ?? this.catalog,
      cart: cart ?? this.cart,
      checkout: checkout ?? this.checkout,
      payment: payment ?? this.payment,
      orderSync: orderSync ?? this.orderSync,
    );
  }
}
