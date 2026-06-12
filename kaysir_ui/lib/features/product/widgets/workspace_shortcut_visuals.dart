import 'package:flutter/material.dart';

import '../models/product_workspace_shortcut.dart';

/// Builds the icon for a product workspace shortcut.
typedef ProductWorkspaceShortcutIconBuilder =
    IconData Function(ProductWorkspaceShortcut shortcut);

/// Builds the accent color for a product workspace shortcut.
typedef ProductWorkspaceShortcutColorBuilder =
    Color Function(BuildContext context, ProductWorkspaceShortcut shortcut);

/// Default icon mapping for product workspace shortcuts.
IconData defaultProductWorkspaceShortcutIcon(
  ProductWorkspaceShortcut shortcut,
) {
  switch (shortcut.id) {
    case ProductWorkspaceShortcutId.strategy:
      return Icons.tune_rounded;
    case ProductWorkspaceShortcutId.assortmentPlanning:
      return Icons.view_cozy_rounded;
    case ProductWorkspaceShortcutId.categoryManagement:
      return Icons.category_rounded;
    case ProductWorkspaceShortcutId.pricingManagement:
      return Icons.sell_rounded;
    case ProductWorkspaceShortcutId.sourcingManagement:
      return Icons.local_shipping_rounded;
    case ProductWorkspaceShortcutId.lifecycleManagement:
      return Icons.flag_circle_rounded;
    case ProductWorkspaceShortcutId.variantManagement:
      return Icons.layers_rounded;
    case ProductWorkspaceShortcutId.relationshipManagement:
      return Icons.link_rounded;
    case ProductWorkspaceShortcutId.availabilityManagement:
      return Icons.event_available_rounded;
    case ProductWorkspaceShortcutId.channelReadiness:
      return Icons.hub_rounded;
    case ProductWorkspaceShortcutId.setupTargets:
      return Icons.rule_rounded;
    case ProductWorkspaceShortcutId.packContracts:
      return Icons.account_tree_rounded;
    case ProductWorkspaceShortcutId.catalog:
      return Icons.inventory_2_rounded;
    case ProductWorkspaceShortcutId.freshnessReview:
      return Icons.eco_rounded;
    case ProductWorkspaceShortcutId.addProduct:
      return Icons.add_business_rounded;
    case ProductWorkspaceShortcutId.stockMovements:
      return Icons.timeline_rounded;
    case ProductWorkspaceShortcutId.addStockMovement:
      return Icons.add_box_rounded;
    case ProductWorkspaceShortcutId.stockOpname:
      return Icons.fact_check_rounded;
    case ProductWorkspaceShortcutId.scanProduct:
      return Icons.document_scanner_rounded;
    case ProductWorkspaceShortcutId.discrepancyReport:
      return Icons.rule_rounded;
    case ProductWorkspaceShortcutId.freshnessQueue:
      return Icons.eco_rounded;
    case ProductWorkspaceShortcutId.attentionReview:
      return Icons.warning_amber_rounded;
  }
}

/// Default accent color mapping for product workspace shortcuts.
Color defaultProductWorkspaceShortcutColor(
  BuildContext context,
  ProductWorkspaceShortcut shortcut,
) {
  final colorScheme = Theme.of(context).colorScheme;

  switch (shortcut.id) {
    case ProductWorkspaceShortcutId.strategy:
      return Colors.indigo.shade700;
    case ProductWorkspaceShortcutId.assortmentPlanning:
      return Colors.pink.shade700;
    case ProductWorkspaceShortcutId.categoryManagement:
      return Colors.deepPurple.shade600;
    case ProductWorkspaceShortcutId.pricingManagement:
      return Colors.amber.shade800;
    case ProductWorkspaceShortcutId.sourcingManagement:
      return Colors.lightBlue.shade800;
    case ProductWorkspaceShortcutId.lifecycleManagement:
      return Colors.green.shade800;
    case ProductWorkspaceShortcutId.variantManagement:
      return Colors.cyan.shade800;
    case ProductWorkspaceShortcutId.relationshipManagement:
      return Colors.indigo.shade800;
    case ProductWorkspaceShortcutId.availabilityManagement:
      return Colors.deepOrange.shade700;
    case ProductWorkspaceShortcutId.channelReadiness:
      return Colors.teal.shade700;
    case ProductWorkspaceShortcutId.setupTargets:
      return Colors.orange.shade700;
    case ProductWorkspaceShortcutId.packContracts:
      return Colors.blueGrey.shade700;
    case ProductWorkspaceShortcutId.catalog:
      return Colors.blue.shade700;
    case ProductWorkspaceShortcutId.freshnessReview:
      return Colors.lightGreen.shade700;
    case ProductWorkspaceShortcutId.addProduct:
      return Colors.cyan.shade700;
    case ProductWorkspaceShortcutId.stockMovements:
      return Colors.teal.shade700;
    case ProductWorkspaceShortcutId.addStockMovement:
      return Colors.green.shade700;
    case ProductWorkspaceShortcutId.stockOpname:
      return Colors.indigo.shade600;
    case ProductWorkspaceShortcutId.scanProduct:
      return Colors.deepPurple.shade600;
    case ProductWorkspaceShortcutId.discrepancyReport:
      return Colors.orange.shade700;
    case ProductWorkspaceShortcutId.freshnessQueue:
      return Colors.lightGreen.shade700;
    case ProductWorkspaceShortcutId.attentionReview:
      return colorScheme.error;
  }
}
