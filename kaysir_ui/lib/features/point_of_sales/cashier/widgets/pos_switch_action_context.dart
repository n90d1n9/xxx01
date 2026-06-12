import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../experiences/pos_switch_action_result.dart';
import 'pos_switch_interaction.dart';

export '../experiences/pos_switch_action_result.dart';

typedef POSSwitchNoticePresenter =
    Future<void> Function(POSSwitchNoticeRequest request);

typedef POSSwitchConfirmationPresenter =
    Future<bool> Function(POSSwitchConfirmationRequest request);

typedef POSSwitchContinuationGuard = bool Function();

class POSSwitchNoticeRequest {
  final String title;
  final String message;
  final String confirmLabel;

  const POSSwitchNoticeRequest({
    required this.title,
    required this.message,
    required this.confirmLabel,
  });
}

class POSSwitchConfirmationRequest {
  final String title;
  final String message;
  final String confirmLabel;
  final Widget? details;
  final ValueListenable<bool>? canConfirmListenable;

  const POSSwitchConfirmationRequest({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.details,
    this.canConfirmListenable,
  });
}

class POSSwitchActionContext {
  final POSSwitchNoticePresenter showNotice;
  final POSSwitchConfirmationPresenter showConfirmation;
  final POSSwitchContinuationGuard canContinue;
  final POSSwitchActionResultListener? onActionResult;
  final VoidCallback? onActionHandled;

  const POSSwitchActionContext({
    required this.showNotice,
    required this.showConfirmation,
    this.canContinue = _alwaysContinue,
    this.onActionResult,
    this.onActionHandled,
  });

  factory POSSwitchActionContext.dialogs(
    BuildContext context, {
    POSSwitchActionResultListener? onActionResult,
    VoidCallback? onActionHandled,
  }) {
    return POSSwitchActionContext(
      showNotice:
          (request) => showPOSSwitchNoticeDialog(
            context: context,
            title: request.title,
            message: request.message,
            confirmLabel: request.confirmLabel,
          ),
      showConfirmation: (request) async {
        final confirmed = await showPOSSwitchConfirmationDialog(
          context: context,
          title: request.title,
          message: request.message,
          confirmLabel: request.confirmLabel,
          details: request.details,
          canConfirmListenable: request.canConfirmListenable,
        );

        return confirmed == true;
      },
      canContinue: () => context.mounted,
      onActionResult: onActionResult,
      onActionHandled: onActionHandled,
    );
  }

  POSSwitchActionResult complete(
    POSSwitchActionResult result, {
    bool handled = false,
  }) {
    onActionResult?.call(result);
    if (handled) markHandled();
    return result;
  }

  void markHandled() {
    onActionHandled?.call();
  }
}

bool _alwaysContinue() => true;
