import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../utils/inventory_formatters.dart';
import 'movement_list_entry.dart';
import 'recent_movement_tile.dart';

/// Dashboard panel that lists the latest inventory movement activity.
class RecentInventoryMovementsPanel extends StatelessWidget {
  const RecentInventoryMovementsPanel({
    super.key,
    required this.movements,
    this.dateFormat,
  });

  final List<InventoryMovementListEntry> movements;
  final DateFormat? dateFormat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final movementDateFormat = dateFormat ?? inventoryTimestampFormat();

    return AppContentPanel(
      title: 'Recent Inventory Movements',
      subtitle: 'Latest stock receipts, issues, transfers, and adjustments',
      leadingIcon: Icons.sync_alt_rounded,
      trailing: AppStatusPill(
        label: movements.isEmpty ? 'No activity' : '${movements.length} latest',
        icon: Icons.history_rounded,
        color: colorScheme.primary,
      ),
      child:
          movements.isEmpty
              ? const SizedBox(
                height: 220,
                child: AppEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No recent movements',
                  message:
                      'Stock activity will appear here as inventory moves.',
                ),
              )
              : Column(
                children: [
                  for (var index = 0; index < movements.length; index += 1)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index == movements.length - 1 ? 0 : 10,
                      ),
                      child: RecentInventoryMovementTile(
                        entry: movements[index],
                        dateFormat: movementDateFormat,
                      ),
                    ),
                ],
              ),
    );
  }
}
