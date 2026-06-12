import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_movement_record.dart';
import 'inventory_reset_filters_button.dart';
import 'inventory_separated_list.dart';
import 'movement_timeline_tile.dart';

/// Panel that renders filtered inventory movement records as a timeline.
class InventoryMovementHistoryPanel extends StatelessWidget {
  const InventoryMovementHistoryPanel({
    super.key,
    required this.records,
    required this.totalCount,
    this.onResetFilters,
  });

  final List<InventoryMovementRecord> records;
  final int totalCount;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Movement Timeline',
      subtitle: '${records.length} of $totalCount movements shown',
      leadingIcon: Icons.timeline_rounded,
      trailing:
          records.isEmpty
              ? null
              : AppStatusPill(
                label: '${records.length} visible',
                icon: Icons.visibility_rounded,
                color: Theme.of(context).colorScheme.primary,
                maxWidth: 130,
              ),
      child:
          records.isEmpty
              ? AppEmptyState(
                title: 'No matching movements',
                message:
                    'Try another movement type, warehouse, or search term.',
                icon: Icons.timeline_rounded,
                action:
                    onResetFilters == null
                        ? null
                        : InventoryResetFiltersButton(
                          onPressed: onResetFilters!,
                        ),
              )
              : InventorySeparatedList<InventoryMovementRecord>(
                items: records,
                itemBuilder: (context, record, index) {
                  return InventoryMovementTimelineTile(record: record);
                },
              ),
    );
  }
}
