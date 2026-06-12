import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/states/product_catalog_panel_content_state.dart';
import 'package:kaysir/features/inventory/widgets/product_catalog_preview_data.dart';

void main() {
  test('product catalog panel content state exposes bulk action state', () {
    final records = inventoryProductCatalogPreviewRecords();
    final selectedIds = {records.first.id};

    final state = InventoryProductCatalogPanelContentState.resolve(
      records: records,
      selectedProductIds: selectedIds,
      hasSelectVisibleHandler: true,
      hasClearSelectionHandler: true,
      hasBulkChangeCategoryHandler: true,
      hasBulkDeleteSelectedHandler: true,
      hasRepairCandidateHandler: true,
    );

    expect(state.visibleCount, records.length);
    expect(state.selectedVisibleCount, 1);
    expect(state.allVisibleSelected, isFalse);
    expect(state.selectionSummary.productCount, 1);
    expect(state.canShowBulkActions, isTrue);
    expect(state.canShowRepairQuickSelect, isFalse);
  });

  test('product catalog panel content state exposes repair prompt state', () {
    final records = inventoryProductCatalogPreviewRecords();

    final state = InventoryProductCatalogPanelContentState.resolve(
      records: records,
      selectedProductIds: const {},
      hasSelectVisibleHandler: true,
      hasClearSelectionHandler: true,
      hasBulkChangeCategoryHandler: true,
      hasBulkDeleteSelectedHandler: true,
      hasRepairCandidateHandler: true,
    );

    expect(state.canShowBulkActions, isFalse);
    expect(state.visibleRepairSummary.hasQualityIssues, isTrue);
    expect(state.canShowRepairQuickSelect, isTrue);
  });
}
