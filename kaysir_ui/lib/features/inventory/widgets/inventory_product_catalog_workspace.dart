import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_browser_filter_host.dart';

import '../../product/models/product.dart';
import '../models/inventory_product_catalog.dart';
import '../models/inventory_product_catalog_operation.dart';
import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_saved_view.dart';
import '../models/inventory_product_catalog_table_view_state.dart';
import '../models/inventory_product_catalog_view_mode.dart';
import '../states/inventory_projection_provider.dart';
import '../states/product_provider.dart';
import 'inventory_product_catalog_workspace_actions.dart';
import 'inventory_product_catalog_workspace_contracts.dart';
import 'inventory_product_catalog_workspace_controller.dart';
import 'inventory_product_catalog_workspace_mutations.dart';
import 'inventory_product_catalog_workspace_selection.dart';
import 'inventory_product_catalog_workspace_view.dart';
import 'inventory_product_catalog_saved_view_button.dart';
import 'inventory_product_catalog_table_column_contribution.dart';

export 'inventory_product_catalog_workspace_contracts.dart';

class InventoryProductCatalogWorkspace extends ConsumerStatefulWidget {
  const InventoryProductCatalogWorkspace({
    super.key,
    this.eyebrow = 'Product Operations',
    this.title = 'Product Directory',
    this.padding = const EdgeInsets.all(20),
    this.initialFilter = InventoryProductCatalogFilter.all,
    this.initialQuery = '',
    this.filterAccessoryBuilder,
    this.extensionBuilder,
    this.onOperationCompleted,
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
    this.onAddProduct,
    this.onEditProduct,
    this.mutationSync,
    this.tableColumnContributions =
        const <InventoryProductCatalogTableColumnContribution>[],
  });

  final String eyebrow;
  final String title;
  final EdgeInsetsGeometry padding;
  final InventoryProductCatalogFilter initialFilter;
  final String initialQuery;
  final InventoryProductCatalogWorkspaceFilterAccessoryBuilder?
  filterAccessoryBuilder;
  final InventoryProductCatalogWorkspaceExtensionBuilder? extensionBuilder;
  final ValueChanged<InventoryProductCatalogOperationResult>?
  onOperationCompleted;
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
  final VoidCallback? onAddProduct;
  final ValueChanged<Product>? onEditProduct;
  final InventoryProductCatalogMutationSync? mutationSync;
  final List<InventoryProductCatalogTableColumnContribution>
  tableColumnContributions;

  @override
  ConsumerState<InventoryProductCatalogWorkspace> createState() =>
      _InventoryProductCatalogWorkspaceState();
}

class _InventoryProductCatalogWorkspaceState
    extends ConsumerState<InventoryProductCatalogWorkspace>
    with
        InventoryProductCatalogWorkspaceSelectionController<
          InventoryProductCatalogWorkspace
        >,
        InventoryProductCatalogWorkspaceProductMutationController<
          InventoryProductCatalogWorkspace
        >,
        InventoryProductCatalogWorkspaceBulkMutationController<
          InventoryProductCatalogWorkspace
        >,
        InventoryProductCatalogWorkspaceMutationController<
          InventoryProductCatalogWorkspace
        >,
        InventoryProductCatalogWorkspaceProductDialogController<
          InventoryProductCatalogWorkspace
        >,
        InventoryProductCatalogWorkspaceBulkDialogController<
          InventoryProductCatalogWorkspace
        >,
        InventoryProductCatalogWorkspaceOperationController<
          InventoryProductCatalogWorkspace
        >,
        InventoryProductCatalogWorkspaceActionController<
          InventoryProductCatalogWorkspace
        > {
  final _selectedProductIds = <String>{};

  @override
  Set<String> get selectedProductIds => _selectedProductIds;

  @override
  void notifyOperationCompleted(InventoryProductCatalogOperationResult result) {
    widget.onOperationCompleted?.call(result);
  }

  @override
  void syncProductCatalogUpserts(List<Product> products) {
    widget.mutationSync?.upsertProducts(products);
  }

  @override
  void syncProductCatalogDeletes(Set<String> productIds) {
    widget.mutationSync?.deleteProductIds(productIds);
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final stockRecords = ref.watch(inventoryStockRecordsProvider);
    final records = buildInventoryProductCatalogRecords(
      products: products,
      stockRecords: stockRecords,
    );
    final summary = summarizeInventoryProductCatalogRecords(records);
    final activeSelection = activeSelectionSnapshot(records);

    return POSBrowserFilterHost<InventoryProductCatalogFilter>(
      initialFilter: widget.initialFilter,
      initialQuery: widget.initialQuery,
      builder: (context, browserController, browserActions) {
        final visibleRecords = filterInventoryProductCatalogRecords(
          records: records,
          query: browserController.query,
          filter: browserController.filter,
        );
        final workspaceContext = InventoryProductCatalogWorkspaceContext(
          records: records,
          visibleRecords: visibleRecords,
          summary: summary,
          browserController: browserController,
          browserActions: browserActions,
          openProductEditor:
              (product, {focusTarget}) => showAddEditProductDialog(
                context,
                product: product,
                focusTarget: focusTarget,
              ),
        );
        return InventoryProductCatalogWorkspaceView(
          eyebrow: widget.eyebrow,
          title: widget.title,
          padding: widget.padding,
          workspaceContext: workspaceContext,
          selectedProductIds: activeSelection.selectedIds,
          selectionSummary: activeSelection.summary,
          filterAccessoryBuilder: widget.filterAccessoryBuilder,
          extensionBuilder: widget.extensionBuilder,
          recordFooterBuilder: widget.recordFooterBuilder,
          initialPresentationState: widget.initialPresentationState,
          savedViews: widget.savedViews,
          activeSavedViewId: widget.activeSavedViewId,
          defaultSavedViewId: widget.defaultSavedViewId,
          onSavedViewSelected: widget.onSavedViewSelected,
          onSaveCurrentView: widget.onSaveCurrentView,
          onSavedViewCopied: widget.onSavedViewCopied,
          onSavedViewRenamed: widget.onSavedViewRenamed,
          onSavedViewUpdated: widget.onSavedViewUpdated,
          onSavedViewDeleted: widget.onSavedViewDeleted,
          onDefaultSavedViewChanged: widget.onDefaultSavedViewChanged,
          canCopySavedView: widget.canCopySavedView,
          canRenameSavedView: widget.canRenameSavedView,
          canUpdateSavedView: widget.canUpdateSavedView,
          canDeleteSavedView: widget.canDeleteSavedView,
          canSetDefaultSavedView: widget.canSetDefaultSavedView,
          savedViewSectionLabel: widget.savedViewSectionLabel,
          onPresentationStateChanged: widget.onPresentationStateChanged,
          initialTableViewState: widget.initialTableViewState,
          initialViewMode: widget.initialViewMode,
          onViewModeChanged: widget.onViewModeChanged,
          onTableViewStateChanged: widget.onTableViewStateChanged,
          tableColumnContributions: widget.tableColumnContributions,
          actions: buildProductCatalogWorkspaceViewActions(
            context: context,
            visibleRecords: visibleRecords,
            activeSelection: activeSelection,
            onAddProductOverride: widget.onAddProduct,
            onEditProductOverride: widget.onEditProduct,
          ),
        );
      },
    );
  }
}
