enum POSDataTraitArea {
  catalog,
  order,
  customer,
  payment,
  inventory,
  service,
  hospitality,
  compliance,
}

class POSDataTrait {
  final String key;
  final String label;
  final String description;
  final POSDataTraitArea area;

  const POSDataTrait({
    required this.key,
    required this.label,
    required this.description,
    required this.area,
  });
}

abstract final class POSDataTraitKeys {
  static const catalog = 'catalog';
  static const menu = 'menu';
  static const orders = 'orders';
  static const customers = 'customers';
  static const payments = 'payments';
  static const promotions = 'promotions';
  static const inventory = 'inventory';
  static const variants = 'variants';
  static const modifierGroups = 'modifier_groups';
  static const weightedItems = 'weighted_items';
  static const serialTracked = 'serial_tracked';
  static const batchTracked = 'batch_tracked';
  static const tableService = 'table_service';
  static const appointments = 'appointments';
  static const deposits = 'deposits';
  static const ageRestricted = 'age_restricted';
  static const bundles = 'bundles';
  static const serviceTickets = 'service_tickets';

  static const standardCommerce = [catalog, orders, customers, payments];

  static const quickCheckout = [catalog, orders, payments];

  static const assistedService = [catalog, orders, customers, payments];
}

abstract final class POSDataTraits {
  static const catalog = POSDataTrait(
    key: POSDataTraitKeys.catalog,
    label: 'Catalog',
    description: 'Sellable product or service catalog records.',
    area: POSDataTraitArea.catalog,
  );

  static const menu = POSDataTrait(
    key: POSDataTraitKeys.menu,
    label: 'Menu',
    description: 'Menu-oriented catalog records for food, drink, or services.',
    area: POSDataTraitArea.catalog,
  );

  static const orders = POSDataTrait(
    key: POSDataTraitKeys.orders,
    label: 'Orders',
    description: 'Order headers, line items, totals, and status.',
    area: POSDataTraitArea.order,
  );

  static const customers = POSDataTrait(
    key: POSDataTraitKeys.customers,
    label: 'Customers',
    description: 'Customer profiles, contacts, and loyalty identity.',
    area: POSDataTraitArea.customer,
  );

  static const payments = POSDataTrait(
    key: POSDataTraitKeys.payments,
    label: 'Payments',
    description: 'Tender methods, payment records, and settlement state.',
    area: POSDataTraitArea.payment,
  );

  static const promotions = POSDataTrait(
    key: POSDataTraitKeys.promotions,
    label: 'Promotions',
    description: 'Discounts, vouchers, and campaign eligibility data.',
    area: POSDataTraitArea.payment,
  );

  static const inventory = POSDataTrait(
    key: POSDataTraitKeys.inventory,
    label: 'Inventory',
    description: 'Stock availability, warehouses, and inventory movement data.',
    area: POSDataTraitArea.inventory,
  );

  static const variants = POSDataTrait(
    key: POSDataTraitKeys.variants,
    label: 'Variants',
    description: 'Size, color, style, or option-level sellable variants.',
    area: POSDataTraitArea.catalog,
  );

  static const modifierGroups = POSDataTrait(
    key: POSDataTraitKeys.modifierGroups,
    label: 'Modifier groups',
    description:
        'Cafe or service add-ons such as size, milk, topping, or prep.',
    area: POSDataTraitArea.hospitality,
  );

  static const weightedItems = POSDataTrait(
    key: POSDataTraitKeys.weightedItems,
    label: 'Weighted items',
    description: 'Scale-priced items sold by weight or measured quantity.',
    area: POSDataTraitArea.inventory,
  );

  static const serialTracked = POSDataTrait(
    key: POSDataTraitKeys.serialTracked,
    label: 'Serial tracked',
    description: 'Serial-numbered items such as electronics or equipment.',
    area: POSDataTraitArea.inventory,
  );

  static const batchTracked = POSDataTrait(
    key: POSDataTraitKeys.batchTracked,
    label: 'Batch tracked',
    description: 'Lot, batch, expiry, or production-run tracked items.',
    area: POSDataTraitArea.inventory,
  );

  static const tableService = POSDataTrait(
    key: POSDataTraitKeys.tableService,
    label: 'Table service',
    description: 'Tables, guests, tabs, and dining-service order state.',
    area: POSDataTraitArea.hospitality,
  );

  static const appointments = POSDataTrait(
    key: POSDataTraitKeys.appointments,
    label: 'Appointments',
    description: 'Scheduled service windows and assigned staff.',
    area: POSDataTraitArea.service,
  );

  static const deposits = POSDataTrait(
    key: POSDataTraitKeys.deposits,
    label: 'Deposits',
    description: 'Advance payments, deposits, and deferred balance tracking.',
    area: POSDataTraitArea.payment,
  );

  static const ageRestricted = POSDataTrait(
    key: POSDataTraitKeys.ageRestricted,
    label: 'Age restricted',
    description: 'Products requiring age or compliance verification.',
    area: POSDataTraitArea.compliance,
  );

  static const bundles = POSDataTrait(
    key: POSDataTraitKeys.bundles,
    label: 'Bundles',
    description: 'Bundled products, kits, or grouped sellable offers.',
    area: POSDataTraitArea.catalog,
  );

  static const serviceTickets = POSDataTrait(
    key: POSDataTraitKeys.serviceTickets,
    label: 'Service tickets',
    description: 'Service job tickets, intake notes, and handoff state.',
    area: POSDataTraitArea.service,
  );

  static const all = [
    catalog,
    menu,
    orders,
    customers,
    payments,
    promotions,
    inventory,
    variants,
    modifierGroups,
    weightedItems,
    serialTracked,
    batchTracked,
    tableService,
    appointments,
    deposits,
    ageRestricted,
    bundles,
    serviceTickets,
  ];

  static POSDataTrait? resolve(String key) {
    final normalizedKey = key.trim();
    for (final trait in all) {
      if (trait.key == normalizedKey) return trait;
    }

    return null;
  }

  static bool isKnown(String key) => resolve(key) != null;

  static String labelFor(String key) {
    return resolve(key)?.label ?? _fallbackLabel(key);
  }

  static List<String> labelsFor(Iterable<String> keys) {
    return keys.map(labelFor).toList(growable: false);
  }

  static List<String> keysOf(Iterable<POSDataTrait> traits) {
    return traits.map((trait) => trait.key).toList(growable: false);
  }

  static String _fallbackLabel(String key) {
    final normalized = key.trim().replaceAll('_', ' ');
    if (normalized.isEmpty) return key;

    return normalized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
