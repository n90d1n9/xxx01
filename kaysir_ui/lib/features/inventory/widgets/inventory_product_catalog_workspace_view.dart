import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

import '../models/inventory_product_catalog.dart';
import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_saved_view.dart';
import '../models/inventory_product_catalog_table_view_state.dart';
import 'inventory_product_catalog_components.dart';
import 'inventory_product_catalog_workspace_contracts.dart';
import 'inventory_product_catalog_workspace_filters.dart';
import 'inventory_product_catalog_workspace_header.dart';
import 'inventory_product_catalog_workspace_panel.dart';
import 'inventory_product_catalog_workspace_view_actions.dart';

class InventoryProductCatalogWorkspaceView extends StatelessWidget {
  const InventoryProductCatalogWorkspaceView({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.padding,
    required this.workspaceContext,
    required this.selectedProductIds,
    required this.selectionSummary,
    required this.actions,
    this.filterAccessoryBuilder,
    this.extensionBuilder,
    this.recordFooterBuilder,
    this.initialPresentationState,
    this.savedViews = const <InventoryProductCatalogSavedView>[],
    this.activeSavedViewId,
    this.defaultSavedViewId,
    this.onSavedViewSelected,
    this.onSaveCurrentView,
    this.onSavedViewCopied,
    this.onSavedViewRenamed,
    this.onSavedViewUpdated,
    this.onSavedViewDeleted,
    this.onDefaultSavedViewChanged,
    this.canCopySavedView,
    this.canRenameSavedView,
    this.canUpdateSavedView,
    this.canDeleteSavedView,
    this.canSetDefaultSavedView,
    this.savedViewSectionLabel,
    this.onPresentationStateChanged,
    this.initialTableViewState,
    this.initialViewMode = InventoryProductCatalogViewMode.cards,
    this.onViewModeChanged,
    this.onTableViewStateChanged,
    this.tableColumnContributions =
        const <InventoryProductCatalogTableColumnContribution>[],
  });

  final String eyebrow;
  final String title;
  final EdgeInsetsGeometry padding;
  final InventoryProductCatalogWorkspaceContext workspaceContext;
  final Set<String> selectedProductIds;
  final InventoryProductCatalogSelectionSummary selectionSummary;
  final InventoryProductCatalogWorkspaceViewActions actions;
  final InventoryProductCatalogWorkspaceFilterAccessoryBuilder?
  filterAccessoryBuilder;
  final InventoryProductCatalogWorkspaceExtensionBuilder? extensionBuilder;
  final InventoryProductCatalogWorkspaceRecordFooterBuilder?
  recordFooterBuilder;
  final InventoryProductCatalogPresentationState? initialPresentationState;
  final List<InventoryProductCatalogSavedView> savedViews;
  final String? activeSavedViewId;
  final String? defaultSavedViewId;
  final ValueChanged<InventoryProductCatalogSavedView>? onSavedViewSelected;
  final ValueChanged<InventoryProductCatalogPresentationState>?
  onSaveCurrentView;
  final ValueChanged<InventoryProductCatalogSavedView>? onSavedViewCopied;
  final ValueChanged<InventoryProductCatalogSavedView>? onSavedViewRenamed;
  final InventoryProductCatalogSavedViewStateChanged? onSavedViewUpdated;
  final ValueChanged<InventoryProductCatalogSavedView>? onSavedViewDeleted;
  final InventoryProductCatalogSavedViewDefaultChanged?
  onDefaultSavedViewChanged;
  final InventoryProductCatalogSavedViewActionPredicate? canCopySavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canRenameSavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canUpdateSavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canDeleteSavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canSetDefaultSavedView;
  final InventoryProductCatalogSavedViewSectionLabel? savedViewSectionLabel;
  final ValueChanged<InventoryProductCatalogPresentationState>?
  onPresentationStateChanged;
  final InventoryProductCatalogTableViewState? initialTableViewState;
  final InventoryProductCatalogViewMode initialViewMode;
  final ValueChanged<InventoryProductCatalogViewMode>? onViewModeChanged;
  final ValueChanged<InventoryProductCatalogTableViewState>?
  onTableViewStateChanged;
  final List<InventoryProductCatalogTableColumnContribution>
  tableColumnContributions;

  @override
  Widget build(BuildContext context) {
    final filterAccessory = filterAccessoryBuilder?.call(
      context,
      workspaceContext,
    );
    final extensions =
        extensionBuilder?.call(context, workspaceContext) ?? const <Widget>[];

    return AppListSurface(
      padding: padding,
      sectionSpacing: 20,
      header: InventoryProductCatalogWorkspaceHeader(
        eyebrow: eyebrow,
        title: title,
        summary: workspaceContext.summary,
        onAddProduct: actions.onAddProduct,
      ),
      metrics: InventoryProductCatalogSummaryGrid(
        summary: workspaceContext.summary,
      ),
      filters: InventoryProductCatalogWorkspaceFilters(
        workspaceContext: workspaceContext,
        filterAccessory: filterAccessory,
      ),
      children: [
        InventoryProductCatalogWorkspacePanel(
          workspaceContext: workspaceContext,
          selectedProductIds: selectedProductIds,
          selectionSummary: selectionSummary,
          actions: actions,
          initialPresentationState: initialPresentationState,
          savedViews: savedViews,
          activeSavedViewId: activeSavedViewId,
          defaultSavedViewId: defaultSavedViewId,
          onSavedViewSelected: onSavedViewSelected,
          onSaveCurrentView: onSaveCurrentView,
          onSavedViewCopied: onSavedViewCopied,
          onSavedViewRenamed: onSavedViewRenamed,
          onSavedViewUpdated: onSavedViewUpdated,
          onSavedViewDeleted: onSavedViewDeleted,
          onDefaultSavedViewChanged: onDefaultSavedViewChanged,
          canCopySavedView: canCopySavedView,
          canRenameSavedView: canRenameSavedView,
          canUpdateSavedView: canUpdateSavedView,
          canDeleteSavedView: canDeleteSavedView,
          canSetDefaultSavedView: canSetDefaultSavedView,
          savedViewSectionLabel: savedViewSectionLabel,
          onPresentationStateChanged: onPresentationStateChanged,
          initialTableViewState: initialTableViewState,
          initialViewMode: initialViewMode,
          onViewModeChanged: onViewModeChanged,
          onTableViewStateChanged: onTableViewStateChanged,
          tableColumnContributions: tableColumnContributions,
          recordFooterBuilder: recordFooterBuilder,
        ),
        ...extensions,
      ],
    );
  }
}
