import 'package:flutter/material.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../models/inventory_branch_filter.dart';
import '../models/warehouse.dart';

class InventoryBranchSelectField extends StatelessWidget {
  const InventoryBranchSelectField({
    super.key,
    this.branchLabels = const [],
    this.branchOptions,
    required this.selectedBranch,
    required this.onChanged,
    this.label = 'Branch',
    this.allLabel = 'All branches',
    this.icon = Icons.account_tree_rounded,
  });

  static const _allBranchesValue = '__all_inventory_branches__';

  final List<String> branchLabels;
  final List<InventoryBranchFilterOption>? branchOptions;
  final String? selectedBranch;
  final ValueChanged<String?> onChanged;
  final String label;
  final String allLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final options =
        branchOptions ?? inventoryBranchOptionsForLabels(branchLabels);

    return AppSelectField<String>(
      key: ValueKey(selectedBranch ?? _allBranchesValue),
      label: label,
      icon: icon,
      value: selectedBranch ?? _allBranchesValue,
      options: [
        AppSelectOption(value: _allBranchesValue, label: allLabel),
        for (final option in options)
          AppSelectOption(value: option.value, label: option.label),
      ],
      onChanged: (value) {
        onChanged(value == _allBranchesValue ? null : value);
      },
    );
  }
}

class InventoryWarehouseSelectField extends StatelessWidget {
  const InventoryWarehouseSelectField({
    super.key,
    required this.warehouses,
    required this.selectedWarehouseId,
    required this.onChanged,
    this.label = 'Warehouse',
    this.allLabel = 'All warehouses',
    this.icon = Icons.warehouse_rounded,
  });

  static const _allWarehousesValue = '__all_inventory_warehouses__';

  final List<Warehouse> warehouses;
  final String? selectedWarehouseId;
  final ValueChanged<String?> onChanged;
  final String label;
  final String allLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<String>(
      key: ValueKey(selectedWarehouseId ?? _allWarehousesValue),
      label: label,
      icon: icon,
      value: selectedWarehouseId ?? _allWarehousesValue,
      options: [
        AppSelectOption(value: _allWarehousesValue, label: allLabel),
        for (final warehouse in warehouses)
          AppSelectOption(value: warehouse.id, label: warehouse.name),
      ],
      onChanged: (value) {
        onChanged(value == _allWarehousesValue ? null : value);
      },
    );
  }
}
