import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/company_branch_governance.dart';
import 'branch_governance_tile.dart';
import 'branch_preview_data.dart';

/// Vertical list of branch governance readiness tiles.
class CompanyBranchGovernanceTileList extends StatelessWidget {
  const CompanyBranchGovernanceTileList({super.key, required this.items});

  final List<CompanyBranchGovernanceItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index += 1) ...[
          CompanyBranchGovernanceTile(item: items[index]),
          if (index != items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

@Preview(name: 'Company branch governance tile list')
Widget companyBranchGovernanceTileListPreview() {
  return inventoryBranchPreviewScaffold(
    CompanyBranchGovernanceTileList(
      items: inventoryBranchPreviewGovernanceSummary().items,
    ),
  );
}
