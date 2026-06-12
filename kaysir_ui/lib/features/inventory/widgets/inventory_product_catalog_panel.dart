import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/inventory_product_catalog.dart';
import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_saved_view.dart';
import '../models/inventory_product_catalog_table_preferences.dart';
import '../models/inventory_product_catalog_table_sort.dart';
import '../models/inventory_product_catalog_table_view_state.dart';
import '../models/inventory_product_catalog_view_mode.dart';
import '../states/product_catalog_panel_controller.dart';
import '../states/product_catalog_panel_state.dart';
import 'inventory_product_catalog_panel_content.dart';
import 'inventory_product_catalog_panel_trailing_controls.dart';
import 'inventory_product_catalog_record_footer_builder.dart';
import 'inventory_product_catalog_saved_view_button.dart';
import 'inventory_product_catalog_table_column_contribution.dart';
import 'product_catalog_preview_data.dart';

/// Stateful product catalog panel with card/table presentation controls.
class InventoryProductCatalogPanel extends StatefulWidget {
  const InventoryProductCatalogPanel({
    super.key,
    required this.records,
    required this.totalCount,
    this.selectedProductIds = const <String>{},
    this.selectionSummary,
    this.onResetFilters,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.onSelectionChanged,
    this.onSelectVisibleChanged,
    this.onSelectRepairCandidates,
    this.onClearSelection,
    this.onBulkChangeCategory,
    this.onBulkUpdatePrice,
    this.onBulkGenerateSku,
    this.onBulkGenerateShortcut,
    this.onBulkFillDescription,
    this.onBulkDeleteSelected,
    this.initialTablePreferences =
        const InventoryProductCatalogTablePreferences(),
    this.initialTableSortState = const InventoryProductCatalogTableSortState(),
    this.initialTableViewState,
    this.initialViewMode = InventoryProductCatalogViewMode.cards,
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
    this.onViewModeChanged,
    this.onTablePreferencesChanged,
    this.onTableSortStateChanged,
    this.onTableViewStateChanged,
    this.onPresentationStateChanged,
    this.recordFooterBuilder,
    this.tableColumnContributions =
        const <InventoryProductCatalogTableColumnContribution>[],
  });

  final List<InventoryProductCatalogRecord> records;
  final int totalCount;
  final Set<String> selectedProductIds;
  final InventoryProductCatalogSelectionSummary? selectionSummary;
  final VoidCallback? onResetFilters;
  final ValueChanged<InventoryProductCatalogRecord>? onEdit;
  final ValueChanged<InventoryProductCatalogRecord>? onDuplicate;
  final ValueChanged<InventoryProductCatalogRecord>? onDelete;
  final void Function(InventoryProductCatalogRecord record, bool selected)?
  onSelectionChanged;
  final ValueChanged<bool>? onSelectVisibleChanged;
  final ValueChanged<InventoryProductCatalogRepairTarget>?
  onSelectRepairCandidates;
  final VoidCallback? onClearSelection;
  final VoidCallback? onBulkChangeCategory;
  final VoidCallback? onBulkUpdatePrice;
  final VoidCallback? onBulkGenerateSku;
  final VoidCallback? onBulkGenerateShortcut;
  final VoidCallback? onBulkFillDescription;
  final VoidCallback? onBulkDeleteSelected;
  final InventoryProductCatalogTablePreferences initialTablePreferences;
  final InventoryProductCatalogTableSortState initialTableSortState;
  final InventoryProductCatalogTableViewState? initialTableViewState;
  final InventoryProductCatalogViewMode initialViewMode;
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
  final ValueChanged<InventoryProductCatalogViewMode>? onViewModeChanged;
  final ValueChanged<InventoryProductCatalogTablePreferences>?
  onTablePreferencesChanged;
  final ValueChanged<InventoryProductCatalogTableSortState>?
  onTableSortStateChanged;
  final ValueChanged<InventoryProductCatalogTableViewState>?
  onTableViewStateChanged;
  final ValueChanged<InventoryProductCatalogPresentationState>?
  onPresentationStateChanged;
  final InventoryProductCatalogRecordFooterBuilder? recordFooterBuilder;
  final List<InventoryProductCatalogTableColumnContribution>
  tableColumnContributions;

  @override
  State<InventoryProductCatalogPanel> createState() =>
      _InventoryProductCatalogPanelState();
}

