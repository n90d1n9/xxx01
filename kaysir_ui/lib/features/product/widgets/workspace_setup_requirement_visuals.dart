import 'package:flutter/material.dart';

import '../models/product_workspace_setup_target.dart';

/// Resolves the semantic color for a setup requirement type.
Color productWorkspaceSetupRequirementColor(
  ColorScheme colorScheme,
  ProductWorkspaceSetupRequirementType type,
) {
  return switch (type) {
    ProductWorkspaceSetupRequirementType.data => colorScheme.primary,
    ProductWorkspaceSetupRequirementType.workflow => colorScheme.tertiary,
    ProductWorkspaceSetupRequirementType.channel => colorScheme.secondary,
    ProductWorkspaceSetupRequirementType.integration => colorScheme.error,
  };
}

/// Resolves the leading icon for a setup requirement type.
IconData productWorkspaceSetupRequirementIcon(
  ProductWorkspaceSetupRequirementType type,
) {
  return switch (type) {
    ProductWorkspaceSetupRequirementType.data => Icons.dataset_rounded,
    ProductWorkspaceSetupRequirementType.workflow => Icons.bolt_rounded,
    ProductWorkspaceSetupRequirementType.channel => Icons.route_rounded,
    ProductWorkspaceSetupRequirementType.integration =>
      Icons.account_tree_rounded,
  };
}
