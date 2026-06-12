import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_report_catalog.dart';
import 'report_icon_badge.dart';
import 'report_visuals.dart';

/// Actionable card for one report definition in the inventory report catalog.
class InventoryReportCard extends StatelessWidget {
  const InventoryReportCard({
    super.key,
    required this.definition,
    required this.stats,
    this.onGenerate,
  });

  final InventoryReportDefinition definition;
  final InventoryReportHubStats stats;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = inventoryReportVisualsFor(definition.type);
    final canGenerate = stats.canGenerate(definition.type);

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onGenerate,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InventoryReportIconBadge(style: style),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          definition.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          definition.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppStatusPill(
                    label: stats.readinessLabelFor(definition.type),
                    icon:
                        canGenerate
                            ? Icons.check_circle_outline_rounded
                            : Icons.info_outline_rounded,
                    color:
                        canGenerate
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                    maxWidth: 160,
                  ),
                  AppStatusPill(
                    label: stats.dataLabelFor(definition.type),
                    icon: Icons.storage_rounded,
                    color: style.color,
                    maxWidth: 170,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: AppActionButton(
                  label: 'Open report',
                  icon: Icons.open_in_new_rounded,
                  compact: true,
                  variant:
                      canGenerate
                          ? AppActionButtonVariant.primary
                          : AppActionButtonVariant.secondary,
                  onPressed: onGenerate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
