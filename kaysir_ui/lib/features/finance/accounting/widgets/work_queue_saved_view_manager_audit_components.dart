import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/work_queue_saved_view_manager_audit.dart';

/// Compact in-dialog audit snapshot for recent custom queue view changes.
class WorkQueueSavedViewManagerAuditTrail extends StatelessWidget {
  const WorkQueueSavedViewManagerAuditTrail({
    required this.events,
    this.maxVisibleEvents = 3,
    this.onCopyBrief,
    super.key,
  });

  final List<WorkQueueSavedViewManagerAuditEvent> events;
  final int maxVisibleEvents;
  final VoidCallback? onCopyBrief;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visibleEvents = events.take(maxVisibleEvents).toList(growable: false);
    final hiddenCount = events.length - visibleEvents.length;

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-saved-view-manager-audit'),
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
                  Icons.history_rounded,
                  color: colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 7),
                Text(
                  'Recent changes',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                if (onCopyBrief != null)
                  IconButton(
                    key: const ValueKey(
                      'accounting-work-queue-saved-view-manager-audit-copy',
                    ),
                    tooltip: 'Copy recent changes',
                    onPressed: onCopyBrief,
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    color: colorScheme.primary,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (final event in visibleEvents) ...[
              _SavedViewManagerAuditEventRow(event: event),
              if (event != visibleEvents.last) const SizedBox(height: 7),
            ],
            if (hiddenCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '+$hiddenCount older change${hiddenCount == 1 ? '' : 's'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Work queue saved view manager audit')
Widget workQueueSavedViewManagerAuditTrailPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: WorkQueueSavedViewManagerAuditTrail(
          events: const [
            WorkQueueSavedViewManagerAuditEvent(
              action: WorkQueueSavedViewManagerAuditAction.renamed,
              previousLabel: 'Month-end blockers',
              nextLabel: 'Close blockers',
            ),
            WorkQueueSavedViewManagerAuditEvent(
              action: WorkQueueSavedViewManagerAuditAction.deleted,
              previousLabel: 'Old approver pulse',
            ),
            WorkQueueSavedViewManagerAuditEvent(
              action: WorkQueueSavedViewManagerAuditAction.restored,
              previousLabel: 'Reviewer triage',
            ),
          ],
          onCopyBrief: () {},
        ),
      ),
    ),
  );
}

/// Single row in the custom queue view management audit snapshot.
class _SavedViewManagerAuditEventRow extends StatelessWidget {
  const _SavedViewManagerAuditEventRow({required this.event});

  final WorkQueueSavedViewManagerAuditEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final supportLabel = _auditEventSupportLabel(context, event);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _iconForAuditAction(event.action),
          color: colorScheme.secondary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                supportLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
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

String _auditEventSupportLabel(
  BuildContext context,
  WorkQueueSavedViewManagerAuditEvent event,
) {
  final recordedAt = event.occurredAt;
  if (recordedAt == null) return event.supportLabel;

  final localizations = MaterialLocalizations.of(context);
  final mediaQuery = MediaQuery.maybeOf(context);
  final localRecordedAt = recordedAt.toLocal();
  final dateLabel = localizations.formatShortDate(localRecordedAt);
  final timeLabel = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(localRecordedAt),
    alwaysUse24HourFormat: mediaQuery?.alwaysUse24HourFormat ?? false,
  );

  return '${event.supportLabel} - $dateLabel $timeLabel';
}

IconData _iconForAuditAction(WorkQueueSavedViewManagerAuditAction action) {
  switch (action) {
    case WorkQueueSavedViewManagerAuditAction.renamed:
      return Icons.edit_note_rounded;
    case WorkQueueSavedViewManagerAuditAction.deleted:
      return Icons.delete_outline_rounded;
    case WorkQueueSavedViewManagerAuditAction.restored:
      return Icons.restore_rounded;
  }
}
