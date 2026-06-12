import 'package:flutter/widgets.dart';

import '../experiences/pos_commerce_channel_controller.dart';
import '../experiences/pos_commerce_channel_switch_plan.dart';
import '../experiences/pos_commerce_channel_switch_preflight.dart';
import 'pos_commerce_channel_switch_confirmation_details.dart';
import 'pos_switch_action_context.dart';

Future<POSSwitchActionResult> handlePOSCommerceChannelSwitchAction({
  required POSSwitchActionContext actionContext,
  required POSCommerceChannelSwitchController switchController,
  required POSCommerceChannelSwitchPlan plan,
}) async {
  const kind = POSSwitchActionKind.commerceChannel;
  final targetId = plan.targetChannel.id;
  final targetLabel = plan.targetChannel.label;

  if (plan.needsConfirmation) {
    final canConfirmNotifier = _canConfirmNotifier(plan);
    bool confirmed;
    try {
      confirmed = await actionContext.showConfirmation(
        POSSwitchConfirmationRequest(
          title: plan.title,
          message: plan.message,
          confirmLabel: plan.confirmLabel,
          details: _confirmationDetails(
            plan,
            canConfirmNotifier: canConfirmNotifier,
          ),
          canConfirmListenable: canConfirmNotifier,
        ),
      );
    } finally {
      canConfirmNotifier?.dispose();
    }

    if (!confirmed) {
      return actionContext.complete(
        POSSwitchActionResult.cancelled(
          kind: kind,
          targetId: targetId,
          targetLabel: targetLabel,
          reason: plan.title,
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

  switchController.applyPlan(plan);
  return actionContext.complete(
    POSSwitchActionResult.applied(
      kind: kind,
      targetId: targetId,
      targetLabel: targetLabel,
    ),
    handled: true,
  );
}

ValueNotifier<bool>? _canConfirmNotifier(POSCommerceChannelSwitchPlan plan) {
  final preflight = POSCommerceChannelSwitchPreflight.fromPlan(plan);
  if (!preflight.hasRequirements) return null;

  return ValueNotifier<bool>(preflight.canConfirm);
}

Widget? _confirmationDetails(
  POSCommerceChannelSwitchPlan plan, {
  ValueNotifier<bool>? canConfirmNotifier,
}) {
  if (!POSCommerceChannelSwitchConfirmationDetails.hasContent(plan)) {
    return null;
  }

  return POSCommerceChannelSwitchConfirmationDetails(
    plan: plan,
    canConfirmNotifier: canConfirmNotifier,
  );
}
