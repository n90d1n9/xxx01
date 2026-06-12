import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../product/models/product.dart';
import '../models/inventory_branch_filter.dart';
import '../models/inventory_item.dart';
import '../models/inventory_valuation_report.dart';
import '../models/warehouse.dart';
import '../services/inventory_report_export_service.dart';
import '../utils/inventory_formatters.dart';
import '../widgets/inventory_branch_filter.dart';
import '../widgets/inventory_report_scaffold.dart';
import '../widgets/inventory_valuation_report_components.dart';

class InventoryValuationReportPage extends StatefulWidget {
  const InventoryValuationReportPage({
    super.key,
    required this.products,
    required this.inventoryItems,
    required this.warehouses,
  });

  final List<Product> products;
  final List<InventoryItem> inventoryItems;
  final List<Warehouse> warehouses;

  @override
  State<InventoryValuationReportPage> createState() =>
      _InventoryValuationReportPageState();
}

class _InventoryValuationReportPageState
    extends State<InventoryValuationReportPage> {
  String? _selectedBranch;

  @override
  Widget build(BuildContext context) {
    final lines = buildInventoryValuationLines(
      products: widget.products,
      inventoryItems: widget.inventoryItems,
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
    final filteredLines = filterInventoryValuationLines(
      lines,
      branchName: selectedBranch,
    );
    final summary = summarizeInventoryValuationLines(filteredLines);
    final asOfDate = DateTime.now();
    final asOfLabel = formatInventoryIsoDate(asOfDate);

    return InventoryReportScaffold(
      title: 'Inventory Valuation Report',
      actions: [
        IconButton(
          tooltip: 'Export valuation report',
          icon: const Icon(Icons.file_download_rounded),
          onPressed: () => _exportToCsv(context, filteredLines, asOfDate),
        ),
      ],
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Inventory Reports',
          title: 'Inventory Valuation Report',
          subtitle:
              'As of $asOfLabel | ${summary.lineCount} lines across ${summary.warehouseCount} warehouses',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryValuationSummaryGrid(summary: summary),
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
          InventoryValuationPanel(
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
    List<InventoryValuationLine> lines,
    DateTime asOfDate,
  ) async {
    final document = buildInventoryValuationCsvDocument(
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
