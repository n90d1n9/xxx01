import '../../order/models/order.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_switch_plan.dart';
import 'pos_order_fulfillment.dart';

enum POSCommerceChannelSwitchPreflightField {
  contact,
  destination,
  table,
  schedule,
}

class POSCommerceChannelSwitchPreflightRequirement {
  final POSCommerceChannelSwitchPreflightField field;
  final String label;
  final String hintText;
  final String initialValue;

  const POSCommerceChannelSwitchPreflightRequirement({
    required this.field,
    required this.label,
    required this.hintText,
    required this.initialValue,
  });

  String get id => field.name;

  Iterable<String> get searchTerms sync* {
    yield id;
    yield label;
    yield hintText;
  }

  POSOrderFulfillmentContext applyTo(
    POSOrderFulfillmentContext context,
    String value,
  ) {
    switch (field) {
      case POSCommerceChannelSwitchPreflightField.contact:
        return context.copyWith(contactName: value);
      case POSCommerceChannelSwitchPreflightField.destination:
        return context.copyWith(destination: value);
      case POSCommerceChannelSwitchPreflightField.table:
        return context.copyWith(tableName: value);
      case POSCommerceChannelSwitchPreflightField.schedule:
        return context.copyWith(scheduleLabel: value);
    }
  }

  String valueFrom(POSOrderFulfillmentContext context) {
    switch (field) {
      case POSCommerceChannelSwitchPreflightField.contact:
        return context.contactName;
      case POSCommerceChannelSwitchPreflightField.destination:
        return context.destination;
      case POSCommerceChannelSwitchPreflightField.table:
        return context.tableName;
      case POSCommerceChannelSwitchPreflightField.schedule:
        return context.scheduleLabel;
    }
  }

  bool isSatisfiedBy(POSOrderFulfillmentContext context) {
    return valueFrom(context).trim().isNotEmpty;
  }
}

class POSCommerceChannelSwitchPreflight {
  final POSCommerceChannelSwitchPlan plan;
  final Order? order;
  final POSCommerceChannel targetChannel;
  final POSOrderFulfillmentContext context;
  final List<POSCommerceChannelSwitchPreflightRequirement> requirements;

  POSCommerceChannelSwitchPreflight({
    required this.plan,
    required this.order,
    required this.targetChannel,
    required this.context,
    required Iterable<POSCommerceChannelSwitchPreflightRequirement>
    requirements,
  }) : requirements = List.unmodifiable(requirements);

  factory POSCommerceChannelSwitchPreflight.fromPlan(
    POSCommerceChannelSwitchPlan plan,
  ) {
    final order = plan.availability.decision.order;
    if (order == null || order.items.isEmpty || plan.isCurrent) {
      return POSCommerceChannelSwitchPreflight(
        plan: plan,
        order: order,
        targetChannel: plan.targetChannel,
        context: plan.targetFulfillmentContext,
        requirements: const [],
      );
    }

    final readiness =
        plan.targetFulfillmentReadiness ??
        resolvePOSOrderFulfillmentReadiness(
          order: order,
          channel: plan.targetChannel,
          context: plan.targetFulfillmentContext,
        );

    return POSCommerceChannelSwitchPreflight(
      plan: plan,
      order: order,
      targetChannel: plan.targetChannel,
      context: readiness.context,
      requirements: _requirementsFor(
        readiness: readiness,
        context: readiness.context,
      ),
    );
  }

  bool get hasRequirements => requirements.isNotEmpty;

  bool get canConfirm => isSatisfiedBy(context);

  bool isSatisfiedBy(POSOrderFulfillmentContext context) {
    return requirements.every(
      (requirement) => requirement.isSatisfiedBy(context),
    );
  }

  Iterable<String> get searchTerms sync* {
    if (!hasRequirements) return;

    yield 'switch preflight';
    yield 'channel preflight';
    yield targetChannel.label;

    for (final requirement in requirements) {
      yield* requirement.searchTerms;
    }
  }
}

List<POSCommerceChannelSwitchPreflightRequirement> _requirementsFor({
  required POSOrderFulfillmentReadiness readiness,
  required POSOrderFulfillmentContext context,
}) {
  final requirements = <POSCommerceChannelSwitchPreflightRequirement>[];
  final fields = <POSCommerceChannelSwitchPreflightField>{};

  for (final issue in readiness.issues) {
    final requirement = _requirementFor(issue: issue, context: context);
    if (requirement == null || fields.contains(requirement.field)) continue;

    fields.add(requirement.field);
    requirements.add(requirement);
  }

  return requirements;
}

POSCommerceChannelSwitchPreflightRequirement? _requirementFor({
  required POSOrderFulfillmentIssue issue,
  required POSOrderFulfillmentContext context,
}) {
  switch (issue.type) {
    case POSOrderFulfillmentIssueType.unsupportedMode:
      return null;
    case POSOrderFulfillmentIssueType.missingContact:
      return POSCommerceChannelSwitchPreflightRequirement(
        field: POSCommerceChannelSwitchPreflightField.contact,
        label: _contactLabel(context.mode),
        hintText: 'Customer or contact name',
        initialValue: context.contactName,
      );
    case POSOrderFulfillmentIssueType.missingDestination:
      return POSCommerceChannelSwitchPreflightRequirement(
        field: POSCommerceChannelSwitchPreflightField.destination,
        label: _destinationLabel(context.mode),
        hintText: 'Address or delivery notes',
        initialValue: context.destination,
      );
    case POSOrderFulfillmentIssueType.missingTable:
      return POSCommerceChannelSwitchPreflightRequirement(
        field: POSCommerceChannelSwitchPreflightField.table,
        label: 'Table',
        hintText: 'Table or service area',
        initialValue: context.tableName,
      );
    case POSOrderFulfillmentIssueType.missingSchedule:
      return POSCommerceChannelSwitchPreflightRequirement(
        field: POSCommerceChannelSwitchPreflightField.schedule,
        label: 'Schedule',
        hintText: 'Pickup, delivery, or service time',
        initialValue: context.scheduleLabel,
      );
  }
}

String _contactLabel(POSFulfillmentMode mode) {
  switch (mode) {
    case POSFulfillmentMode.pickup:
      return 'Pickup contact';
    case POSFulfillmentMode.preorder:
      return 'Pre-order contact';
    case POSFulfillmentMode.immediateHandoff:
    case POSFulfillmentMode.delivery:
    case POSFulfillmentMode.shipment:
    case POSFulfillmentMode.tableService:
    case POSFulfillmentMode.fieldDelivery:
      return 'Contact';
  }
}

String _destinationLabel(POSFulfillmentMode mode) {
  switch (mode) {
    case POSFulfillmentMode.shipment:
      return 'Shipping address';
    case POSFulfillmentMode.fieldDelivery:
      return 'Field destination';
    case POSFulfillmentMode.delivery:
      return 'Delivery destination';
    case POSFulfillmentMode.immediateHandoff:
    case POSFulfillmentMode.pickup:
    case POSFulfillmentMode.tableService:
    case POSFulfillmentMode.preorder:
      return 'Destination';
  }
}
