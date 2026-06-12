import '../../order/models/order.dart';
import '../../order/utils/order_display.dart';
import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_order_fulfillment.dart';

enum POSCommerceChannelSwitchDisposition { safe, confirm }

class POSCommerceChannelSwitchDecision {
  final POSCommerceChannel currentChannel;
  final POSCommerceChannel targetChannel;
  final POSLayoutPreference currentLayoutPreference;
  final POSOrderFulfillmentContext currentFulfillmentContext;
  final POSOrderFulfillmentReadiness? targetFulfillmentReadiness;
  final Order? order;
  final POSCommerceChannelSwitchDisposition disposition;
  final String reason;

  const POSCommerceChannelSwitchDecision({
    required this.currentChannel,
    required this.targetChannel,
    required this.currentLayoutPreference,
    required this.currentFulfillmentContext,
    required this.disposition,
    this.targetFulfillmentReadiness,
    this.order,
    this.reason = '',
  });

  bool get needsConfirmation {
    return disposition == POSCommerceChannelSwitchDisposition.confirm;
  }

  bool get hasActiveOrder => order != null && order!.items.isNotEmpty;

  bool get isCurrentChannel => currentChannel.id == targetChannel.id;

  bool get changesLayout {
    return currentLayoutPreference != targetChannel.preferredLayout;
  }

  bool get changesFulfillmentMode {
    final targetContext = targetFulfillmentReadiness?.context;
    if (targetContext == null) return false;

    return currentFulfillmentContext.mode != targetContext.mode;
  }

  String get statusLabel {
    if (isCurrentChannel) return 'Current channel';
    if (!hasActiveOrder) return 'Available';

    switch (disposition) {
      case POSCommerceChannelSwitchDisposition.safe:
        return 'Order safe';
      case POSCommerceChannelSwitchDisposition.confirm:
        return 'Review order';
    }
  }

  String get title {
    switch (disposition) {
      case POSCommerceChannelSwitchDisposition.safe:
        return 'Switch channel';
      case POSCommerceChannelSwitchDisposition.confirm:
        return 'Keep current order?';
    }
  }

  String get message {
    if (reason.isNotEmpty) return reason;

    return '${targetChannel.label} can be used with the current order.';
  }

  String get confirmLabel {
    switch (disposition) {
      case POSCommerceChannelSwitchDisposition.safe:
        return 'Switch channel';
      case POSCommerceChannelSwitchDisposition.confirm:
        return 'Keep order';
    }
  }
}

abstract final class POSCommerceChannelSwitchGuard {
  static POSCommerceChannelSwitchDecision evaluate({
    required POSCommerceChannel currentChannel,
    required POSCommerceChannel targetChannel,
    required POSLayoutPreference currentLayoutPreference,
    required POSOrderFulfillmentContext currentFulfillmentContext,
    required POSOrderFulfillmentContext targetFulfillmentContext,
    required Order? order,
  }) {
    final targetReadiness =
        order == null
            ? null
            : resolvePOSOrderFulfillmentReadiness(
              order: order,
              channel: targetChannel,
              context: targetFulfillmentContext,
            );

    if (currentChannel.id == targetChannel.id ||
        order == null ||
        order.items.isEmpty) {
      return POSCommerceChannelSwitchDecision(
        currentChannel: currentChannel,
        targetChannel: targetChannel,
        currentLayoutPreference: currentLayoutPreference,
        currentFulfillmentContext: currentFulfillmentContext,
        targetFulfillmentReadiness: targetReadiness,
        order: order,
        disposition: POSCommerceChannelSwitchDisposition.safe,
      );
    }

    final changesLayout =
        currentLayoutPreference != targetChannel.preferredLayout;
    final changesFulfillment =
        currentFulfillmentContext.mode != targetFulfillmentContext.mode;
    final needsFulfillmentInput = targetReadiness?.canComplete == false;

    if (changesLayout || changesFulfillment || needsFulfillmentInput) {
      return POSCommerceChannelSwitchDecision(
        currentChannel: currentChannel,
        targetChannel: targetChannel,
        currentLayoutPreference: currentLayoutPreference,
        currentFulfillmentContext: currentFulfillmentContext,
        targetFulfillmentReadiness: targetReadiness,
        order: order,
        disposition: POSCommerceChannelSwitchDisposition.confirm,
        reason: _reviewMessage(
          order: order,
          targetChannel: targetChannel,
          targetContext: targetFulfillmentContext,
          changesLayout: changesLayout,
          changesFulfillment: changesFulfillment,
          targetReadiness: targetReadiness,
        ),
      );
    }

    return POSCommerceChannelSwitchDecision(
      currentChannel: currentChannel,
      targetChannel: targetChannel,
      currentLayoutPreference: currentLayoutPreference,
      currentFulfillmentContext: currentFulfillmentContext,
      targetFulfillmentReadiness: targetReadiness,
      order: order,
      disposition: POSCommerceChannelSwitchDisposition.safe,
    );
  }
}

String _reviewMessage({
  required Order order,
  required POSCommerceChannel targetChannel,
  required POSOrderFulfillmentContext targetContext,
  required bool changesLayout,
  required bool changesFulfillment,
  required POSOrderFulfillmentReadiness? targetReadiness,
}) {
  final impacts = <String>[];
  if (changesLayout) {
    impacts.add('layout to ${targetChannel.preferredLayout.label}');
  }
  if (changesFulfillment) {
    impacts.add('fulfillment to ${targetContext.mode.label}');
  }

  final issueMessage = _firstIssueMessage(targetReadiness);
  final impactSummary =
      impacts.isEmpty ? 'channel behavior' : impacts.join(' and ');
  final issueSummary =
      issueMessage == null
          ? ''
          : ' ${targetChannel.label} also needs: $issueMessage';

  return 'Switching to ${targetChannel.label} keeps the current order '
      '(${posOrderSwitchSummary(order)}), but changes $impactSummary.'
      '$issueSummary Review checkout and fulfillment after switching.';
}

String? _firstIssueMessage(POSOrderFulfillmentReadiness? readiness) {
  final issues = readiness?.issues;
  if (issues == null || issues.isEmpty) return null;

  return issues.first.message;
}
