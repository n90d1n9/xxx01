import 'warehouse.dart';

class InventoryBranchFilterOption {
  const InventoryBranchFilterOption({required this.value, required this.label});

  final String value;
  final String label;
}

List<InventoryBranchFilterOption> inventoryBranchOptionsForWarehouses(
  Iterable<Warehouse> warehouses,
) {
  final optionsByValue = <String, InventoryBranchFilterOption>{};

  for (final warehouse in warehouses) {
    final value = inventoryBranchFilterValueForWarehouse(warehouse);
    optionsByValue.putIfAbsent(
      value,
      () => InventoryBranchFilterOption(
        value: value,
        label: warehouse.branchLabel,
      ),
    );
  }

  final options = optionsByValue.values.toList();
  options.sort((first, second) => first.label.compareTo(second.label));
  return options;
}

List<InventoryBranchFilterOption> inventoryBranchOptionsForLabels(
  Iterable<String> branchLabels,
) {
  final options =
      <String>{
        for (final branchLabel in branchLabels) branchLabel.trim(),
      }.where((branchLabel) => branchLabel.isNotEmpty).map((branchLabel) {
        return InventoryBranchFilterOption(
          value: branchLabel,
          label: branchLabel,
        );
      }).toList();

  options.sort((first, second) => first.label.compareTo(second.label));
  return options;
}

List<String> inventoryBranchLabelsForWarehouses(
  Iterable<Warehouse> warehouses,
) {
  return [
    for (final option in inventoryBranchOptionsForWarehouses(warehouses))
      option.label,
  ];
}

String inventoryBranchFilterValueForWarehouse(Warehouse warehouse) {
  final branchId = warehouse.branchId?.trim();
  if (branchId != null && branchId.isNotEmpty) {
    return branchId;
  }

  return warehouse.branchLabel;
}

bool inventoryBranchLabelMatches(String branchLabel, String? selectedBranch) {
  return inventoryBranchFilterMatches(
    branchId: null,
    branchLabel: branchLabel,
    selectedBranch: selectedBranch,
  );
}

bool inventoryBranchFilterMatches({
  required String branchLabel,
  required String? selectedBranch,
  String? branchId,
}) {
  if (selectedBranch == null) return true;

  final normalizedBranchId = branchId?.trim();
  final normalizedSelectedValue = selectedBranch.trim();
  if (normalizedBranchId != null &&
      normalizedBranchId.isNotEmpty &&
      normalizedBranchId == normalizedSelectedValue) {
    return true;
  }

  final normalizedBranch = _normalizeBranchLabel(branchLabel);
  final normalizedSelectedBranch = _normalizeBranchLabel(selectedBranch);

  return normalizedBranch == normalizedSelectedBranch;
}

bool inventoryWarehouseMatchesBranch(
  Warehouse warehouse,
  String? selectedBranch,
) {
  return inventoryBranchFilterMatches(
    branchId: warehouse.branchId,
    branchLabel: warehouse.branchLabel,
    selectedBranch: selectedBranch,
  );
}

List<Warehouse> filterInventoryWarehousesByBranch(
  List<Warehouse> warehouses, {
  String? selectedBranch,
}) {
  return [
    for (final warehouse in warehouses)
      if (inventoryWarehouseMatchesBranch(warehouse, selectedBranch)) warehouse,
  ];
}

String? inventoryValidBranchFilter(
  String? selectedBranch,
  Iterable<String> branchLabels,
) {
  return inventoryValidBranchFilterValue(
    selectedBranch,
    inventoryBranchOptionsForLabels(branchLabels),
  );
}

String? inventoryValidBranchFilterValue(
  String? selectedBranch,
  Iterable<InventoryBranchFilterOption> branchOptions,
) {
  if (selectedBranch == null) return null;

  final selectedValue = selectedBranch.trim();
  for (final branchOption in branchOptions) {
    if (branchOption.value == selectedValue ||
        inventoryBranchLabelMatches(branchOption.label, selectedBranch)) {
      return branchOption.value;
    }
  }

  return null;
}

String _normalizeBranchLabel(String value) => value.trim().toLowerCase();
