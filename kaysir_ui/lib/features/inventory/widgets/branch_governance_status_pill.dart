import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/company_branch_governance.dart';
import 'branch_governance_visuals.dart';
import 'branch_preview_data.dart';

/// Panel-level status pill for overall branch governance readiness.
class CompanyBranchGovernanceStatusPill extends StatelessWidget {
  const CompanyBranchGovernanceStatusPill({super.key, required this.summary});

  final CompanyBranchGovernanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: summary.riskCount == 0 ? 'Governance ready' : 'Needs review',
      icon:
          summary.riskCount == 0
              ? Icons.verified_outlined
              : Icons.warning_amber_rounded,
      color: companyBranchGovernanceRiskColor(summary.riskCount),
      maxWidth: 170,
    );
  }
}

/// Tile-level readiness pill for a single branch governance record.
class CompanyBranchGovernanceReadinessPill extends StatelessWidget {
  const CompanyBranchGovernanceReadinessPill({super.key, required this.item});

  final CompanyBranchGovernanceItem item;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: '${item.readinessScore}% ready',
      icon: item.isReady ? Icons.verified_outlined : Icons.rule_rounded,
      color: companyBranchGovernanceReadinessColor(item),
      maxWidth: 130,
    );
  }
}

@Preview(name: 'Company branch governance status')
Widget companyBranchGovernanceStatusPillPreview() {
  return inventoryBranchPreviewScaffold(
    CompanyBranchGovernanceStatusPill(
      summary: inventoryBranchPreviewGovernanceSummary(),
    ),
  );
}

@Preview(name: 'Company branch governance readiness')
Widget companyBranchGovernanceReadinessPillPreview() {
  return inventoryBranchPreviewScaffold(
    CompanyBranchGovernanceReadinessPill(
      item: inventoryBranchPreviewGovernanceSummary().items.first,
    ),
  );
}
