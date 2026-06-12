import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';

class InventoryProductCatalogBulkRepairActionButton extends StatelessWidget {
  const InventoryProductCatalogBulkRepairActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.repairCount,
    required this.issueLabel,
    required this.emptyTooltip,
    required this.onPressed,
    this.pluralIssueLabel,
  });

  final String label;
  final IconData icon;
  final int? repairCount;
  final String issueLabel;
  final String? pluralIssueLabel;
  final String emptyTooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = repairCount == null || repairCount! > 0;
    final button = AppActionButton(
      label: _repairActionLabel(label, repairCount),
      icon: icon,
      variant: AppActionButtonVariant.secondary,
      compact: true,
      onPressed: enabled ? onPressed : null,
    );

    if (repairCount == null) return button;

    return Tooltip(
      message:
          enabled
              ? _selectedRepairTooltip(
                repairCount!,
                issueLabel,
                plural: pluralIssueLabel,
              )
              : emptyTooltip,
      child: button,
    );
  }
}

String _repairActionLabel(String label, int? repairCount) {
  if (repairCount == null) return label;
  return '$label ($repairCount)';
}

String _selectedRepairTooltip(int count, String singular, {String? plural}) {
  final productNoun = count == 1 ? 'product' : 'products';
  final issueNoun = count == 1 ? singular : plural ?? '${singular}s';
  return '$count selected $productNoun missing $issueNoun';
}
