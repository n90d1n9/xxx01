import '../../order/models/order.dart';
import '../experiences/pos_mode_switch_availability.dart';
import '../experiences/pos_mode_switch_controller.dart';
import 'pos_switch_action_context.dart';

Future<POSSwitchActionResult> handlePOSModeSwitchAction({
  required POSSwitchActionContext actionContext,
  required POSModeSwitchController switchController,
  required POSModeSwitchOption option,
  required Order? currentOrder,
}) async {
  const kind = POSSwitchActionKind.mode;
  final targetId = option.id;
  final targetLabel = option.experience.label;
  final availability = POSModeSwitchAvailability.evaluate(
    option: option,
    order: currentOrder,
  );
  final blockedMode = availability.blockedModeDecision;
  if (blockedMode != null) {
    await actionContext.showNotice(
      POSSwitchNoticeRequest(
        title: blockedMode.title,
        message: blockedMode.message,
        confirmLabel: 'OK',
      ),
    );
    return actionContext.complete(
      POSSwitchActionResult.blocked(
        kind: kind,
        targetId: targetId,
        targetLabel: targetLabel,
        reason: blockedMode.title,
      ),
    );
  }

  final modeConfirmation = availability.modeConfirmation;
  if (modeConfirmation != null) {
    final confirmed = await actionContext.showConfirmation(
      POSSwitchConfirmationRequest(
        title: modeConfirmation.title,
        message: modeConfirmation.message,
        confirmLabel: 'Switch anyway',
      ),
    );
    if (!confirmed) {
      return actionContext.complete(
        POSSwitchActionResult.cancelled(
          kind: kind,
          targetId: targetId,
          targetLabel: targetLabel,
          reason: modeConfirmation.title,
        ),
      );
    }
    if (!actionContext.canContinue()) {
      return actionContext.complete(
        POSSwitchActionResult.cancelled(
          kind: kind,
          targetId: targetId,
          targetLabel: targetLabel,
          reason: 'Switch context unavailable',
        ),
      );
    }
  }

  final blockedOrder = availability.blockedOrderDecision;
  if (blockedOrder != null) {
    await actionContext.showNotice(
      POSSwitchNoticeRequest(
        title: blockedOrder.title,
        message: blockedOrder.message,
        confirmLabel: blockedOrder.confirmLabel,
      ),
    );
    return actionContext.complete(
      POSSwitchActionResult.blocked(
        kind: kind,
        targetId: targetId,
        targetLabel: targetLabel,
        reason: blockedOrder.title,
      ),
    );
  }

  final orderConfirmation = availability.orderConfirmation;
  if (orderConfirmation != null) {
    final confirmed = await actionContext.showConfirmation(
      POSSwitchConfirmationRequest(
        title: orderConfirmation.title,
        message: orderConfirmation.message,
        confirmLabel: orderConfirmation.confirmLabel,
      ),
    );
    if (!confirmed) {
      return actionContext.complete(
        POSSwitchActionResult.cancelled(
          kind: kind,
          targetId: targetId,
          targetLabel: targetLabel,
          reason: orderConfirmation.title,
        ),
      );
    }
    if (!actionContext.canContinue()) {
      return actionContext.complete(
        POSSwitchActionResult.cancelled(
          kind: kind,
          targetId: targetId,
          targetLabel: targetLabel,
          reason: 'Switch context unavailable',
        ),
      );
    }
  }

  switchController.apply(option);
  return actionContext.complete(
    POSSwitchActionResult.applied(
      kind: kind,
      targetId: targetId,
      targetLabel: targetLabel,
    ),
    handled: true,
  );
}
