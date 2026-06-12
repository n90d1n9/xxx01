import 'package:flutter/material.dart';

import '../experiences/pos_switch_action_result.dart';
import 'pos_switch_action_presentation.dart';

class POSSwitchActionFeedback {
  final String message;
  final IconData icon;
  final Duration duration;
  final SnackBarBehavior behavior;
  final bool showCloseIcon;

  const POSSwitchActionFeedback({
    required this.message,
    required this.icon,
    this.duration = const Duration(milliseconds: 1400),
    this.behavior = SnackBarBehavior.floating,
    this.showCloseIcon = false,
  });

  factory POSSwitchActionFeedback.fromResult(POSSwitchActionResult result) {
    return POSSwitchActionFeedback.fromPresentation(
      POSSwitchActionPresentation.fromResult(result),
    );
  }

  factory POSSwitchActionFeedback.fromPresentation(
    POSSwitchActionPresentation presentation,
  ) {
    return POSSwitchActionFeedback(
      message: presentation.feedbackMessage,
      icon: presentation.outcomeIcon,
      showCloseIcon: presentation.showCloseIcon,
    );
  }
}

void showPOSSwitchActionFeedback(
  BuildContext context,
  POSSwitchActionResult result,
) {
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final presentation = POSSwitchActionPresentation.fromResult(result);
  final feedback = POSSwitchActionFeedback.fromPresentation(presentation);
  final colors = presentation.snackBarPalette(Theme.of(context).colorScheme);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(feedback.icon, color: colors.foreground, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                feedback.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.background,
        behavior: feedback.behavior,
        duration: feedback.duration,
        closeIconColor: colors.foreground,
        showCloseIcon: feedback.showCloseIcon,
      ),
    );
}
