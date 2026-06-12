import 'package:flutter/material.dart';

import '../models/company_branch_governance.dart';
import '../models/inventory_branch.dart';

/// Color used for overall governance risk indicators.
Color companyBranchGovernanceRiskColor(int riskCount) {
  return riskCount == 0 ? Colors.green.shade700 : Colors.red.shade700;
}

/// Color used for a branch governance readiness score and blocked state.
Color companyBranchGovernanceReadinessColor(CompanyBranchGovernanceItem item) {
  if (item.isReady) return Colors.green.shade700;
  if (item.isBlocked) return Colors.red.shade700;
  return Colors.orange.shade800;
}

/// Color used for branch governance compliance tier pills.
Color companyBranchGovernanceComplianceColor(
  InventoryBranchComplianceTier tier,
) {
  switch (tier) {
    case InventoryBranchComplianceTier.standard:
      return Colors.green.shade700;
    case InventoryBranchComplianceTier.monitored:
      return Colors.orange.shade800;
    case InventoryBranchComplianceTier.restricted:
      return Colors.red.shade700;
  }
}
