import 'package:flutter/material.dart';

import '../models/management_pack_contribution_bundle.dart';

/// Icon used for a contribution kind across pack contract surfaces.
IconData productManagementPackContributionKindIcon(
  ProductManagementPackContributionKind kind,
) {
  switch (kind) {
    case ProductManagementPackContributionKind.workspaceAction:
      return Icons.bolt_rounded;
    case ProductManagementPackContributionKind.setupReadiness:
      return Icons.fact_check_rounded;
    case ProductManagementPackContributionKind.recommendation:
      return Icons.auto_awesome_rounded;
    case ProductManagementPackContributionKind.moduleBriefAction:
      return Icons.ads_click_rounded;
    case ProductManagementPackContributionKind.availabilityTemplate:
      return Icons.rule_rounded;
  }
}

/// Accent color used for a contribution kind across pack contract surfaces.
Color productManagementPackContributionKindColor(
  ProductManagementPackContributionKind kind,
) {
  switch (kind) {
    case ProductManagementPackContributionKind.workspaceAction:
      return Colors.deepOrange.shade700;
    case ProductManagementPackContributionKind.setupReadiness:
      return Colors.indigo.shade700;
    case ProductManagementPackContributionKind.recommendation:
      return Colors.teal.shade700;
    case ProductManagementPackContributionKind.moduleBriefAction:
      return Colors.purple.shade700;
    case ProductManagementPackContributionKind.availabilityTemplate:
      return Colors.blueGrey.shade700;
  }
}
