import '../models/billing_business_domain_profile.dart';
import 'billing_business_domain_blueprint.dart';

enum BillingBusinessDomainBlueprintFitSignal {
  checkout,
  projects,
  subscriptions,
  service,
  omniChannel,
}

class BillingBusinessDomainBlueprintFitColumn {
  final BillingBusinessDomainBlueprintFitSignal signal;
  final String label;
  final String description;

  const BillingBusinessDomainBlueprintFitColumn({
    required this.signal,
    required this.label,
    required this.description,
  });
}

class BillingBusinessDomainBlueprintFitCell {
  final BillingBusinessDomainBlueprintFitSignal signal;
  final bool isSupported;
  final String detail;

  const BillingBusinessDomainBlueprintFitCell({
    required this.signal,
    required this.isSupported,
    required this.detail,
  });
}

class BillingBusinessDomainBlueprintFitRow {
  final BillingBusinessDomainBlueprint blueprint;
  final List<BillingBusinessDomainBlueprintFitCell> cells;

  BillingBusinessDomainBlueprintFitRow({
    required this.blueprint,
    Iterable<BillingBusinessDomainBlueprintFitCell> cells = const [],
  }) : cells = List.unmodifiable(cells);

  String get domainKey => blueprint.domainKey;

  String get domainLabel => blueprint.domainLabel;

  String get productModeLabel => blueprint.productModeLabel;

  int get supportedSignalCount {
    return cells.where((cell) => cell.isSupported).length;
  }

  bool supports(BillingBusinessDomainBlueprintFitSignal signal) {
    return cellFor(signal)?.isSupported ?? false;
  }

  BillingBusinessDomainBlueprintFitCell? cellFor(
    BillingBusinessDomainBlueprintFitSignal signal,
  ) {
    for (final cell in cells) {
      if (cell.signal == signal) return cell;
    }

    return null;
  }

  BillingBusinessDomainBlueprintFitCell requireCell(
    BillingBusinessDomainBlueprintFitSignal signal,
  ) {
    final cell = cellFor(signal);
    if (cell == null) {
      throw StateError('No billing blueprint fit cell exists for $signal.');
    }

    return cell;
  }
}

class BillingBusinessDomainBlueprintFitMatrix {
  final List<BillingBusinessDomainBlueprintFitColumn> columns;
  final List<BillingBusinessDomainBlueprintFitRow> rows;

  BillingBusinessDomainBlueprintFitMatrix({
    Iterable<BillingBusinessDomainBlueprintFitColumn> columns =
        standardBillingBusinessDomainBlueprintFitColumns,
    Iterable<BillingBusinessDomainBlueprintFitRow> rows = const [],
  }) : columns = List.unmodifiable(columns),
       rows = List.unmodifiable(rows);

  factory BillingBusinessDomainBlueprintFitMatrix.forRegistry(
    BillingBusinessDomainBlueprintRegistry registry, {
    Iterable<BillingBusinessDomainBlueprintFitColumn> columns =
        standardBillingBusinessDomainBlueprintFitColumns,
  }) {
    final resolvedColumns = columns.toList(growable: false);

    return BillingBusinessDomainBlueprintFitMatrix(
      columns: resolvedColumns,
      rows: registry.blueprints.map(
        (blueprint) => BillingBusinessDomainBlueprintFitRow(
          blueprint: blueprint,
          cells: resolvedColumns.map(
            (column) => BillingBusinessDomainBlueprintFitCell(
              signal: column.signal,
              isSupported: _supportsSignal(blueprint, column.signal),
              detail: _signalDetail(blueprint, column.signal),
            ),
          ),
        ),
      ),
    );
  }

  bool get isEmpty => rows.isEmpty;

  int get domainCount => rows.length;

  int get signalCount => columns.length;

  int get supportedCellCount {
    return rows.fold(0, (total, row) => total + row.supportedSignalCount);
  }

  List<String> get domainKeys {
    return List.unmodifiable(rows.map((row) => row.domainKey));
  }

  BillingBusinessDomainBlueprintFitRow? rowForDomain(String domain) {
    final key = billingBusinessDomainKey(domain);

    for (final row in rows) {
      if (row.domainKey == key) return row;
    }

    return null;
  }

  BillingBusinessDomainBlueprintFitRow requireRowForDomain(String domain) {
    final row = rowForDomain(domain);
    if (row == null) {
      throw StateError(
        'No billing blueprint fit row is available for $domain.',
      );
    }

    return row;
  }
}

