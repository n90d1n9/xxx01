import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_switch_availability.dart';

enum POSCommerceChannelSwitchPreviewItemRole {
  availability,
  order,
  layout,
  fulfillment,
  fulfillmentIssue,
  capabilityScope,
}

enum POSCommerceChannelSwitchPreviewItemTone {
  neutral,
  positive,
  warning,
  danger,
}

class POSCommerceChannelSwitchPreviewItem {
  final String id;
  final String label;
  final POSCommerceChannelSwitchPreviewItemRole role;
  final POSCommerceChannelSwitchPreviewItemTone tone;

  const POSCommerceChannelSwitchPreviewItem({
    required this.id,
    required this.label,
    required this.role,
    this.tone = POSCommerceChannelSwitchPreviewItemTone.neutral,
  });
}

class POSCommerceChannelSwitchPreview {
  final POSCommerceChannelSwitchAvailability availability;
  final POSLayoutPreference currentLayoutPreference;
  final POSLayoutPreference targetLayoutPreference;
  final POSFulfillmentMode currentFulfillmentMode;
  final POSFulfillmentMode targetFulfillmentMode;
  final List<POSCommerceChannelSwitchPreviewItem> items;

  POSCommerceChannelSwitchPreview({
    required this.availability,
    required this.currentLayoutPreference,
    required this.targetLayoutPreference,
    required this.currentFulfillmentMode,
    required this.targetFulfillmentMode,
    required Iterable<POSCommerceChannelSwitchPreviewItem> items,
  }) : items = List.unmodifiable(items);

  factory POSCommerceChannelSwitchPreview.evaluate({
    required POSCommerceChannelSwitchAvailability availability,
  }) {
    final decision = availability.decision;
    final targetReadiness = decision.targetFulfillmentReadiness;
    final targetFulfillmentMode =
        targetReadiness?.context.mode ??
        _defaultFulfillmentMode(decision.targetChannel);
    final items = <POSCommerceChannelSwitchPreviewItem>[
      POSCommerceChannelSwitchPreviewItem(
        id: 'availability',
        label: availability.statusLabel,
        role: POSCommerceChannelSwitchPreviewItemRole.availability,
        tone: _availabilityTone(availability),
      ),
    ];

    if (_shouldShowOrderItem(availability)) {
      items.add(
        POSCommerceChannelSwitchPreviewItem(
          id: 'order',
          label: decision.statusLabel,
          role: POSCommerceChannelSwitchPreviewItemRole.order,
          tone: _orderTone(availability),
        ),
      );
    }

    if (decision.currentLayoutPreference !=
        decision.targetChannel.preferredLayout) {
      items.add(
        POSCommerceChannelSwitchPreviewItem(
          id: 'layout',
          label:
              '${decision.currentLayoutPreference.label} to '
              '${decision.targetChannel.preferredLayout.label}',
          role: POSCommerceChannelSwitchPreviewItemRole.layout,
        ),
      );
    }

    if (decision.currentFulfillmentContext.mode != targetFulfillmentMode) {
      items.add(
        POSCommerceChannelSwitchPreviewItem(
          id: 'fulfillment',
          label:
              '${decision.currentFulfillmentContext.mode.label} to '
              '${targetFulfillmentMode.label}',
          role: POSCommerceChannelSwitchPreviewItemRole.fulfillment,
          tone:
              decision.needsConfirmation
                  ? POSCommerceChannelSwitchPreviewItemTone.warning
                  : POSCommerceChannelSwitchPreviewItemTone.neutral,
        ),
      );
    }

    final firstIssue =
        targetReadiness == null || targetReadiness.issues.isEmpty
            ? null
            : targetReadiness.issues.first;
    if (firstIssue != null) {
      items.add(
        POSCommerceChannelSwitchPreviewItem(
          id: 'fulfillment_issue',
          label: firstIssue.label,
          role: POSCommerceChannelSwitchPreviewItemRole.fulfillmentIssue,
          tone: POSCommerceChannelSwitchPreviewItemTone.warning,
        ),
      );
    }

    if (!availability.isCurrent) {
      items.add(
        POSCommerceChannelSwitchPreviewItem(
          id: 'capability_scope',
          label: _capabilityScopeLabel(decision.targetChannel),
          role: POSCommerceChannelSwitchPreviewItemRole.capabilityScope,
        ),
      );
    }

    return POSCommerceChannelSwitchPreview(
      availability: availability,
      currentLayoutPreference: decision.currentLayoutPreference,
      targetLayoutPreference: decision.targetChannel.preferredLayout,
      currentFulfillmentMode: decision.currentFulfillmentContext.mode,
      targetFulfillmentMode: targetFulfillmentMode,
      items: items,
    );
  }

  bool get isCurrentChannel => availability.isCurrent;

  bool get changesLayout => currentLayoutPreference != targetLayoutPreference;

  bool get changesFulfillment {
    return currentFulfillmentMode != targetFulfillmentMode;
  }

  String get primaryLabel => items.first.label;

  Iterable<String> get searchTerms sync* {
    yield primaryLabel;
    yield availability.channel.id;
    yield availability.channel.label;
    yield availability.channel.kind.label;
    yield availability.channel.preferredLayout.label;
    yield availability.channel.fulfillmentSummary;
    yield availability.channel.capabilitySummary;

    for (final item in items) {
      yield item.id;
      yield item.label;
      yield item.role.name;
      yield item.tone.name;
    }
  }

  List<POSCommerceChannelSwitchPreviewItem> compactItems({
    bool includeAvailability = false,
  }) {
    return List.unmodifiable(
      items.where(
        (item) =>
            includeAvailability ||
            item.role != POSCommerceChannelSwitchPreviewItemRole.availability,
      ),
    );
  }

  static bool _shouldShowOrderItem(
    POSCommerceChannelSwitchAvailability availability,
  ) {
    final decision = availability.decision;
    if (!decision.hasActiveOrder) return false;

    return availability.statusLabel != decision.statusLabel;
  }

  static POSCommerceChannelSwitchPreviewItemTone _availabilityTone(
    POSCommerceChannelSwitchAvailability availability,
  ) {
    switch (availability.status) {
      case POSCommerceChannelSwitchAvailabilityStatus.current:
        return POSCommerceChannelSwitchPreviewItemTone.neutral;
      case POSCommerceChannelSwitchAvailabilityStatus.available:
        return POSCommerceChannelSwitchPreviewItemTone.positive;
      case POSCommerceChannelSwitchAvailabilityStatus.confirm:
        return POSCommerceChannelSwitchPreviewItemTone.warning;
    }
  }

  static POSCommerceChannelSwitchPreviewItemTone _orderTone(
    POSCommerceChannelSwitchAvailability availability,
  ) {
    if (availability.needsConfirmation) {
      return POSCommerceChannelSwitchPreviewItemTone.warning;
    }

    return POSCommerceChannelSwitchPreviewItemTone.positive;
  }
}

POSFulfillmentMode _defaultFulfillmentMode(POSCommerceChannel channel) {
  if (channel.fulfillmentModes.isEmpty) {
    return POSFulfillmentMode.immediateHandoff;
  }

  return channel.fulfillmentModes.first;
}

String _capabilityScopeLabel(POSCommerceChannel channel) {
  final capabilityCount = channel.capabilities.length;
  if (capabilityCount == 0) return 'No capabilities';

  return '$capabilityCount ${capabilityCount == 1 ? 'capability' : 'capabilities'}';
}
