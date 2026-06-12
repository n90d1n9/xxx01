import '../../order/models/order.dart';
import '../../order/models/order_fulfillment_snapshot.dart';
import 'pos_commerce_channel.dart';

enum POSOrderFulfillmentIssueType {
  unsupportedMode,
  missingContact,
  missingDestination,
  missingTable,
  missingSchedule,
}

class POSOrderFulfillmentContext {
  final POSFulfillmentMode mode;
  final String contactName;
  final String destination;
  final String tableName;
  final String scheduleLabel;

  const POSOrderFulfillmentContext({
    required this.mode,
    this.contactName = '',
    this.destination = '',
    this.tableName = '',
    this.scheduleLabel = '',
  });

  factory POSOrderFulfillmentContext.forChannel(POSCommerceChannel channel) {
    final mode =
        channel.fulfillmentModes.isEmpty
            ? POSFulfillmentMode.immediateHandoff
            : channel.fulfillmentModes.first;

    return POSOrderFulfillmentContext(mode: mode);
  }

  POSOrderFulfillmentContext copyWith({
    POSFulfillmentMode? mode,
    String? contactName,
    String? destination,
    String? tableName,
    String? scheduleLabel,
  }) {
    return POSOrderFulfillmentContext(
      mode: mode ?? this.mode,
      contactName: contactName ?? this.contactName,
      destination: destination ?? this.destination,
      tableName: tableName ?? this.tableName,
      scheduleLabel: scheduleLabel ?? this.scheduleLabel,
    );
  }
}

class POSOrderFulfillmentIssue {
  final POSOrderFulfillmentIssueType type;
  final String label;
  final String message;

  const POSOrderFulfillmentIssue({
    required this.type,
    required this.label,
    required this.message,
  });
}

class POSOrderFulfillmentReadiness {
  final POSCommerceChannel channel;
  final POSOrderFulfillmentContext context;
  final List<POSOrderFulfillmentIssue> issues;
  final String customerName;

  POSOrderFulfillmentReadiness({
    required this.channel,
    required this.context,
    required Iterable<POSOrderFulfillmentIssue> issues,
    this.customerName = '',
  }) : issues = List.unmodifiable(issues);

  bool get canComplete => issues.isEmpty;

  bool get needsOperatorInput {
    return channel.fulfillmentModes.length > 1 ||
        context.mode != POSFulfillmentMode.immediateHandoff ||
        issues.isNotEmpty;
  }

  String get statusLabel {
    if (issues.isNotEmpty) return issues.first.label;

    switch (context.mode) {
      case POSFulfillmentMode.immediateHandoff:
        return 'Ready for handoff';
      case POSFulfillmentMode.pickup:
        return 'Pickup ready';
      case POSFulfillmentMode.delivery:
        return 'Delivery ready';
      case POSFulfillmentMode.shipment:
        return 'Shipment ready';
      case POSFulfillmentMode.tableService:
        return 'Table ready';
      case POSFulfillmentMode.preorder:
        return 'Pre-order ready';
      case POSFulfillmentMode.fieldDelivery:
        return 'Field delivery ready';
    }
  }

  String get summaryLabel {
    if (issues.isNotEmpty) return issues.first.message;

    final detail = switch (context.mode) {
      POSFulfillmentMode.immediateHandoff => 'Immediate handoff',
      POSFulfillmentMode.pickup => _firstNonBlank([
        context.contactName,
        customerName,
        channel.label,
      ]),
      POSFulfillmentMode.delivery ||
      POSFulfillmentMode.shipment ||
      POSFulfillmentMode.fieldDelivery => context.destination.trim(),
      POSFulfillmentMode.tableService => context.tableName.trim(),
      POSFulfillmentMode.preorder => context.scheduleLabel.trim(),
    };

    return detail.isEmpty ? context.mode.label : detail;
  }

