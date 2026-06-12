import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_worksheet_filter.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/states/stock_opname_form_controller.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('stock opname form controller selects initial warehouse lines', () {
    final controller = InventoryStockOpnameFormController();
    addTearDown(controller.dispose);

    final selected = controller.selectInitialWarehouse(
      warehouses: _warehouses(),
      records: _records(),
    );

    expect(selected, isTrue);
    expect(controller.selectedWarehouseId, 'w1');
    expect(controller.selectedWarehouse(_warehouses())?.name, 'Main Warehouse');
    expect(controller.lines, hasLength(2));
    expect(controller.lines.first.productName, 'Laptop');
  });

  test('stock opname form controller syncs invalid warehouse selection', () {
    final controller = InventoryStockOpnameFormController();
    addTearDown(controller.dispose);

    controller.selectWarehouse('w2', _records());

    expect(
      controller.shouldSyncWarehouseSelection([_warehouses().first]),
      true,
    );

    final synced = controller.syncWarehouseSelection(
      warehouses: [_warehouses().first],
      records: _records(),
    );

    expect(synced, isTrue);
    expect(controller.selectedWarehouseId, 'w1');
    expect(controller.lines, hasLength(2));
  });

  test('stock opname form controller edits and resets count lines', () {
    final controller = InventoryStockOpnameFormController();
    addTearDown(controller.dispose);

    controller.selectWarehouse('w1', _records());

    expect(controller.hasUnsavedCountSheetChanges, isFalse);
    expect(controller.countSheetDraftStatus.hasUnsavedChanges, isFalse);
    expect(controller.firstCountSheetDraftLineId, isNull);

    controller.updateActualQuantity(controller.lines.first, '7');
    controller.updateNotes(controller.lines.first, 'Shelf recount');

    expect(controller.lines.first.actualQuantity, 7);
    expect(controller.lines.first.notes, 'Shelf recount');
    expect(controller.hasUnsavedCountSheetChanges, isTrue);
    expect(controller.countSheetDraftStatus.changedLineCount, 1);
    expect(controller.countSheetDraftStatus.invalidActualQuantityLineCount, 0);
    expect(controller.firstCountSheetDraftLineId, 'i1');

    controller.updateActualQuantity(controller.lines.first, '');
    controller.updateActualQuantity(controller.lines.first, 'invalid');

    expect(controller.lines.first.actualQuantity, 7);
    expect(controller.hasUnsavedCountSheetChanges, isTrue);
    expect(controller.countSheetDraftStatus.changedLineCount, 1);
    expect(controller.countSheetDraftStatus.invalidActualQuantityLineCount, 1);
    expect(controller.firstCountSheetDraftLineId, 'i1');

    controller.markCountSheetSaved();

    expect(controller.hasUnsavedCountSheetChanges, isFalse);
    expect(controller.countSheetDraftStatus.hasUnsavedChanges, isFalse);
    expect(controller.firstCountSheetDraftLineId, isNull);

    controller.matchSystemCount(controller.lines.first);

    expect(controller.lines.first.actualQuantity, 5);
    expect(controller.hasUnsavedCountSheetChanges, isTrue);
    expect(controller.countSheetDraftStatus.changedLineCount, 1);

    controller.updateActualQuantity(controller.lines.first, '9');
    controller.resetCountSheet(_records());

    expect(controller.lines.first.actualQuantity, 5);
    expect(controller.lines.first.notes, isEmpty);
    expect(controller.hasUnsavedCountSheetChanges, isFalse);
    expect(controller.countSheetDraftStatus.hasUnsavedChanges, isFalse);
  });

  test('stock opname form controller filters worksheet lines', () {
    final controller = InventoryStockOpnameFormController();
    addTearDown(controller.dispose);

    controller.selectWarehouse('w1', _records());

    expect(controller.filteredLines, hasLength(2));
    expect(controller.worksheetFilterCounts.total, 2);
    expect(controller.worksheetFilterCounts.filtered, 2);

    controller.updateActualQuantity(controller.lines.first, '7');
    controller.updateWorksheetFilter(
      InventoryStockOpnameWorksheetFilter.edited,
    );
    controller.updateWorksheetSort(
      InventoryStockOpnameWorksheetSort.productName,
    );

    expect(controller.filteredLines, hasLength(1));
    expect(controller.filteredLines.single.id, 'i1');
    expect(controller.worksheetFilterCounts.edited, 1);

    controller.updateWorksheetSearchQuery('cable');

    expect(controller.filteredLines, isEmpty);
    expect(controller.worksheetFilterCounts.filtered, 0);

    controller.resetWorksheetFilters();

    expect(controller.worksheetFilter.hasActiveFilters, isFalse);
    expect(
      controller.worksheetFilter.sort,
      InventoryStockOpnameWorksheetSort.sheetOrder,
    );
    expect(controller.countSheetSearchController.text, isEmpty);
    expect(controller.filteredLines, hasLength(2));
    expect(controller.filteredLines.first.id, 'i1');
  });

  test('stock opname form controller sorts worksheet lines', () {
    final controller = InventoryStockOpnameFormController();
    addTearDown(controller.dispose);

    controller.selectWarehouse('w1', _records());

    expect(controller.filteredLines.first.id, 'i1');

    controller.updateWorksheetSort(
      InventoryStockOpnameWorksheetSort.productName,
    );

    expect(controller.filteredLines.first.id, 'i2');
    expect(
      controller.worksheetFilter.sort,
      InventoryStockOpnameWorksheetSort.productName,
    );
  });

  test('stock opname form controller matches visible worksheet lines', () {
    final controller = InventoryStockOpnameFormController();
    addTearDown(controller.dispose);

    var notifications = 0;
    controller.addListener(() => notifications += 1);

    controller.selectWarehouse('w1', _records());
    controller.updateActualQuantity(controller.lines.first, '7');
    controller.updateActualQuantity(controller.lines.last, '9');
    controller.updateActualQuantity(controller.lines.first, '');

    expect(controller.lines.first.actualQuantity, 7);
    expect(controller.lines.last.actualQuantity, 9);
    expect(controller.countSheetDraftStatus.invalidActualQuantityLineCount, 1);

    final notificationsBeforeBatch = notifications;
    controller.matchSystemCounts([controller.lines.first]);

    expect(controller.lines.first.actualQuantity, 5);
    expect(controller.lines.last.actualQuantity, 9);
    expect(controller.countSheetDraftStatus.invalidActualQuantityLineCount, 0);
    expect(controller.countSheetDraftStatus.changedLineCount, 1);
    expect(notifications, notificationsBeforeBatch + 1);
  });

  test('stock opname form controller reveals first draft issue in filters', () {
    final controller = InventoryStockOpnameFormController();
    addTearDown(controller.dispose);

    controller.selectWarehouse('w1', _records());
    controller.updateWorksheetSearchQuery('cable');
    controller.updateActualQuantity(controller.lines.first, '');

    controller.revealFirstDraftLineInWorksheet();

    expect(controller.countSheetSearchController.text, isEmpty);
    expect(
      controller.worksheetFilter.filter,
      InventoryStockOpnameWorksheetFilter.invalid,
    );
    expect(controller.filteredLines.single.id, 'i1');
  });

  test('stock opname form controller exposes validation state and issues', () {
    final controller = InventoryStockOpnameFormController();
    addTearDown(controller.dispose);

    expect(controller.showValidation, isFalse);
    expect(controller.revealValidation(), isTrue);
    expect(controller.showValidation, isTrue);
    expect(controller.revealValidation(), isFalse);
    expect(
      controller.sessionIssueMessage,
      'Select a warehouse before saving the count.',
    );

    controller.selectWarehouse('w1', _records());
    expect(
      controller.sessionIssueMessage,
      'Enter who conducted the stock opname.',
    );

    controller.conductedByController.text = 'Nina';
    expect(controller.sessionIssueMessage, isNull);
  });
}

List<Warehouse> _warehouses() {
  return [
    Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
    Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
  ];
}

List<InventoryStockRecord> _records() {
  final warehouses = _warehouses();
  return [
    InventoryStockRecord(
      item: InventoryItem(
        id: 'i1',
        productId: 'p1',
        warehouseId: 'w1',
        currentQuantity: 5,
        reorderPoint: 2,
        reorderQuantity: 8,
      ),
      product: Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
      warehouse: warehouses.first,
    ),
    InventoryStockRecord(
      item: InventoryItem(
        id: 'i2',
        productId: 'p2',
        warehouseId: 'w1',
        currentQuantity: 12,
        reorderPoint: 4,
        reorderQuantity: 10,
      ),
      product: Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 25),
      warehouse: warehouses.first,
    ),
    InventoryStockRecord(
      item: InventoryItem(
        id: 'i3',
        productId: 'p3',
        warehouseId: 'w2',
        currentQuantity: 3,
        reorderPoint: 1,
        reorderQuantity: 5,
      ),
      product: Product(id: 'p3', name: 'Mouse', sku: 'MS-001', price: 30),
      warehouse: warehouses.last,
    ),
  ];
}
