import '../../order/utils/order_display.dart';
import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_switch_plan.dart';
import 'pos_order_fulfillment.dart';

enum POSCommerceChannelActiveOrderImpactRole {
  orderKept,
  layoutChange,
  fulfillmentChange,
  requirement,
  retiredDetail,
}

class POSCommerceChannelActiveOrderImpactItem {
  final String id;
  final String label;
  final String message;
  final POSCommerceChannelActiveOrderImpactRole role;
  final bool requiresAttention;

  const POSCommerceChannelActiveOrderImpactItem({
    required this.id,
    required this.label,
    required this.role,
    this.message = '',
    this.requiresAttention = false,
  });

  Iterable<String> get searchTerms sync* {
    yield id;
    yield label;
    yield message;
    yield role.name;
    yield requiresAttention ? 'requires attention' : 'safe';
  }
}

class POSCommerceChannelActiveOrderImpact {
  final POSCommerceChannelSwitchPlan plan;
  final List<POSCommerceChannelActiveOrderImpactItem> items;

  POSCommerceChannelActiveOrderImpact({
    required this.plan,
    required Iterable<POSCommerceChannelActiveOrderImpactItem> items,
  }) : items = List.unmodifiable(items);

  factory POSCommerceChannelActiveOrderImpact.fromPlan(
    POSCommerceChannelSwitchPlan plan,
  ) {
    final order = plan.availability.decision.order;
    if (order == null || !plan.hasActiveOrder || plan.isCurrent) {
      return POSCommerceChannelActiveOrderImpact(plan: plan, items: const []);
    }

    final targetReadiness = plan.targetFulfillmentReadiness;
    final currentContext = plan.currentFulfillmentContext;
    final targetContext = plan.targetFulfillmentContext;

    return POSCommerceChannelActiveOrderImpact(
      plan: plan,
      items: [
        POSCommerceChannelActiveOrderImpactItem(
          id: 'order_kept',
          label: 'Order stays active',
          role: POSCommerceChannelActiveOrderImpactRole.orderKept,
          message: posOrderSwitchSummary(order),
        ),
        if (plan.changesLayout)
          POSCommerceChannelActiveOrderImpactItem(
            id: 'layout_change',
            label:
                'Layout changes to '
                '${plan.targetLayoutPreference.label}',
            role: POSCommerceChannelActiveOrderImpactRole.layoutChange,
            message:
                '${plan.targetChannel.label} prefers '
                '${plan.targetLayoutPreference.label} layout.',
          ),
        if (plan.changesFulfillmentMode)
          POSCommerceChannelActiveOrderImpactItem(
            id: 'fulfillment_change',
            label:
                'Fulfillment changes to '
                '${targetContext.mode.label}',
            role: POSCommerceChannelActiveOrderImpactRole.fulfillmentChange,
            message:
                '${plan.currentFulfillmentContext.mode.label} becomes '
                '${targetContext.mode.label}.',
            requiresAttention: plan.hasFulfillmentIssues,
          ),
        if (targetReadiness != null)
          for (final issue in targetReadiness.issues)
            _requirementItem(issue: issue, context: targetContext),
        ..._retiredDetailItems(
          currentContext: currentContext,
          targetContext: targetContext,
        ),
      ],
    );
  }

  bool get isVisible => items.isNotEmpty;

  bool get requiresAttention {
    return items.any((item) => item.requiresAttention);
  }

  Iterable<String> get searchTerms sync* {
    if (!isVisible) return;

    yield 'active order impact';
    yield 'order switch impact';
    yield plan.impactLabel;
    yield plan.statusLabel;

    for (final item in items) {
      yield* item.searchTerms;
    }
  }
}

POSCommerceChannelActiveOrderImpactItem _requirementItem({
  required POSOrderFulfillmentIssue issue,
  required POSOrderFulfillmentContext context,
}) {
  return POSCommerceChannelActiveOrderImpactItem(
    id: 'requirement_${issue.type.name}',
    label: _requirementLabel(issue: issue, context: context),
    role: POSCommerceChannelActiveOrderImpactRole.requirement,
    message: issue.message,
    requiresAttention: true,
  );
}

String _requirementLabel({
  required POSOrderFulfillmentIssue issue,
  required POSOrderFulfillmentContext context,
}) {
  switch (issue.type) {
    case POSOrderFulfillmentIssueType.unsupportedMode:
      return issue.label;
    case POSOrderFulfillmentIssueType.missingContact:
      return 'Customer/contact required';
    case POSOrderFulfillmentIssueType.missingDestination:
      return _destinationRequirementLabel(context.mode);
    case POSOrderFulfillmentIssueType.missingTable:
      return 'Table required';
    case POSOrderFulfillmentIssueType.missingSchedule:
      return 'Schedule required';
  }
}

