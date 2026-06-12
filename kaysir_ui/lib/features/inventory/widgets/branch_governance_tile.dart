import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/company_branch_governance.dart';
import 'branch_governance_details.dart';
import 'branch_governance_status_pill.dart';
import 'branch_governance_visuals.dart';
import 'branch_preview_data.dart';

/// Responsive tile for one branch's company governance readiness record.
class CompanyBranchGovernanceTile extends StatelessWidget {
  const CompanyBranchGovernanceTile({super.key, required this.item});

  final CompanyBranchGovernanceItem item;

  @override
  Widget build(BuildContext context) {
    final color = companyBranchGovernanceReadinessColor(item);
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final heading = AppInfoRow(
              icon: Icons.business_rounded,
              iconStyle: AppInfoRowIconStyle.badge,
              iconBackgroundColor: color.withValues(alpha: 0.12),
              iconForegroundColor: color,
              title: item.branchName,
              subtitle: '${item.branchCode} | ${item.legalEntity}',
              titleMaxLines: 2,
              subtitleMaxLines: 2,
              padding: EdgeInsets.zero,
            );
            final status = CompanyBranchGovernanceReadinessPill(item: item);
            final details = CompanyBranchGovernanceDetails(item: item);

            if (constraints.maxWidth < 780) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  heading,
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: status),
                  const SizedBox(height: 12),
                  details,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: heading),
                const SizedBox(width: 14),
                Expanded(child: details),
                const SizedBox(width: 12),
                status,
              ],
            );
          },
        ),
      ),
    );
  }
}

@Preview(name: 'Company branch governance tile')
Widget companyBranchGovernanceTilePreview() {
  return inventoryBranchPreviewScaffold(
    CompanyBranchGovernanceTile(
      item: inventoryBranchPreviewGovernanceSummary().items.first,
    ),
  );
}
