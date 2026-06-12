import '../states/pos_layout_provider.dart';
import 'pos_experience.dart';
import 'pos_mode_switch_availability.dart';
import 'pos_mode_switch_impact.dart';

enum POSModeSwitchPreviewItemRole {
  availability,
  order,
  layout,
  featureSummary,
  featureChange,
}

enum POSModeSwitchPreviewItemTone { neutral, positive, warning, danger }

class POSModeSwitchPreviewItem {
  final String id;
  final String label;
  final POSModeSwitchPreviewItemRole role;
  final POSModeSwitchPreviewItemTone tone;

  const POSModeSwitchPreviewItem({
    required this.id,
    required this.label,
    required this.role,
    this.tone = POSModeSwitchPreviewItemTone.neutral,
  });
}

class POSModeSwitchPreview {
  final POSModeSwitchAvailability availability;
  final POSModeSwitchImpact impact;
  final POSLayoutPreference currentLayoutPreference;
  final POSLayoutPreference targetLayoutPreference;
  final List<POSModeSwitchPreviewItem> items;

  POSModeSwitchPreview({
    required this.availability,
    required this.impact,
    required this.currentLayoutPreference,
    required this.targetLayoutPreference,
    required Iterable<POSModeSwitchPreviewItem> items,
  }) : items = List.unmodifiable(items);

  factory POSModeSwitchPreview.evaluate({
    required POSModeSwitchAvailability availability,
    required POSExperience currentExperience,
    POSLayoutPreference? currentLayoutPreference,
  }) {
    final targetExperience = availability.option.experience;
    final resolvedCurrentLayout =
        currentLayoutPreference ?? currentExperience.preferredLayout;
    final resolvedTargetLayout = targetExperience.preferredLayout;
    final impact = POSModeSwitchImpact.evaluate(
      currentExperience: currentExperience,
      targetExperience: targetExperience,
    );
    final items = <POSModeSwitchPreviewItem>[
      POSModeSwitchPreviewItem(
        id: 'availability',
        label: availability.statusLabel,
        role: POSModeSwitchPreviewItemRole.availability,
        tone: _availabilityTone(availability),
      ),
    ];

    if (_shouldShowOrderItem(availability)) {
      items.add(
        POSModeSwitchPreviewItem(
          id: 'order',
          label: availability.orderDecision.statusLabel,
          role: POSModeSwitchPreviewItemRole.order,
          tone: _orderTone(availability),
        ),
      );
    }

    if (resolvedCurrentLayout != resolvedTargetLayout) {
      items.add(
        POSModeSwitchPreviewItem(
          id: 'layout',
          label:
              '${resolvedCurrentLayout.label} to ${resolvedTargetLayout.label}',
          role: POSModeSwitchPreviewItemRole.layout,
        ),
      );
    }

    if (!impact.isCurrentMode && impact.hasChanges) {
      items.add(
        POSModeSwitchPreviewItem(
          id: 'feature_impact',
          label: impact.summaryLabel,
          role: POSModeSwitchPreviewItemRole.featureSummary,
        ),
      );
      for (final impactItem in impact.items) {
        items.add(
          POSModeSwitchPreviewItem(
            id: 'feature_${impactItem.id}',
            label: impactItem.statusLabel,
            role: POSModeSwitchPreviewItemRole.featureChange,
            tone:
                impactItem.direction == POSModeSwitchImpactDirection.disabled
                    ? POSModeSwitchPreviewItemTone.warning
                    : POSModeSwitchPreviewItemTone.positive,
          ),
        );
      }
    }

    return POSModeSwitchPreview(
      availability: availability,
      impact: impact,
      currentLayoutPreference: resolvedCurrentLayout,
      targetLayoutPreference: resolvedTargetLayout,
      items: items,
    );
  }

  bool get isCurrentMode => availability.option.selected;

  bool get changesLayout => currentLayoutPreference != targetLayoutPreference;

  String? get layoutChangeLabel {
    if (!changesLayout) return null;
    return '${currentLayoutPreference.label} to ${targetLayoutPreference.label}';
  }

  String get primaryLabel => items.first.label;

  Iterable<String> get searchTerms sync* {
    yield primaryLabel;
    if (layoutChangeLabel case final label?) yield label;
    yield impact.summaryLabel;

    for (final item in items) {
      yield item.id;
      yield item.label;
      yield item.role.name;
      yield item.tone.name;
    }
    for (final impactItem in impact.items) {
      yield impactItem.id;
      yield impactItem.label;
      yield impactItem.statusLabel;
    }
  }

  List<POSModeSwitchPreviewItem> compactItems({int featureChangeLimit = 3}) {
    var featureChangeCount = 0;
    final visibleItems = <POSModeSwitchPreviewItem>[];

    for (final item in items) {
      if (item.role == POSModeSwitchPreviewItemRole.featureChange) {
        if (featureChangeCount >= featureChangeLimit) continue;
        featureChangeCount += 1;
      }
      visibleItems.add(item);
    }

    return List.unmodifiable(visibleItems);
  }

  static bool _shouldShowOrderItem(POSModeSwitchAvailability availability) {
    final orderDecision = availability.orderDecision;
    if (!orderDecision.hasActiveOrder) {
      return false;
    }

    return availability.statusLabel != orderDecision.statusLabel;
  }

  static POSModeSwitchPreviewItemTone _availabilityTone(
    POSModeSwitchAvailability availability,
  ) {
    switch (availability.status) {
      case POSModeSwitchAvailabilityStatus.current:
        return POSModeSwitchPreviewItemTone.neutral;
      case POSModeSwitchAvailabilityStatus.available:
        return POSModeSwitchPreviewItemTone.positive;
      case POSModeSwitchAvailabilityStatus.confirm:
        return POSModeSwitchPreviewItemTone.warning;
      case POSModeSwitchAvailabilityStatus.blocked:
        return POSModeSwitchPreviewItemTone.danger;
    }
  }

  static POSModeSwitchPreviewItemTone _orderTone(
    POSModeSwitchAvailability availability,
  ) {
    if (availability.orderDecision.isBlocked) {
      return POSModeSwitchPreviewItemTone.danger;
    }
    if (availability.orderDecision.needsConfirmation) {
      return POSModeSwitchPreviewItemTone.warning;
    }
    return POSModeSwitchPreviewItemTone.positive;
  }
}
