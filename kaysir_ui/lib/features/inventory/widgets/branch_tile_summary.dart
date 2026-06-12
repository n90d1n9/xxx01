import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_branch.dart';
import 'branch_preview_data.dart';
import 'inventory_branch_status_visuals.dart';

/// Primary branch identity block used at the start of a branch tile.
class InventoryBranchTileSummary extends StatelessWidget {
  const InventoryBranchTileSummary({super.key, required this.branch});

  final InventoryBranch branch;

  @override
  Widget build(BuildContext context) {
    final statusColor = inventoryBranchStatusColor(branch.status);

    return AppInfoRow(
      icon: Icons.account_tree_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      iconBackgroundColor: statusColor.withValues(alpha: 0.12),
      iconForegroundColor: statusColor,
      title: branch.nameLabel,
      subtitle: _subtitleFor(branch),
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      padding: EdgeInsets.zero,
    );
  }

  String _subtitleFor(InventoryBranch branch) {
    final notes = (branch.notes ?? '').trim();
    final base =
        '${branch.codeLabel} | ${branch.cityLabel} | ${branch.legalEntityLabel}';

    return notes.isEmpty ? base : '$base | $notes';
  }
}

@Preview(name: 'Inventory branch tile summary')
Widget inventoryBranchTileSummaryPreview() {
  return inventoryBranchPreviewScaffold(
    InventoryBranchTileSummary(branch: inventoryBranchPreviewBranch()),
  );
}
