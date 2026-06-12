import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/company_branch_governance.dart';
import '../models/inventory_branch.dart';
import '../utils/inventory_formatters.dart';
import 'branch_governance_visuals.dart';
import 'branch_preview_data.dart';

/// Detail pill cluster for a branch governance tile.
class CompanyBranchGovernanceDetails extends StatelessWidget {
  const CompanyBranchGovernanceDetails({super.key, required this.item});

  final CompanyBranchGovernanceItem item;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        CompanyBranchGovernanceDetailPill(
          icon: Icons.map_rounded,
          label: item.region,
          color: Colors.blueGrey.shade700,
        ),
        CompanyBranchGovernanceDetailPill(
          icon: Icons.category_rounded,
          label: inventoryBranchTypeLabel(item.type),
          color: Colors.indigo.shade700,
        ),
        CompanyBranchGovernanceDetailPill(
          icon: Icons.policy_rounded,
          label: inventoryBranchComplianceTierLabel(item.complianceTier),
          color: companyBranchGovernanceComplianceColor(item.complianceTier),
        ),
        CompanyBranchGovernanceDetailPill(
          icon: Icons.groups_rounded,
          label: '${formatInventoryNumber(item.employeeCount)} people',
          color: Colors.teal.shade700,
        ),
        CompanyBranchGovernanceDetailPill(
          icon: Icons.warehouse_rounded,
          label: '${formatInventoryNumber(item.warehouseCount)} warehouses',
          color: Colors.deepPurple.shade700,
        ),
        CompanyBranchGovernanceDetailPill(
          icon: item.hasRisk ? Icons.flag_outlined : Icons.check_circle_outline,
          label: item.action,
          color: item.hasRisk ? Colors.orange.shade800 : Colors.green.shade700,
          maxWidth: 260,
        ),
      ],
    );
  }
}

/// Single governance detail pill with bounded label width.
class CompanyBranchGovernanceDetailPill extends StatelessWidget {
  const CompanyBranchGovernanceDetailPill({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.maxWidth = 180,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: label,
      icon: icon,
      color: color,
      maxWidth: maxWidth,
    );
  }
}

@Preview(name: 'Company branch governance details')
Widget companyBranchGovernanceDetailsPreview() {
  return inventoryBranchPreviewScaffold(
    CompanyBranchGovernanceDetails(
      item: inventoryBranchPreviewGovernanceSummary().items.first,
    ),
  );
}
