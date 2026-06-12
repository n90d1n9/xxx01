import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/branch_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_branch_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/company_branch_governance_panel.dart';
import 'package:kaysir/features/inventory/widgets/inventory_branch_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_branch_dialog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('branch page composes branch directory workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_branchPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryBranchWorkspace), findsOneWidget);
    expect(find.byType(InventoryBranchSummary), findsOneWidget);
    expect(find.byType(CompanyBranchGovernancePanel), findsOneWidget);
    expect(find.text('Company Management'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Branch Directory'), 500);
    await tester.pumpAndSettle();
    expect(find.byType(InventoryBranchPanel), findsOneWidget);
    expect(find.text('Branch Directory'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsWidgets);
    expect(find.text('Bandung Retail'), findsWidgets);
  });

  testWidgets('branch page uses shared inventory navigation shell', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_branchPage());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.branches,
      ),
    );
  });

  testWidgets('branch page adds edits and deletes an unassigned branch', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_branchPage());

    await tester.tap(find.byTooltip('Add branch'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryBranchDialog), findsOneWidget);

    var fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Bekasi Outlet');
    await tester.enterText(fields.at(1), 'Bekasi');
    await tester.enterText(fields.at(2), 'Dewi Lestari');
    await tester.enterText(fields.at(3), 'bekasi.ops@kaysir.local');
    await tester.enterText(fields.at(4), 'BKS-OT');
    await tester.enterText(fields.at(5), 'Java West');
    await tester.enterText(fields.at(6), 'PT Kaysir Retail Indonesia');
    await tester.enterText(fields.at(7), '12');
    await tester.enterText(fields.at(8), 'Satellite stock point');
    final addButton = find.widgetWithText(FilledButton, 'Add branch');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Bekasi Outlet'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Bekasi Outlet'), 500);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Edit Bekasi Outlet'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit Bekasi Outlet'));
    await tester.pumpAndSettle();

    fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Bekasi Fulfillment');
    final updateButton = find.widgetWithText(FilledButton, 'Update branch');
    await tester.ensureVisible(updateButton);
    await tester.tap(updateButton);
    await tester.pumpAndSettle();

    expect(find.text('Bekasi Fulfillment'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Bekasi Fulfillment'), 500);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Delete Bekasi Fulfillment'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete Bekasi Fulfillment'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryBranchDeleteDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Bekasi Fulfillment'), findsNothing);
  });

  testWidgets('branch page blocks deleting an assigned branch', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_branchPage());

    await tester.scrollUntilVisible(find.text('Jakarta Central').last, 500);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Delete Jakarta Central'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete Jakarta Central'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryBranchDeleteDialog), findsOneWidget);
    expect(find.textContaining('Move 1 assigned warehouses'), findsOneWidget);

    final blockedButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Branch in use'),
    );
    expect(blockedButton.onPressed, isNull);
  });
}

Widget _branchPage() {
  return ProviderScope(
    overrides: [
      inventoryBranchesProvider.overrideWith((ref) => _SeededBranches()),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses()),
    ],
    child: const MaterialApp(home: BranchPage()),
  );
}

class _SeededBranches extends InventoryBranchesNotifier {
  _SeededBranches() {
    state = const [
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
      ),
    ];
  }
}

class _SeededWarehouses extends WarehousesNotifier {
  _SeededWarehouses() {
    state = [
      Warehouse(
        id: 'w1',
        name: 'Main Warehouse',
        branchId: 'b1',
        branchName: 'Jakarta Central',
        location: 'Jakarta',
      ),
    ];
  }
}
