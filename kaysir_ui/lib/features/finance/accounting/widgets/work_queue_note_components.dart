import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/work_queue_note.dart';

/// Compact execution note panel for accounting work queue activity review.
class AccountingNavigationWorkQueueNotesPanel extends StatelessWidget {
  const AccountingNavigationWorkQueueNotesPanel({
    required this.notes,
    required this.onNoteAdded,
    required this.onCopyNotes,
    super.key,
  });

  final List<AccountingWorkspaceWorkQueueNote> notes;
  final ValueChanged<AccountingWorkspaceWorkQueueNoteDraft> onNoteAdded;
  final VoidCallback onCopyNotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasNotes = notes.isNotEmpty;

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-notes-panel'),
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
                  Icons.sticky_note_2_rounded,
                  color: colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Execution notes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _NoteCountBadge(count: notes.length),
                const SizedBox(width: 3),
                IconButton(
                  key: const ValueKey('accounting-work-queue-notes-copy'),
                  tooltip: 'Copy execution notes',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_rounded, size: 17),
                  onPressed: hasNotes ? onCopyNotes : null,
                ),
                IconButton(
                  key: const ValueKey('accounting-work-queue-notes-add'),
                  tooltip: 'Add execution note',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_comment_rounded, size: 17),
                  onPressed: () => _showComposer(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!hasNotes)
              _NotesEmptyState()
            else
              Column(
                children: [
                  for (final note in notes.take(3)) ...[
                    _NoteRow(note: note),
                    if (note != notes.take(3).last)
                      Divider(height: 14, color: colorScheme.outlineVariant),
                  ],
                  if (notes.length > 3) ...[
                    const SizedBox(height: 6),
                    Text(
                      '+${notes.length - 3} older notes kept in audit copy',
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
    final draft = await showDialog<AccountingWorkspaceWorkQueueNoteDraft>(
      context: context,
      builder: (context) => const AccountingWorkQueueNoteComposerDialog(),
    );
    if (draft == null || !draft.canSubmit) return;

    onNoteAdded(draft);
  }
}

/// Dialog that captures a typed execution note without owning persistence.
class AccountingWorkQueueNoteComposerDialog extends StatefulWidget {
  const AccountingWorkQueueNoteComposerDialog({super.key});

  @override
  State<AccountingWorkQueueNoteComposerDialog> createState() =>
      _AccountingWorkQueueNoteComposerDialogState();
}

class _AccountingWorkQueueNoteComposerDialogState
    extends State<AccountingWorkQueueNoteComposerDialog> {
  final _controller = TextEditingController();
  AccountingWorkspaceWorkQueueNoteType _type =
      AccountingWorkspaceWorkQueueNoteType.note;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add execution note'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<AccountingWorkspaceWorkQueueNoteType>(
              key: const ValueKey('accounting-work-queue-note-type-field'),
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Type',
                prefixIcon: Icon(Icons.label_rounded),
              ),
              items: [
                for (final type in AccountingWorkspaceWorkQueueNoteType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() => _type = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('accounting-work-queue-note-body-field'),
              controller: _controller,
              autofocus: true,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Note',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture the owner handoff, evidence status, risk, or decision needed for the audit trail.',
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
          key: const ValueKey('accounting-work-queue-note-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const ValueKey('accounting-work-queue-note-save'),
          onPressed:
              _controller.text.trim().isEmpty
                  ? null
                  : () => Navigator.of(context).pop(
                    AccountingWorkspaceWorkQueueNoteDraft(
                      body: _controller.text,
                      type: _type,
                    ),
                  ),
          icon: const Icon(Icons.save_rounded, size: 18),
          label: const Text('Save note'),
        ),
      ],
    );
  }
}

@Preview(name: 'Work queue execution notes')
Widget workQueueNotesPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationWorkQueueNotesPanel(
          notes: [
            AccountingWorkspaceWorkQueueNote.create(
              id: 'note-1',
              queueId: 'auditor-evidence-gaps',
              authorLabel: 'Auditor',
              body: 'Controller confirmed the disclosure evidence owner.',
              createdAt: DateTime(2026, 6, 9, 10, 15),
              type: AccountingWorkspaceWorkQueueNoteType.handoff,
            ),
            AccountingWorkspaceWorkQueueNote.create(
              id: 'note-2',
              queueId: 'auditor-evidence-gaps',
              authorLabel: 'Auditor',
              body: 'Release manifest support is still missing signatures.',
              createdAt: DateTime(2026, 6, 9, 11),
              type: AccountingWorkspaceWorkQueueNoteType.evidence,
            ),
          ],
          onNoteAdded: (_) {},
          onCopyNotes: () {},
        ),
      ),
    ),
  );
}

class _NoteCountBadge extends StatelessWidget {
  const _NoteCountBadge({required this.count});

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
                : colorScheme.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          count == 1 ? '1 note' : '$count notes',
          style: theme.textTheme.labelSmall?.copyWith(
            color:
                count == 0
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _NotesEmptyState extends StatelessWidget {
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
            'No execution notes yet.',
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

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.note});

  final AccountingWorkspaceWorkQueueNote note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _noteAccentColor(colorScheme, note.type);

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
            child: Icon(_noteIcon(note.type), color: accentColor, size: 15),
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
                  _NoteTypeBadge(note: note),
                  _NoteMeta(
                    icon: Icons.person_rounded,
                    label: note.authorDisplayLabel,
                  ),
                  _NoteMeta(
                    icon: Icons.schedule_rounded,
                    label: note.timeLabel,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                note.body,
                maxLines: 3,
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
    );
  }
}

class _NoteTypeBadge extends StatelessWidget {
  const _NoteTypeBadge({required this.note});

  final AccountingWorkspaceWorkQueueNote note;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _noteAccentColor(colorScheme, note.type);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          note.typeLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _NoteMeta extends StatelessWidget {
  const _NoteMeta({required this.icon, required this.label});

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

IconData _noteIcon(AccountingWorkspaceWorkQueueNoteType type) {
  switch (type) {
    case AccountingWorkspaceWorkQueueNoteType.note:
      return Icons.notes_rounded;
    case AccountingWorkspaceWorkQueueNoteType.handoff:
      return Icons.swap_horiz_rounded;
    case AccountingWorkspaceWorkQueueNoteType.evidence:
      return Icons.inventory_2_rounded;
    case AccountingWorkspaceWorkQueueNoteType.risk:
      return Icons.priority_high_rounded;
    case AccountingWorkspaceWorkQueueNoteType.decision:
      return Icons.verified_rounded;
  }
}

Color _noteAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueNoteType type,
) {
  switch (type) {
    case AccountingWorkspaceWorkQueueNoteType.note:
      return colorScheme.primary;
    case AccountingWorkspaceWorkQueueNoteType.handoff:
      return colorScheme.secondary;
    case AccountingWorkspaceWorkQueueNoteType.evidence:
      return colorScheme.tertiary;
    case AccountingWorkspaceWorkQueueNoteType.risk:
      return colorScheme.error;
    case AccountingWorkspaceWorkQueueNoteType.decision:
      return colorScheme.onSurfaceVariant;
  }
}
