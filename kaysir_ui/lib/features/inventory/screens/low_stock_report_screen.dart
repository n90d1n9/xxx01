import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../product/models/product.dart';
import '../models/inventory_branch_filter.dart';
import '../models/inventory_item.dart';
import '../models/inventory_low_stock_report.dart';
import '../models/warehouse.dart';
import '../services/inventory_report_export_service.dart';
import '../utils/inventory_formatters.dart';
import '../widgets/inventory_branch_filter.dart';
import '../widgets/inventory_low_stock_report_components.dart';
import '../widgets/inventory_report_scaffold.dart';

class LowStockReportPage extends StatefulWidget {
  const LowStockReportPage({
    super.key,
    required this.products,
    required this.lowStockItems,
    required this.warehouses,
  });

  final List<Product> products;
  final List<InventoryItem> lowStockItems;
  final List<Warehouse> warehouses;

  @override
  State<LowStockReportPage> createState() => _LowStockReportPageState();
}

class _LowStockReportPageState extends State<LowStockReportPage> {
  String? _selectedBranch;

  @override
  Widget build(BuildContext context) {
    final lines = buildInventoryLowStockReportLines(
      products: widget.products,
      lowStockItems: widget.lowStockItems,
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
    final filteredLines = filterInventoryLowStockReportLines(
      lines,
      branchName: selectedBranch,
    );
    final summary = summarizeInventoryLowStockReportLines(filteredLines);
    final asOfDate = DateTime.now();
    final asOfLabel = formatInventoryIsoDate(asOfDate);

    return InventoryReportScaffold(
      title: 'Low Stock Report',
      actions: [
        IconButton(
          tooltip: 'Export low stock report',
          icon: const Icon(Icons.file_download_rounded),
          onPressed: () => _exportToCsv(context, filteredLines, asOfDate),
        ),
      ],
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Inventory Reports',
          title: 'Low Stock Report',
          subtitle:
              'As of $asOfLabel | ${summary.alertCount} active alerts and ${summary.criticalCount} critical items',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryLowStockReportSummaryGrid(summary: summary),
        filters: AppFilterBar(
          trailing: [
            InventoryBranchSelectField(
              branchLabels: branchLabels,
              branchOptions: branchOptions,
              selectedBranch: selectedBranch,
              onChanged: (value) => setState(() => _selectedBranch = value),
            ),
          ],
        ),
        children: [
          InventoryLowStockReportPanel(
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
    });
  }

  Future<void> _exportToCsv(
    BuildContext context,
    List<InventoryLowStockReportLine> lines,
    DateTime asOfDate,
  ) async {
    final document = buildLowStockCsvDocument(lines: lines, asOfDate: asOfDate);
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
