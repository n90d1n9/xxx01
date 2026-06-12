import '../../order/utils/order_display.dart';
import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_switch_plan.dart';
import 'pos_commerce_channel_switch_preflight.dart';
import 'pos_order_fulfillment.dart';

enum POSCommerceChannelSwitchResultItemRole {
  channel,
  layout,
  activeOrder,
  fulfillment,
  completedRequirement,
  unresolvedRequirement,
}

class POSCommerceChannelSwitchResultItem {
  final String id;
  final String label;
  final String message;
  final POSCommerceChannelSwitchResultItemRole role;
  final bool changed;
  final bool requiresAttention;

  const POSCommerceChannelSwitchResultItem({
    required this.id,
    required this.label,
    required this.role,
    this.message = '',
    this.changed = false,
    this.requiresAttention = false,
  });

  Iterable<String> get searchTerms sync* {
    yield id;
    yield label;
    yield message;
    yield role.name;
    yield changed ? 'changed' : 'preserved';
    yield requiresAttention ? 'requires attention' : 'ready';
  }
}

class POSCommerceChannelSwitchResult {
  final POSCommerceChannelSwitchPlan plan;
  final POSOrderFulfillmentContext resolvedFulfillmentContext;
  final POSOrderFulfillmentReadiness? resolvedFulfillmentReadiness;
  final List<POSCommerceChannelSwitchResultItem> items;

  POSCommerceChannelSwitchResult({
    required this.plan,
    required this.resolvedFulfillmentContext,
    required this.resolvedFulfillmentReadiness,
    required Iterable<POSCommerceChannelSwitchResultItem> items,
  }) : items = List.unmodifiable(items);

  factory POSCommerceChannelSwitchResult.fromPlan({
    required POSCommerceChannelSwitchPlan plan,
    required POSOrderFulfillmentContext resolvedFulfillmentContext,
  }) {
    final order = plan.availability.decision.order;
    final readiness =
        order == null
            ? null
            : resolvePOSOrderFulfillmentReadiness(
              order: order,
              channel: plan.targetChannel,
              context: resolvedFulfillmentContext,
            );

    return POSCommerceChannelSwitchResult(
      plan: plan,
      resolvedFulfillmentContext: resolvedFulfillmentContext,
      resolvedFulfillmentReadiness: readiness,
      items: _itemsFor(
        plan: plan,
        resolvedContext: resolvedFulfillmentContext,
        resolvedReadiness: readiness,
      ),
    );
  }

  bool get changesChannel => plan.currentChannel.id != plan.targetChannel.id;

  bool get changesLayout {
    return plan.currentLayoutPreference != plan.targetLayoutPreference;
  }

  bool get changesFulfillmentMode {
    return plan.currentFulfillmentContext.mode !=
        resolvedFulfillmentContext.mode;
  }

  bool get hasActiveOrder => plan.hasActiveOrder;

  bool get activeOrderPreserved => hasActiveOrder && changesChannel;

  bool get hasChanges {
    return items.any((item) => item.changed);
  }

  bool get requiresAttention {
    return items.any((item) => item.requiresAttention);
  }

  int get completedRequirementCount {
    return items
        .where(
          (item) =>
              item.role ==
              POSCommerceChannelSwitchResultItemRole.completedRequirement,
        )
        .length;
  }

  String get summaryLabel {
    if (!hasChanges) return '${plan.targetChannel.label} already active';

    final completed = completedRequirementCount;
    if (completed > 0) {
      return 'Switched to ${plan.targetChannel.label} with $completed '
          'fulfillment ${completed == 1 ? 'detail' : 'details'}';
    }

    if (activeOrderPreserved) {
      return 'Switched to ${plan.targetChannel.label}; order stayed active';
    }

    return 'Switched to ${plan.targetChannel.label}';
  }

  Iterable<String> get searchTerms sync* {
    yield summaryLabel;
    yield plan.targetChannel.label;
    yield plan.targetLayoutPreference.label;
    yield resolvedFulfillmentContext.mode.label;

    for (final item in items) {
      yield* item.searchTerms;
    }
  }
}

