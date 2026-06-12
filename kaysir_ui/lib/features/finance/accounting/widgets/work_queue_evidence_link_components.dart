import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/work_queue_evidence_link.dart';
import '../models/work_queue_evidence_review_state.dart';

/// Compact evidence reference panel for accounting work queue support.
class AccountingNavigationWorkQueueEvidenceLinksPanel extends StatelessWidget {
  const AccountingNavigationWorkQueueEvidenceLinksPanel({
    required this.links,
    required this.reviewStates,
    required this.onLinkAdded,
    required this.onReviewDecisionChanged,
    required this.onCopyLinks,
    super.key,
  });

  final List<AccountingWorkspaceWorkQueueEvidenceLink> links;
  final Map<String, AccountingWorkspaceWorkQueueEvidenceReviewState>
  reviewStates;
  final ValueChanged<AccountingWorkspaceWorkQueueEvidenceLinkDraft> onLinkAdded;
  final void Function(
    AccountingWorkspaceWorkQueueEvidenceLink link,
    AccountingWorkspaceWorkQueueEvidenceReviewDraft draft,
  )
  onReviewDecisionChanged;
  final VoidCallback onCopyLinks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasLinks = links.isNotEmpty;
    final visibleLinks = links.take(3).toList(growable: false);

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-evidence-links-panel'),
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
                  Icons.attachment_rounded,
                  color: colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Evidence links',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _EvidenceLinkCountBadge(count: links.length),
                const SizedBox(width: 3),
                IconButton(
                  key: const ValueKey(
                    'accounting-work-queue-evidence-links-copy',
                  ),
                  tooltip: 'Copy evidence links',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_rounded, size: 17),
                  onPressed: hasLinks ? onCopyLinks : null,
                ),
                IconButton(
                  key: const ValueKey(
                    'accounting-work-queue-evidence-links-add',
                  ),
                  tooltip: 'Add evidence link',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_link_rounded, size: 17),
                  onPressed: () => _showComposer(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!hasLinks)
              _EvidenceLinksEmptyState()
            else
              Column(
                children: [
                  for (final link in visibleLinks) ...[
                    _EvidenceLinkRow(
                      link: link,
                      reviewState: reviewStates[link.id],
                      onReviewDecisionChanged:
                          (draft) => onReviewDecisionChanged(link, draft),
                    ),
                    if (link != visibleLinks.last)
                      Divider(height: 14, color: colorScheme.outlineVariant),
                  ],
                  if (links.length > visibleLinks.length) ...[
                    const SizedBox(height: 6),
                    Text(
                      '+${links.length - visibleLinks.length} older links kept in audit copy',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showComposer(BuildContext context) async {
    final draft =
        await showDialog<AccountingWorkspaceWorkQueueEvidenceLinkDraft>(
          context: context,
          builder: (context) => const AccountingWorkQueueEvidenceLinkDialog(),
        );
    if (draft == null || !draft.canSubmit) return;

    onLinkAdded(draft);
  }
}

/// Dialog that captures an evidence reference without owning persistence.
class AccountingWorkQueueEvidenceLinkDialog extends StatefulWidget {
  const AccountingWorkQueueEvidenceLinkDialog({super.key});

  @override
  State<AccountingWorkQueueEvidenceLinkDialog> createState() =>
      _AccountingWorkQueueEvidenceLinkDialogState();
}

class _AccountingWorkQueueEvidenceLinkDialogState
    extends State<AccountingWorkQueueEvidenceLinkDialog> {
  final _labelController = TextEditingController();
  final _referenceController = TextEditingController();
  AccountingWorkspaceWorkQueueEvidenceLinkType _type =
      AccountingWorkspaceWorkQueueEvidenceLinkType.workpaper;

  @override
  void dispose() {
    _labelController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit =
        _labelController.text.trim().isNotEmpty &&
        _referenceController.text.trim().isNotEmpty;

    return AlertDialog(
      title: const Text('Add evidence link'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<
              AccountingWorkspaceWorkQueueEvidenceLinkType
            >(
              key: const ValueKey(
                'accounting-work-queue-evidence-link-type-field',
              ),
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Type',
                prefixIcon: Icon(Icons.label_rounded),
              ),
              items: [
                for (final type
                    in AccountingWorkspaceWorkQueueEvidenceLinkType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() => _type = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey(
                'accounting-work-queue-evidence-link-label-field',
              ),
              controller: _labelController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Label',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey(
                'accounting-work-queue-evidence-link-reference-field',
              ),
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Reference or URL',
                prefixIcon: Icon(Icons.link_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              'Link workpaper IDs, document URLs, approval references, or filing evidence used to clear the queue.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('accounting-work-queue-evidence-link-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const ValueKey('accounting-work-queue-evidence-link-save'),
          onPressed:
              canSubmit
                  ? () => Navigator.of(context).pop(
                    AccountingWorkspaceWorkQueueEvidenceLinkDraft(
                      label: _labelController.text,
                      reference: _referenceController.text,
                      type: _type,
                    ),
                  )
                  : null,
          icon: const Icon(Icons.save_rounded, size: 18),
          label: const Text('Save link'),
        ),
      ],
    );
  }
}

@Preview(name: 'Work queue evidence links')
Widget workQueueEvidenceLinksPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationWorkQueueEvidenceLinksPanel(
          links: [
            AccountingWorkspaceWorkQueueEvidenceLink.create(
              id: 'link-1',
              queueId: 'auditor-evidence-gaps',
              label: 'Release manifest workpaper',
              reference: 'WP-REL-2026-06',
              addedByLabel: 'Auditor',
              addedAt: DateTime(2026, 6, 9, 10, 20),
            ),
            AccountingWorkspaceWorkQueueEvidenceLink.create(
              id: 'link-2',
              queueId: 'auditor-evidence-gaps',
              label: 'Controller approval',
              reference: 'https://example.internal/approval/42',
              addedByLabel: 'Auditor',
              addedAt: DateTime(2026, 6, 9, 11),
              type: AccountingWorkspaceWorkQueueEvidenceLinkType.approval,
            ),
          ],
          reviewStates: {
            'link-1': AccountingWorkspaceWorkQueueEvidenceReviewState(
              queueId: 'auditor-evidence-gaps',
              linkId: 'link-1',
              decision:
                  AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
              reviewedByLabel: 'Auditor',
              reviewedAt: DateTime(2026, 6, 9, 12),
            ),
          },
          onLinkAdded: (_) {},
          onReviewDecisionChanged: (_, _) {},
          onCopyLinks: () {},
        ),
      ),
    ),
  );
}

