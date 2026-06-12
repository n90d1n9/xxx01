import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/accounting_workspace_work_queue_activity.dart';
import '../models/accounting_workspace_work_queue_activity_action_state.dart';
import '../models/accounting_workspace_work_queue_evidence_request.dart';
import '../models/work_queue_evidence_link.dart';
import '../models/work_queue_evidence_readiness.dart';
import '../models/work_queue_evidence_review_state.dart';
import '../models/work_queue_note.dart';
import 'work_queue_evidence_link_components.dart';
import 'work_queue_evidence_readiness_components.dart';
import 'work_queue_note_components.dart';

/// Activity timeline with action capture, evidence references, and notes.
class AccountingNavigationWorkQueueActivityPanel extends StatelessWidget {
  const AccountingNavigationWorkQueueActivityPanel({
    required this.trail,
    required this.evidenceRequest,
    required this.actionState,
    required this.evidenceLinks,
    required this.evidenceReviewStates,
    required this.notes,
    required this.onOwnerAcknowledged,
    required this.onEvidenceReceived,
    required this.onEscalationLogged,
    required this.onEvidenceLinkAdded,
    required this.onEvidenceLinkReviewDecisionChanged,
    required this.onCopyEvidenceLinks,
    required this.onNoteAdded,
    required this.onCopyNotes,
    required this.onCopyAuditBrief,
    super.key,
  });

