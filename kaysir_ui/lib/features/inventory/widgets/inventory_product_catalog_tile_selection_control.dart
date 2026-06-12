import 'package:flutter/material.dart';

class InventoryProductCatalogTileSelectionControl extends StatelessWidget {
  const InventoryProductCatalogTileSelectionControl({
    super.key,
    required this.productName,
    required this.selected,
    required this.onSelectionChanged,
  });

  final String productName;
  final bool selected;
  final ValueChanged<bool> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: selected ? 'Deselect $productName' : 'Select $productName',
      child: Checkbox(
        value: selected,
        onChanged: (value) => onSelectionChanged(value ?? false),
      ),
    );
  }
}