class _EvidenceLinkCountBadge extends StatelessWidget {
  const _EvidenceLinkCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            count == 0
                ? colorScheme.surfaceContainerLow
                : colorScheme.tertiaryContainer.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          count == 1 ? '1 link' : '$count links',
          style: theme.textTheme.labelSmall?.copyWith(
            color:
                count == 0
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onTertiaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _EvidenceLinksEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: colorScheme.onSurfaceVariant,
          size: 16,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'No evidence links attached yet.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EvidenceLinkRow extends StatelessWidget {
  const _EvidenceLinkRow({
    required this.link,
    required this.reviewState,
    required this.onReviewDecisionChanged,
  });

  final AccountingWorkspaceWorkQueueEvidenceLink link;
  final AccountingWorkspaceWorkQueueEvidenceReviewState? reviewState;
  final ValueChanged<AccountingWorkspaceWorkQueueEvidenceReviewDraft>
  onReviewDecisionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _evidenceLinkAccentColor(colorScheme, link.type);
    final effectiveReviewState =
        reviewState ??
        AccountingWorkspaceWorkQueueEvidenceReviewState(
          queueId: link.queueId,
          linkId: link.id,
        );

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
              _evidenceLinkIcon(link.type),
              color: accentColor,
              size: 15,
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
                  _EvidenceLinkTypeBadge(link: link),
                  _EvidenceReviewStatusBadge(state: effectiveReviewState),
                  _EvidenceLinkMeta(
                    icon: Icons.person_rounded,
                    label: link.addedByDisplayLabel,
                  ),
                  _EvidenceLinkMeta(
                    icon: Icons.schedule_rounded,
                    label: link.timeLabel,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                link.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                link.reference,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (effectiveReviewState.hasReviewTrail) ...[
                const SizedBox(height: 6),
                _EvidenceReviewTrail(state: effectiveReviewState),
              ],
              if (effectiveReviewState.hasReviewNote) ...[
                const SizedBox(height: 6),
                _EvidenceReviewMemo(state: effectiveReviewState),
              ],
              const SizedBox(height: 7),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _EvidenceReviewActionButton(
                    key: ValueKey(
                      'accounting-work-queue-evidence-link-accept-${link.id}',
                    ),
                    icon: Icons.check_circle_rounded,
                    label: 'Accept',
                    selected: effectiveReviewState.isAccepted,
                    onPressed:
                        effectiveReviewState.isAccepted
                            ? null
                            : () => onReviewDecisionChanged(
                              const AccountingWorkspaceWorkQueueEvidenceReviewDraft(
                                decision:
                                    AccountingWorkspaceWorkQueueEvidenceReviewDecision
                                        .accepted,
                              ),
                            ),
                  ),
                  _EvidenceReviewActionButton(
                    key: ValueKey(
                      'accounting-work-queue-evidence-link-rework-${link.id}',
                    ),
                    icon: Icons.assignment_return_rounded,
                    label: 'Rework',
                    selected: effectiveReviewState.needsRework,
                    onPressed:
                        () => _requestRework(context, effectiveReviewState),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _requestRework(
    BuildContext context,
    AccountingWorkspaceWorkQueueEvidenceReviewState state,
  ) async {
    final reviewNote = await showDialog<String>(
      context: context,
      builder:
          (context) => AccountingWorkQueueEvidenceReviewDialog(
            initialReviewNote: state.reviewNote,
          ),
    );
    if (reviewNote == null) return;

    final draft = AccountingWorkspaceWorkQueueEvidenceReviewDraft(
      decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework,
      reviewNote: reviewNote,
    );
    if (!draft.canSubmit) return;

    onReviewDecisionChanged(draft);
  }
}

/// Dialog that captures reviewer memo text for returned evidence support.
class AccountingWorkQueueEvidenceReviewDialog extends StatefulWidget {
  const AccountingWorkQueueEvidenceReviewDialog({
    this.initialReviewNote = '',
    super.key,
  });

  final String initialReviewNote;

  @override
  State<AccountingWorkQueueEvidenceReviewDialog> createState() =>
      _AccountingWorkQueueEvidenceReviewDialogState();
}

class _AccountingWorkQueueEvidenceReviewDialogState
    extends State<AccountingWorkQueueEvidenceReviewDialog> {
  late final TextEditingController _reviewNoteController;

  @override
  void initState() {
    super.initState();
    _reviewNoteController = TextEditingController(
      text: widget.initialReviewNote,
    );
  }

  @override
  void dispose() {
    _reviewNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _reviewNoteController.text.trim().isNotEmpty;

    return AlertDialog(
      title: const Text('Return evidence'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: TextField(
          key: const ValueKey(
            'accounting-work-queue-evidence-review-note-field',
          ),
          controller: _reviewNoteController,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Reviewer memo',
            prefixIcon: Icon(Icons.rate_review_rounded),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('accounting-work-queue-evidence-review-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const ValueKey('accounting-work-queue-evidence-review-save'),
          onPressed:
              canSubmit
                  ? () => Navigator.of(
                    context,
                  ).pop(_reviewNoteController.text.trim())
                  : null,
          icon: const Icon(Icons.assignment_return_rounded, size: 18),
          label: const Text('Return'),
        ),
      ],
    );
  }
}

@Preview(name: 'Work queue evidence review dialog')
Widget workQueueEvidenceReviewDialogPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: AccountingWorkQueueEvidenceReviewDialog(
          initialReviewNote:
              'Approval reference is missing controller sign-off.',
        ),
      ),
    ),
  );
}

