import 'pos_experience.dart';

enum POSModeSwitchImpactDirection { enabled, disabled }

class POSModeSwitchImpactItem {
  final String id;
  final String label;
  final POSModeSwitchImpactDirection direction;

  const POSModeSwitchImpactItem({
    required this.id,
    required this.label,
    required this.direction,
  });

  String get statusLabel {
    switch (direction) {
      case POSModeSwitchImpactDirection.enabled:
        return '$label on';
      case POSModeSwitchImpactDirection.disabled:
        return '$label off';
    }
  }
}

class POSModeSwitchImpact {
  final POSExperience currentExperience;
  final POSExperience targetExperience;
  final List<POSModeSwitchImpactItem> items;

  POSModeSwitchImpact({
    required this.currentExperience,
    required this.targetExperience,
    required Iterable<POSModeSwitchImpactItem> items,
  }) : items = List.unmodifiable(items);

  factory POSModeSwitchImpact.evaluate({
    required POSExperience currentExperience,
    required POSExperience targetExperience,
  }) {
    const builder = _POSModeSwitchImpactBuilder();

    return POSModeSwitchImpact(
      currentExperience: currentExperience,
      targetExperience: targetExperience,
      items:
          [
            builder.capability(
              id: 'barcode_scanning',
              label: 'Scanning',
              current: currentExperience.capabilities.barcodeScanning,
              target: targetExperience.capabilities.barcodeScanning,
            ),
            builder.capability(
              id: 'customer_selection',
              label: 'Customer',
              current: currentExperience.capabilities.customerSelection,
              target: targetExperience.capabilities.customerSelection,
            ),
            builder.capability(
              id: 'held_orders',
              label: 'Holds',
              current: currentExperience.capabilities.heldOrders,
              target: targetExperience.capabilities.heldOrders,
            ),
            builder.capability(
              id: 'promotions',
              label: 'Promos',
              current: currentExperience.capabilities.promotions,
              target: targetExperience.capabilities.promotions,
            ),
            builder.capability(
              id: 'payments',
              label: 'Payments',
              current: currentExperience.capabilities.payments,
              target: targetExperience.capabilities.payments,
            ),
            builder.capability(
              id: 'new_orders',
              label: 'New orders',
              current: currentExperience.capabilities.newOrders,
              target: targetExperience.capabilities.newOrders,
            ),
            builder.capability(
              id: 'layout_switching',
              label: 'Layouts',
              current: currentExperience.capabilities.layoutSwitching,
              target: targetExperience.capabilities.layoutSwitching,
            ),
          ].whereType<POSModeSwitchImpactItem>(),
    );
  }

  bool get isCurrentMode => currentExperience.id == targetExperience.id;

  bool get hasChanges => items.isNotEmpty;

  Iterable<POSModeSwitchImpactItem> get enabledItems {
    return items.where(
      (item) => item.direction == POSModeSwitchImpactDirection.enabled,
    );
  }

  Iterable<POSModeSwitchImpactItem> get disabledItems {
    return items.where(
      (item) => item.direction == POSModeSwitchImpactDirection.disabled,
    );
  }

  int get enabledCount => enabledItems.length;

  int get disabledCount => disabledItems.length;

  String get summaryLabel {
    if (isCurrentMode) return 'Current feature set';
    if (!hasChanges) return 'Same feature set';

    final parts = <String>[];
    if (disabledCount > 0) parts.add('$disabledCount off');
    if (enabledCount > 0) parts.add('$enabledCount on');
    return parts.join(', ');
  }

  List<POSModeSwitchImpactItem> previewItems({int limit = 3}) {
    return [
      ...disabledItems,
      ...enabledItems,
    ].take(limit).toList(growable: false);
  }
}

class _POSModeSwitchImpactBuilder {
  const _POSModeSwitchImpactBuilder();

  POSModeSwitchImpactItem? capability({
    required String id,
    required String label,
    required bool current,
    required bool target,
  }) {
    if (current == target) return null;

    return POSModeSwitchImpactItem(
      id: id,
      label: label,
      direction:
          target
              ? POSModeSwitchImpactDirection.enabled
              : POSModeSwitchImpactDirection.disabled,
    );
  }
}
