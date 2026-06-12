import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_report_catalog.dart';
import 'report_card.dart';

/// Catalog panel that lays out available inventory reports responsively.
class InventoryReportCatalogPanel extends StatelessWidget {
  const InventoryReportCatalogPanel({
    super.key,
    required this.stats,
    required this.onGenerate,
  });

  final InventoryReportHubStats stats;
  final ValueChanged<InventoryReportType> onGenerate;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Report Catalog',
      subtitle:
          'Operational inventory reports generated from live workspace data',
      leadingIcon: Icons.folder_copy_rounded,
      trailing: AppStatusPill(
        label: '${stats.readyReportCount} ready',
        icon: Icons.check_circle_outline_rounded,
        color: Colors.green.shade700,
        maxWidth: 130,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 920 ? 2 : 1;
          const spacing = 12.0;
          final width =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final definition in inventoryReportDefinitions)
                SizedBox(
                  width: width,
                  child: InventoryReportCard(
                    definition: definition,
                    stats: stats,
                    onGenerate:
                        stats.canGenerate(definition.type)
                            ? () => onGenerate(definition.type)
                            : null,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
