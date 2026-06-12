import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/company_branch_governance.dart';
import '../utils/inventory_formatters.dart';
import 'branch_governance_visuals.dart';
import 'branch_preview_data.dart';

/// Metric grid summarizing branch governance readiness and company records.
class CompanyBranchGovernanceMetricGrid extends StatelessWidget {
  const CompanyBranchGovernanceMetricGrid({super.key, required this.summary});

  final CompanyBranchGovernanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final riskColor = companyBranchGovernanceRiskColor(summary.riskCount);

    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Readiness',
          value: '${summary.averageReadiness}%',
          helper: '${summary.readyCount}/${summary.totalBranches} ready',
          icon: Icons.fact_check_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Legal Entities',
          value: formatInventoryNumber(summary.legalEntityCount),
          helper: 'Company records',
          icon: Icons.account_balance_rounded,
          accentColor: Colors.indigo.shade700,
        ),
        AppMetricGridItem(
          title: 'Employees',
          value: formatInventoryNumber(summary.employeeCount),
          helper: 'Branch headcount',
          icon: Icons.groups_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Risks',
          value: formatInventoryNumber(summary.riskCount),
          helper: summary.nextAction,
          icon: Icons.policy_rounded,
          accentColor: riskColor,
        ),
      ],
    );
  }
}

@Preview(name: 'Company branch governance metrics')
Widget companyBranchGovernanceMetricGridPreview() {
  return inventoryBranchPreviewScaffold(
    CompanyBranchGovernanceMetricGrid(
      summary: inventoryBranchPreviewGovernanceSummary(),
    ),
  );
}