List<POSCommerceChannelSwitchResultItem> _itemsFor({
  required POSCommerceChannelSwitchPlan plan,
  required POSOrderFulfillmentContext resolvedContext,
  required POSOrderFulfillmentReadiness? resolvedReadiness,
}) {
  final items = <POSCommerceChannelSwitchResultItem>[];
  final channelChanged = plan.currentChannel.id != plan.targetChannel.id;
  final layoutChanged =
      plan.currentLayoutPreference != plan.targetLayoutPreference;
  final fulfillmentChanged =
      plan.currentFulfillmentContext.mode != resolvedContext.mode;

  items.add(
    POSCommerceChannelSwitchResultItem(
      id: channelChanged ? 'channel_changed' : 'channel_preserved',
      label:
          channelChanged
              ? 'Channel switched to ${plan.targetChannel.label}'
              : 'Channel kept as ${plan.targetChannel.label}',
      role: POSCommerceChannelSwitchResultItemRole.channel,
      message:
          channelChanged
              ? '${plan.currentChannel.label} to ${plan.targetChannel.label}.'
              : plan.targetChannel.label,
      changed: channelChanged,
    ),
  );

  items.add(
    POSCommerceChannelSwitchResultItem(
      id: layoutChanged ? 'layout_changed' : 'layout_preserved',
      label:
          layoutChanged
              ? 'Layout changed to ${plan.targetLayoutPreference.label}'
              : 'Layout kept as ${plan.targetLayoutPreference.label}',
      role: POSCommerceChannelSwitchResultItemRole.layout,
      message:
          layoutChanged
              ? '${plan.currentLayoutPreference.label} to '
                  '${plan.targetLayoutPreference.label}.'
              : plan.targetLayoutPreference.label,
      changed: layoutChanged,
    ),
  );

  final order = plan.availability.decision.order;
  if (order != null && order.items.isNotEmpty) {
    items.add(
      POSCommerceChannelSwitchResultItem(
        id: 'active_order_preserved',
        label: 'Order stayed active',
        role: POSCommerceChannelSwitchResultItemRole.activeOrder,
        message: posOrderSwitchSummary(order),
      ),
    );
  }

  items.add(
    POSCommerceChannelSwitchResultItem(
      id: fulfillmentChanged ? 'fulfillment_changed' : 'fulfillment_preserved',
      label:
          fulfillmentChanged
              ? 'Fulfillment changed to ${resolvedContext.mode.label}'
              : 'Fulfillment kept as ${resolvedContext.mode.label}',
      role: POSCommerceChannelSwitchResultItemRole.fulfillment,
      message:
          fulfillmentChanged
              ? '${plan.currentFulfillmentContext.mode.label} to '
                  '${resolvedContext.mode.label}.'
              : resolvedContext.mode.label,
      changed: fulfillmentChanged,
    ),
  );

  final preflight = POSCommerceChannelSwitchPreflight.fromPlan(plan);
  for (final requirement in preflight.requirements) {
    if (!requirement.isSatisfiedBy(resolvedContext)) continue;

    items.add(
      POSCommerceChannelSwitchResultItem(
        id: 'completed_${requirement.id}',
        label: '${requirement.label} completed',
        role: POSCommerceChannelSwitchResultItemRole.completedRequirement,
        message: requirement.valueFrom(resolvedContext).trim(),
        changed: true,
      ),
    );
  }

  final issues =
      resolvedReadiness?.issues ?? const <POSOrderFulfillmentIssue>[];
  for (final issue in issues) {
    items.add(
      POSCommerceChannelSwitchResultItem(
        id: 'unresolved_${issue.type.name}',
        label: issue.label,
        role: POSCommerceChannelSwitchResultItemRole.unresolvedRequirement,
        message: issue.message,
        requiresAttention: true,
      ),
    );
  }

  return items;
}
