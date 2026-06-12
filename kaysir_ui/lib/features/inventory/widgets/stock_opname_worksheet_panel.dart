import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_stock_opname_draft_status.dart';
import '../models/inventory_stock_opname_session.dart';
import '../models/inventory_stock_opname_worksheet_filter.dart';
import 'stock_opname_line_preview_data.dart';
import 'stock_opname_worksheet_actions.dart';
import 'stock_opname_worksheet_empty_state.dart';
import 'stock_opname_worksheet_line_list.dart';
import 'stock_opname_worksheet_preview_data.dart';
import 'stock_opname_worksheet_review_header.dart';

/// Worksheet panel for reviewing and submitting stock opname count lines.
class InventoryStockOpnamePanel extends StatelessWidget {
  const InventoryStockOpnamePanel({
    super.key,
    required this.lines,
    required this.totalInventoryLines,
    this.allLines,
    this.countSheetSearchController,
    this.worksheetFilter = InventoryStockOpnameWorksheetFilterState.initial,
    this.worksheetFilterCounts,
    this.draftStatus = InventoryStockOpnameDraftStatus.clean,
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

  final List<InventoryStockOpnameLine> lines;
  final int totalInventoryLines;
  final List<InventoryStockOpnameLine>? allLines;
  final TextEditingController? countSheetSearchController;
  final InventoryStockOpnameWorksheetFilterState worksheetFilter;
  final InventoryStockOpnameWorksheetFilterCounts? worksheetFilterCounts;
  final InventoryStockOpnameDraftStatus draftStatus;
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
    final countSheetLines = allLines ?? lines;
    final stats = summarizeInventoryStockOpnameLines(countSheetLines);
    final matchableLineCount =
        lines.where((line) => line.discrepancy != 0).length;

    return AppContentPanel(
      title: 'Count Worksheet',
      subtitle: 'Review physical counts against system quantities',
      leadingIcon: Icons.inventory_2_rounded,
      trailing: AppStatusPill(
        label: '${stats.varianceLineCount} variance',
        icon: stats.hasVariance ? Icons.warning_amber_rounded : Icons.done_all,
        color:
            stats.hasVariance ? Colors.orange.shade700 : Colors.green.shade700,
        maxWidth: 150,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InventoryStockOpnameWorksheetReviewHeader(
            showToolbar: _canShowToolbar(countSheetLines),
            searchController: countSheetSearchController,
            state: worksheetFilter,
            counts: worksheetFilterCounts,
            draftStatus: draftStatus,
            onSearchChanged: onWorksheetSearchChanged,
            onFilterChanged: onWorksheetFilterChanged,
            onSortChanged: onWorksheetSortChanged,
            onResetFilters: onWorksheetFiltersReset,
            visibleLineCount: lines.length,
            matchableLineCount: matchableLineCount,
            onMatchVisible:
                onMatchVisibleLines == null || lines.isEmpty
                    ? null
                    : () => onMatchVisibleLines!(List.unmodifiable(lines)),
            onReviewDraftIssue: onReviewDraftIssue,
            onReset: onReset,
          ),
          if (lines.isEmpty)
            InventoryStockOpnameWorksheetEmptyState(
              filter: worksheetFilter,
              totalInventoryLines: totalInventoryLines,
            )
          else ...[
            InventoryStockOpnameWorksheetLineList(
              lines: lines,
              onActualQuantityChanged: onActualQuantityChanged,
              onNotesChanged: onNotesChanged,
              onMatchSystem: onMatchSystem,
              lineKeyBuilder: lineKeyBuilder,
            ),
            const SizedBox(height: 16),
            InventoryStockOpnameActions(
              onReset: onReset,
              onSaveDraft: onSaveDraft,
              onComplete: onComplete,
            ),
          ],
        ],
      ),
    );
  }

  bool _canShowToolbar(List<InventoryStockOpnameLine> countSheetLines) {
    return countSheetSearchController != null &&
        worksheetFilterCounts != null &&
        onWorksheetSearchChanged != null &&
        onWorksheetFilterChanged != null &&
        onWorksheetSortChanged != null &&
        onWorksheetFiltersReset != null &&
        countSheetLines.isNotEmpty;
  }
}

@Preview(name: 'Inventory stock opname panel')
Widget inventoryStockOpnamePanelPreview() {
  final searchController =
      inventoryStockOpnameWorksheetPreviewSearchController();

  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnamePanel(
      lines: [
        inventoryStockOpnamePreviewLine(),
        inventoryStockOpnamePreviewLine(id: 'i2', actualQuantity: 5, notes: ''),
      ],
      totalInventoryLines: 2,
      countSheetSearchController: searchController,
      worksheetFilter: inventoryStockOpnameWorksheetPreviewState(),
      worksheetFilterCounts: inventoryStockOpnameWorksheetPreviewCounts(),
      onActualQuantityChanged: (_, _) {},
      onNotesChanged: (_, _) {},
      onMatchSystem: (_) {},
      onMatchVisibleLines: (_) {},
      onWorksheetSearchChanged: (_) {},
      onWorksheetFilterChanged: (_) {},
      onWorksheetSortChanged: (_) {},
      onWorksheetFiltersReset: () {},
      onReset: () {},
      onSaveDraft: () {},
      onComplete: () {},
    ),
  );
}
