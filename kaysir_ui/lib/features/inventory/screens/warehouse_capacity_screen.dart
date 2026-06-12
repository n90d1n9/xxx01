import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/inventory_branch_filter.dart';
import '../models/inventory_item.dart';
import '../models/inventory_warehouse_capacity_report.dart';
import '../models/warehouse.dart';
import '../services/inventory_report_export_service.dart';
import '../states/inventory_item_provider.dart';
import '../states/warehouse_provider.dart';
import '../utils/inventory_formatters.dart';
import '../widgets/inventory_branch_filter.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_report_scaffold.dart';
import '../widgets/inventory_warehouse_capacity_report_components.dart';

class WarehouseCapacityPage extends ConsumerWidget {
  const WarehouseCapacityPage({
    super.key,
    this.initialBranch,
    this.initialWarehouseId,
  });

  final String? initialBranch;
  final String? initialWarehouseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WarehouseCapacityReportPage(
      warehouses: ref.watch(warehousesProvider),
      inventoryItems: ref.watch(inventoryItemsProvider),
      currentDestination: InventoryNavigationDestination.warehouseCapacity,
      initialBranch: initialBranch,
      initialWarehouseId: initialWarehouseId,
    );
  }
}

class WarehouseCapacityReportPage extends StatefulWidget {
  const WarehouseCapacityReportPage({
    super.key,
    required this.warehouses,
    required this.inventoryItems,
    this.currentDestination = InventoryNavigationDestination.reports,
    this.initialBranch,
    this.initialWarehouseId,
  });

  final List<Warehouse> warehouses;
  final List<InventoryItem> inventoryItems;
  final InventoryNavigationDestination currentDestination;
  final String? initialBranch;
  final String? initialWarehouseId;

  @override
  State<WarehouseCapacityReportPage> createState() =>
      _WarehouseCapacityReportPageState();
}

class _WarehouseCapacityReportPageState
    extends State<WarehouseCapacityReportPage> {
  String? _selectedBranch;
  String? _selectedWarehouseId;

  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.initialBranch;
    _selectedWarehouseId = widget.initialWarehouseId;
  }

  @override
  Widget build(BuildContext context) {
    final lines = buildInventoryWarehouseCapacityLines(
      warehouses: widget.warehouses,
      inventoryItems: widget.inventoryItems,
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
    final filteredLines = filterInventoryWarehouseCapacityLines(
      lines,
      branchName: selectedBranch,
      warehouseId: selectedWarehouseId,
    );
    final summary = summarizeInventoryWarehouseCapacityLines(filteredLines);
    final asOfDate = DateTime.now();
    final asOfLabel = formatInventoryIsoDate(asOfDate);

    return InventoryReportScaffold(
      title: 'Warehouse Capacity Report',
      currentDestination: widget.currentDestination,
      actions: [
        IconButton(
          tooltip: 'Export capacity report',
          icon: const Icon(Icons.file_download_rounded),
          onPressed: () => _exportToCsv(context, filteredLines, asOfDate),
        ),
      ],
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Inventory Reports',
          title: 'Warehouse Capacity Report',
          subtitle:
              'As of $asOfLabel | ${summary.trackedWarehouseCount} of ${summary.warehouseCount} warehouses track capacity',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryWarehouseCapacitySummaryGrid(summary: summary),
        filters: AppFilterBar(
          trailing: [
            InventoryBranchSelectField(
              branchLabels: branchLabels,
              branchOptions: branchOptions,
              selectedBranch: selectedBranch,
              onChanged:
                  (value) => setState(() {
                    _selectedBranch = value;
                    _selectedWarehouseId = null;
                  }),
            ),
            InventoryWarehouseSelectField(
              warehouses: warehouseOptions,
              selectedWarehouseId: selectedWarehouseId,
              onChanged:
                  (value) => setState(() {
                    _selectedWarehouseId = value;
                  }),
            ),
          ],
        ),
        children: [
          InventoryWarehouseCapacityPanel(
            lines: filteredLines,
            totalCount: lines.length,
            onResetFilters: _resetFilters,
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedBranch = null;
      _selectedWarehouseId = null;
    });
  }

  Future<void> _exportToCsv(
    BuildContext context,
    List<InventoryWarehouseCapacityLine> lines,
    DateTime asOfDate,
  ) async {
    final document = buildWarehouseCapacityCsvDocument(
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
