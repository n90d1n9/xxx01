import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_product_catalog_visuals.dart';

class InventoryProductCatalogRepairQuickSelectBar extends StatelessWidget {
  const InventoryProductCatalogRepairQuickSelectBar({
    super.key,
    required this.summary,
    required this.onSelectTarget,
  });

  final InventoryProductCatalogSelectionSummary summary;
  final ValueChanged<InventoryProductCatalogRepairTarget> onSelectTarget;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeTargets = [
      for (final target in InventoryProductCatalogRepairTarget.values)
        if (summary.repairCountFor(target) > 0) target,
    ];

    if (activeTargets.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppStatusPill(
              label: 'Repair candidates',
              color: colorScheme.primary,
              icon: Icons.auto_fix_high_rounded,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              maxWidth: 170,
            ),
            for (final target in activeTargets)
              AppActionButton(
                label: inventoryProductCatalogRepairTargetButtonLabel(
                  target,
                  summary.repairCountFor(target),
                ),
                icon: inventoryProductCatalogRepairTargetIcon(target),
                variant: AppActionButtonVariant.secondary,
                compact: true,
                height: 34,
                onPressed: () => onSelectTarget(target),
              ),
          ],
        ),
      ),
    );
  }
}
