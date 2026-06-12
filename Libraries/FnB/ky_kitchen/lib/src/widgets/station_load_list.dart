import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_station_board.dart';
import '../models/kitchen_station_load.dart';
import 'station_load_card.dart';

/// Renders filtered kitchen station load cards from a station board.
class KitchenStationLoadList extends StatelessWidget {
  const KitchenStationLoadList({
    super.key,
    required this.board,
    this.filter = FnbKitchenStationFilter.all,
    this.selectedStationId,
    this.onLoadSelected,
    this.emptyMessage,
  });

  final KitchenStationBoard board;
  final FnbKitchenStationFilter filter;
  final String? selectedStationId;
  final ValueChanged<KitchenStationLoad>? onLoadSelected;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final loads = board.filteredLoads(filter);
    if (loads.isEmpty) {
      return _StationLoadEmptyState(
        message:
            emptyMessage ??
            'No ${filter.label.toLowerCase()} kitchen stations right now.',
      );
    }

    return Column(
      children: [
        for (final load in loads) ...[
          KitchenStationLoadCard(
            load: load,
            selected: load.station.id == selectedStationId,
            onPressed: onLoadSelected == null
                ? null
                : () => onLoadSelected!(load),
          ),
          if (load != loads.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Empty state for filtered station load lists.
class _StationLoadEmptyState extends StatelessWidget {
  const _StationLoadEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .34),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .56)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.soup_kitchen_outlined, color: colors.onSurfaceVariant),
            const SizedBox(width: 10),
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
        ),
      ),
    );
  }
}
