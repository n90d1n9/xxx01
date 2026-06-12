import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_select_field.dart';
import '../../product/models/product.dart';
import '../models/inventory_branch_filter.dart';
import '../models/inventory_stock_movement_report.dart';
import '../models/movement_type.dart';
import '../models/warehouse.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_branch_filter.dart';
import 'inventory_date_picker_button.dart';
import 'inventory_reset_filters_button.dart';

/// Filter panel for narrowing a stock movement report.
class InventoryStockMovementReportFilters extends StatelessWidget {
  const InventoryStockMovementReportFilters({
    super.key,
    required this.products,
    required this.branchLabels,
    this.branchOptions,
    required this.warehouses,
    required this.startDate,
    required this.endDate,
    required this.productId,
    required this.branchName,
    required this.movementType,
    required this.warehouseId,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
    required this.onProductChanged,
    required this.onBranchChanged,
    required this.onMovementTypeChanged,
    required this.onWarehouseChanged,
    required this.onResetFilters,
  });

  static const _allProductsValue = '__all_products__';
  static const _allTypesValue = '__all_types__';
  static const _allWarehousesValue = '__all_warehouses__';

  final List<Product> products;
  final List<String> branchLabels;
  final List<InventoryBranchFilterOption>? branchOptions;
  final List<Warehouse> warehouses;
  final DateTime startDate;
  final DateTime endDate;
  final String? productId;
  final String? branchName;
  final MovementType? movementType;
  final String? warehouseId;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;
  final ValueChanged<String?> onProductChanged;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<MovementType?> onMovementTypeChanged;
  final ValueChanged<String?> onWarehouseChanged;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Report Filters',
      subtitle:
          'Refine movement activity by period, product, type, or warehouse',
      leadingIcon: Icons.tune_rounded,
      trailing: InventoryResetFiltersButton(onPressed: onResetFilters),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fieldWidth =
              constraints.maxWidth < 760
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 24) / 3;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: fieldWidth,
                child: InventoryDatePickerButton(
                  label: 'Start date',
                  valueLabel: formatInventoryIsoDate(startDate),
                  onPressed: onSelectStartDate,
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: InventoryDatePickerButton(
                  label: 'End date',
                  valueLabel: formatInventoryIsoDate(endDate),
                  onPressed: onSelectEndDate,
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: AppSelectField<String>(
                  key: ValueKey(productId ?? _allProductsValue),
                  label: 'Product',
                  icon: Icons.inventory_2_rounded,
                  value: productId ?? _allProductsValue,
                  options: [
                    const AppSelectOption(
                      value: _allProductsValue,
                      label: 'All products',
                    ),
                    for (final product in products)
                      AppSelectOption(value: product.id, label: product.name),
                  ],
                  onChanged:
                      (value) => onProductChanged(
                        value == _allProductsValue ? null : value,
                      ),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: InventoryBranchSelectField(
                  branchLabels: branchLabels,
                  branchOptions: branchOptions,
                  selectedBranch: branchName,
                  onChanged: onBranchChanged,
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: AppSelectField<String>(
                  key: ValueKey(movementType?.name ?? _allTypesValue),
                  label: 'Movement type',
                  icon: Icons.sync_alt_rounded,
                  value: movementType?.name ?? _allTypesValue,
                  options: [
                    const AppSelectOption(
                      value: _allTypesValue,
                      label: 'All types',
                    ),
                    for (final type in MovementType.values)
                      AppSelectOption(
                        value: type.name,
                        label: inventoryStockMovementReportTypeLabel(type),
                      ),
                  ],
                  onChanged: (value) {
                    onMovementTypeChanged(
                      value == _allTypesValue
                          ? null
                          : MovementType.values.firstWhere(
                            (type) => type.name == value,
                          ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: AppSelectField<String>(
                  key: ValueKey(warehouseId ?? _allWarehousesValue),
                  label: 'Warehouse',
                  icon: Icons.warehouse_rounded,
                  value: warehouseId ?? _allWarehousesValue,
                  options: [
                    const AppSelectOption(
                      value: _allWarehousesValue,
                      label: 'All warehouses',
                    ),
                    for (final warehouse in warehouses)
                      AppSelectOption(
                        value: warehouse.id,
                        label: warehouse.name,
                      ),
                  ],
                  onChanged:
                      (value) => onWarehouseChanged(
                        value == _allWarehousesValue ? null : value,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
