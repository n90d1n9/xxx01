import 'package:flutter/material.dart';

import '../models/kitchen_handoff_audit_entry.dart';

/// Shows recently archived handoff verification records for served tickets.
class KitchenHandoffAuditList extends StatelessWidget {
  const KitchenHandoffAuditList({
    super.key,
    required this.entries,
    this.limit = 3,
    this.emptyMessage = 'No handoff verifications archived.',
  }) : assert(limit > 0, 'limit must be greater than zero.');

  final List<KitchenHandoffAuditEntry> entries;
  final int limit;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final visibleEntries = entries.take(limit).toList(growable: false);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .56)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 18,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Handoff audit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${entries.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (visibleEntries.isEmpty)
              _HandoffAuditEmptyState(message: emptyMessage)
            else
              for (final entry in visibleEntries) ...[
                _HandoffAuditEntryRow(entry: entry),
                if (entry != visibleEntries.last)
                  Divider(
                    height: 14,
                    color: colors.outlineVariant.withValues(alpha: .5),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for the archived handoff audit list.
class _HandoffAuditEmptyState extends StatelessWidget {
  const _HandoffAuditEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(Icons.history_toggle_off_outlined, color: colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// One archived handoff verification summary row.
class _HandoffAuditEntryRow extends StatelessWidget {
  const _HandoffAuditEntryRow({required this.entry});

  final KitchenHandoffAuditEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              Icons.done_all_rounded,
              size: 18,
              color: colors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.customerLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.summaryLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          entry.closedLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
