import 'package:flutter/material.dart';

import '../utils/inventory_formatters.dart';

String compactInventoryWarehouseCount(
  int value,
  String singular,
  String plural,
) {
  return '${formatInventoryNumber(value)} ${value == 1 ? singular : plural}';
}

/// Compact inline metric used by warehouse detail cards and report rows.
class InventoryWarehouseDetailInlineFact extends StatelessWidget {
  const InventoryWarehouseDetailInlineFact({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$value $label',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
