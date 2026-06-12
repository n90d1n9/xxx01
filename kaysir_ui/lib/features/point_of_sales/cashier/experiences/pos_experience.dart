import '../states/pos_layout_provider.dart';
import 'pos_behavior_set.dart';
import 'pos_cart_behavior.dart';
import 'pos_catalog_behavior.dart';
import 'pos_checkout_behavior.dart';
import 'pos_feature_module.dart';
import 'pos_experience_manifest.dart';
import 'pos_payment_behavior.dart';
import '../../order/utils/order_save_outbox_sync_behavior.dart';

class POSExperience {
  final String id;
  final String label;
  final String description;
  final POSLayoutPreference preferredLayout;
  final POSExperienceCapabilities capabilities;
  final List<POSFeatureModule> modules;
  final POSBehaviorSet behaviors;
  final POSExperienceManifest manifest;

  const POSExperience({
    required this.id,
    required this.label,
    required this.description,
    required this.preferredLayout,
    required this.capabilities,
    this.modules = const [],
    this.behaviors = POSBehaviorSet.standard,
    this.manifest = const POSExperienceManifest(),
  });

  POSCatalogBehavior get catalogBehavior => behaviors.catalog;

  POSCartBehavior get cartBehavior => behaviors.cart;

  POSCheckoutBehavior get checkoutBehavior => behaviors.checkout;

  POSPaymentBehavior get paymentBehavior => behaviors.payment;

  POSOrderSaveOutboxSyncBehavior get orderSyncBehavior => behaviors.orderSync;

  Iterable<String> get moduleIds => modules.map((module) => module.id);

  bool hasModule(String moduleId) {
    return modules.any((module) => module.id == moduleId);
  }

  POSExperience copyWith({
    String? id,
    String? label,
    String? description,
    POSLayoutPreference? preferredLayout,
    POSExperienceCapabilities? capabilities,
    List<POSFeatureModule>? modules,
    POSBehaviorSet? behaviors,
    POSExperienceManifest? manifest,
    POSCatalogBehavior? catalogBehavior,
    POSCartBehavior? cartBehavior,
    POSCheckoutBehavior? checkoutBehavior,
    POSPaymentBehavior? paymentBehavior,
    POSOrderSaveOutboxSyncBehavior? orderSyncBehavior,
  }) {
    final hasBehaviorOverrides =
        catalogBehavior != null ||
        cartBehavior != null ||
        checkoutBehavior != null ||
        paymentBehavior != null ||
        orderSyncBehavior != null;
    final nextBehaviors =
        behaviors ??
        (hasBehaviorOverrides
            ? this.behaviors.copyWith(
              catalog: catalogBehavior,
              cart: cartBehavior,
              checkout: checkoutBehavior,
              payment: paymentBehavior,
              orderSync: orderSyncBehavior,
            )
            : this.behaviors);

    return POSExperience(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      preferredLayout: preferredLayout ?? this.preferredLayout,
      capabilities: capabilities ?? this.capabilities,
      modules: modules ?? this.modules,
      behaviors: nextBehaviors,
      manifest: manifest ?? this.manifest,
    );
  }
}

class POSExperienceCapabilities {
  final bool barcodeScanning;
  final bool customerSelection;
  final bool heldOrders;
  final bool promotions;
  final bool payments;
  final bool newOrders;
  final bool layoutSwitching;

  const POSExperienceCapabilities({
    this.barcodeScanning = true,
    this.customerSelection = true,
    this.heldOrders = true,
    this.promotions = true,
    this.payments = true,
    this.newOrders = true,
    this.layoutSwitching = true,
  });

  POSExperienceCapabilities copyWith({
    bool? barcodeScanning,
    bool? customerSelection,
    bool? heldOrders,
    bool? promotions,
    bool? payments,
    bool? newOrders,
    bool? layoutSwitching,
  }) {
    return POSExperienceCapabilities(
      barcodeScanning: barcodeScanning ?? this.barcodeScanning,
      customerSelection: customerSelection ?? this.customerSelection,
      heldOrders: heldOrders ?? this.heldOrders,
      promotions: promotions ?? this.promotions,
      payments: payments ?? this.payments,
      newOrders: newOrders ?? this.newOrders,
      layoutSwitching: layoutSwitching ?? this.layoutSwitching,
    );
  }
}
