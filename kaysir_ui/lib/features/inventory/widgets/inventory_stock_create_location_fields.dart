import 'package:flutter/material.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../../product/models/product.dart';
import '../models/warehouse.dart';

class InventoryStockCreateLocationFields extends StatelessWidget {
  const InventoryStockCreateLocationFields({
    super.key,
    required this.products,
    required this.warehouses,
    required this.selectedProductId,
    required this.selectedWarehouseId,
    required this.onProductChanged,
    required this.onWarehouseChanged,
  });

  final List<Product> products;
  final List<Warehouse> warehouses;
  final String selectedProductId;
  final String selectedWarehouseId;
  final ValueChanged<String> onProductChanged;
  final ValueChanged<String> onWarehouseChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final fields = [
          AppSelectField<String>(
            label: 'Product',
            icon: Icons.category_rounded,
            value: selectedProductId,
            options: [
              for (final product in products)
                AppSelectOption(value: product.id, label: product.name),
            ],
            onChanged: onProductChanged,
            menuMaxHeight: 260,
          ),
          AppSelectField<String>(
            label: 'Warehouse',
            icon: Icons.warehouse_rounded,
            value: selectedWarehouseId,
            options: [
              for (final warehouse in warehouses)
                AppSelectOption(value: warehouse.id, label: warehouse.name),
            ],
            onChanged: onWarehouseChanged,
            menuMaxHeight: 260,
          ),
        ];

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [fields[0], const SizedBox(height: 12), fields[1]],
          );
        }

        return Row(
          children: [
            Expanded(child: fields[0]),
            const SizedBox(width: 12),
            Expanded(child: fields[1]),
          ],
        );
      },
    );
  }
}
