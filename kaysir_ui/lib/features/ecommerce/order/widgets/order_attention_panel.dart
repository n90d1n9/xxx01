import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_attention.dart';

class OrderAttentionPanel extends StatelessWidget {
  final List<OrderAttentionSignal> signals;

  const OrderAttentionPanel({super.key, required this.signals});

  @override
  Widget build(BuildContext context) {
    if (signals.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final criticalCount =
        signals
            .where(
              (signal) => signal.severity == OrderAttentionSeverity.critical,
            )
            .length;
    final chipLabel =
        criticalCount > 0
            ? '$criticalCount high priority'
            : '${signals.length} signals';

    return POSSurface(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
      border: Border.all(color: theme.dividerColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              POSIconBadge(
                icon: Icons.assignment_late_outlined,
                backgroundColor: theme.colorScheme.tertiaryContainer,
                foregroundColor: theme.colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: POSUiTokens.gapLarge),
              Expanded(
                child: Text(
                  'Operations attention',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(POSUiTokens.radius),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(
                  chipLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          Wrap(
            spacing: POSUiTokens.gap,
            runSpacing: POSUiTokens.gap,
            children:
                signals
                    .map((signal) => _AttentionSignalTile(signal: signal))
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _AttentionSignalTile extends StatelessWidget {
  final OrderAttentionSignal signal;

  const _AttentionSignalTile({required this.signal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accentColor(theme.colorScheme);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, size: 18, color: accent),
              const SizedBox(width: POSUiTokens.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      signal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      signal.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    return switch (signal.severity) {
      OrderAttentionSeverity.info => Icons.info_outline,
      OrderAttentionSeverity.warning => Icons.priority_high_outlined,
      OrderAttentionSeverity.critical => Icons.report_outlined,
    };
  }

  Color _accentColor(ColorScheme scheme) {
    return switch (signal.severity) {
      OrderAttentionSeverity.info => scheme.primary,
      OrderAttentionSeverity.warning => Colors.orange,
      OrderAttentionSeverity.critical => scheme.error,
    };
  }
}
