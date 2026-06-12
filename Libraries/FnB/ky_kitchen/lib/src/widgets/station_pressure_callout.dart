import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import 'station_status_visuals.dart';

/// Highlights the top kitchen station pressure signal with a focus action.
class KitchenStationPressureCallout extends StatelessWidget {
  const KitchenStationPressureCallout({
    super.key,
    required this.signal,
    this.onStationSelected,
    this.showWhenClear = false,
  });

  final FnbKitchenStationPressureSignal signal;
  final ValueChanged<FnbKitchenStation>? onStationSelected;
  final bool showWhenClear;

  @override
  Widget build(BuildContext context) {
    if (!signal.hasPressure && !showWhenClear) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = kitchenStatusColor(colors, signal.status);
    final station = signal.station;
    final canSelect = station != null && onStationSelected != null;

    return Semantics(
      button: canSelect,
      label: signal.accessibilityLabel,
      child: Material(
        color: statusColor.withValues(alpha: .08),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: statusColor.withValues(alpha: .24)),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: canSelect ? () => onStationSelected!(station) : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      kitchenStatusIcon(signal.status),
                      color: statusColor,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        signal.titleLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        signal.messageLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canSelect) ...[
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 168),
                    child: _PressureFocusButton(
                      label: signal.actionLabel,
                      color: statusColor,
                      onPressed: () => onStationSelected!(station),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact call-to-action for selecting the pressured station.
class _PressureFocusButton extends StatelessWidget {
  const _PressureFocusButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: label,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: TextButton.styleFrom(
          foregroundColor: color,
          textStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}
