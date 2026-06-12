import '../models/inventory_product_catalog.dart';

/// Presentation decisions for the product catalog panel content area.
class InventoryProductCatalogPanelContentState {
  const InventoryProductCatalogPanelContentState({
    required this.visibleCount,
    required this.selectedVisibleCount,
    required this.selectionSummary,
    required this.visibleRepairSummary,
    required this.canShowBulkActions,
    required this.canShowRepairQuickSelect,
  });

  final int visibleCount;
  final int selectedVisibleCount;
  final InventoryProductCatalogSelectionSummary selectionSummary;
  final InventoryProductCatalogSelectionSummary visibleRepairSummary;
  final bool canShowBulkActions;
  final bool canShowRepairQuickSelect;

  bool get allVisibleSelected {
    return visibleCount > 0 && selectedVisibleCount == visibleCount;
  }

  /// Resolves content visibility and summaries from current selection state.
  factory InventoryProductCatalogPanelContentState.resolve({
    required List<InventoryProductCatalogRecord> records,
    required Set<String> selectedProductIds,
    InventoryProductCatalogSelectionSummary? selectionSummary,
    required bool hasSelectVisibleHandler,
    required bool hasClearSelectionHandler,
    required bool hasBulkChangeCategoryHandler,
    required bool hasBulkDeleteSelectedHandler,
    required bool hasRepairCandidateHandler,
  }) {
    final selectedVisibleCount =
        records
            .where((record) => selectedProductIds.contains(record.id))
            .length;
    final effectiveSelectionSummary =
        selectionSummary ??
        summarizeInventoryProductCatalogSelection(
          records: records,
          selectedProductIds: selectedProductIds,
        );
    final visibleRepairSummary = summarizeInventoryProductCatalogSelection(
      records: records,
      selectedProductIds: {for (final record in records) record.id},
    );
    final canShowBulkActions =
        selectedProductIds.isNotEmpty &&
        hasSelectVisibleHandler &&
        hasClearSelectionHandler &&
        hasBulkChangeCategoryHandler &&
        hasBulkDeleteSelectedHandler;

    return InventoryProductCatalogPanelContentState(
      visibleCount: records.length,
      selectedVisibleCount: selectedVisibleCount,
      selectionSummary: effectiveSelectionSummary,
      visibleRepairSummary: visibleRepairSummary,
      canShowBulkActions: canShowBulkActions,
      canShowRepairQuickSelect:
          selectedProductIds.isEmpty &&
          hasRepairCandidateHandler &&
          visibleRepairSummary.hasQualityIssues,
    );
  }
}
