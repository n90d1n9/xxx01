import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../services/work_queue_resolution_gate_service.dart';

/// Resolution gate card for marking accounting work queues cleared.
class AccountingNavigationWorkQueueResolutionGatePanel extends StatelessWidget {
  const AccountingNavigationWorkQueueResolutionGatePanel({
    required this.gate,
    required this.onClear,
    super.key,
  });

  final AccountingWorkspaceWorkQueueResolutionGate gate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _gateAccentColor(colorScheme, gate);

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-resolution-gate-panel'),
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
                Icon(Icons.flag_rounded, color: accentColor, size: 17),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Resolution gate',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _ResolutionGateBadge(gate: gate),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              gate.detailLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (gate.hasBlockers) ...[
              const SizedBox(height: 7),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final blocker in gate.blockers.take(3))
                    _ResolutionBlockerPill(label: blocker),
                ],
              ),
            ],
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: Text(
                    gate.nextActionLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: const ValueKey('accounting-work-queue-mark-cleared'),
                  onPressed: gate.canClear ? onClear : null,
                  icon: Icon(
                    gate.isCleared
                        ? Icons.check_circle_rounded
                        : Icons.task_alt_rounded,
                    size: 17,
                  ),
                  label: Text(gate.isCleared ? 'Cleared' : 'Mark cleared'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Work queue resolution gate')
Widget workQueueResolutionGatePanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationWorkQueueResolutionGatePanel(
          gate: AccountingWorkspaceWorkQueueResolutionGate(
            canClear: false,
            isCleared: false,
            statusLabel: 'Evidence gate blocked',
            detailLabel: 'Attached evidence needs review before approval.',
            nextActionLabel:
                'Review attached evidence and accept or return it for rework.',
            blockers: const ['Accepted evidence'],
          ),
          onClear: () {},
        ),
      ),
    ),
  );
}

class _ResolutionGateBadge extends StatelessWidget {
  const _ResolutionGateBadge({required this.gate});

  final AccountingWorkspaceWorkQueueResolutionGate gate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _gateAccentColor(colorScheme, gate);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          gate.statusLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ResolutionBlockerPill extends StatelessWidget {
  const _ResolutionBlockerPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onErrorContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

Color _gateAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueResolutionGate gate,
) {
  if (gate.isCleared || gate.canClear) return colorScheme.tertiary;
  if (gate.statusLabel.contains('blocked')) return colorScheme.error;

  return colorScheme.primary;
}
