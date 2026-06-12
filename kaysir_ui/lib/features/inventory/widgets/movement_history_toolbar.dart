import 'package:flutter/material.dart';

import '../../../widgets/ui/app_filter_bar.dart';
import '../../../widgets/ui/app_filter_chip_group.dart';
import '../../../widgets/ui/app_icon_action_button.dart';
import '../models/inventory_branch_filter.dart';
import '../models/inventory_movement_record.dart';
import '../models/warehouse.dart';
import 'inventory_branch_filter.dart';
import 'inventory_search_field.dart';
import 'movement_direction_visuals.dart';

/// Filter toolbar for searching and segmenting inventory movement history.
class InventoryMovementHistoryToolbar extends StatelessWidget {
  const InventoryMovementHistoryToolbar({
    super.key,
    required this.searchController,
    required this.records,
    required this.branchLabels,
    this.branchOptions,
    required this.warehouses,
    required this.selectedBranch,
    required this.selectedWarehouseId,
    required this.filter,
    required this.onSearchChanged,
    required this.onBranchChanged,
    required this.onWarehouseChanged,
    required this.onFilterChanged,
    this.onCopyLink,
  });

  final TextEditingController searchController;
  final List<InventoryMovementRecord> records;
  final List<String> branchLabels;
  final List<InventoryBranchFilterOption>? branchOptions;
  final List<Warehouse> warehouses;
  final String? selectedBranch;
  final String? selectedWarehouseId;
  final InventoryMovementFilter filter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<String?> onWarehouseChanged;
  final ValueChanged<InventoryMovementFilter> onFilterChanged;
  final VoidCallback? onCopyLink;

  @override
  Widget build(BuildContext context) {
    return AppFilterBar(
      search: InventorySearchField(
        controller: searchController,
        hintText: 'Search product, SKU, warehouse, reference, or notes',
        onChanged: onSearchChanged,
      ),
      filters: [
        AppFilterChipGroup<InventoryMovementFilter>(
          value: filter,
          options: [
            AppFilterChipOption(
              value: InventoryMovementFilter.all,
              label: 'All',
              icon: Icons.all_inclusive_rounded,
              count: records.length,
            ),
            AppFilterChipOption(
              value: InventoryMovementFilter.inbound,
              label: 'Inbound',
              icon: movementDirectionIcon(InventoryMovementDirection.inbound),
              count: _count(records, InventoryMovementFilter.inbound),
            ),
            AppFilterChipOption(
              value: InventoryMovementFilter.outbound,
              label: 'Outbound',
              icon: movementDirectionIcon(InventoryMovementDirection.outbound),
              count: _count(records, InventoryMovementFilter.outbound),
            ),
            AppFilterChipOption(
              value: InventoryMovementFilter.transfer,
              label: 'Transfer',
              icon: movementDirectionIcon(InventoryMovementDirection.transfer),
              count: _count(records, InventoryMovementFilter.transfer),
            ),
            AppFilterChipOption(
              value: InventoryMovementFilter.adjustment,
              label: 'Adjust',
              icon: movementDirectionIcon(
                InventoryMovementDirection.adjustment,
              ),
              count: _count(records, InventoryMovementFilter.adjustment),
            ),
            AppFilterChipOption(
              value: InventoryMovementFilter.stockOpname,
              label: 'Audit',
              icon: movementDirectionIcon(InventoryMovementDirection.audit),
              count: _count(records, InventoryMovementFilter.stockOpname),
            ),
          ],
          onChanged: onFilterChanged,
        ),
        AppIconActionButton(
          icon: Icons.link_rounded,
          tooltip: 'Copy filtered link',
          variant: AppIconActionButtonVariant.outlined,
          onPressed: onCopyLink,
        ),
      ],
      trailing: [
        InventoryBranchSelectField(
          branchLabels: branchLabels,
          branchOptions: branchOptions,
          selectedBranch: selectedBranch,
          onChanged: onBranchChanged,
        ),
        InventoryWarehouseSelectField(
          warehouses: warehouses,
          selectedWarehouseId: selectedWarehouseId,
          onChanged: onWarehouseChanged,
        ),
      ],
    );
  }

  int _count(
    List<InventoryMovementRecord> records,
    InventoryMovementFilter filter,
  ) {
    return records.where((record) => record.matchesFilter(filter)).length;
  }
}