String _destinationRequirementLabel(POSFulfillmentMode mode) {
  switch (mode) {
    case POSFulfillmentMode.shipment:
      return 'Shipping address required';
    case POSFulfillmentMode.fieldDelivery:
      return 'Field destination required';
    case POSFulfillmentMode.delivery:
      return 'Delivery address required';
    case POSFulfillmentMode.immediateHandoff:
    case POSFulfillmentMode.pickup:
    case POSFulfillmentMode.tableService:
    case POSFulfillmentMode.preorder:
      return 'Destination required';
  }
}

Iterable<POSCommerceChannelActiveOrderImpactItem> _retiredDetailItems({
  required POSOrderFulfillmentContext currentContext,
  required POSOrderFulfillmentContext targetContext,
}) sync* {
  if (_usesDestination(currentContext.mode) &&
      !_usesDestination(targetContext.mode) &&
      currentContext.destination.trim().isNotEmpty) {
    yield POSCommerceChannelActiveOrderImpactItem(
      id: 'retire_destination',
      label: '${_destinationDetailName(currentContext.mode)} no longer applies',
      role: POSCommerceChannelActiveOrderImpactRole.retiredDetail,
      message: currentContext.destination.trim(),
      requiresAttention: true,
    );
  }

  if (currentContext.mode == POSFulfillmentMode.tableService &&
      targetContext.mode != POSFulfillmentMode.tableService &&
      currentContext.tableName.trim().isNotEmpty) {
    yield POSCommerceChannelActiveOrderImpactItem(
      id: 'retire_table',
      label: 'Table detail no longer applies',
      role: POSCommerceChannelActiveOrderImpactRole.retiredDetail,
      message: currentContext.tableName.trim(),
      requiresAttention: true,
    );
  }

  if (currentContext.mode == POSFulfillmentMode.preorder &&
      targetContext.mode != POSFulfillmentMode.preorder &&
      currentContext.scheduleLabel.trim().isNotEmpty) {
    yield POSCommerceChannelActiveOrderImpactItem(
      id: 'retire_schedule',
      label: 'Schedule no longer applies',
      role: POSCommerceChannelActiveOrderImpactRole.retiredDetail,
      message: currentContext.scheduleLabel.trim(),
      requiresAttention: true,
    );
  }

  if (_usesStandaloneContact(currentContext.mode) &&
      !_usesStandaloneContact(targetContext.mode) &&
      currentContext.contactName.trim().isNotEmpty) {
    yield POSCommerceChannelActiveOrderImpactItem(
      id: 'retire_contact',
      label: 'Contact detail no longer applies',
      role: POSCommerceChannelActiveOrderImpactRole.retiredDetail,
      message: currentContext.contactName.trim(),
      requiresAttention: true,
    );
  }
}

bool _usesDestination(POSFulfillmentMode mode) {
  switch (mode) {
    case POSFulfillmentMode.delivery:
    case POSFulfillmentMode.shipment:
    case POSFulfillmentMode.fieldDelivery:
      return true;
    case POSFulfillmentMode.immediateHandoff:
    case POSFulfillmentMode.pickup:
    case POSFulfillmentMode.tableService:
    case POSFulfillmentMode.preorder:
      return false;
  }
}

bool _usesStandaloneContact(POSFulfillmentMode mode) {
  switch (mode) {
    case POSFulfillmentMode.pickup:
    case POSFulfillmentMode.preorder:
      return true;
    case POSFulfillmentMode.immediateHandoff:
    case POSFulfillmentMode.delivery:
    case POSFulfillmentMode.shipment:
    case POSFulfillmentMode.tableService:
    case POSFulfillmentMode.fieldDelivery:
      return false;
  }
}

String _destinationDetailName(POSFulfillmentMode mode) {
  switch (mode) {
    case POSFulfillmentMode.shipment:
      return 'Shipping address';
    case POSFulfillmentMode.fieldDelivery:
      return 'Field destination';
    case POSFulfillmentMode.delivery:
      return 'Delivery address';
    case POSFulfillmentMode.immediateHandoff:
    case POSFulfillmentMode.pickup:
    case POSFulfillmentMode.tableService:
    case POSFulfillmentMode.preorder:
      return 'Destination';
  }
}
