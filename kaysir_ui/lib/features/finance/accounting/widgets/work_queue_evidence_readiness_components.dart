import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/accounting_workspace_work_queue_evidence_request.dart';
import '../models/work_queue_evidence_link.dart';
import '../models/work_queue_evidence_readiness.dart';

/// Compact readiness panel for work queue evidence coverage decisions.
class AccountingNavigationWorkQueueEvidenceReadinessPanel
    extends StatelessWidget {
  const AccountingNavigationWorkQueueEvidenceReadinessPanel({
    required this.readiness,
    super.key,
  });

  final AccountingWorkspaceWorkQueueEvidenceReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _readinessAccentColor(colorScheme, readiness.status);
    final visibleMissingItems = readiness.remainingRequestedItems
        .take(2)
        .toList(growable: false);

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-evidence-readiness-panel'),
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
                Icon(Icons.fact_check_rounded, color: accentColor, size: 16),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Evidence readiness',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _ReadinessStatusBadge(readiness: readiness),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: readiness.coverageRatio.clamp(0, 1),
                color: accentColor,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _ReadinessMetric(
                  icon: Icons.format_list_numbered_rounded,
                  label: readiness.coverageLabel,
                ),
                _ReadinessMetric(
                  icon: Icons.attachment_rounded,
                  label:
                      readiness.linkedEvidenceCount == 1
                          ? '1 link'
                          : '${readiness.linkedEvidenceCount} links',
                ),
                if (readiness.pendingReviewCount > 0)
                  _ReadinessMetric(
                    icon: Icons.rate_review_rounded,
                    label: '${readiness.pendingReviewCount} pending',
                  ),
                if (readiness.reworkEvidenceCount > 0)
                  _ReadinessMetric(
                    icon: Icons.assignment_return_rounded,
                    label: '${readiness.reworkEvidenceCount} rework',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              readiness.detailLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              readiness.nextActionLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (visibleMissingItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final item in visibleMissingItems) ...[
                _MissingEvidenceItem(label: item),
                if (item != visibleMissingItems.last) const SizedBox(height: 5),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Work queue evidence readiness')
Widget workQueueEvidenceReadinessPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationWorkQueueEvidenceReadinessPanel(
          readiness: AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
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
              requestedItems: const [
                'Release manifest support',
                'Signed controller approval',
                'Disclosure checklist tie-out',
              ],
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
          ),
        ),
      ),
    ),
  );
}

/// Compact evidence readiness chip for dense accounting work queue rows.
class AccountingNavigationWorkQueueEvidenceSignalPill extends StatelessWidget {
  const AccountingNavigationWorkQueueEvidenceSignalPill({
    required this.readiness,
    this.showWhenReady = false,
    super.key,
  });

  final AccountingWorkspaceWorkQueueEvidenceReadiness readiness;
  final bool showWhenReady;

  @override
  Widget build(BuildContext context) {
    if (!showWhenReady &&
        readiness.status ==
            AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _readinessAccentColor(colorScheme, readiness.status);

    return DecoratedBox(
      key: ValueKey(
        'accounting-work-queue-evidence-signal-${readiness.queueId}',
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _readinessIcon(readiness.status),
              color: accentColor,
              size: 13,
            ),
            const SizedBox(width: 5),
            Text(
              '${readiness.statusLabel} · ${readiness.coverageLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Work queue evidence signal')
Widget workQueueEvidenceSignalPillPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationWorkQueueEvidenceSignalPill(
          readiness: AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
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
              requestedItems: const [
                'Release manifest support',
                'Signed controller approval',
              ],
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
          ),
        ),
      ),
    ),
  );
}

class _ReadinessStatusBadge extends StatelessWidget {
  const _ReadinessStatusBadge({required this.readiness});

  final AccountingWorkspaceWorkQueueEvidenceReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _readinessAccentColor(colorScheme, readiness.status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          readiness.statusLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ReadinessMetric extends StatelessWidget {
  const _ReadinessMetric({required this.icon, required this.label});

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
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MissingEvidenceItem extends StatelessWidget {
  const _MissingEvidenceItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.pending_rounded, color: colorScheme.secondary, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
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

Color _readinessAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueEvidenceReadinessStatus status,
) {
  switch (status) {
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
      return colorScheme.error;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
      return colorScheme.secondary;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
      return colorScheme.error;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
      return colorScheme.secondary;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
      return colorScheme.tertiary;
  }
}

IconData _readinessIcon(
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