const standardBillingBusinessDomainBlueprintFitColumns = [
  BillingBusinessDomainBlueprintFitColumn(
    signal: BillingBusinessDomainBlueprintFitSignal.checkout,
    label: 'Checkout',
    description: 'Catalog, inventory, cart, and payment-led billing.',
  ),
  BillingBusinessDomainBlueprintFitColumn(
    signal: BillingBusinessDomainBlueprintFitSignal.projects,
    label: 'Projects',
    description: 'Milestones, progress billing, and staged delivery.',
  ),
  BillingBusinessDomainBlueprintFitColumn(
    signal: BillingBusinessDomainBlueprintFitSignal.subscriptions,
    label: 'Subscriptions',
    description: 'Recurring periods, usage, and renewal billing.',
  ),
  BillingBusinessDomainBlueprintFitColumn(
    signal: BillingBusinessDomainBlueprintFitSignal.service,
    label: 'Service',
    description: 'Retainers, service periods, and work-order style billing.',
  ),
  BillingBusinessDomainBlueprintFitColumn(
    signal: BillingBusinessDomainBlueprintFitSignal.omniChannel,
    label: 'Omni-channel',
    description: 'Ready for multi-channel business surfaces.',
  ),
];

bool _supportsSignal(
  BillingBusinessDomainBlueprint blueprint,
  BillingBusinessDomainBlueprintFitSignal signal,
) {
  return switch (signal) {
    BillingBusinessDomainBlueprintFitSignal.checkout =>
      blueprint.supports(BillingBusinessDomainCapability.productCatalog) ||
          blueprint.supports(BillingBusinessDomainCapability.inventory) ||
          blueprint.supports(BillingBusinessDomainCapability.cartCheckout),
    BillingBusinessDomainBlueprintFitSignal.projects =>
      blueprint.supports(BillingBusinessDomainCapability.projectMilestones) ||
          blueprint.supports(BillingBusinessDomainCapability.progressBilling),
    BillingBusinessDomainBlueprintFitSignal.subscriptions =>
      blueprint.supports(
            BillingBusinessDomainCapability.recurringSubscriptions,
          ) ||
          blueprint.supports(BillingBusinessDomainCapability.meteredUsage),
    BillingBusinessDomainBlueprintFitSignal.service =>
      blueprint.supports(BillingBusinessDomainCapability.servicePeriods) ||
          blueprint.supports(BillingBusinessDomainCapability.retainers),
    BillingBusinessDomainBlueprintFitSignal.omniChannel => blueprint.supports(
      BillingBusinessDomainCapability.omniChannel,
    ),
  };
}

String _signalDetail(
  BillingBusinessDomainBlueprint blueprint,
  BillingBusinessDomainBlueprintFitSignal signal,
) {
  final supportedCapabilities = _signalCapabilities(
    signal,
  ).where(blueprint.supports).map(_capabilityLabel).toList(growable: false);

  if (supportedCapabilities.isEmpty) return 'Not exposed';
  return supportedCapabilities.join(', ');
}

List<BillingBusinessDomainCapability> _signalCapabilities(
  BillingBusinessDomainBlueprintFitSignal signal,
) {
  return switch (signal) {
    BillingBusinessDomainBlueprintFitSignal.checkout => const [
      BillingBusinessDomainCapability.productCatalog,
      BillingBusinessDomainCapability.inventory,
      BillingBusinessDomainCapability.cartCheckout,
    ],
    BillingBusinessDomainBlueprintFitSignal.projects => const [
      BillingBusinessDomainCapability.projectMilestones,
      BillingBusinessDomainCapability.progressBilling,
    ],
    BillingBusinessDomainBlueprintFitSignal.subscriptions => const [
      BillingBusinessDomainCapability.recurringSubscriptions,
      BillingBusinessDomainCapability.meteredUsage,
    ],
    BillingBusinessDomainBlueprintFitSignal.service => const [
      BillingBusinessDomainCapability.servicePeriods,
      BillingBusinessDomainCapability.retainers,
    ],
    BillingBusinessDomainBlueprintFitSignal.omniChannel => const [
      BillingBusinessDomainCapability.omniChannel,
    ],
  };
}

String _capabilityLabel(BillingBusinessDomainCapability capability) {
  return switch (capability) {
    BillingBusinessDomainCapability.productCatalog => 'Product catalog',
    BillingBusinessDomainCapability.inventory => 'Inventory',
    BillingBusinessDomainCapability.cartCheckout => 'Cart checkout',
    BillingBusinessDomainCapability.projectMilestones => 'Project milestones',
    BillingBusinessDomainCapability.progressBilling => 'Progress billing',
    BillingBusinessDomainCapability.recurringSubscriptions =>
      'Recurring subscriptions',
    BillingBusinessDomainCapability.meteredUsage => 'Metered usage',
    BillingBusinessDomainCapability.servicePeriods => 'Service periods',
    BillingBusinessDomainCapability.retainers => 'Retainers',
    BillingBusinessDomainCapability.omniChannel => 'Omni-channel',
  };
}
