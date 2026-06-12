import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/inventory_stock_opname_draft_status.dart';
import '../models/inventory_stock_opname_session.dart';
import '../models/inventory_stock_opname_worksheet_filter.dart';
import '../models/warehouse.dart';
import 'inventory_stock_opname_controls_components.dart';
import 'inventory_stock_opname_summary_components.dart';
import 'inventory_stock_opname_worksheet_components.dart';

/// Complete stock opname workspace layout with setup fields, count metrics,
/// and the editable worksheet panel.
class InventoryStockOpnameWorkspace extends StatelessWidget {
  const InventoryStockOpnameWorkspace({
    super.key,
    required this.formKey,
    required this.showValidation,
    required this.warehouses,
    required this.selectedWarehouseId,
    required this.selectedWarehouse,
    required this.conductedByController,
    required this.lines,
    required this.totalInventoryLines,
    this.filteredLines,
    this.countSheetSearchController,
    this.worksheetFilter = InventoryStockOpnameWorksheetFilterState.initial,
    this.worksheetFilterCounts,
    this.draftStatus = InventoryStockOpnameDraftStatus.clean,
    this.onWarehouseChanged,
    this.onConductedByChanged,
    this.onActualQuantityChanged,
    this.onNotesChanged,
    this.onMatchSystem,
    this.onMatchVisibleLines,
    this.onWorksheetSearchChanged,
    this.onWorksheetFilterChanged,
    this.onWorksheetSortChanged,
    this.onWorksheetFiltersReset,
    this.onReviewDraftIssue,
    this.onReset,
    this.onSaveDraft,
    this.onComplete,
    this.lineKeyBuilder,
  });

  final GlobalKey<FormState> formKey;
  final bool showValidation;
  final List<Warehouse> warehouses;
  final String? selectedWarehouseId;
  final Warehouse? selectedWarehouse;
  final TextEditingController conductedByController;
  final List<InventoryStockOpnameLine> lines;
  final int totalInventoryLines;
  final List<InventoryStockOpnameLine>? filteredLines;
  final TextEditingController? countSheetSearchController;
  final InventoryStockOpnameWorksheetFilterState worksheetFilter;
  final InventoryStockOpnameWorksheetFilterCounts? worksheetFilterCounts;
  final InventoryStockOpnameDraftStatus draftStatus;
  final ValueChanged<String?>? onWarehouseChanged;
  final ValueChanged<String>? onConductedByChanged;
  final void Function(InventoryStockOpnameLine line, String value)?
  onActualQuantityChanged;
  final void Function(InventoryStockOpnameLine line, String value)?
  onNotesChanged;
  final ValueChanged<InventoryStockOpnameLine>? onMatchSystem;
  final ValueChanged<List<InventoryStockOpnameLine>>? onMatchVisibleLines;
  final ValueChanged<String>? onWorksheetSearchChanged;
  final ValueChanged<InventoryStockOpnameWorksheetFilter>?
  onWorksheetFilterChanged;
  final ValueChanged<InventoryStockOpnameWorksheetSort>? onWorksheetSortChanged;
  final VoidCallback? onWorksheetFiltersReset;
  final VoidCallback? onReviewDraftIssue;
  final VoidCallback? onReset;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onComplete;
  final Key Function(InventoryStockOpnameLine line)? lineKeyBuilder;

  @override
  Widget build(BuildContext context) {
    final displayedLines = filteredLines ?? lines;

    return Form(
      key: formKey,
      autovalidateMode:
          showValidation
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
      child: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Inventory Audit',
          title: 'Stock Opname',
          subtitle: _headerSubtitle,
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryStockOpnameSummary(lines: lines),
        filters: InventoryStockOpnameControls(
          warehouses: warehouses,
          selectedWarehouseId: selectedWarehouseId,
          conductedByController: conductedByController,
          warehouseValidator: inventoryStockOpnameWarehouseFieldError,
          conductedByValidator: inventoryStockOpnameCounterFieldError,
          onWarehouseChanged: onWarehouseChanged,
          onConductedByChanged: onConductedByChanged,
        ),
        children: [
          InventoryStockOpnamePanel(
            lines: displayedLines,
            allLines: lines,
            totalInventoryLines: totalInventoryLines,
            countSheetSearchController: countSheetSearchController,
            worksheetFilter: worksheetFilter,
            worksheetFilterCounts: worksheetFilterCounts,
            draftStatus: draftStatus,
            onActualQuantityChanged: onActualQuantityChanged,
            onNotesChanged: onNotesChanged,
            onMatchSystem: onMatchSystem,
            onMatchVisibleLines: onMatchVisibleLines,
            onWorksheetSearchChanged: onWorksheetSearchChanged,
            onWorksheetFilterChanged: onWorksheetFilterChanged,
            onWorksheetSortChanged: onWorksheetSortChanged,
            onWorksheetFiltersReset: onWorksheetFiltersReset,
            onReviewDraftIssue: onReviewDraftIssue,
            onReset: onReset,
            onSaveDraft: onSaveDraft,
            onComplete: onComplete,
            lineKeyBuilder: lineKeyBuilder,
          ),
        ],
      ),
    );
  }

  String get _headerSubtitle {
    final warehouse = selectedWarehouse;
    if (warehouse == null) {
      return 'Select a warehouse to prepare a physical count sheet';
    }

    return '${warehouse.name} count sheet with ${lines.length} stock lines';
  }
}

@Preview(name: 'Inventory stock opname workspace')
Widget inventoryStockOpnameWorkspacePreview() {
  final warehouses = [
    Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
    Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
  ];

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: InventoryStockOpnameWorkspace(
          formKey: GlobalKey<FormState>(),
          showValidation: false,
          warehouses: warehouses,
          selectedWarehouseId: 'w1',
          selectedWarehouse: warehouses.first,
          conductedByController: TextEditingController(text: 'Nina'),
          countSheetSearchController: TextEditingController(text: 'lap'),
          worksheetFilter: InventoryStockOpnameWorksheetFilterState(
            query: 'lap',
            filter: InventoryStockOpnameWorksheetFilter.variance,
            sort: InventoryStockOpnameWorksheetSort.varianceMagnitude,
          ),
          worksheetFilterCounts: InventoryStockOpnameWorksheetFilterCounts(
            total: 2,
            edited: 1,
            invalid: 0,
            variance: 1,
            matched: 1,
            filtered: 1,
          ),
          draftStatus: InventoryStockOpnameDraftStatus(
            changedLineCount: 1,
            invalidActualQuantityLineCount: 0,
          ),
          onWorksheetSearchChanged: (_) {},
          onWorksheetFilterChanged: (_) {},
          onWorksheetSortChanged: (_) {},
          onWorksheetFiltersReset: () {},
          onMatchVisibleLines: (_) {},
          lines: const [
            InventoryStockOpnameLine(
              id: 'i1',
              inventoryItemId: 'i1',
              productId: 'p1',
              productName: 'Laptop',
              skuLabel: 'LT-001',
              systemQuantity: 5,
              actualQuantity: 7,
              notes: 'Shelf recount',
            ),
            InventoryStockOpnameLine(
              id: 'i2',
              inventoryItemId: 'i2',
              productId: 'p2',
              productName: 'Cable',
              skuLabel: 'CB-001',
              systemQuantity: 12,
              actualQuantity: 12,
            ),
          ],
          totalInventoryLines: 2,
        ),
      ),
    ),
  );
}
