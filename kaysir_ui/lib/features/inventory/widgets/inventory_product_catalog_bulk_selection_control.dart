import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';

class InventoryProductCatalogBulkSelectionControl extends StatelessWidget {
  const InventoryProductCatalogBulkSelectionControl({
    super.key,
    required this.selectedCount,
    required this.visibleCount,
    required this.allVisibleSelected,
    required this.onSelectVisibleChanged,
  });

  final int selectedCount;
  final int visibleCount;
  final bool allVisibleSelected;
  final ValueChanged<bool> onSelectVisibleChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message:
              allVisibleSelected
                  ? 'Clear visible selection'
                  : 'Select all visible products',
          child: Checkbox(
            value: allVisibleSelected,
            onChanged:
                visibleCount == 0
                    ? null
                    : (value) => onSelectVisibleChanged(value ?? false),
          ),
        ),
        const SizedBox(width: 4),
        AppStatusPill(
          label: '$selectedCount selected',
          color: colorScheme.primary,
          icon: Icons.library_add_check_rounded,
          maxWidth: 140,
        ),
      ],
    );
  }
}
