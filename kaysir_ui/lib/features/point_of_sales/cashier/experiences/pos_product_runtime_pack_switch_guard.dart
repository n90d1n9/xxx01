import '../../order/models/order.dart';
import '../../order/utils/order_display.dart';
import 'pos_product_runtime_pack.dart';
import 'pos_product_runtime_pack_switch_plan.dart';

enum POSProductRuntimePackSwitchDisposition { safe, confirm, blocked }

class POSProductRuntimePackSwitchDecision {
  final POSProductRuntimePackSwitchPlan plan;
  final POSProductRuntimePack currentPack;
  final Order? order;
  final POSProductRuntimePackSwitchDisposition disposition;
  final String reason;

  const POSProductRuntimePackSwitchDecision({
    required this.plan,
    required this.currentPack,
    required this.order,
    required this.disposition,
    this.reason = '',
  });

  bool get needsConfirmation {
    return disposition == POSProductRuntimePackSwitchDisposition.confirm;
  }

  bool get isBlocked {
    return disposition == POSProductRuntimePackSwitchDisposition.blocked;
  }

  bool get hasActiveOrder => order != null && order!.items.isNotEmpty;

  bool get isCurrentPack => plan.pack.id == currentPack.id;

  String get statusLabel {
    if (isCurrentPack) return 'Current pack';
    if (!hasActiveOrder) return 'No order';

    switch (disposition) {
      case POSProductRuntimePackSwitchDisposition.safe:
        return 'Order safe';
      case POSProductRuntimePackSwitchDisposition.confirm:
        return 'Review order';
      case POSProductRuntimePackSwitchDisposition.blocked:
        return 'Finish order';
    }
  }

  String get title {
    switch (disposition) {
      case POSProductRuntimePackSwitchDisposition.safe:
        return 'Switch runtime pack';
      case POSProductRuntimePackSwitchDisposition.confirm:
        return 'Keep current order?';
      case POSProductRuntimePackSwitchDisposition.blocked:
        return 'Finish current order first';
    }
  }

  String get message {
    if (reason.isNotEmpty) return reason;
    return '${plan.pack.label} can be used with the current order.';
  }

  String get confirmLabel {
    switch (disposition) {
      case POSProductRuntimePackSwitchDisposition.safe:
        return 'Switch pack';
      case POSProductRuntimePackSwitchDisposition.confirm:
        return 'Keep order';
      case POSProductRuntimePackSwitchDisposition.blocked:
        return 'OK';
    }
  }
}

abstract final class POSProductRuntimePackSwitchGuard {
  static POSProductRuntimePackSwitchDecision evaluate({
    required POSProductRuntimePackSwitchPlan plan,
    required POSProductRuntimePack currentPack,
    required Order? order,
  }) {
    if (plan.pack.id == currentPack.id ||
        order == null ||
        order.items.isEmpty) {
      return POSProductRuntimePackSwitchDecision(
        plan: plan,
        currentPack: currentPack,
        order: order,
        disposition: POSProductRuntimePackSwitchDisposition.safe,
      );
    }

    final experience = plan.experience;
    if (order.payments.isNotEmpty &&
        experience != null &&
        !experience.capabilities.payments) {
      return POSProductRuntimePackSwitchDecision(
        plan: plan,
        currentPack: currentPack,
        order: order,
        disposition: POSProductRuntimePackSwitchDisposition.blocked,
        reason:
            '${plan.pack.label} resolves to ${experience.label}, which does not support payments, but the current order already has recorded payments. Complete or cancel this order before switching runtime packs.',
      );
    }

    if (plan.preservesSelections) {
      return POSProductRuntimePackSwitchDecision(
        plan: plan,
        currentPack: currentPack,
        order: order,
        disposition: POSProductRuntimePackSwitchDisposition.safe,
      );
    }

    return POSProductRuntimePackSwitchDecision(
      plan: plan,
      currentPack: currentPack,
      order: order,
      disposition: POSProductRuntimePackSwitchDisposition.confirm,
      reason:
          'Switching to ${plan.pack.label} keeps the current order (${posOrderSwitchSummary(order)}), but changes the runtime context to ${plan.selectionLabel}. Review cart, checkout, fulfillment, and channel behavior after switching.',
    );
  }
}
