import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../../../widgets/ui/app_surface.dart';
import '../../inventory/models/inventory_item.dart';
import '../../inventory/models/inventory_stock_record.dart';
import '../../inventory/models/warehouse.dart';
import '../models/management_pack.dart';
import '../models/product.dart';
import '../models/management_module_brief.dart';
import '../models/sales_channel_profile.dart';
import '../models/sales_channel_profile_pack_overview.dart';
import '../models/product_workspace_action_registry.dart';
import '../models/product_workspace_overview.dart';
import 'management_suite_navigation_items.dart';

/// Compact operational brief for the active product management module.
class ProductManagementSuiteModuleBrief extends StatelessWidget {
  const ProductManagementSuiteModuleBrief({
    super.key,
    required this.activeItem,
    required this.overview,
    required this.action,
    required this.onActionPressed,
  });

  final ProductManagementSuiteNavigationItem activeItem;
  final ProductWorkspaceOverview overview;
  final ProductManagementModuleBriefAction action;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      key: const ValueKey('product-management-suite-module-brief'),
      padding: const EdgeInsets.all(14),
      backgroundColor: colorScheme.surfaceContainerLowest,
      borderColor: colorScheme.outlineVariant.withValues(alpha: 0.72),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heading = _ModuleBriefHeading(
            activeItem: activeItem,
            overview: overview,
          );
          final statusPills = _ModuleBriefStatusPills(
            overview: overview,
            alignment:
                constraints.maxWidth < 760
                    ? WrapAlignment.start
                    : WrapAlignment.end,
          );
          final nextAction = _ModuleBriefNextAction(
            action: action,
            onPressed: onActionPressed,
            alignEnd: constraints.maxWidth >= 760,
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading,
                const SizedBox(height: 12),
                statusPills,
                const SizedBox(height: 12),
                nextAction,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: heading),
              const SizedBox(width: 16),
              Flexible(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    statusPills,
                    const SizedBox(height: 12),
                    nextAction,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

@Preview(name: 'Product management module brief')
Widget productManagementSuiteModuleBriefPreview() {
  final overview = _previewOverview();

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductManagementSuiteModuleBrief(
          activeItem: productManagementSuitePricingManagementItem,
          overview: overview,
          action: defaultProductManagementModuleBriefRegistry.resolve(
            activeDestination:
                productManagementSuitePricingManagementItem.destination,
            overview: overview,
          ),
          onActionPressed: () {},
        ),
      ),
    ),
  );
}

/// Title and catalog scope summary for the active suite module.
class _ModuleBriefHeading extends StatelessWidget {
  const _ModuleBriefHeading({required this.activeItem, required this.overview});

  final ProductManagementSuiteNavigationItem activeItem;
  final ProductWorkspaceOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.24),
            ),
          ),
          child: Icon(activeItem.icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${activeItem.label} snapshot',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                activeItem.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _catalogScopeLabel(overview),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Responsive health pills derived from the shared product workspace overview.
class _ModuleBriefStatusPills extends StatelessWidget {
  const _ModuleBriefStatusPills({
    required this.overview,
    required this.alignment,
  });

  final ProductWorkspaceOverview overview;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final attentionColor =
        overview.hasAttention ? colorScheme.error : colorScheme.secondary;

    return Wrap(
      alignment: alignment,
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusPill(
          label: overview.catalogQualityLabel,
          color: colorScheme.primary,
          icon: Icons.verified_rounded,
          maxWidth: 210,
        ),
        AppStatusPill(
          label: overview.attentionLabel,
          color: attentionColor,
          icon:
              overview.hasAttention
                  ? Icons.priority_high_rounded
                  : Icons.check_circle_rounded,
          maxWidth: 220,
        ),
        AppStatusPill(
          label: overview.workflowReadinessLabel,
          color: colorScheme.tertiary,
          icon: Icons.task_alt_rounded,
          maxWidth: 220,
        ),
        AppStatusPill(
          label: overview.launchQueueLabel,
          color: colorScheme.secondary,
          icon: Icons.rocket_launch_rounded,
          maxWidth: 220,
        ),
      ],
    );
  }
}

/// Next action control resolved by the module brief action registry.
class _ModuleBriefNextAction extends StatelessWidget {
  const _ModuleBriefNextAction({
    required this.action,
    required this.onPressed,
    required this.alignEnd,
  });

  final ProductManagementModuleBriefAction action;
  final VoidCallback onPressed;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final crossAxisAlignment =
        alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;
    final contextLabel = action.contextLabel.trim();
    final headingLabel =
        contextLabel.isEmpty ? 'Next action' : 'Next action / $contextLabel';

