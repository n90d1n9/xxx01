import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_dashboard.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_branch_detail_panel_state.dart';

void main() {
  test('branch detail panel state selects requested branch', () {
    final state = InventoryAnalyticsBranchDetailPanelState.fromDetails(
      details: _details,
      selectedBranchId: 'branch-surabaya',
    );

    expect(state.hasDetail, isTrue);
    expect(state.selectedDetail?.branchName, 'Surabaya North');
    expect(state.options.map((option) => option.label), [
      'Jakarta Central',
      'Surabaya North',
    ]);
  });

  test('branch detail panel state falls back to first detail', () {
    final state = InventoryAnalyticsBranchDetailPanelState.fromDetails(
      details: _details,
      selectedBranchId: 'missing-branch',
    );

    expect(state.selectedDetail?.branchId, 'branch-jakarta');
  });

  test('branch detail panel state handles empty details', () {
    final state = InventoryAnalyticsBranchDetailPanelState.fromDetails(
      details: const [],
      selectedBranchId: null,
    );

    expect(state.hasDetail, isFalse);
    expect(state.selectedDetail, isNull);
    expect(state.options, isEmpty);
  });
}

const _details = [
  InventoryAnalyticsBranchDetail(
    branchId: 'branch-jakarta',
    branchName: 'Jakarta Central',
    value: 550,
    quantity: 7,
    lowStockCount: 1,
    warehouseCount: 1,
    productCount: 2,
    movementCount: 2,
    warehouses: [],
    recentMovements: [],
  ),
  InventoryAnalyticsBranchDetail(
    branchId: 'branch-surabaya',
    branchName: 'Surabaya North',
    value: 265,
    quantity: 13,
    lowStockCount: 1,
    warehouseCount: 1,
    productCount: 2,
    movementCount: 1,
    warehouses: [],
    recentMovements: [],
  ),
];