  OrderFulfillmentSnapshot toOrderFulfillmentSnapshot() {
    return OrderFulfillmentSnapshot(
      commerceChannelId: channel.id,
      commerceChannelLabel: channel.label,
      fulfillmentModeKey: context.mode.name,
      fulfillmentModeLabel: context.mode.label,
      contactName: _firstNonBlank([context.contactName, customerName]),
      destination: context.destination.trim(),
      tableName: context.tableName.trim(),
      scheduleLabel: context.scheduleLabel.trim(),
      statusLabel: statusLabel,
      summaryLabel: summaryLabel,
    );
  }
}

POSOrderFulfillmentReadiness resolvePOSOrderFulfillmentReadiness({
  required Order order,
  required POSCommerceChannel channel,
  required POSOrderFulfillmentContext context,
  Iterable<POSOrderFulfillmentIssue> extraIssues = const [],
}) {
  final issues = <POSOrderFulfillmentIssue>[];

  if (!channel.supportsFulfillment(context.mode)) {
    _addIssue(
      issues,
      POSOrderFulfillmentIssue(
        type: POSOrderFulfillmentIssueType.unsupportedMode,
        label: 'Fulfillment unavailable',
        message:
            '${context.mode.label} is not supported by ${channel.label} channel.',
      ),
    );
  }

  if (order.items.isNotEmpty) {
    switch (context.mode) {
      case POSFulfillmentMode.immediateHandoff:
        break;
      case POSFulfillmentMode.pickup:
        if (!_hasContact(order, context)) {
          _addIssue(
            issues,
            const POSOrderFulfillmentIssue(
              type: POSOrderFulfillmentIssueType.missingContact,
              label: 'Pickup contact needed',
              message: 'Add a customer or pickup name before closing.',
            ),
          );
        }
        break;
      case POSFulfillmentMode.delivery:
      case POSFulfillmentMode.fieldDelivery:
        if (context.destination.trim().isEmpty) {
          _addIssue(
            issues,
            const POSOrderFulfillmentIssue(
              type: POSOrderFulfillmentIssueType.missingDestination,
              label: 'Delivery address needed',
              message: 'Add a delivery destination before closing.',
            ),
          );
        }
        break;
      case POSFulfillmentMode.shipment:
        if (context.destination.trim().isEmpty) {
          _addIssue(
            issues,
            const POSOrderFulfillmentIssue(
              type: POSOrderFulfillmentIssueType.missingDestination,
              label: 'Shipping address needed',
              message: 'Add a shipping destination before closing.',
            ),
          );
        }
        break;
      case POSFulfillmentMode.tableService:
        if (context.tableName.trim().isEmpty) {
          _addIssue(
            issues,
            const POSOrderFulfillmentIssue(
              type: POSOrderFulfillmentIssueType.missingTable,
              label: 'Table needed',
              message: 'Add a table before closing this service order.',
            ),
          );
        }
        break;
      case POSFulfillmentMode.preorder:
        if (!_hasContact(order, context)) {
          _addIssue(
            issues,
            const POSOrderFulfillmentIssue(
              type: POSOrderFulfillmentIssueType.missingContact,
              label: 'Pre-order contact needed',
              message: 'Add a customer or contact before closing.',
            ),
          );
        }
        if (context.scheduleLabel.trim().isEmpty) {
          _addIssue(
            issues,
            const POSOrderFulfillmentIssue(
              type: POSOrderFulfillmentIssueType.missingSchedule,
              label: 'Schedule needed',
              message: 'Add a pickup, delivery, or service schedule.',
            ),
          );
        }
        break;
    }
  }

  for (final issue in extraIssues) {
    _addIssue(issues, issue);
  }

  return POSOrderFulfillmentReadiness(
    channel: channel,
    context: context,
    issues: issues,
    customerName: order.customer?.name ?? '',
  );
}

void _addIssue(
  List<POSOrderFulfillmentIssue> issues,
  POSOrderFulfillmentIssue issue,
) {
  if (issues.any((current) => current.type == issue.type)) return;
  issues.add(issue);
}

bool _hasContact(Order order, POSOrderFulfillmentContext context) {
  return order.customer != null || context.contactName.trim().isNotEmpty;
}

String _firstNonBlank(List<String> values) {
  for (final value in values) {
    final normalized = value.trim();
    if (normalized.isNotEmpty) return normalized;
  }

  return '';
}
