import '../../order/models/order.dart';
import '../../order/utils/order_display.dart';
import 'pos_mode_switch_controller.dart';

enum POSModeSwitchOrderDisposition { safe, confirm, blocked }

class POSModeSwitchOrderDecision {
  final POSModeSwitchOption option;
  final Order? order;
  final POSModeSwitchOrderDisposition disposition;
  final String reason;

  const POSModeSwitchOrderDecision({
    required this.option,
    required this.order,
    required this.disposition,
    this.reason = '',
  });

  bool get needsConfirmation =>
      disposition == POSModeSwitchOrderDisposition.confirm;

  bool get isBlocked => disposition == POSModeSwitchOrderDisposition.blocked;

  bool get hasActiveOrder => order != null && order!.items.isNotEmpty;

  String get statusLabel {
    if (!hasActiveOrder) return 'No order';
    if (option.selected) return 'Current order';

    switch (disposition) {
      case POSModeSwitchOrderDisposition.safe:
        return 'Order safe';
      case POSModeSwitchOrderDisposition.confirm:
        return 'Keeps order';
      case POSModeSwitchOrderDisposition.blocked:
        return 'Finish order';
    }
  }

  String get title {
    switch (disposition) {
      case POSModeSwitchOrderDisposition.safe:
        return 'Switch POS mode';
      case POSModeSwitchOrderDisposition.confirm:
        return 'Keep current order?';
      case POSModeSwitchOrderDisposition.blocked:
        return 'Finish current order first';
    }
  }

  String get message {
    if (reason.isNotEmpty) return reason;
    return '${option.experience.label} can be used with the current order.';
  }

  String get confirmLabel {
    switch (disposition) {
      case POSModeSwitchOrderDisposition.safe:
        return 'Switch';
      case POSModeSwitchOrderDisposition.confirm:
        return 'Keep order';
      case POSModeSwitchOrderDisposition.blocked:
        return 'OK';
    }
  }
}

abstract final class POSModeSwitchOrderGuard {
  static POSModeSwitchOrderDecision evaluate({
    required POSModeSwitchOption option,
    required Order? order,
  }) {
    if (option.selected || order == null || order.items.isEmpty) {
      return POSModeSwitchOrderDecision(
        option: option,
        order: order,
        disposition: POSModeSwitchOrderDisposition.safe,
      );
    }

    if (order.payments.isNotEmpty && !option.experience.capabilities.payments) {
      return POSModeSwitchOrderDecision(
        option: option,
        order: order,
        disposition: POSModeSwitchOrderDisposition.blocked,
        reason:
            '${option.experience.label} does not support payments, but the current order already has recorded payments. Complete or cancel this order before switching.',
      );
    }

    return POSModeSwitchOrderDecision(
      option: option,
      order: order,
      disposition: POSModeSwitchOrderDisposition.confirm,
      reason:
          'Switching to ${option.experience.label} keeps the current order (${posOrderSwitchSummary(order)}), but cart, checkout, and action behavior may change.',
    );
  }
}
