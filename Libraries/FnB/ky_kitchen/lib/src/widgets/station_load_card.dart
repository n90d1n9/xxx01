import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_station_load.dart';
import 'station_status_visuals.dart';

/// Displays one kitchen station's ticket load, timing, and operating status.
class KitchenStationLoadCard extends StatelessWidget {
  const KitchenStationLoadCard({
    super.key,
    required this.load,
    this.onPressed,
    this.selected = false,
  });

  final KitchenStationLoad load;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final station = load.stationSnapshot;
    final statusColor = kitchenStatusColor(colors, station.status);

    return Semantics(
      button: onPressed != null,
      selected: selected,
      label:
          '${station.accessibilityLabel}, ${station.status.label}, '
          '${load.readyTicketCount} ready, ${load.itemCount} items',
      child: Material(
        color: colors.surface.withValues(alpha: .92),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected
                ? statusColor.withValues(alpha: .56)
                : colors.outlineVariant.withValues(alpha: .58),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FnbStatusBadge(
                      icon: kitchenStatusIcon(station.status),
                      color: statusColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            station.queueLeadLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FnbStatusPill(
                      label: station.status.label,
                      color: statusColor,
                      borderAlpha: .18,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FnbMetricChip(
                      icon: Icons.receipt_long_outlined,
                      label: '${load.activeTicketCount} active',
                    ),
                    FnbMetricChip(
                      icon: Icons.timer_outlined,
                      label: '${load.lateTicketCount} late',
                    ),
                    FnbMetricChip(
                      icon: Icons.room_service_outlined,
                      label: '${load.readyTicketCount} ready',
                    ),
                    FnbMetricChip(
                      icon: Icons.restaurant_menu_outlined,
                      label: '${load.itemCount} items',
                    ),
                    FnbMetricChip(
                      icon: Icons.local_fire_department_outlined,
                      label: station.fireTimeLabel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