  final AccountingWorkspaceWorkQueueActivityTrail trail;
  final AccountingWorkspaceWorkQueueEvidenceRequest evidenceRequest;
  final AccountingWorkspaceWorkQueueActivityActionState actionState;
  final List<AccountingWorkspaceWorkQueueEvidenceLink> evidenceLinks;
  final Map<String, AccountingWorkspaceWorkQueueEvidenceReviewState>
  evidenceReviewStates;
  final List<AccountingWorkspaceWorkQueueNote> notes;
  final VoidCallback onOwnerAcknowledged;
  final VoidCallback onEvidenceReceived;
  final VoidCallback onEscalationLogged;
  final ValueChanged<AccountingWorkspaceWorkQueueEvidenceLinkDraft>
  onEvidenceLinkAdded;
  final void Function(
    AccountingWorkspaceWorkQueueEvidenceLink link,
    AccountingWorkspaceWorkQueueEvidenceReviewDraft draft,
  )
  onEvidenceLinkReviewDecisionChanged;
  final VoidCallback onCopyEvidenceLinks;
  final ValueChanged<AccountingWorkspaceWorkQueueNoteDraft> onNoteAdded;
  final VoidCallback onCopyNotes;
  final VoidCallback onCopyAuditBrief;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final evidenceReadiness =
        AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
          queueId: trail.queueId,
          request: evidenceRequest,
          links: evidenceLinks,
          reviewStates: evidenceReviewStates.values,
        );

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-activity-panel'),
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
                Icon(
                  Icons.manage_history_rounded,
                  color: colorScheme.primary,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  'Activity trail',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  trail.summaryLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            _ActivityNextAction(label: trail.nextActionLabel),
            const SizedBox(height: 10),
            _ActivityActionCapture(
              state: actionState,
              onOwnerAcknowledged: onOwnerAcknowledged,
              onEvidenceReceived: onEvidenceReceived,
              onEscalationLogged: onEscalationLogged,
              onCopyAuditBrief: onCopyAuditBrief,
            ),
            const SizedBox(height: 10),
            AccountingNavigationWorkQueueEvidenceReadinessPanel(
              readiness: evidenceReadiness,
            ),
            const SizedBox(height: 10),
            AccountingNavigationWorkQueueEvidenceLinksPanel(
              links: evidenceLinks,
              reviewStates: evidenceReviewStates,
              onLinkAdded: onEvidenceLinkAdded,
              onReviewDecisionChanged: onEvidenceLinkReviewDecisionChanged,
              onCopyLinks: onCopyEvidenceLinks,
            ),
            const SizedBox(height: 10),
            AccountingNavigationWorkQueueNotesPanel(
              notes: notes,
              onNoteAdded: onNoteAdded,
              onCopyNotes: onCopyNotes,
            ),
            const SizedBox(height: 10),
            for (final entry in trail.entries) ...[
              _ActivityEntryRow(entry: entry),
              if (entry != trail.entries.last)
                Divider(height: 14, color: colorScheme.outlineVariant),
            ],
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Work queue activity trail')
Widget workQueueActivityPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AccountingNavigationWorkQueueActivityPanel(
            trail: AccountingWorkspaceWorkQueueActivityTrail(
              queueId: 'auditor-evidence-gaps',
              queueTitle: 'Audit evidence gaps',
              ownerLabel: 'Audit liaison',
              dueLabel: '2 days overdue',
              summaryLabel: '0 ready / 1 waiting / 3 blocked',
              nextActionLabel: 'Send request and record owner response today',
              entries: const [
                AccountingWorkspaceWorkQueueActivityEntry(
                  id: 'evidence-request',
                  type: AccountingWorkspaceWorkQueueActivityType.evidence,
                  title: 'Evidence request issued',
                  detail: 'Release manifest support requested from owner.',
                  actorLabel: 'Audit liaison',
                  timeLabel: 'Today',
                  statusLabel: 'Overdue follow-up',
                ),
              ],
            ),
            evidenceRequest: AccountingWorkspaceWorkQueueEvidenceRequest(
              recipientLabel: 'Audit liaison',
              subject: 'Evidence request: Audit evidence gaps',
              responseDueLabel: 'Today before release',
              statusLabel: 'Overdue follow-up',
              agingLabel: '2 days overdue',
              followUpLabel: 'Daily until cleared',
              nextTrackingActionLabel: 'Send request today',
              requestBody: 'Evidence request body',
              requestedItems: const [
                'Release manifest support',
                'Signed controller approval',
              ],
            ),
            actionState: const AccountingWorkspaceWorkQueueActivityActionState(
              queueId: 'auditor-evidence-gaps',
              ownerAcknowledged: true,
            ),
            evidenceLinks: [
              AccountingWorkspaceWorkQueueEvidenceLink.create(
                id: 'link-1',
                queueId: 'auditor-evidence-gaps',
                label: 'Release manifest workpaper',
                reference: 'WP-REL-2026-06',
                addedByLabel: 'Auditor',
                addedAt: DateTime(2026, 6, 9, 10, 20),
              ),
            ],
            evidenceReviewStates: {
              'link-1': const AccountingWorkspaceWorkQueueEvidenceReviewState(
                queueId: 'auditor-evidence-gaps',
                linkId: 'link-1',
                decision:
                    AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
              ),
            },
            notes: [
              AccountingWorkspaceWorkQueueNote.create(
                id: 'note-1',
                queueId: 'auditor-evidence-gaps',
                authorLabel: 'Auditor',
                body: 'Controller confirmed owner handoff before close lock.',
                createdAt: DateTime(2026, 6, 9, 10, 15),
                type: AccountingWorkspaceWorkQueueNoteType.handoff,
              ),
            ],
            onOwnerAcknowledged: () {},
            onEvidenceReceived: () {},
            onEscalationLogged: () {},
            onEvidenceLinkAdded: (_) {},
            onEvidenceLinkReviewDecisionChanged: (_, _) {},
            onCopyEvidenceLinks: () {},
            onNoteAdded: (_) {},
            onCopyNotes: () {},
            onCopyAuditBrief: () {},
          ),
        ),
      ),
    ),
  );
}

class _ActivityActionCapture extends StatelessWidget {
  const _ActivityActionCapture({
    required this.state,
    required this.onOwnerAcknowledged,
    required this.onEvidenceReceived,
    required this.onEscalationLogged,
    required this.onCopyAuditBrief,
  });

