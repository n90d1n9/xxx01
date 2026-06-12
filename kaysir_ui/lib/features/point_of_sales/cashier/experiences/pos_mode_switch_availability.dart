import '../../order/models/order.dart';
import 'pos_mode_switch_controller.dart';
import 'pos_mode_switch_order_guard.dart';
import 'pos_mode_switch_policy.dart';

enum POSModeSwitchAvailabilityStatus { current, available, confirm, blocked }

class POSModeSwitchAvailability {
  final POSModeSwitchOption option;
  final POSModeSwitchOrderDecision orderDecision;

  const POSModeSwitchAvailability({
    required this.option,
    required this.orderDecision,
  });

  factory POSModeSwitchAvailability.evaluate({
    required POSModeSwitchOption option,
    required Order? order,
  }) {
    return POSModeSwitchAvailability(
      option: option,
      orderDecision: POSModeSwitchOrderGuard.evaluate(
        option: option,
        order: order,
      ),
    );
  }

  POSModeSwitchAvailabilityStatus get status {
    if (option.selected) return POSModeSwitchAvailabilityStatus.current;
    if (option.decision.isBlocked || orderDecision.isBlocked) {
      return POSModeSwitchAvailabilityStatus.blocked;
    }
    if (option.decision.needsConfirmation || orderDecision.needsConfirmation) {
      return POSModeSwitchAvailabilityStatus.confirm;
    }

    return POSModeSwitchAvailabilityStatus.available;
  }

  bool get canSwitch => status != POSModeSwitchAvailabilityStatus.blocked;

  bool get needsConfirmation =>
      status == POSModeSwitchAvailabilityStatus.confirm;

  bool get isBlocked => status == POSModeSwitchAvailabilityStatus.blocked;

  String get statusLabel {
    switch (status) {
      case POSModeSwitchAvailabilityStatus.current:
        return 'Current mode';
      case POSModeSwitchAvailabilityStatus.available:
        return option.decision.statusLabel;
      case POSModeSwitchAvailabilityStatus.confirm:
        if (option.decision.needsConfirmation) {
          return option.decision.statusLabel;
        }
        return orderDecision.statusLabel;
      case POSModeSwitchAvailabilityStatus.blocked:
        if (option.decision.isBlocked) return option.decision.statusLabel;
        return orderDecision.statusLabel;
    }
  }

  POSModeSwitchDecision? get blockedModeDecision {
    if (!option.decision.isBlocked) return null;
    return option.decision;
  }

  POSModeSwitchOrderDecision? get blockedOrderDecision {
    if (!orderDecision.isBlocked) return null;
    return orderDecision;
  }

  POSModeSwitchDecision? get modeConfirmation {
    if (!option.decision.needsConfirmation) return null;
    return option.decision;
  }

  POSModeSwitchOrderDecision? get orderConfirmation {
    if (!orderDecision.needsConfirmation) return null;
    return orderDecision;
  }
}
