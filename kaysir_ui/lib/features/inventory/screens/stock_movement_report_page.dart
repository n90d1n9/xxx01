import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../product/models/product.dart';
import '../models/inventory_branch_filter.dart';
import '../models/inventory_movement.dart';
import '../models/inventory_stock_movement_report.dart';
import '../models/movement_type.dart';
import '../models/warehouse.dart';
import '../services/inventory_report_export_service.dart';
import '../utils/inventory_formatters.dart';
import '../widgets/inventory_report_scaffold.dart';
import '../widgets/inventory_stock_movement_report_components.dart';

class StockMovementReportPage extends StatefulWidget {
  const StockMovementReportPage({
    super.key,
    required this.products,
    required this.movements,
    required this.warehouses,
  });

  final List<Product> products;
  final List<InventoryMovement> movements;
  final List<Warehouse> warehouses;

  @override
  State<StockMovementReportPage> createState() =>
      _StockMovementReportPageState();
}

class _StockMovementReportPageState extends State<StockMovementReportPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedProductId;
  String? _selectedBranch;
  MovementType? _selectedMovementType;
  String? _selectedWarehouseId;

  @override
  void initState() {
    super.initState();
    _resetDateRange();
  }

  @override
  Widget build(BuildContext context) {
    final lines = buildInventoryStockMovementReportLines(
      products: widget.products,
      movements: widget.movements,
      warehouses: widget.warehouses,
    );
    final branchOptions = inventoryBranchOptionsForWarehouses(
      widget.warehouses,
    );
    final branchLabels = [
      for (final branchOption in branchOptions) branchOption.label,
    ];
    final selectedBranch = inventoryValidBranchFilterValue(
      _selectedBranch,
      branchOptions,
    );
    final warehouseOptions = filterInventoryWarehousesByBranch(
      widget.warehouses,
      selectedBranch: selectedBranch,
    );
    final selectedWarehouseId =
        warehouseOptions.any(
              (warehouse) => warehouse.id == _selectedWarehouseId,
            )
            ? _selectedWarehouseId
            : null;
    final filteredLines = filterInventoryStockMovementReportLines(
      lines: lines,
      startDate: _startDate,
      endDate: _endDate,
      productId: _selectedProductId,
      movementType: _selectedMovementType,
      warehouseId: selectedWarehouseId,
      branchName: selectedBranch,
    );
    final summary = summarizeInventoryStockMovementReportLines(
      filteredLines,
      warehouseId: selectedWarehouseId,
    );
    final asOfDate = DateTime.now();
    final asOfLabel = formatInventoryIsoDate(asOfDate);
    final dateRangeLabel =
        '${formatInventoryIsoDate(_startDate)} to ${formatInventoryIsoDate(_endDate)}';

    return InventoryReportScaffold(
      title: 'Stock Movement Report',
      actions: [
        IconButton(
          tooltip: 'Export movement report',
          icon: const Icon(Icons.file_download_rounded),
          onPressed: () => _exportToCsv(context, filteredLines, asOfDate),
        ),
      ],
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Inventory Reports',
          title: 'Stock Movement Report',
          subtitle:
              'As of $asOfLabel | $dateRangeLabel | ${summary.movementCount} visible movements',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryStockMovementReportSummaryGrid(summary: summary),
        filters: InventoryStockMovementReportFilters(
          products: widget.products,
          branchLabels: branchLabels,
          branchOptions: branchOptions,
          warehouses: warehouseOptions,
          startDate: _startDate,
          endDate: _endDate,
          productId: _selectedProductId,
          branchName: selectedBranch,
          movementType: _selectedMovementType,
          warehouseId: selectedWarehouseId,
          onSelectStartDate: () => _selectStartDate(context),
          onSelectEndDate: () => _selectEndDate(context),
          onProductChanged:
              (value) => setState(() => _selectedProductId = value),
          onBranchChanged:
              (value) => setState(() {
                _selectedBranch = value;
                _selectedWarehouseId = null;
              }),
          onMovementTypeChanged:
              (value) => setState(() => _selectedMovementType = value),
          onWarehouseChanged:
              (value) => setState(() => _selectedWarehouseId = value),
          onResetFilters: _resetFilters,
        ),
        children: [
          InventoryStockMovementReportPanel(
            lines: filteredLines,
            totalCount: lines.length,
            onResetFilters: _resetFilters,
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;

    setState(() {
      _startDate = picked;
      if (_endDate.isBefore(picked)) {
        _endDate = picked;
      }
    });
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;

    setState(() {
      _endDate = picked;
      if (_startDate.isAfter(picked)) {
        _startDate = picked;
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedProductId = null;
      _selectedBranch = null;
      _selectedMovementType = null;
      _selectedWarehouseId = null;
      _resetDateRange();
    });
  }

  void _resetDateRange() {
    final now = DateTime.now();
    _endDate = now;
    _startDate = now.subtract(const Duration(days: 30));
  }

  Future<void> _exportToCsv(
    BuildContext context,
    List<InventoryStockMovementReportLine> lines,
    DateTime asOfDate,
  ) async {
    final document = buildStockMovementCsvDocument(
      lines: lines,
      asOfDate: asOfDate,
    );
    await Clipboard.setData(ClipboardData(text: document.contents));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${document.fileName} copied to clipboard (${document.dataRowCount} rows)',
        ),
      ),
    );
  }
}
