import 'package:flutter/material.dart';

import '../models/inventory_stock_opname_draft_status.dart';
import '../models/inventory_stock_opname_session.dart';
import '../models/inventory_stock_opname_warehouse_selection.dart';
import '../models/inventory_stock_opname_worksheet_filter.dart';
import '../models/inventory_stock_opname_worksheet_filter_mutations.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';
import 'stock_opname_count_sheet_state.dart';

/// Coordinates mutable form state for the stock opname workspace.
///
/// The controller keeps selected warehouse, editable count lines, validation
/// visibility, and text controllers outside the route so the screen can stay
/// focused on provider orchestration and persistence.
class InventoryStockOpnameFormController extends ChangeNotifier {
  InventoryStockOpnameFormController({
    GlobalKey<FormState>? formKey,
    TextEditingController? conductedByController,
    TextEditingController? countSheetSearchController,
  }) : formKey = formKey ?? GlobalKey<FormState>(),
       conductedByController = conductedByController ?? TextEditingController(),
       countSheetSearchController =
           countSheetSearchController ?? TextEditingController(),
       _ownsConductedByController = conductedByController == null,
       _ownsCountSheetSearchController = countSheetSearchController == null;

  final GlobalKey<FormState> formKey;
  final TextEditingController conductedByController;
  final TextEditingController countSheetSearchController;
  final bool _ownsConductedByController;
  final bool _ownsCountSheetSearchController;

  String? _selectedWarehouseId;
  final InventoryStockOpnameCountSheetState _countSheet =
      InventoryStockOpnameCountSheetState();
  InventoryStockOpnameWorksheetFilterState _worksheetFilter =
      InventoryStockOpnameWorksheetFilterState.initial;
  bool _showValidation = false;

  String? get selectedWarehouseId => _selectedWarehouseId;

  List<InventoryStockOpnameLine> get lines => _countSheet.lines;

  List<InventoryStockOpnameLine> get filteredLines {
    return filterInventoryStockOpnameWorksheetLines(
      lines: _countSheet.lines,
      editedLineIds: _countSheet.changedLineIds,
      invalidLineIds: _countSheet.invalidActualQuantityLineIds,
      state: _worksheetFilter,
    );
  }

  bool get showValidation => _showValidation;

  String get conductedBy => conductedByController.text;

  InventoryStockOpnameWorksheetFilterState get worksheetFilter =>
      _worksheetFilter;

  InventoryStockOpnameWorksheetFilterCounts get worksheetFilterCounts {
    return summarizeInventoryStockOpnameWorksheetFilters(
      lines: _countSheet.lines,
      editedLineIds: _countSheet.changedLineIds,
      invalidLineIds: _countSheet.invalidActualQuantityLineIds,
      state: _worksheetFilter,
    );
  }

  InventoryStockOpnameDraftStatus get countSheetDraftStatus =>
      _countSheet.draftStatus;

  bool get hasUnsavedCountSheetChanges => _countSheet.hasUnsavedChanges;

  String? get firstCountSheetDraftLineId =>
      _countSheet.draftReviewTarget?.lineId;

  Warehouse? selectedWarehouse(List<Warehouse> warehouses) {
    return selectedInventoryStockOpnameWarehouse(
      warehouseId: _selectedWarehouseId,
      warehouses: warehouses,
    );
  }

  bool selectInitialWarehouse({
    required List<Warehouse> warehouses,
    required List<InventoryStockRecord> records,
  }) {
    if (_selectedWarehouseId != null || warehouses.isEmpty) return false;

    selectWarehouse(warehouses.first.id, records);
    return true;
  }

  bool shouldSyncWarehouseSelection(List<Warehouse> warehouses) {
    return shouldSyncInventoryStockOpnameWarehouseSelection(
      selectedWarehouseId: _selectedWarehouseId,
      warehouses: warehouses,
    );
  }

  bool syncWarehouseSelection({
    required List<Warehouse> warehouses,
    required List<InventoryStockRecord> records,
  }) {
    final nextWarehouseId = resolveInventoryStockOpnameWarehouseId(
      selectedWarehouseId: _selectedWarehouseId,
      warehouses: warehouses,
    );
    if (nextWarehouseId == _selectedWarehouseId) return false;

    selectWarehouse(nextWarehouseId, records);
    return true;
  }

