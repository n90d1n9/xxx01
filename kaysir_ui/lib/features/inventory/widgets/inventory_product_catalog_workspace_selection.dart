import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_product_catalog.dart';

class InventoryProductCatalogWorkspaceSelectionSnapshot {
  const InventoryProductCatalogWorkspaceSelectionSnapshot({
    required this.selectedIds,
    required this.selectedRecords,
    required this.summary,
  });

  factory InventoryProductCatalogWorkspaceSelectionSnapshot.from({
    required List<InventoryProductCatalogRecord> records,
    required Set<String> selectedProductIds,
  }) {
    final availableIds = {for (final record in records) record.id};
    final activeSelectedIds = {
      for (final id in selectedProductIds)
        if (availableIds.contains(id)) id,
    };

    return InventoryProductCatalogWorkspaceSelectionSnapshot(
      selectedIds: activeSelectedIds,
      selectedRecords: [
        for (final record in records)
          if (activeSelectedIds.contains(record.id)) record,
      ],
      summary: summarizeInventoryProductCatalogSelection(
        records: records,
        selectedProductIds: activeSelectedIds,
      ),
    );
  }

  final Set<String> selectedIds;
  final List<InventoryProductCatalogRecord> selectedRecords;
  final InventoryProductCatalogSelectionSummary summary;
}

mixin InventoryProductCatalogWorkspaceSelectionController<
  T extends ConsumerStatefulWidget
>
    on ConsumerState<T> {
  Set<String> get selectedProductIds;

  InventoryProductCatalogWorkspaceSelectionSnapshot activeSelectionSnapshot(
    List<InventoryProductCatalogRecord> records,
  ) {
    return InventoryProductCatalogWorkspaceSelectionSnapshot.from(
      records: records,
      selectedProductIds: selectedProductIds,
    );
  }

  void setProductSelected(InventoryProductCatalogRecord record, bool selected) {
    setState(() {
      if (selected) {
        selectedProductIds.add(record.id);
      } else {
        selectedProductIds.remove(record.id);
      }
    });
  }

  void setVisibleProductsSelected(
    List<InventoryProductCatalogRecord> visibleRecords, {
    required bool selected,
  }) {
    setState(() {
      for (final record in visibleRecords) {
        if (selected) {
          selectedProductIds.add(record.id);
        } else {
          selectedProductIds.remove(record.id);
        }
      }
    });
  }

  void selectVisibleRepairCandidates(
    List<InventoryProductCatalogRecord> visibleRecords,
    InventoryProductCatalogRepairTarget target,
  ) {
    setState(() {
      selectedProductIds
        ..clear()
        ..addAll(
          visibleRecords
              .where(
                (record) =>
                    inventoryProductCatalogRecordNeedsRepair(record, target),
              )
              .map((record) => record.id),
        );
    });
  }

  void clearSelection() {
    setState(selectedProductIds.clear);
  }
}
