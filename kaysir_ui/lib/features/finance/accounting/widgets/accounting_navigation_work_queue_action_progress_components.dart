import 'package:flutter/material.dart';

import '../models/accounting_workspace_work_queue_activity_action_state.dart';

class AccountingNavigationWorkQueueActionProgressStrip extends StatelessWidget {
  const AccountingNavigationWorkQueueActionProgressStrip({
    required this.actionState,
    super.key,
  });

  final AccountingWorkspaceWorkQueueActivityActionState actionState;

  @override
  Widget build(BuildContext context) {
    if (!actionState.hasCapturedActions) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor =
        actionState.isComplete ? colorScheme.tertiary : colorScheme.primary;

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-action-progress-strip'),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          children: [
            Icon(
              actionState.isComplete
                  ? Icons.task_alt_rounded
                  : Icons.pending_actions_rounded,
              color: accentColor,
              size: 16,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                actionState.progressLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                actionState.nextActionLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
