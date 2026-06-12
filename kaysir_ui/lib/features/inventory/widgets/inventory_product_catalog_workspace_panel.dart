import 'package:flutter/material.dart';

import '../models/inventory_product_catalog.dart';
import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_saved_view.dart';
import '../models/inventory_product_catalog_table_view_state.dart';
import 'inventory_product_catalog_components.dart';
import 'inventory_product_catalog_workspace_contracts.dart';
import 'inventory_product_catalog_workspace_view_actions.dart';

class InventoryProductCatalogWorkspacePanel extends StatelessWidget {
  const InventoryProductCatalogWorkspacePanel({
    super.key,
    required this.workspaceContext,
    required this.selectedProductIds,
    required this.selectionSummary,
    required this.actions,
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

  final InventoryProductCatalogWorkspaceContext workspaceContext;
  final Set<String> selectedProductIds;
  final InventoryProductCatalogSelectionSummary selectionSummary;
  final InventoryProductCatalogWorkspaceViewActions actions;
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
    return InventoryProductCatalogPanel(
      records: workspaceContext.visibleRecords,
      totalCount: workspaceContext.records.length,
      selectedProductIds: selectedProductIds,
      selectionSummary: selectionSummary,
      onResetFilters:
          () => workspaceContext.browserActions.reset(
            filter: InventoryProductCatalogFilter.all,
          ),
      onSelectionChanged: actions.onSelectionChanged,
      onSelectVisibleChanged: actions.onSelectVisibleChanged,
      onSelectRepairCandidates: actions.onSelectRepairCandidates,
      onClearSelection: actions.onClearSelection,
      onBulkChangeCategory: actions.onBulkChangeCategory,
      onBulkUpdatePrice: actions.onBulkUpdatePrice,
      onBulkGenerateSku: actions.onBulkGenerateSku,
      onBulkGenerateShortcut: actions.onBulkGenerateShortcut,
      onBulkFillDescription: actions.onBulkFillDescription,
      onBulkDeleteSelected: actions.onBulkDeleteSelected,
      onEdit: actions.onEditRecord,
      onDuplicate: actions.onDuplicateRecord,
      onDelete: actions.onDeleteRecord,
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
      recordFooterBuilder:
          recordFooterBuilder == null
              ? null
              : (context, record) =>
                  recordFooterBuilder!(context, workspaceContext, record),
    );
  }
}
