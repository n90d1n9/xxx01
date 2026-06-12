import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/widgets/inventory_branch_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_row_actions.dart';
import 'package:kaysir/features/inventory/widgets/inventory_separated_list.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('branch summary renders reusable metrics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryBranchSummary(
            branches: _branches,
            warehouseCountByBranchId: const {'b1': 2, 'b2': 0},
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Branches'), findsOneWidget);
    expect(find.text('Linked Warehouses'), findsOneWidget);
    expect(find.text('Planning'), findsOneWidget);
    expect(find.text('Staffed'), findsOneWidget);
    expect(find.text('Entities'), findsOneWidget);
  });

  testWidgets('branch panel renders tiles and emits actions', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var edited = false;
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InventoryBranchPanel(
              branches: _branches,
              warehouseCountByBranchId: const {'b1': 2, 'b2': 0},
              onEditBranch: (_) => edited = true,
              onDeleteBranch: (_) => deleted = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryBranchPanelStatusPill), findsOneWidget);
    expect(find.byType(InventoryBranchPanelList), findsOneWidget);
    expect(
      find.byType(InventorySeparatedList<InventoryBranch>),
      findsOneWidget,
    );
    expect(find.byType(InventoryBranchTile), findsNWidgets(2));
    expect(find.byType(InventoryBranchTileSummary), findsNWidgets(2));
    expect(find.byType(InventoryBranchTileMetricStrip), findsNWidgets(2));
    expect(find.byType(InventoryBranchTileStatusPill), findsNWidgets(2));
    expect(find.byType(InventoryBranchTileActions), findsNWidgets(2));
    expect(find.byType(InventoryBranchTileExpandedLayout), findsNWidgets(2));
    expect(find.byType(InventoryTileSurface), findsAtLeastNWidgets(2));
    expect(find.text('Jakarta Central'), findsOneWidget);
    expect(find.textContaining('JKT-HQ'), findsOneWidget);
    expect(find.textContaining('PT Kaysir Nusantara'), findsOneWidget);
    expect(find.text('Headquarters'), findsOneWidget);
    expect(find.text('Planning'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byType(InventoryRowActions), findsNWidgets(2));

    await tester.tap(find.byTooltip('Edit Jakarta Central'));
    expect(edited, isTrue);

    await tester.tap(find.byTooltip('Delete Bandung Retail'));
    expect(deleted, isTrue);
  });

  testWidgets('branch tile switches to compact layout on narrow width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryBranchTile(branch: _branches.first, warehouseCount: 2),
        ),
      ),
    );

    expect(find.byType(InventoryBranchTileCompactLayout), findsOneWidget);
    expect(find.byType(InventoryBranchTileExpandedLayout), findsNothing);
    expect(find.text('Jakarta Central'), findsOneWidget);
  });

  testWidgets('branch panel shows empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryBranchPanel(
            branches: [],
            warehouseCountByBranchId: {},
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.byType(InventoryBranchPanelEmptyState), findsOneWidget);
    expect(find.byType(InventoryBranchPanelStatusPill), findsNothing);
    expect(find.text('No branches yet'), findsOneWidget);
  });
}

const _branches = [
  InventoryBranch(
    id: 'b1',
    name: 'Jakarta Central',
    city: 'Jakarta',
    managerName: 'Rina Wijaya',
    contact: 'jakarta.ops@kaysir.local',
    code: 'JKT-HQ',
    region: 'Java West',
    legalEntity: 'PT Kaysir Nusantara',
    type: InventoryBranchType.headquarters,
    employeeCount: 52,
  ),
  InventoryBranch(
    id: 'b2',
    name: 'Bandung Retail',
    city: 'Bandung',
    managerName: 'Maya Lestari',
    contact: 'bandung.ops@kaysir.local',
    code: 'BDG-RT',
    region: 'Java West',
    legalEntity: 'PT Kaysir Retail Indonesia',
    type: InventoryBranchType.retailOutlet,
    employeeCount: 18,
    status: InventoryBranchStatus.planning,
  ),
];
