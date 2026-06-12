import '../states/pos_layout_provider.dart';
import 'pos_product_runtime_pack.dart';
import 'pos_product_runtime_pack_switch_availability.dart';

enum POSProductRuntimePackSwitchPreviewItemRole {
  availability,
  order,
  productLine,
  layout,
  selection,
  catalogScope,
}

enum POSProductRuntimePackSwitchPreviewItemTone {
  neutral,
  positive,
  warning,
  danger,
}

class POSProductRuntimePackSwitchPreviewItem {
  final String id;
  final String label;
  final POSProductRuntimePackSwitchPreviewItemRole role;
  final POSProductRuntimePackSwitchPreviewItemTone tone;

  const POSProductRuntimePackSwitchPreviewItem({
    required this.id,
    required this.label,
    required this.role,
    this.tone = POSProductRuntimePackSwitchPreviewItemTone.neutral,
  });
}

class POSProductRuntimePackSwitchPreview {
  final POSProductRuntimePackSwitchAvailability availability;
  final POSLayoutPreference? currentLayoutPreference;
  final POSLayoutPreference? targetLayoutPreference;
  final List<POSProductRuntimePackSwitchPreviewItem> items;

  POSProductRuntimePackSwitchPreview({
    required this.availability,
    required this.currentLayoutPreference,
    required this.targetLayoutPreference,
    required Iterable<POSProductRuntimePackSwitchPreviewItem> items,
  }) : items = List.unmodifiable(items);

  factory POSProductRuntimePackSwitchPreview.evaluate({
    required POSProductRuntimePackSwitchAvailability availability,
    POSLayoutPreference? currentLayoutPreference,
  }) {
    final plan = availability.plan;
    final currentPack = availability.decision.currentPack;
    final targetPack = plan.pack;
    final resolvedTargetLayout = plan.layoutPreference;
    final items = <POSProductRuntimePackSwitchPreviewItem>[
      POSProductRuntimePackSwitchPreviewItem(
        id: 'availability',
        label: availability.statusLabel,
        role: POSProductRuntimePackSwitchPreviewItemRole.availability,
        tone: _availabilityTone(availability),
      ),
    ];

    if (_shouldShowOrderItem(availability)) {
      items.add(
        POSProductRuntimePackSwitchPreviewItem(
          id: 'order',
          label: availability.decision.statusLabel,
          role: POSProductRuntimePackSwitchPreviewItemRole.order,
          tone: _orderTone(availability),
        ),
      );
    }

    final productLineChangeLabel = _productLineChangeLabel(
      currentPack,
      targetPack,
    );
    if (productLineChangeLabel != null) {
      items.add(
        POSProductRuntimePackSwitchPreviewItem(
          id: 'product_line',
          label: productLineChangeLabel,
          role: POSProductRuntimePackSwitchPreviewItemRole.productLine,
        ),
      );
    }

    if (currentLayoutPreference != null &&
        resolvedTargetLayout != null &&
        currentLayoutPreference != resolvedTargetLayout) {
      items.add(
        POSProductRuntimePackSwitchPreviewItem(
          id: 'layout',
          label:
              '${currentLayoutPreference.label} to '
              '${resolvedTargetLayout.label}',
          role: POSProductRuntimePackSwitchPreviewItemRole.layout,
        ),
      );
    }

    if (!availability.isCurrent) {
      items.add(
        POSProductRuntimePackSwitchPreviewItem(
          id: 'selection',
          label:
              plan.preservesSelections ? plan.impactLabel : plan.selectionLabel,
          role: POSProductRuntimePackSwitchPreviewItemRole.selection,
          tone: _selectionTone(availability),
        ),
      );
    }

    if (_changesCatalogScope(currentPack, targetPack)) {
      items.add(
        POSProductRuntimePackSwitchPreviewItem(
          id: 'catalog_scope',
          label: _scopeLabel(targetPack),
          role: POSProductRuntimePackSwitchPreviewItemRole.catalogScope,
        ),
      );
    }

    return POSProductRuntimePackSwitchPreview(
      availability: availability,
      currentLayoutPreference: currentLayoutPreference,
      targetLayoutPreference: resolvedTargetLayout,
      items: items,
    );
  }

  POSProductRuntimePack get currentPack => availability.decision.currentPack;

  POSProductRuntimePack get targetPack => availability.plan.pack;

  bool get isCurrentPack => availability.isCurrent;

  bool get changesLayout {
    return currentLayoutPreference != null &&
        targetLayoutPreference != null &&
        currentLayoutPreference != targetLayoutPreference;
  }

  String? get layoutChangeLabel {
    if (!changesLayout) return null;
    return '${currentLayoutPreference!.label} to '
        '${targetLayoutPreference!.label}';
  }

  bool get changesProductLine {
    return _normalizedProductLine(currentPack) !=
        _normalizedProductLine(targetPack);
  }

