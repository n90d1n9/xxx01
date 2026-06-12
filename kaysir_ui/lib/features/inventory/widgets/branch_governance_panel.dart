import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/company_branch_governance.dart';
import 'branch_governance_metric_grid.dart';
import 'branch_governance_status_pill.dart';
import 'branch_governance_tile_list.dart';
import 'branch_preview_data.dart';

/// Company branch governance panel for readiness, risk, and entity health.
class CompanyBranchGovernancePanel extends StatelessWidget {
  const CompanyBranchGovernancePanel({super.key, required this.summary});

  final CompanyBranchGovernanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Company Management',
      subtitle: 'Legal entities, branch governance, and operating readiness',
      leadingIcon: Icons.business_center_rounded,
      trailing: CompanyBranchGovernanceStatusPill(summary: summary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CompanyBranchGovernanceMetricGrid(summary: summary),
          const SizedBox(height: 14),
          CompanyBranchGovernanceTileList(items: summary.items),
        ],
      ),
    );
  }
}

@Preview(name: 'Company branch governance panel')
Widget companyBranchGovernancePanelPreview() {
  return inventoryBranchPreviewScaffold(
    CompanyBranchGovernancePanel(
      summary: inventoryBranchPreviewGovernanceSummary(),
    ),
  );
}
