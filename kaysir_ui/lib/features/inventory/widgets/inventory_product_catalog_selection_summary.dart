import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_product_catalog.dart';
import '../utils/inventory_formatters.dart';

class InventoryProductCatalogSelectionImpactStrip extends StatelessWidget {
  const InventoryProductCatalogSelectionImpactStrip({
    super.key,
    required this.summary,
  });

  final InventoryProductCatalogSelectionSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.productCount == 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final attentionColor =
        summary.hasAttention ? Colors.orange.shade800 : Colors.green.shade700;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppStatusPill(
          label: _attentionLabel(summary.attentionProductCount),
          color: attentionColor,
          icon:
              summary.hasAttention
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_rounded,
          tooltip: 'Selected products needing catalog or stock attention',
          maxWidth: 170,
        ),
        AppStatusPill(
          label: _countLabel(summary.totalQuantity, 'unit'),
          color: colorScheme.primary,
          icon: Icons.inventory_rounded,
          tooltip: 'Total stock units in the current selection',
          maxWidth: 130,
        ),
        AppStatusPill(
          label: formatInventoryCurrency(summary.totalInventoryValue),
          color: Colors.teal.shade700,
          icon: Icons.payments_rounded,
          tooltip: 'Total stock value in the current selection',
          maxWidth: 150,
        ),
        AppStatusPill(
          label: _countLabel(summary.categoryCount, 'category', 'categories'),
          color: Colors.blueGrey.shade700,
          icon: Icons.sell_rounded,
          tooltip: 'Distinct categories in the current selection',
          maxWidth: 150,
        ),
        ..._qualityRepairPills(context, summary),
        if (summary.totalShortage > 0)
          AppStatusPill(
            label: _countLabel(summary.totalShortage, 'shortage'),
            color: colorScheme.error,
            icon: Icons.flag_rounded,
            tooltip: 'Total reorder shortage in the current selection',
            maxWidth: 140,
          ),
      ],
    );
  }
}

List<Widget> _qualityRepairPills(
  BuildContext context,
  InventoryProductCatalogSelectionSummary summary,
) {
  if (!summary.hasQualityIssues) {
    return [
      AppStatusPill(
        label: 'Quality ready',
        color: Colors.green.shade700,
        icon: Icons.verified_rounded,
        tooltip: 'Selected products have core catalog fields ready',
        maxWidth: 150,
      ),
    ];
  }

  return [
    if (summary.missingSkuCount > 0)
      _qualityRepairPill(
        label: _countLabel(summary.missingSkuCount, 'missing SKU'),
        icon: Icons.tag_rounded,
        tooltip: 'Selected products missing SKU',
      ),
    if (summary.missingCategoryCount > 0)
      _qualityRepairPill(
        label: _countLabel(summary.missingCategoryCount, 'missing category'),
        icon: Icons.category_rounded,
        tooltip: 'Selected products missing category',
      ),
    if (summary.missingDescriptionCount > 0)
      _qualityRepairPill(
        label: _countLabel(
          summary.missingDescriptionCount,
          'missing description',
        ),
        icon: Icons.notes_rounded,
        tooltip: 'Selected products missing description',
      ),
    if (summary.missingPriceCount > 0)
      _qualityRepairPill(
        label: _countLabel(summary.missingPriceCount, 'missing price'),
        icon: Icons.sell_rounded,
        tooltip: 'Selected products missing price',
      ),
    if (summary.missingScanCodeCount > 0)
      _qualityRepairPill(
        label: _countLabel(summary.missingScanCodeCount, 'missing scan code'),
        icon: Icons.qr_code_scanner_rounded,
        tooltip: 'Selected products missing barcode or shortcut key',
      ),
  ];
}

Widget _qualityRepairPill({
  required String label,
  required IconData icon,
  required String tooltip,
}) {
  return AppStatusPill(
    label: label,
    color: Colors.deepOrange.shade700,
    icon: icon,
    tooltip: tooltip,
    maxWidth: 190,
  );
}

String _attentionLabel(int count) {
  if (count == 0) return 'No attention';
  if (count == 1) return '1 attention item';
  return '${formatInventoryNumber(count)} attention items';
}

String _countLabel(int value, String singular, [String? plural]) {
  final noun = value == 1 ? singular : plural ?? '${singular}s';
  return '${formatInventoryNumber(value)} $noun';
}