  String? get productLineChangeLabel {
    return _productLineChangeLabel(currentPack, targetPack);
  }

  bool get changesCatalogScope {
    return _changesCatalogScope(currentPack, targetPack);
  }

  String get targetScopeLabel => _scopeLabel(targetPack);

  String get primaryLabel => items.first.label;

  Iterable<String> get searchTerms sync* {
    yield primaryLabel;
    yield availability.plan.impactLabel;
    yield availability.plan.selectionLabel;
    yield availability.plan.experienceLabel;
    yield availability.plan.commerceChannelLabel;
    yield currentPack.id;
    yield currentPack.label;
    yield currentPack.productLine;
    yield targetPack.id;
    yield targetPack.label;
    yield targetPack.productLine;
    yield targetScopeLabel;

    if (layoutChangeLabel case final label?) yield label;
    if (productLineChangeLabel case final label?) yield label;

    for (final item in items) {
      yield item.id;
      yield item.label;
      yield item.role.name;
      yield item.tone.name;
    }
  }

  List<POSProductRuntimePackSwitchPreviewItem> compactItems() {
    return List.unmodifiable(items);
  }

  static bool _shouldShowOrderItem(
    POSProductRuntimePackSwitchAvailability availability,
  ) {
    final decision = availability.decision;
    if (!decision.hasActiveOrder) return false;

    return availability.statusLabel != decision.statusLabel;
  }

  static POSProductRuntimePackSwitchPreviewItemTone _availabilityTone(
    POSProductRuntimePackSwitchAvailability availability,
  ) {
    switch (availability.status) {
      case POSProductRuntimePackSwitchAvailabilityStatus.current:
        return POSProductRuntimePackSwitchPreviewItemTone.neutral;
      case POSProductRuntimePackSwitchAvailabilityStatus.available:
        return POSProductRuntimePackSwitchPreviewItemTone.positive;
      case POSProductRuntimePackSwitchAvailabilityStatus.confirm:
        return POSProductRuntimePackSwitchPreviewItemTone.warning;
      case POSProductRuntimePackSwitchAvailabilityStatus.blocked:
        return POSProductRuntimePackSwitchPreviewItemTone.danger;
    }
  }

  static POSProductRuntimePackSwitchPreviewItemTone _orderTone(
    POSProductRuntimePackSwitchAvailability availability,
  ) {
    if (availability.decision.isBlocked) {
      return POSProductRuntimePackSwitchPreviewItemTone.danger;
    }
    if (availability.decision.needsConfirmation) {
      return POSProductRuntimePackSwitchPreviewItemTone.warning;
    }
    return POSProductRuntimePackSwitchPreviewItemTone.positive;
  }

  static POSProductRuntimePackSwitchPreviewItemTone _selectionTone(
    POSProductRuntimePackSwitchAvailability availability,
  ) {
    if (availability.isBlocked) {
      return POSProductRuntimePackSwitchPreviewItemTone.danger;
    }
    if (availability.needsConfirmation) {
      return POSProductRuntimePackSwitchPreviewItemTone.warning;
    }
    if (!availability.plan.preservesSelections) {
      return POSProductRuntimePackSwitchPreviewItemTone.positive;
    }

    return POSProductRuntimePackSwitchPreviewItemTone.neutral;
  }

  static String? _productLineChangeLabel(
    POSProductRuntimePack currentPack,
    POSProductRuntimePack targetPack,
  ) {
    if (_normalizedProductLine(currentPack) ==
        _normalizedProductLine(targetPack)) {
      return null;
    }

    return '${_productLineLabel(currentPack.productLine)} to '
        '${_productLineLabel(targetPack.productLine)}';
  }

  static bool _changesCatalogScope(
    POSProductRuntimePack currentPack,
    POSProductRuntimePack targetPack,
  ) {
    return currentPack.productProfileCatalog.profiles.length !=
            targetPack.productProfileCatalog.profiles.length ||
        currentPack.commerceChannelRegistry.channels.length !=
            targetPack.commerceChannelRegistry.channels.length;
  }

  static String _scopeLabel(POSProductRuntimePack pack) {
    final profileCount = pack.productProfileCatalog.profiles.length;
    final channelCount = pack.commerceChannelRegistry.channels.length;

    return '${_countLabel(profileCount, 'mode')} | '
        '${_countLabel(channelCount, 'channel')}';
  }

  static String _countLabel(int count, String singular) {
    return '$count $singular${count == 1 ? '' : 's'}';
  }

  static String _normalizedProductLine(POSProductRuntimePack pack) {
    return pack.productLine.trim().toLowerCase();
  }

  static String _productLineLabel(String productLine) {
    final trimmed = productLine.trim();
    return trimmed.isEmpty ? 'Unassigned' : trimmed;
  }
}
