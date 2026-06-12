import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import '../models/accounting_workspace_work_queue_evidence_request.dart';
import '../models/work_queue_evidence_link.dart';
import '../models/work_queue_evidence_readiness.dart';
import '../models/work_queue_reviewer_sign_off_guard.dart';

/// Reviewer sign-off card with evidence-gated approval controls.
class AccountingNavigationWorkQueueReviewerSignOffPanel
    extends StatelessWidget {
  const AccountingNavigationWorkQueueReviewerSignOffPanel({
    required this.state,
    this.approvalGuard,
    required this.onApproved,
    required this.onReturned,
    required this.onBlocked,
    super.key,
  });

  final AccountingWorkspaceWorkQueueReviewerSignOffState state;
  final AccountingWorkspaceWorkQueueReviewerSignOffGuard? approvalGuard;
  final VoidCallback onApproved;
  final VoidCallback onReturned;
  final VoidCallback onBlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _decisionAccentColor(colorScheme, state.decision);
    final canApprove = approvalGuard?.canApprove ?? true;

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-reviewer-sign-off-panel'),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user_rounded, color: accentColor, size: 17),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Reviewer sign-off',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _ReviewerDecisionBadge(state: state),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              state.detailLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            _ReviewerNextAction(label: state.nextActionLabel),
            if (approvalGuard case final approvalGuard?) ...[
              const SizedBox(height: 9),
              _ReviewerApprovalGuardBanner(guard: approvalGuard),
            ],
            const SizedBox(height: 9),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _ReviewerDecisionButton(
                  key: const ValueKey('accounting-work-queue-reviewer-approve'),
                  icon: Icons.task_alt_rounded,
                  label: 'Approve',
                  selected:
                      state.decision ==
                      AccountingWorkspaceWorkQueueReviewerDecision.approved,
                  onPressed: canApprove ? onApproved : null,
                ),
                _ReviewerDecisionButton(
                  key: const ValueKey('accounting-work-queue-reviewer-return'),
                  icon: Icons.keyboard_return_rounded,
                  label: 'Return',
                  selected:
                      state.decision ==
                      AccountingWorkspaceWorkQueueReviewerDecision.returned,
                  onPressed: onReturned,
                ),
                _ReviewerDecisionButton(
                  key: const ValueKey('accounting-work-queue-reviewer-block'),
                  icon: Icons.block_rounded,
                  label: 'Block',
                  selected:
                      state.decision ==
                      AccountingWorkspaceWorkQueueReviewerDecision.blocked,
                  onPressed: onBlocked,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Reviewer sign-off guarded')
Widget reviewerSignOffPanelPreview() {
  final readiness = AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
    queueId: 'auditor-evidence-gaps',
    request: AccountingWorkspaceWorkQueueEvidenceRequest(
      recipientLabel: 'Audit liaison',
      subject: 'Evidence request: Audit evidence gaps',
      responseDueLabel: 'Today before release',
      statusLabel: 'Overdue follow-up',
      agingLabel: '2 days overdue',
      followUpLabel: 'Daily until cleared',
      nextTrackingActionLabel: 'Send request today',
      requestBody: 'Evidence request body',
      requestedItems: const ['Release manifest support'],
    ),
    links: [
      AccountingWorkspaceWorkQueueEvidenceLink.create(
        id: 'link-1',
        queueId: 'auditor-evidence-gaps',
        label: 'Release manifest workpaper',
        reference: 'WP-REL-2026-06',
        addedByLabel: 'Auditor',
        addedAt: DateTime(2026, 6, 9, 10, 20),
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationWorkQueueReviewerSignOffPanel(
          state: const AccountingWorkspaceWorkQueueReviewerSignOffState(
            queueId: 'auditor-evidence-gaps',
          ),
          approvalGuard: AccountingWorkspaceWorkQueueReviewerSignOffGuard(
            readiness: readiness,
          ),
          onApproved: () {},
          onReturned: () {},
          onBlocked: () {},
        ),
      ),
    ),
  );
}

class _ReviewerApprovalGuardBanner extends StatelessWidget {
  const _ReviewerApprovalGuardBanner({required this.guard});

  final AccountingWorkspaceWorkQueueReviewerSignOffGuard guard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor =
        guard.canApprove ? colorScheme.tertiary : colorScheme.error;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              guard.canApprove
                  ? Icons.verified_rounded
                  : Icons.gpp_maybe_rounded,
              color: accentColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${guard.statusLabel} · ${guard.readiness.coverageLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    guard.detailLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewerNextAction extends StatelessWidget {
  const _ReviewerNextAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          children: [
            Icon(
              Icons.track_changes_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 15,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
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

class _ReviewerDecisionBadge extends StatelessWidget {
  const _ReviewerDecisionBadge({required this.state});

  final AccountingWorkspaceWorkQueueReviewerSignOffState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _decisionAccentColor(colorScheme, state.decision);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          state.statusLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ReviewerDecisionButton extends StatelessWidget {
  const _ReviewerDecisionButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
    );
  }
}

Color _decisionAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueReviewerDecision decision,
) {
  switch (decision) {
    case AccountingWorkspaceWorkQueueReviewerDecision.pending:
      return colorScheme.primary;
    case AccountingWorkspaceWorkQueueReviewerDecision.approved:
      return colorScheme.tertiary;
    case AccountingWorkspaceWorkQueueReviewerDecision.returned:
      return colorScheme.secondary;
    case AccountingWorkspaceWorkQueueReviewerDecision.blocked:
      return colorScheme.error;
  }
}
