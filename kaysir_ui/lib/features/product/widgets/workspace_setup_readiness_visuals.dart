import 'package:flutter/material.dart';

import '../models/product_workspace_setup_readiness.dart';

/// Resolves the semantic color for a setup readiness summary.
Color productWorkspaceSetupReadinessColor(
  ColorScheme colorScheme,
  ProductWorkspaceSetupReadiness readiness,
) {
  if (readiness.hasBlockedRequirements) return colorScheme.error;
  if (readiness.hasMissingRequirements) return colorScheme.tertiary;
  if (readiness.isReady) return colorScheme.primary;

  return colorScheme.secondary;
}

/// Resolves the leading icon for a setup readiness summary.
IconData productWorkspaceSetupReadinessIcon(
  ProductWorkspaceSetupReadiness readiness,
) {
  if (readiness.hasBlockedRequirements) return Icons.block_rounded;
  if (readiness.hasMissingRequirements) return Icons.build_rounded;
  if (readiness.isReady) return Icons.verified_rounded;

  return Icons.rule_rounded;
}

/// Resolves the semantic color for an individual setup requirement status.
Color productWorkspaceSetupRequirementStatusColor(
  ColorScheme colorScheme,
  ProductWorkspaceSetupRequirementStatus status,
) {
  return switch (status) {
    ProductWorkspaceSetupRequirementStatus.ready => colorScheme.primary,
    ProductWorkspaceSetupRequirementStatus.missing => colorScheme.tertiary,
    ProductWorkspaceSetupRequirementStatus.blocked => colorScheme.error,
    ProductWorkspaceSetupRequirementStatus.optional => colorScheme.secondary,
  };
}

/// Resolves the leading icon for an individual setup requirement status.
IconData productWorkspaceSetupRequirementStatusIcon(
  ProductWorkspaceSetupRequirementStatus status,
) {
  return switch (status) {
    ProductWorkspaceSetupRequirementStatus.ready => Icons.verified_rounded,
    ProductWorkspaceSetupRequirementStatus.missing => Icons.build_rounded,
    ProductWorkspaceSetupRequirementStatus.blocked => Icons.block_rounded,
    ProductWorkspaceSetupRequirementStatus.optional =>
      Icons.info_outline_rounded,
  };
}
