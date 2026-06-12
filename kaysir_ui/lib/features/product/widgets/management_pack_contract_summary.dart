import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack.dart';
import '../models/management_pack_contribution_bundle.dart';
import 'management_pack_contract_grid.dart';
import 'management_pack_contract_metrics.dart';

/// Combined contract summary for a product management pack.
class ProductManagementPackContractSummary extends StatelessWidget {
  const ProductManagementPackContractSummary({super.key, required this.bundle});

  final ProductManagementPackContributionBundle bundle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductManagementPackContractMetrics(bundle: bundle),
        const SizedBox(height: 18),
        ProductManagementPackContractGrid(bundle: bundle),
      ],
    );
  }
}

@Preview(name: 'Management pack contract summary')
Widget productManagementPackContractSummaryPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackContractSummary(bundle: _previewBundle),
      ),
    ),
  );
}

final _previewBundle = ProductManagementPackContributionBundle(
  managementPack: coreProductManagementPack,
  workspaceActionGroups: const [],
  actionContributions: const [],
  recommendationContributions: const [],
);
