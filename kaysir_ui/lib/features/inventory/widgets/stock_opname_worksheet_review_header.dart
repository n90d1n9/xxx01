import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_stock_opname_draft_status.dart';
import '../models/inventory_stock_opname_worksheet_filter.dart';
import 'inventory_stock_opname_batch_actions.dart';
import 'inventory_stock_opname_draft_status_banner.dart';
import 'inventory_stock_opname_worksheet_toolbar.dart';
import 'stock_opname_worksheet_preview_data.dart';

/// Optional review controls shown above stock opname worksheet rows.
class InventoryStockOpnameWorksheetReviewHeader extends StatelessWidget {
  const InventoryStockOpnameWorksheetReviewHeader({
    super.key,
    required this.showToolbar,
    required this.state,
    required this.draftStatus,
    this.searchController,
    this.counts,
    this.onSearchChanged,
    this.onFilterChanged,
    this.onSortChanged,
    this.onResetFilters,
    this.visibleLineCount = 0,
    this.matchableLineCount = 0,
    this.onMatchVisible,
    this.onReviewDraftIssue,
    this.onReset,
  }) : assert(
         !showToolbar ||
             (searchController != null &&
                 counts != null &&
                 onSearchChanged != null &&
                 onFilterChanged != null &&
                 onSortChanged != null &&
                 onResetFilters != null),
       );

  final bool showToolbar;
  final TextEditingController? searchController;
  final InventoryStockOpnameWorksheetFilterState state;
  final InventoryStockOpnameWorksheetFilterCounts? counts;
  final InventoryStockOpnameDraftStatus draftStatus;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<InventoryStockOpnameWorksheetFilter>? onFilterChanged;
  final ValueChanged<InventoryStockOpnameWorksheetSort>? onSortChanged;
  final VoidCallback? onResetFilters;
  final int visibleLineCount;
  final int matchableLineCount;
  final VoidCallback? onMatchVisible;
  final VoidCallback? onReviewDraftIssue;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (showToolbar)
        InventoryStockOpnameWorksheetToolbar(
          searchController: searchController!,
          state: state,
          counts: counts!,
          onSearchChanged: onSearchChanged!,
          onFilterChanged: onFilterChanged!,
          onSortChanged: onSortChanged!,
          onResetFilters: onResetFilters!,
        ),
      if (visibleLineCount > 0 && onMatchVisible != null)
        InventoryStockOpnameBatchActions(
          visibleLineCount: visibleLineCount,
          matchableLineCount: matchableLineCount,
          onMatchVisible: onMatchVisible,
        ),
      if (draftStatus.hasUnsavedChanges)
        InventoryStockOpnameDraftStatusBanner(
          status: draftStatus,
          onReviewFirstIssue: onReviewDraftIssue,
          onReset: onReset,
        ),
    ];

    if (children.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < children.length; index += 1) ...[
            if (index > 0) const SizedBox(height: 14),
            children[index],
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Inventory stock opname worksheet review header')
Widget inventoryStockOpnameWorksheetReviewHeaderPreview() {
  final searchController =
      inventoryStockOpnameWorksheetPreviewSearchController();

  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnameWorksheetReviewHeader(
      showToolbar: true,
      searchController: searchController,
      state: inventoryStockOpnameWorksheetPreviewState(),
      counts: inventoryStockOpnameWorksheetPreviewCounts(),
      draftStatus: const InventoryStockOpnameDraftStatus(
        changedLineCount: 2,
        invalidActualQuantityLineCount: 1,
      ),
      onSearchChanged: (_) {},
      onFilterChanged: (_) {},
      onSortChanged: (_) {},
      onResetFilters: () {},
      visibleLineCount: 3,
      matchableLineCount: 2,
      onMatchVisible: () {},
      onReviewDraftIssue: () {},
      onReset: () {},
    ),
  );
}
