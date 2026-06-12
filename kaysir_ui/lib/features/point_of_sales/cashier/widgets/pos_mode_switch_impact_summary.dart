import 'package:flutter/material.dart';

import '../experiences/pos_mode_switch_impact.dart';
import 'pos_ui.dart';

class POSModeSwitchImpactSummary extends StatelessWidget {
  final POSModeSwitchImpact impact;

  const POSModeSwitchImpactSummary({super.key, required this.impact});

  @override
  Widget build(BuildContext context) {
    if (impact.isCurrentMode || !impact.hasChanges) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _ImpactPill(
          icon: Icons.compare_arrows_outlined,
          label: impact.summaryLabel,
          background: colorScheme.surfaceContainerHighest,
          foreground: colorScheme.onSurfaceVariant,
        ),
        for (final item in impact.previewItems())
          _ImpactPill(
            icon:
                item.direction == POSModeSwitchImpactDirection.disabled
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
            label: item.statusLabel,
            background:
                item.direction == POSModeSwitchImpactDirection.disabled
                    ? colorScheme.errorContainer.withValues(alpha: 0.72)
                    : colorScheme.secondaryContainer.withValues(alpha: 0.72),
            foreground:
                item.direction == POSModeSwitchImpactDirection.disabled
                    ? colorScheme.onErrorContainer
                    : colorScheme.onSecondaryContainer,
          ),
      ],
    );
  }
}

class _ImpactPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const _ImpactPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
