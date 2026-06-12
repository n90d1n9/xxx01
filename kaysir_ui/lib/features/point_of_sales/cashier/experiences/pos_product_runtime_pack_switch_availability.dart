import '../../order/models/order.dart';
import 'pos_product_runtime_pack.dart';
import 'pos_product_runtime_pack_switch_guard.dart';
import 'pos_product_runtime_pack_switch_plan.dart';

enum POSProductRuntimePackSwitchAvailabilityStatus {
  current,
  available,
  confirm,
  blocked,
}

class POSProductRuntimePackSwitchAvailability {
  final POSProductRuntimePackSwitchPlan plan;
  final POSProductRuntimePackSwitchDecision decision;

  const POSProductRuntimePackSwitchAvailability({
    required this.plan,
    required this.decision,
  });

  factory POSProductRuntimePackSwitchAvailability.evaluate({
    required POSProductRuntimePackSwitchPlan plan,
    required POSProductRuntimePack currentPack,
    required Order? order,
  }) {
    return POSProductRuntimePackSwitchAvailability(
      plan: plan,
      decision: POSProductRuntimePackSwitchGuard.evaluate(
        plan: plan,
        currentPack: currentPack,
        order: order,
      ),
    );
  }

  POSProductRuntimePackSwitchAvailabilityStatus get status {
    if (isCurrent) {
      return POSProductRuntimePackSwitchAvailabilityStatus.current;
    }
    if (decision.isBlocked) {
      return POSProductRuntimePackSwitchAvailabilityStatus.blocked;
    }
    if (decision.needsConfirmation) {
      return POSProductRuntimePackSwitchAvailabilityStatus.confirm;
    }

    return POSProductRuntimePackSwitchAvailabilityStatus.available;
  }

  bool get isCurrent => plan.pack.id == decision.currentPack.id;

  bool get canSwitch {
    return status != POSProductRuntimePackSwitchAvailabilityStatus.blocked;
  }

  bool get needsConfirmation {
    return status == POSProductRuntimePackSwitchAvailabilityStatus.confirm;
  }

  bool get isBlocked {
    return status == POSProductRuntimePackSwitchAvailabilityStatus.blocked;
  }

  String get statusLabel {
    switch (status) {
      case POSProductRuntimePackSwitchAvailabilityStatus.current:
        return 'Current pack';
      case POSProductRuntimePackSwitchAvailabilityStatus.available:
        return 'Available';
      case POSProductRuntimePackSwitchAvailabilityStatus.confirm:
      case POSProductRuntimePackSwitchAvailabilityStatus.blocked:
        return decision.statusLabel;
    }
  }
}
