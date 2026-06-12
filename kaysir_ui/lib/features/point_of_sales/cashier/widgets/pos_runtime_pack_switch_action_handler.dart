import '../../order/models/order.dart';
import '../experiences/pos_product_runtime_pack.dart';
import '../experiences/pos_product_runtime_pack_controller.dart';
import '../experiences/pos_product_runtime_pack_switch_availability.dart';
import 'pos_switch_action_context.dart';

Future<POSSwitchActionResult> handlePOSRuntimePackSwitchAction({
  required POSSwitchActionContext actionContext,
  required POSProductRuntimePackSwitchController switchController,
  required POSProductRuntimePack pack,
  required Order? currentOrder,
}) async {
  const kind = POSSwitchActionKind.runtimePack;
  final plan = switchController.planFor(pack);
  final availability = POSProductRuntimePackSwitchAvailability.evaluate(
    plan: plan,
    currentPack: switchController.currentPack,
    order: currentOrder,
  );

  if (!availability.canSwitch) {
    await actionContext.showNotice(
      POSSwitchNoticeRequest(
        title: availability.decision.title,
        message: availability.decision.message,
        confirmLabel: availability.decision.confirmLabel,
      ),
    );
    return actionContext.complete(
      POSSwitchActionResult.blocked(
        kind: kind,
        targetId: pack.id,
        targetLabel: pack.label,
        reason: availability.decision.title,
      ),
    );
  }

  if (availability.needsConfirmation) {
    final confirmed = await actionContext.showConfirmation(
      POSSwitchConfirmationRequest(
        title: availability.decision.title,
        message: availability.decision.message,
        confirmLabel: availability.decision.confirmLabel,
      ),
    );
    if (!confirmed) {
      return actionContext.complete(
        POSSwitchActionResult.cancelled(
          kind: kind,
          targetId: pack.id,
          targetLabel: pack.label,
          reason: availability.decision.title,
        ),
      );
    }
    if (!actionContext.canContinue()) {
      return actionContext.complete(
        POSSwitchActionResult.cancelled(
          kind: kind,
          targetId: pack.id,
          targetLabel: pack.label,
          reason: 'Switch context unavailable',
        ),
      );
    }
  }

  switchController.apply(pack);
  return actionContext.complete(
    POSSwitchActionResult.applied(
      kind: kind,
      targetId: pack.id,
      targetLabel: pack.label,
    ),
    handled: true,
  );
}