    return Wrap(
      alignment: alignEnd ? WrapAlignment.end : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Text(
                headingLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: textAlign,
                style: textTheme.labelSmall?.copyWith(
                  color: _actionColor(colorScheme, action.tone),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                action.detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: textAlign,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        AppActionButton(
          label: action.label,
          icon: _actionIcon(action.tone),
          variant: _actionButtonVariant(action.tone),
          compact: true,
          onPressed: onPressed,
        ),
      ],
    );
  }
}

Color _actionColor(
  ColorScheme colorScheme,
  ProductManagementModuleBriefActionTone tone,
) {
  return switch (tone) {
    ProductManagementModuleBriefActionTone.info => colorScheme.primary,
    ProductManagementModuleBriefActionTone.success => colorScheme.secondary,
    ProductManagementModuleBriefActionTone.warning => colorScheme.tertiary,
    ProductManagementModuleBriefActionTone.danger => colorScheme.error,
  };
}

IconData _actionIcon(ProductManagementModuleBriefActionTone tone) {
  return switch (tone) {
    ProductManagementModuleBriefActionTone.info => Icons.arrow_forward_rounded,
    ProductManagementModuleBriefActionTone.success => Icons.task_alt_rounded,
    ProductManagementModuleBriefActionTone.warning =>
      Icons.priority_high_rounded,
    ProductManagementModuleBriefActionTone.danger => Icons.report_rounded,
  };
}

AppActionButtonVariant _actionButtonVariant(
  ProductManagementModuleBriefActionTone tone,
) {
  return switch (tone) {
    ProductManagementModuleBriefActionTone.info =>
      AppActionButtonVariant.secondary,
    ProductManagementModuleBriefActionTone.success =>
      AppActionButtonVariant.secondary,
    ProductManagementModuleBriefActionTone.warning =>
      AppActionButtonVariant.primary,
    ProductManagementModuleBriefActionTone.danger =>
      AppActionButtonVariant.destructive,
  };
}

String _catalogScopeLabel(ProductWorkspaceOverview overview) {
  return '${_countLabel(overview.summary.productCount, 'product')} across '
      '${_countLabel(overview.summary.categoryCount, 'category', 'categories')}';
}

String _countLabel(int count, String noun, [String? pluralNoun]) {
  if (count == 1) return '1 $noun';

  return '$count ${pluralNoun ?? '${noun}s'}';
}

ProductWorkspaceOverview _previewOverview() {
  final products = [
    Product(
      id: 'preview-coffee-beans',
      name: 'House Blend Beans',
      sku: 'COF-001',
      category: 'Coffee',
      description: 'Whole bean retail pack',
      price: 12,
      customAttributes: const {'available_channels': 'POS, Online'},
    ),
    Product(
      id: 'preview-cold-brew',
      name: 'Cold Brew Bottle',
      sku: 'DRK-014',
      category: 'Beverage',
      price: 5,
    ),
    Product(
      id: 'preview-filter-paper',
      name: 'Filter Paper',
      sku: 'SUP-090',
      category: 'Supplies',
      description: 'Reusable brew bar supply',
      price: 3,
      customAttributes: const {'available_channels': 'POS'},
    ),
  ];
  final warehouses = [
    Warehouse(id: 'preview-main', name: 'Main Store', location: 'Jakarta'),
  ];
  final inventoryItems = [
    InventoryItem(
      id: 'preview-stock-1',
      productId: 'preview-coffee-beans',
      warehouseId: 'preview-main',
      currentQuantity: 24,
      reorderPoint: 8,
      reorderQuantity: 20,
    ),
    InventoryItem(
      id: 'preview-stock-2',
      productId: 'preview-cold-brew',
      warehouseId: 'preview-main',
      currentQuantity: 3,
      reorderPoint: 10,
      reorderQuantity: 18,
    ),
  ];
  final registry = defaultProductSalesChannelProfileRegistry;
  final channelProfile = omniRetailProductSalesChannelProfile;

  return buildProductWorkspaceOverview(
    products: products,
    stockRecords: buildInventoryStockRecords(
      inventoryItems: inventoryItems,
      products: products,
      warehouses: warehouses,
    ),
    actionRegistry: ProductWorkspaceActionRegistry(
      pack: coreProductManagementPack,
    ),
    managementPack: coreProductManagementPack,
    channelProfiles: registry.profiles,
    channelProfile: channelProfile,
    channelProfilePackOverview: buildProductSalesChannelProfilePackOverview(
      packs: [defaultProductSalesChannelProfilePack],
      registry: registry,
      selectedProfile: channelProfile,
    ),
  );
}