  void selectWarehouse(
    String? warehouseId,
    List<InventoryStockRecord> records,
  ) {
    _selectedWarehouseId = warehouseId;
    final List<InventoryStockOpnameLine> nextLines =
        warehouseId == null
            ? const []
            : List.unmodifiable(
              buildInventoryStockOpnameLines(
                records: records,
                warehouseId: warehouseId,
              ),
            );
    _countSheet.replaceWithCleanLines(nextLines);
    _resetWorksheetFilters(notify: false);
    notifyListeners();
  }

  void resetCountSheet(List<InventoryStockRecord> records) {
    selectWarehouse(_selectedWarehouseId, records);
  }

  void updateActualQuantity(InventoryStockOpnameLine line, String value) {
    if (_countSheet.updateActualQuantity(lineId: line.id, value: value)) {
      notifyListeners();
    }
  }

  void updateNotes(InventoryStockOpnameLine line, String value) {
    if (_countSheet.updateNotes(lineId: line.id, value: value)) {
      notifyListeners();
    }
  }

  void matchSystemCount(InventoryStockOpnameLine line) {
    if (_countSheet.matchSystemCount(line.id)) {
      notifyListeners();
    }
  }

  void matchSystemCounts(Iterable<InventoryStockOpnameLine> lines) {
    final lineIds = [for (final line in lines) line.id];
    if (_countSheet.matchSystemCounts(lineIds)) {
      notifyListeners();
    }
  }

  void updateWorksheetSearchQuery(String value) {
    final result = updateInventoryStockOpnameWorksheetSearchQuery(
      state: _worksheetFilter,
      query: value,
    );
    if (!result.didChange) return;

    _worksheetFilter = result.state;
    notifyListeners();
  }

  void updateWorksheetFilter(InventoryStockOpnameWorksheetFilter filter) {
    final result = updateInventoryStockOpnameWorksheetFilter(
      state: _worksheetFilter,
      filter: filter,
    );
    if (!result.didChange) return;

    _worksheetFilter = result.state;
    notifyListeners();
  }

  void updateWorksheetSort(InventoryStockOpnameWorksheetSort sort) {
    final result = updateInventoryStockOpnameWorksheetSort(
      state: _worksheetFilter,
      sort: sort,
    );
    if (!result.didChange) return;

    _worksheetFilter = result.state;
    notifyListeners();
  }

  void resetWorksheetFilters() {
    _resetWorksheetFilters();
  }

  void revealFirstDraftLineInWorksheet() {
    final target = _countSheet.draftReviewTarget;
    if (target == null) return;

    final result = revealInventoryStockOpnameDraftReviewTarget(
      state: _worksheetFilter,
      target: target,
    );
    if (!result.didChange) return;

    if (result.shouldClearSearch) {
      countSheetSearchController.clear();
    }
    _worksheetFilter = result.state;
    notifyListeners();
  }

  void markCountSheetSaved() {
    if (_countSheet.markSaved()) {
      notifyListeners();
    }
  }

  bool revealValidation() {
    if (_showValidation) return false;

    _showValidation = true;
    notifyListeners();
    return true;
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  InventoryStockOpnameIssue? validateSession() {
    return validateInventoryStockOpnameSession(
      warehouseId: _selectedWarehouseId,
      conductedBy: conductedBy,
      lines: _countSheet.lines,
    );
  }

  String? get sessionIssueMessage {
    final issue = validateSession();
    if (issue == null) return null;
    return inventoryStockOpnameIssueLabel(issue);
  }

  void _resetWorksheetFilters({bool notify = true}) {
    final result = resetInventoryStockOpnameWorksheetFilters(
      state: _worksheetFilter,
      searchText: countSheetSearchController.text,
    );
    _worksheetFilter = result.state;
    if (result.shouldClearSearch) {
      countSheetSearchController.clear();
    }
    if (notify && result.didChange) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_ownsConductedByController) {
      conductedByController.dispose();
    }
    if (_ownsCountSheetSearchController) {
      countSheetSearchController.dispose();
    }
    super.dispose();
  }
}
