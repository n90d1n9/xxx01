import 'package:flutter/material.dart';

import 'inventory_form_fields.dart';

class InventoryStockCreateQuantityFields extends StatelessWidget {
  const InventoryStockCreateQuantityFields({
    super.key,
    required this.quantityController,
    required this.reorderPointController,
    required this.reorderQuantityController,
  });

  final TextEditingController quantityController;
  final TextEditingController reorderPointController;
  final TextEditingController reorderQuantityController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fields = [
          InventoryIntegerFormField(
            controller: quantityController,
            label: 'Opening quantity',
            icon: Icons.inventory_2_rounded,
            allowZero: true,
          ),
          InventoryIntegerFormField(
            controller: reorderPointController,
            label: 'Reorder point',
            icon: Icons.flag_rounded,
            allowZero: true,
          ),
          InventoryIntegerFormField(
            controller: reorderQuantityController,
            label: 'Reorder quantity',
            icon: Icons.playlist_add_rounded,
            allowZero: false,
          ),
        ];

        if (constraints.maxWidth < 640) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fields[0],
              const SizedBox(height: 12),
              fields[1],
              const SizedBox(height: 12),
              fields[2],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: fields[0]),
            const SizedBox(width: 12),
            Expanded(child: fields[1]),
            const SizedBox(width: 12),
            Expanded(child: fields[2]),
          ],
        );
      },
    );
  }
}