  final AccountingWorkspaceWorkQueueActivityActionState state;
  final VoidCallback onOwnerAcknowledged;
  final VoidCallback onEvidenceReceived;
  final VoidCallback onEscalationLogged;
  final VoidCallback onCopyAuditBrief;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fact_check_rounded,
                  color: colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    state.summaryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 190),
                  child: Text(
                    state.nextActionLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  key: const ValueKey(
                    'accounting-work-queue-activity-copy-brief',
                  ),
                  tooltip: 'Copy activity audit brief',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_rounded, size: 17),
                  onPressed: onCopyAuditBrief,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _ActivityActionButton(
                  key: const ValueKey(
                    'accounting-work-queue-activity-acknowledge-owner',
                  ),
                  icon:
                      state.ownerAcknowledged
                          ? Icons.check_circle_rounded
                          : Icons.person_add_alt_1_rounded,
                  label: state.ownerActionLabel,
                  isComplete: state.ownerAcknowledged,
                  onPressed:
                      state.ownerAcknowledged ? null : onOwnerAcknowledged,
                ),
                _ActivityActionButton(
                  key: const ValueKey(
                    'accounting-work-queue-activity-evidence-received',
                  ),
                  icon:
                      state.evidenceReceived
                          ? Icons.check_circle_rounded
                          : Icons.inventory_2_rounded,
                  label: state.evidenceActionLabel,
                  isComplete: state.evidenceReceived,
                  onPressed: state.evidenceReceived ? null : onEvidenceReceived,
                ),
                _ActivityActionButton(
                  key: const ValueKey(
                    'accounting-work-queue-activity-log-escalation',
                  ),
                  icon:
                      state.escalationLogged
                          ? Icons.check_circle_rounded
                          : Icons.priority_high_rounded,
                  label: state.escalationActionLabel,
                  isComplete: state.escalationLogged,
                  onPressed: state.escalationLogged ? null : onEscalationLogged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityActionButton extends StatelessWidget {
  const _ActivityActionButton({
    required this.icon,
    required this.label,
    required this.isComplete,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isComplete;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
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

class _ActivityNextAction extends StatelessWidget {
  const _ActivityNextAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                style: theme.textTheme.bodySmall?.copyWith(
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

class _ActivityEntryRow extends StatelessWidget {
  const _ActivityEntryRow({required this.entry});

  final AccountingWorkspaceWorkQueueActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _activityAccentColor(colorScheme, entry.type);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              _activityIcon(entry.type),
              color: accentColor,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 7,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    entry.title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  _ActivityStatusBadge(entry: entry),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                entry.detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _ActivityMeta(
                    icon: Icons.person_rounded,
                    label: entry.actorLabel,
                  ),
                  _ActivityMeta(
                    icon: Icons.schedule_rounded,
                    label: entry.timeLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityStatusBadge extends StatelessWidget {
  const _ActivityStatusBadge({required this.entry});

  final AccountingWorkspaceWorkQueueActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _activityAccentColor(colorScheme, entry.type);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            entry.statusLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityMeta extends StatelessWidget {
  const _ActivityMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: colorScheme.primary, size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

IconData _activityIcon(AccountingWorkspaceWorkQueueActivityType type) {
  switch (type) {
    case AccountingWorkspaceWorkQueueActivityType.status:
      return Icons.flag_rounded;
    case AccountingWorkspaceWorkQueueActivityType.evidence:
      return Icons.outbox_outlined;
    case AccountingWorkspaceWorkQueueActivityType.approval:
      return Icons.verified_user_rounded;
    case AccountingWorkspaceWorkQueueActivityType.escalation:
      return Icons.priority_high_rounded;
    case AccountingWorkspaceWorkQueueActivityType.retention:
      return Icons.inventory_2_rounded;
  }
}

Color _activityAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueActivityType type,
) {
  switch (type) {
    case AccountingWorkspaceWorkQueueActivityType.status:
      return colorScheme.primary;
    case AccountingWorkspaceWorkQueueActivityType.evidence:
      return colorScheme.tertiary;
    case AccountingWorkspaceWorkQueueActivityType.approval:
      return colorScheme.secondary;
    case AccountingWorkspaceWorkQueueActivityType.escalation:
      return colorScheme.error;
    case AccountingWorkspaceWorkQueueActivityType.retention:
      return colorScheme.onSurfaceVariant;
  }
}
