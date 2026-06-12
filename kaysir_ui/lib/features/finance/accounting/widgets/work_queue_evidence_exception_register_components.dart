import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/accounting_workspace_work_queue.dart';
import '../models/work_queue_evidence_exception_register.dart';
import '../models/work_queue_evidence_readiness.dart';

/// Compact register of evidence exceptions across accounting work queues.
class AccountingNavigationWorkQueueEvidenceExceptionRegister
    extends StatelessWidget {
  const AccountingNavigationWorkQueueEvidenceExceptionRegister({
    required this.register,
    this.maxVisibleItems = 3,
    this.onCopyBrief,
    this.onExceptionSelected,
    this.onOwnerSelected,
    super.key,
  });

  final AccountingWorkspaceWorkQueueEvidenceExceptionRegister register;
  final int maxVisibleItems;
  final VoidCallback? onCopyBrief;
  final ValueChanged<String>? onExceptionSelected;
  final ValueChanged<String>? onOwnerSelected;

  @override
  Widget build(BuildContext context) {
    if (!register.hasExceptions) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor =
        register.blockerCount > 0 ? colorScheme.error : colorScheme.secondary;
    final visibleItems = register.items.take(maxVisibleItems).toList();
    final hiddenCount = register.exceptionCount - visibleItems.length;

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-evidence-exception-register'),
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
                Icon(Icons.rule_folder_rounded, color: accentColor, size: 17),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Evidence exceptions',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _ExceptionRegisterBadge(
                  label: register.statusLabel,
                  color: accentColor,
                ),
                const SizedBox(width: 4),
                IconButton(
                  key: const ValueKey(
                    'accounting-work-queue-evidence-exception-copy',
                  ),
                  tooltip: 'Copy evidence exception brief',
                  visualDensity: VisualDensity.compact,
                  onPressed: onCopyBrief,
                  icon: Icon(Icons.copy_rounded, color: accentColor, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Review support gaps before close clearance or reviewer sign-off.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (register.ownerHandoffs.isNotEmpty) ...[
              const SizedBox(height: 8),
              _OwnerHandoffStrip(
                handoffs: register.ownerHandoffs,
                onOwnerSelected: onOwnerSelected,
              ),
            ],
            const SizedBox(height: 9),
            for (final item in visibleItems) ...[
              _EvidenceExceptionRow(
                item: item,
                onSelected:
                    onExceptionSelected == null
                        ? null
                        : () => onExceptionSelected!(item.queueId),
              ),
              if (item != visibleItems.last) const SizedBox(height: 7),
            ],
            if (hiddenCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '+$hiddenCount more evidence exception${hiddenCount == 1 ? '' : 's'} in this view',
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

@Preview(name: 'Work queue evidence exceptions')
Widget workQueueEvidenceExceptionRegisterPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationWorkQueueEvidenceExceptionRegister(
          register: AccountingWorkspaceWorkQueueEvidenceExceptionRegister(
            items: const [
              AccountingWorkspaceWorkQueueEvidenceException(
                queueId: 'release-evidence',
                title: 'Release evidence pack',
                ownerLabel: 'Controller',
                dueLabel: '1 day overdue',
                severity: AccountingWorkspaceWorkQueueSeverity.critical,
                slaStatus: AccountingWorkspaceWorkQueueSlaStatus.overdue,
                status:
                    AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework,
                coverageLabel: '1/3 accepted',
                nextActionLabel: 'Send rework comments to the owner.',
                pendingReviewCount: 0,
                reworkEvidenceCount: 1,
                remainingItemCount: 2,
              ),
              AccountingWorkspaceWorkQueueEvidenceException(
                queueId: 'bank-confirmation',
                title: 'Bank confirmation',
                ownerLabel: 'Treasury',
                dueLabel: 'Due today',
                severity: AccountingWorkspaceWorkQueueSeverity.warning,
                slaStatus: AccountingWorkspaceWorkQueueSlaStatus.dueToday,
                status:
                    AccountingWorkspaceWorkQueueEvidenceReadinessStatus
                        .reviewNeeded,
                coverageLabel: '0/2 accepted',
                nextActionLabel: 'Review attached evidence.',
                pendingReviewCount: 1,
                reworkEvidenceCount: 0,
                remainingItemCount: 2,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Inline triage strip that summarizes which owners still need evidence action.
class _OwnerHandoffStrip extends StatelessWidget {
  const _OwnerHandoffStrip({required this.handoffs, this.onOwnerSelected});

  final List<AccountingWorkspaceWorkQueueEvidenceOwnerHandoff> handoffs;
  final ValueChanged<String>? onOwnerSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visibleHandoffs = handoffs.take(3).toList(growable: false);
    final hiddenCount = handoffs.length - visibleHandoffs.length;

    return Wrap(
      key: const ValueKey('accounting-work-queue-evidence-owner-handoff-strip'),
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final handoff in visibleHandoffs)
          _OwnerHandoffChip(handoff: handoff, onOwnerSelected: onOwnerSelected),
        if (hiddenCount > 0)
          Text(
            '+$hiddenCount owner${hiddenCount == 1 ? '' : 's'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

/// Tappable owner handoff chip for filtering the work queue by owner.
class _OwnerHandoffChip extends StatelessWidget {
  const _OwnerHandoffChip({
    required this.handoff,
    required this.onOwnerSelected,
  });

  final AccountingWorkspaceWorkQueueEvidenceOwnerHandoff handoff;
  final ValueChanged<String>? onOwnerSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor =
        handoff.blockerCount > 0 ? colorScheme.error : colorScheme.secondary;
    final borderRadius = BorderRadius.circular(999);

    return Semantics(
      button: onOwnerSelected != null,
      label: 'Evidence owner handoff: ${handoff.displayLabel}',
      child: Tooltip(
        message:
            onOwnerSelected == null
                ? handoff.displayLabel
                : 'Filter evidence exceptions by ${handoff.ownerLabel}',
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: borderRadius,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: InkWell(
              key: ValueKey(
                'accounting-work-queue-evidence-owner-handoff-${_ownerHandoffKeySegment(handoff.ownerLabel)}',
              ),
              borderRadius: borderRadius,
              mouseCursor:
                  onOwnerSelected == null
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
              onTap:
                  onOwnerSelected == null
                      ? null
                      : () => onOwnerSelected!(handoff.ownerLabel),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_search_rounded,
                      color: accentColor,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      handoff.displayLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single evidence exception row with a direct review action.
class _EvidenceExceptionRow extends StatelessWidget {
  const _EvidenceExceptionRow({required this.item, required this.onSelected});

  final AccountingWorkspaceWorkQueueEvidenceException item;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _exceptionAccentColor(colorScheme, item.status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        child: Row(
          children: [
            Icon(_exceptionIcon(item.status), color: accentColor, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _ExceptionRegisterBadge(
                        label: item.statusLabel,
                        color: accentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.metricLabel} · ${item.ownerLabel} · ${item.dueLabel}',
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
            const SizedBox(width: 8),
            IconButton(
              key: ValueKey(
                'accounting-work-queue-evidence-exception-review-${item.queueId}',
              ),
              tooltip: 'Review evidence exception',
              visualDensity: VisualDensity.compact,
              onPressed: onSelected,
              icon: Icon(
                Icons.arrow_forward_rounded,
                color:
                    onSelected == null
                        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.42)
                        : accentColor,
                size: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Converts owner labels into stable key fragments for widget tests.
String _ownerHandoffKeySegment(String ownerLabel) {
  final normalized = ownerLabel
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  return normalized.isEmpty ? 'unassigned' : normalized;
}

/// Small status badge used by the evidence exception register.
class _ExceptionRegisterBadge extends StatelessWidget {
  const _ExceptionRegisterBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

Color _exceptionAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueEvidenceReadinessStatus status,
) {
  switch (status) {
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
      return colorScheme.error;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
      return colorScheme.secondary;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
      return colorScheme.tertiary;
  }
}

IconData _exceptionIcon(
  AccountingWorkspaceWorkQueueEvidenceReadinessStatus status,
) {
  switch (status) {
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
      return Icons.attach_file_rounded;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
      return Icons.rate_review_rounded;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
      return Icons.assignment_return_rounded;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
      return Icons.fact_check_rounded;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
      return Icons.verified_rounded;
  }
}
