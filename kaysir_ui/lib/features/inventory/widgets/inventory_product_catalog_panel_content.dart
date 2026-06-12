import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_empty_state.dart';
import '../models/inventory_product_catalog.dart';
import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_table_sort.dart';
import '../models/inventory_product_catalog_view_mode.dart';
import '../states/product_catalog_panel_content_state.dart';
import 'inventory_product_catalog_advanced_table.dart';
import 'inventory_product_catalog_bulk_actions.dart';
import 'inventory_product_catalog_record_footer_builder.dart';
import 'inventory_product_catalog_repair_quick_select_bar.dart';
import 'inventory_product_catalog_table_column_contribution.dart';
import 'inventory_reset_filters_button.dart';
import 'product_catalog_card_list.dart';
import 'product_catalog_preview_data.dart';

/// Content body for product catalog bulk actions, repair prompts, and records.
class InventoryProductCatalogPanelContent extends StatelessWidget {
  const InventoryProductCatalogPanelContent({
    super.key,
    required this.records,
    required this.selectedProductIds,
    required this.presentationState,
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
    this.onTableSortStateChanged,
    this.recordFooterBuilder,
    this.tableColumnContributions =
        const <InventoryProductCatalogTableColumnContribution>[],
  });

  final List<InventoryProductCatalogRecord> records;
  final Set<String> selectedProductIds;
  final InventoryProductCatalogSelectionSummary? selectionSummary;
  final InventoryProductCatalogPresentationState presentationState;
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
  final ValueChanged<InventoryProductCatalogTableSortState>?
  onTableSortStateChanged;
  final InventoryProductCatalogRecordFooterBuilder? recordFooterBuilder;
  final List<InventoryProductCatalogTableColumnContribution>
  tableColumnContributions;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return AppEmptyState(
        title: 'No products found',
        message: 'Try another search or product health filter.',
        icon: Icons.search_off_rounded,
        action:
            onResetFilters == null
                ? null
                : InventoryResetFiltersButton(onPressed: onResetFilters!),
      );
    }

    final contentState = InventoryProductCatalogPanelContentState.resolve(
      records: records,
      selectedProductIds: selectedProductIds,
      selectionSummary: selectionSummary,
      hasSelectVisibleHandler: onSelectVisibleChanged != null,
      hasClearSelectionHandler: onClearSelection != null,
      hasBulkChangeCategoryHandler: onBulkChangeCategory != null,
      hasBulkDeleteSelectedHandler: onBulkDeleteSelected != null,
      hasRepairCandidateHandler: onSelectRepairCandidates != null,
    );

    return Column(
      children: [
        if (contentState.canShowBulkActions) ...[
          InventoryProductCatalogBulkActionBar(
            selectedCount: selectedProductIds.length,
            visibleCount: records.length,
            allVisibleSelected: contentState.allVisibleSelected,
            selectionSummary: contentState.selectionSummary,
            onSelectVisibleChanged: onSelectVisibleChanged!,
            onChangeCategory: onBulkChangeCategory!,
            onUpdatePrice: onBulkUpdatePrice,
            onGenerateSku: onBulkGenerateSku,
            onGenerateShortcut: onBulkGenerateShortcut,
            onFillDescription: onBulkFillDescription,
            onDeleteSelected: onBulkDeleteSelected!,
            onClearSelection: onClearSelection!,
          ),
          const SizedBox(height: 12),
        ],
        if (contentState.canShowRepairQuickSelect) ...[
          InventoryProductCatalogRepairQuickSelectBar(
            summary: contentState.visibleRepairSummary,
            onSelectTarget: onSelectRepairCandidates!,
          ),
          const SizedBox(height: 6),
        ],
        if (presentationState.viewMode == InventoryProductCatalogViewMode.table)
          InventoryProductCatalogAdvancedTable(
            records: records,
            preferences: presentationState.tableViewState.preferences,
            sortState: presentationState.tableViewState.sortState,
            selectedProductIds: selectedProductIds,
            onSelectionChanged: onSelectionChanged,
            onSelectVisibleChanged: onSelectVisibleChanged,
            onSortStateChanged: onTableSortStateChanged,
            onEdit: onEdit,
            onDuplicate: onDuplicate,
            onDelete: onDelete,
            recordFooterBuilder: recordFooterBuilder,
            columnContributions: tableColumnContributions,
          )
        else
          InventoryProductCatalogCardList(
            records: records,
            selectedProductIds: selectedProductIds,
            onSelectionChanged: onSelectionChanged,
            onEdit: onEdit,
            onDuplicate: onDuplicate,
            onDelete: onDelete,
            recordFooterBuilder: recordFooterBuilder,
          ),
      ],
    );
  }
}

@Preview(name: 'Inventory product catalog panel content')
Widget inventoryProductCatalogPanelContentPreview() {
  final records = inventoryProductCatalogPreviewRecords();

  return inventoryProductCatalogPreviewScaffold(
    InventoryProductCatalogPanelContent(
      records: records,
      selectedProductIds: {records.first.id},
      presentationState: InventoryProductCatalogPresentationState.defaults,
      onSelectionChanged: (_, _) {},
      onSelectVisibleChanged: (_) {},
      onClearSelection: () {},
      onBulkChangeCategory: () {},
      onBulkDeleteSelected: () {},
      onSelectRepairCandidates: (_) {},
      onEdit: (_) {},
      onDuplicate: (_) {},
      onDelete: (_) {},
    ),
  );
}
