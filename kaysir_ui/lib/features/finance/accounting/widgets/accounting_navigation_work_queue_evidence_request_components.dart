import 'package:flutter/material.dart';

import '../models/accounting_workspace_work_queue_evidence_request.dart';

class AccountingNavigationWorkQueueEvidenceRequestPanel
    extends StatelessWidget {
  const AccountingNavigationWorkQueueEvidenceRequestPanel({
    required this.request,
    super.key,
  });

  final AccountingWorkspaceWorkQueueEvidenceRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visibleRequestedItems = request.requestedItems.take(3).toList();

    return DecoratedBox(
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
                  Icons.outbox_outlined,
                  color: colorScheme.primary,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  'Evidence request',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _TrackingChip(
                  icon: Icons.radio_button_checked_rounded,
                  label: request.statusLabel,
                ),
                _TrackingChip(
                  icon: Icons.history_toggle_off_rounded,
                  label: request.agingLabel,
                ),
                _TrackingChip(
                  icon: Icons.repeat_rounded,
                  label: request.followUpLabel,
                ),
              ],
            ),
            const SizedBox(height: 9),
            _RequestLine(
              icon: Icons.person_rounded,
              label: 'Recipient',
              value: request.recipientLabel,
            ),
            const SizedBox(height: 7),
            _RequestLine(
              icon: Icons.subject_rounded,
              label: 'Subject',
              value: request.subject,
            ),
            const SizedBox(height: 7),
            _RequestLine(
              icon: Icons.event_available_rounded,
              label: 'Response due',
              value: request.responseDueLabel,
            ),
            const SizedBox(height: 7),
            _RequestLine(
              icon: Icons.track_changes_rounded,
              label: 'Tracking action',
              value: request.nextTrackingActionLabel,
            ),
            const SizedBox(height: 9),
            Text(
              'Requested items',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            for (
              var index = 0;
              index < visibleRequestedItems.length;
              index++
            ) ...[
              _RequestedItem(label: visibleRequestedItems[index]),
              if (index != visibleRequestedItems.length - 1)
                const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrackingChip extends StatelessWidget {
  const _TrackingChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorScheme.onPrimaryContainer, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestLine extends StatelessWidget {
  const _RequestLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestedItem extends StatelessWidget {
  const _RequestedItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 15),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
