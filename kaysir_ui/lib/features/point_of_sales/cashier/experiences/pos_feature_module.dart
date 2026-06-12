enum POSFeatureModuleArea {
  catalog,
  order,
  customer,
  promotion,
  payment,
  layout,
}

class POSFeatureModule {
  final String id;
  final String label;
  final String description;
  final POSFeatureModuleArea area;

  const POSFeatureModule({
    required this.id,
    required this.label,
    required this.description,
    required this.area,
  });
}

abstract final class POSFeatureModules {
  static const catalogBrowsing = POSFeatureModule(
    id: 'catalog_browsing',
    label: 'Catalog browsing',
    description: 'Browse and filter products from the POS catalog.',
    area: POSFeatureModuleArea.catalog,
  );

  static const cartManagement = POSFeatureModule(
    id: 'cart_management',
    label: 'Cart management',
    description: 'Build and adjust an active order cart.',
    area: POSFeatureModuleArea.order,
  );

  static const barcodeScanning = POSFeatureModule(
    id: 'barcode_scanning',
    label: 'Barcode scanning',
    description: 'Add products by barcode, SKU, or exact code entry.',
    area: POSFeatureModuleArea.catalog,
  );

  static const newOrders = POSFeatureModule(
    id: 'new_orders',
    label: 'New orders',
    description: 'Start fresh orders from the cashier workspace.',
    area: POSFeatureModuleArea.order,
  );

  static const heldOrders = POSFeatureModule(
    id: 'held_orders',
    label: 'Held orders',
    description: 'Hold and resume in-progress orders.',
    area: POSFeatureModuleArea.order,
  );

  static const customerSelection = POSFeatureModule(
    id: 'customer_selection',
    label: 'Customer selection',
    description: 'Attach a known customer to the current order.',
    area: POSFeatureModuleArea.customer,
  );

  static const promotions = POSFeatureModule(
    id: 'promotions',
    label: 'Promotions',
    description: 'Apply eligible promotions and voucher codes.',
    area: POSFeatureModuleArea.promotion,
  );

  static const payments = POSFeatureModule(
    id: 'payments',
    label: 'Payments',
    description: 'Collect tender and complete checkout.',
    area: POSFeatureModuleArea.payment,
  );

  static const layoutSwitching = POSFeatureModule(
    id: 'layout_switching',
    label: 'Layout switching',
    description: 'Allow operators to switch POS layout strategies.',
    area: POSFeatureModuleArea.layout,
  );

  static const standardCashier = [
    catalogBrowsing,
    cartManagement,
    barcodeScanning,
    newOrders,
    heldOrders,
    customerSelection,
    promotions,
    payments,
    layoutSwitching,
  ];

  static const quickCheckout = [
    catalogBrowsing,
    cartManagement,
    barcodeScanning,
    payments,
  ];

  static const assistedService = [
    catalogBrowsing,
    cartManagement,
    newOrders,
    heldOrders,
    customerSelection,
    payments,
    layoutSwitching,
  ];
}
