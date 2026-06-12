import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_stock_opname_session.dart';
import '../models/inventory_stock_record.dart';
import '../models/stockopname.dart';
import '../services/inventory_stock_opname_service.dart';
import '../states/inventory_item_provider.dart';
import '../states/inventory_movement_provider.dart';
import '../states/stock_opname_page_data.dart';
import '../states/stockopname_provider.dart';
import '../widgets/inventory_dialog.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';
import '../widgets/inventory_stock_opname_components.dart';

/// Inventory audit page for preparing, drafting, and completing stock opname
/// sessions.
class StockOpnamePage extends ConsumerStatefulWidget {
  const StockOpnamePage({super.key});

  @override
  ConsumerState<StockOpnamePage> createState() => _StockOpnamePageState();
}

class _StockOpnamePageState extends ConsumerState<StockOpnamePage> {
  late final InventoryStockOpnameFormController _opnameForm;
  final Map<String, GlobalKey> _countLineKeys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _opnameForm =
        InventoryStockOpnameFormController()
          ..addListener(_handleOpnameFormChanged);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _syncInitialWarehouse(),
    );
  }

  @override
  void dispose() {
    _opnameForm
      ..removeListener(_handleOpnameFormChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageData = ref.watch(stockOpnamePageDataProvider);
    final selectedWarehouse = pageData.selectedWarehouse(
      _opnameForm.selectedWarehouseId,
    );

    _scheduleWarehouseSync(pageData);
    _syncCountLineKeys(_opnameForm.lines);

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.stockOpname,
      appBar: AppBar(title: const Text('Stock Opname')),
      body: InventoryStockOpnameWorkspace(
        formKey: _opnameForm.formKey,
        showValidation: _opnameForm.showValidation,
        warehouses: pageData.warehouses,
        selectedWarehouseId: _opnameForm.selectedWarehouseId,
        selectedWarehouse: selectedWarehouse,
        conductedByController: _opnameForm.conductedByController,
        lines: _opnameForm.lines,
        filteredLines: _opnameForm.filteredLines,
        totalInventoryLines: pageData.totalInventoryLines,
        countSheetSearchController: _opnameForm.countSheetSearchController,
        worksheetFilter: _opnameForm.worksheetFilter,
        worksheetFilterCounts: _opnameForm.worksheetFilterCounts,
        draftStatus: _opnameForm.countSheetDraftStatus,
        onWarehouseChanged: (warehouseId) {
          _handleWarehouseChanged(warehouseId, pageData.stockRecords);
        },
        onConductedByChanged: _handleConductedByChanged,
        onActualQuantityChanged: _opnameForm.updateActualQuantity,
        onNotesChanged: _opnameForm.updateNotes,
        onMatchSystem: _opnameForm.matchSystemCount,
        onMatchVisibleLines: _opnameForm.matchSystemCounts,
        onWorksheetSearchChanged: _opnameForm.updateWorksheetSearchQuery,
        onWorksheetFilterChanged: _opnameForm.updateWorksheetFilter,
        onWorksheetSortChanged: _opnameForm.updateWorksheetSort,
        onWorksheetFiltersReset: _opnameForm.resetWorksheetFilters,
        onReviewDraftIssue: _reviewFirstDraftLine,
        onReset: () {
          _resetCountSheet(pageData.stockRecords);
        },
        onSaveDraft: () => _saveCount(StockOpnameStatus.draft),
        onComplete: () => _saveCount(StockOpnameStatus.completed),
        lineKeyBuilder: _countLineKeyFor,
      ),
    );
  }

  void _handleOpnameFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _syncInitialWarehouse() {
    if (!mounted) return;
    final pageData = ref.read(stockOpnamePageDataProvider);
    _opnameForm.selectInitialWarehouse(
      warehouses: pageData.warehouses,
      records: pageData.stockRecords,
    );
  }

  void _scheduleWarehouseSync(InventoryStockOpnamePageData pageData) {
    if (_opnameForm.hasUnsavedCountSheetChanges) return;
    if (!_opnameForm.shouldSyncWarehouseSelection(pageData.warehouses)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _opnameForm.syncWarehouseSelection(
        warehouses: pageData.warehouses,
        records: pageData.stockRecords,
      );
    });
  }

  Future<void> _handleWarehouseChanged(
    String? warehouseId,
    List<InventoryStockRecord> records,
  ) async {
    if (warehouseId == _opnameForm.selectedWarehouseId) return;

    final canDiscard = await _confirmDiscardCountSheetChanges(
      title: 'Switch warehouse?',
      subtitle:
          'Switching warehouses will discard the current count sheet edits.',
      confirmLabel: 'Switch warehouse',
      confirmIcon: Icons.swap_horiz_rounded,
    );
    if (!mounted || !canDiscard) return;

    _opnameForm.selectWarehouse(warehouseId, records);
    _validateAfterInteraction();
  }

  void _handleConductedByChanged(String value) {
    _validateAfterInteraction();
  }

  void _validateAfterInteraction() {
    if (!_opnameForm.showValidation) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _opnameForm.validateForm();
    });
  }

  void _reviewFirstDraftLine() {
    final lineId = _opnameForm.firstCountSheetDraftLineId;
    if (lineId == null) {
      _showMessage('No count sheet changes to review');
      return;
    }

    _opnameForm.revealFirstDraftLineInWorksheet();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToCountLine(lineId);
    });
  }

  void _scrollToCountLine(String lineId) {
    final lineContext = _countLineKeys[lineId]?.currentContext;
    if (lineContext == null) {
      _showMessage('Review the edited count sheet lines');
      return;
    }

    Scrollable.ensureVisible(
      lineContext,
      alignment: 0.12,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    final details = inventoryStockOpnameDraftStatusDetails(
      _opnameForm.countSheetDraftStatus,
    );
    _showMessage(details.reviewMessage);
  }

  Key _countLineKeyFor(InventoryStockOpnameLine line) {
    return _countLineKeys.putIfAbsent(
      line.id,
      () => GlobalKey(debugLabel: 'stock-opname-line-${line.id}'),
    );
  }

  void _syncCountLineKeys(List<InventoryStockOpnameLine> lines) {
    final lineIds = {for (final line in lines) line.id};
    _countLineKeys.removeWhere((lineId, _) => !lineIds.contains(lineId));
  }

  Future<void> _resetCountSheet(List<InventoryStockRecord> records) async {
    final canReset = await _confirmDiscardCountSheetChanges(
      title: 'Reset count sheet?',
      subtitle:
          'Resetting will discard manual counts and notes for the current warehouse.',
      confirmLabel: 'Reset count',
      confirmIcon: Icons.refresh_rounded,
    );
    if (!mounted || !canReset) return;

    _opnameForm.resetCountSheet(records);
    _showMessage('Count sheet reset to system quantities');
  }

  Future<bool> _confirmDiscardCountSheetChanges({
    required String title,
    required String subtitle,
    required String confirmLabel,
    required IconData confirmIcon,
  }) async {
    if (!_opnameForm.hasUnsavedCountSheetChanges) return true;

    final shouldDiscard = await showInventoryDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return InventoryUnsavedChangesDialog(
          title: title,
          subtitle: subtitle,
          confirmLabel: confirmLabel,
          confirmIcon: confirmIcon,
          onCancel: () => Navigator.of(dialogContext).pop(false),
          onConfirm: () => Navigator.of(dialogContext).pop(true),
        );
      },
    );

    return shouldDiscard ?? false;
  }

  void _saveCount(StockOpnameStatus status) {
    _opnameForm.revealValidation();

    final warehouseId = _opnameForm.selectedWarehouseId;
    final issueMessage = _opnameForm.sessionIssueMessage;
    final formIsValid = _opnameForm.validateForm();
    if (!formIsValid) {
      _showMessage(
        issueMessage ?? 'Complete the highlighted count setup fields.',
      );
      return;
    }
    if (issueMessage != null) {
      _showMessage(issueMessage);
      return;
    }
    if (warehouseId == null) return;

    final mutation = buildInventoryStockOpnameMutation(
      warehouseId: warehouseId,
      conductedBy: _opnameForm.conductedBy,
      lines: _opnameForm.lines,
      status: status,
    );

    applyInventoryStockOpnameMutation(
      mutation: mutation,
      addStockOpname: ref.read(stockOpnameProvider.notifier).addStockOpname,
      updateQuantity: ref.read(inventoryItemsProvider.notifier).updateQuantity,
      addMovement: ref.read(inventoryMovementsProvider.notifier).addMovement,
    );

    _opnameForm.markCountSheetSaved();
    _showMessage(
      status == StockOpnameStatus.completed
          ? 'Stock opname completed and inventory updated'
          : 'Stock opname saved as draft',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
