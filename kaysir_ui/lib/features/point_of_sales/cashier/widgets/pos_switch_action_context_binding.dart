import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../experiences/pos_switch_action_history.dart';
import 'pos_switch_action_feedback.dart';
import 'pos_switch_action_context.dart';

POSSwitchActionContext buildPOSSwitchActionContext({
  required BuildContext context,
  required WidgetRef ref,
  bool showFeedback = true,
  VoidCallback? onActionHandled,
}) {
  return POSSwitchActionContext.dialogs(
    context,
    onActionResult: _switchActionResultListener(
      context: context,
      ref: ref,
      showFeedback: showFeedback,
    ),
    onActionHandled: onActionHandled,
  );
}

POSSwitchActionResultListener _switchActionResultListener({
  required BuildContext context,
  required WidgetRef ref,
  required bool showFeedback,
}) {
  return (result) {
    ref.read(posSwitchActionHistoryProvider.notifier).record(result);
    if (showFeedback) showPOSSwitchActionFeedback(context, result);
  };
}