class _InventoryProductCatalogPanelState
    extends State<InventoryProductCatalogPanel> {
  late final InventoryProductCatalogPanelController _controller =
      InventoryProductCatalogPanelController(
        initialPresentationState: widget.initialPresentationState,
        initialViewMode: widget.initialViewMode,
        initialTableViewState: widget.initialTableViewState,
        initialTablePreferences: widget.initialTablePreferences,
        initialTableSortState: widget.initialTableSortState,
      );

  @override
  void didUpdateWidget(covariant InventoryProductCatalogPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.syncInitialState(
      initialPresentationState: widget.initialPresentationState,
      initialViewMode: widget.initialViewMode,
      initialTableViewState: widget.initialTableViewState,
      initialTablePreferences: widget.initialTablePreferences,
      initialTableSortState: widget.initialTableSortState,
    );
  }

  @override
  Widget build(BuildContext context) {
    final presentationState = _controller.presentationState;

    return AppContentPanel(
      title: 'Product Catalog',
      subtitle:
          '${widget.records.length} of ${widget.totalCount} products visible',
      leadingIcon: Icons.inventory_2_rounded,
      trailing: widget.records.isEmpty
          ? null
          : InventoryProductCatalogPanelTrailingControls(
              presentationState: presentationState,
              savedViews: widget.savedViews,
              activeSavedViewId: widget.activeSavedViewId,
              defaultSavedViewId: widget.defaultSavedViewId,
              onSavedViewSelected: _applySavedView,
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
              onPresentationStateChanged: _setPresentationStateFromControls,
              onTablePreferencesChanged: _setTablePreferences,
              onTablePresetSelected: _applyTablePreset,
              columnContributions: widget.tableColumnContributions,
            ),
      child: InventoryProductCatalogPanelContent(
        records: widget.records,
        selectedProductIds: widget.selectedProductIds,
        selectionSummary: widget.selectionSummary,
        presentationState: presentationState,
        onResetFilters: widget.onResetFilters,
        onEdit: widget.onEdit,
        onDuplicate: widget.onDuplicate,
        onDelete: widget.onDelete,
        onSelectionChanged: widget.onSelectionChanged,
        onSelectVisibleChanged: widget.onSelectVisibleChanged,
        onSelectRepairCandidates: widget.onSelectRepairCandidates,
        onClearSelection: widget.onClearSelection,
        onBulkChangeCategory: widget.onBulkChangeCategory,
        onBulkUpdatePrice: widget.onBulkUpdatePrice,
        onBulkGenerateSku: widget.onBulkGenerateSku,
        onBulkGenerateShortcut: widget.onBulkGenerateShortcut,
        onBulkFillDescription: widget.onBulkFillDescription,
        onBulkDeleteSelected: widget.onBulkDeleteSelected,
        onTableSortStateChanged: _setTableSortState,
        recordFooterBuilder: widget.recordFooterBuilder,
        tableColumnContributions: widget.tableColumnContributions,
      ),
    );
  }

  void _applySavedView(InventoryProductCatalogSavedView view) {
    _emitPresentationChange(_controller.applySavedView(view));
    widget.onSavedViewSelected?.call(view);
  }

  void _setTablePreferences(
    InventoryProductCatalogTablePreferences preferences,
  ) {
    _emitPresentationChange(_controller.setTablePreferences(preferences));
  }

  void _setTableSortState(InventoryProductCatalogTableSortState sortState) {
    _emitPresentationChange(_controller.setTableSortState(sortState));
  }

  void _applyTablePreset(InventoryProductCatalogTablePreset preset) {
    _emitPresentationChange(_controller.applyTablePreset(preset));
  }

  void _setPresentationStateFromControls(
    InventoryProductCatalogPresentationState state,
  ) {
    _emitPresentationChange(
      _controller.setPresentationStateFromControls(state),
    );
  }

  void _emitPresentationChange(
    InventoryProductCatalogPanelStateChange? change,
  ) {
    if (change == null) return;
    final nextState = change.state;

    setState(() {});
    if (change.notifyViewMode) {
      widget.onViewModeChanged?.call(nextState.viewMode);
    }
    if (change.notifyPreferences) {
      widget.onTablePreferencesChanged?.call(
        nextState.tableViewState.preferences,
      );
    }
    if (change.notifySort) {
      widget.onTableSortStateChanged?.call(nextState.tableViewState.sortState);
    }
    if (change.notifyTableView) {
      widget.onTableViewStateChanged?.call(nextState.tableViewState);
    }
    widget.onPresentationStateChanged?.call(nextState);
  }
}

@Preview(name: 'Inventory product catalog panel')
Widget inventoryProductCatalogPanelPreview() {
  final records = inventoryProductCatalogPreviewRecords();

  return inventoryProductCatalogPreviewScaffold(
    InventoryProductCatalogPanel(
      records: records,
      totalCount: records.length,
      initialPresentationState: InventoryProductCatalogPresentationPreset
          .operationsTable
          .presentationState,
      onEdit: (_) {},
      onDuplicate: (_) {},
      onDelete: (_) {},
    ),
  );
}