class _EvidenceReviewStatusBadge extends StatelessWidget {
  const _EvidenceReviewStatusBadge({required this.state});

  final AccountingWorkspaceWorkQueueEvidenceReviewState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _reviewAccentColor(colorScheme, state.decision);

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

class _EvidenceReviewMemo extends StatelessWidget {
  const _EvidenceReviewMemo({required this.state});

  final AccountingWorkspaceWorkQueueEvidenceReviewState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.sticky_note_2_rounded,
          color: colorScheme.onSurfaceVariant,
          size: 14,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            state.normalizedReviewNote,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EvidenceReviewTrail extends StatelessWidget {
  const _EvidenceReviewTrail({required this.state});

  final AccountingWorkspaceWorkQueueEvidenceReviewState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.history_rounded, color: colorScheme.primary, size: 13),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            state.reviewTrailLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _EvidenceReviewActionButton extends StatelessWidget {
  const _EvidenceReviewActionButton({
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
        icon: Icon(icon, size: 16),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _EvidenceLinkTypeBadge extends StatelessWidget {
  const _EvidenceLinkTypeBadge({required this.link});

  final AccountingWorkspaceWorkQueueEvidenceLink link;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _evidenceLinkAccentColor(colorScheme, link.type);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          link.typeLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _EvidenceLinkMeta extends StatelessWidget {
  const _EvidenceLinkMeta({required this.icon, required this.label});

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

IconData _evidenceLinkIcon(AccountingWorkspaceWorkQueueEvidenceLinkType type) {
  switch (type) {
    case AccountingWorkspaceWorkQueueEvidenceLinkType.workpaper:
      return Icons.description_rounded;
    case AccountingWorkspaceWorkQueueEvidenceLinkType.sourceDocument:
      return Icons.article_rounded;
    case AccountingWorkspaceWorkQueueEvidenceLinkType.approval:
      return Icons.verified_rounded;
    case AccountingWorkspaceWorkQueueEvidenceLinkType.bankStatement:
      return Icons.account_balance_rounded;
    case AccountingWorkspaceWorkQueueEvidenceLinkType.taxFiling:
      return Icons.receipt_long_rounded;
    case AccountingWorkspaceWorkQueueEvidenceLinkType.other:
      return Icons.attachment_rounded;
  }
}

Color _evidenceLinkAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueEvidenceLinkType type,
) {
  switch (type) {
    case AccountingWorkspaceWorkQueueEvidenceLinkType.workpaper:
      return colorScheme.primary;
    case AccountingWorkspaceWorkQueueEvidenceLinkType.sourceDocument:
      return colorScheme.secondary;
    case AccountingWorkspaceWorkQueueEvidenceLinkType.approval:
      return colorScheme.tertiary;
    case AccountingWorkspaceWorkQueueEvidenceLinkType.bankStatement:
      return colorScheme.onSurfaceVariant;
    case AccountingWorkspaceWorkQueueEvidenceLinkType.taxFiling:
      return colorScheme.error;
    case AccountingWorkspaceWorkQueueEvidenceLinkType.other:
      return colorScheme.outline;
  }
}

Color _reviewAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueEvidenceReviewDecision decision,
) {
  switch (decision) {
    case AccountingWorkspaceWorkQueueEvidenceReviewDecision.pending:
      return colorScheme.secondary;
    case AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted:
      return colorScheme.tertiary;
    case AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework:
      return colorScheme.error;
  }
}
