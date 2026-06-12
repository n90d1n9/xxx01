import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_action_execution.dart';

/// Compact feedback row for an executed omni-channel activity action.
class OmniChannelActivityActionFeedbackContent extends StatelessWidget {
  final OmniChannelActivityActionExecutionResult result;

  const OmniChannelActivityActionFeedbackContent({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = _foregroundColor(colorScheme, result.outcome);

    return Row(
      children: [
        Icon(_iconFor(result.outcome), color: foregroundColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            result.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Omni-channel activity action feedback')
Widget omniChannelActivityActionFeedbackContentPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black87),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: OmniChannelActivityActionFeedbackContent(
                result: OmniChannelActivityActionExecutionResult.completed(
                  action: OmniChannelActivityAction(
                    label: 'Open orders',
                    location: '/commerce/orders',
                    tooltip: 'Open orders',
                  ),
                  message: 'Order workspace opened for ECOM-2026-017.',
                  location: '/commerce/orders',
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void showOmniChannelActivityActionFeedback(
  BuildContext context,
  OmniChannelActivityActionExecutionResult result,
) {
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final colorScheme = Theme.of(context).colorScheme;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: OmniChannelActivityActionFeedbackContent(result: result),
        backgroundColor: _backgroundColor(colorScheme, result.outcome),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
        showCloseIcon:
            result.outcome != OmniChannelActivityActionOutcome.completed,
        closeIconColor: _foregroundColor(colorScheme, result.outcome),
      ),
    );
}

IconData _iconFor(OmniChannelActivityActionOutcome outcome) {
  switch (outcome) {
    case OmniChannelActivityActionOutcome.completed:
      return Icons.check_circle_outline;
    case OmniChannelActivityActionOutcome.blocked:
      return Icons.block_outlined;
    case OmniChannelActivityActionOutcome.failed:
      return Icons.error_outline;
  }
}

Color _backgroundColor(
  ColorScheme colorScheme,
  OmniChannelActivityActionOutcome outcome,
) {
  switch (outcome) {
    case OmniChannelActivityActionOutcome.completed:
      return colorScheme.primary;
    case OmniChannelActivityActionOutcome.blocked:
      return colorScheme.tertiary;
    case OmniChannelActivityActionOutcome.failed:
      return colorScheme.error;
  }
}

Color _foregroundColor(
  ColorScheme colorScheme,
  OmniChannelActivityActionOutcome outcome,
) {
  switch (outcome) {
    case OmniChannelActivityActionOutcome.completed:
      return colorScheme.onPrimary;
    case OmniChannelActivityActionOutcome.blocked:
      return colorScheme.onTertiary;
    case OmniChannelActivityActionOutcome.failed:
      return colorScheme.onError;
  }
}
