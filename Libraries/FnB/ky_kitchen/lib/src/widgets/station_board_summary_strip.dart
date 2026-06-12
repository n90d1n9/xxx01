import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_station_board.dart';
import 'station_status_visuals.dart';

/// Displays station board pressure, throughput, and ticket timing metrics.
class KitchenStationBoardSummaryStrip extends StatelessWidget {
  const KitchenStationBoardSummaryStrip({super.key, required this.board});

  final KitchenStationBoard board;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final summary = board.summary;
    final status =
        board.priorityQueue.topStation?.status ?? FnbServiceStatus.calm;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .42),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .58)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Station board',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  summary.pressureLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: kitchenStatusColor(colors, status),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Semantics(
              label: 'Station board pressure, ${summary.pressureLabel}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: summary.pressureRate.clamp(0.0, 1.0).toDouble(),
                  minHeight: 8,
                  backgroundColor: colors.surface.withValues(alpha: .8),
                  color: kitchenStatusColor(colors, status),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FnbMetricChip.outlined(
                  icon: Icons.receipt_long_outlined,
                  label: '${board.activeTicketCount} active',
                ),
                FnbMetricChip.outlined(
                  icon: Icons.timer_outlined,
                  label: '${board.lateTicketCount} late',
                ),
                FnbMetricChip.outlined(
                  icon: Icons.room_service_outlined,
                  label: '${board.readyTicketCount} ready',
                ),
                FnbMetricChip.outlined(
                  icon: Icons.restaurant_menu_outlined,
                  label: '${board.itemCount} items',
                ),
                FnbMetricChip.outlined(
                  icon: Icons.local_fire_department_outlined,
                  label: '${summary.averageFireMinutes}m avg fire',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
