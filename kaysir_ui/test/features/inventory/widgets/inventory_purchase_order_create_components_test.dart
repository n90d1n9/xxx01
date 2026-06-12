import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_create.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/inventory/utils/inventory_form_utils.dart';
import 'package:kaysir/features/inventory/widgets/inventory_date_picker_button.dart';
import 'package:kaysir/features/inventory/widgets/inventory_purchase_order_create_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_separated_list.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('purchase order create summary renders draft metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderCreateSummaryGrid(draft: _draft),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Order Value'), findsOneWidget);
    expect(find.text('Items'), findsOneWidget);
    expect(find.text('Supplier'), findsOneWidget);
    expect(find.text('Delivery'), findsOneWidget);
    expect(find.text(r'$300.00'), findsOneWidget);
  });

  testWidgets('purchase order details panel renders form fields', (
    tester,
  ) async {
    final supplierController = TextEditingController(text: 'Jakarta Supply');
    final notesController = TextEditingController();
    addTearDown(supplierController.dispose);
    addTearDown(notesController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderCreateDetailsPanel(
            supplierController: supplierController,
            notesController: notesController,
            expectedDeliveryDate: DateTime(2026, 6, 5),
            onExpectedDatePressed: () {},
            onChanged: () {},
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryDatePickerButton), findsOneWidget);
    expect(find.text('Supplier & Delivery'), findsOneWidget);
    expect(find.text('Jakarta Supply'), findsOneWidget);
    expect(find.text('Jun 5, 2026'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
  });

  testWidgets('purchase order details panel validates supplier name', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final supplierController = TextEditingController();
    final notesController = TextEditingController();
    addTearDown(supplierController.dispose);
    addTearDown(notesController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: InventoryPurchaseOrderCreateDetailsPanel(
              supplierController: supplierController,
              notesController: notesController,
              expectedDeliveryDate: null,
              onExpectedDatePressed: () {},
              onChanged: () {},
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text(inventorySupplierNameRequiredError), findsOneWidget);
  });

  testWidgets('purchase order items panel renders tiles and remove callback', (
    tester,
  ) async {
    var removedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderCreateItemsPanel(
            items: _items,
            onAddItem: () {},
            onRemoveItem: (index) => removedIndex = index,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(InventorySeparatedList<PurchaseOrderItem>),
      findsOneWidget,
    );
    expect(find.byType(InventoryPurchaseOrderCreateItemTile), findsNWidgets(2));
    expect(find.byType(InventoryTileSurface), findsNWidgets(3));
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);
    expect(find.text(r'$300.00'), findsOneWidget);
    expect(find.byType(AppIconActionButton), findsNWidgets(2));

    await tester.tap(find.byTooltip('Remove Cable'));
    await tester.pump();
    expect(removedIndex, 1);
  });

  testWidgets('purchase order items panel shows empty state', (tester) async {
    var addCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderCreateItemsPanel(
            items: const [],
            onAddItem: () => addCalled = true,
            onRemoveItem: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No items added'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Add item'));
    await tester.pump();
    expect(addCalled, isTrue);
  });
}

final _items = [
  PurchaseOrderItem(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    quantity: 2,
    unitPrice: 100,
  ),
  PurchaseOrderItem(
    id: 'p2',
    name: 'Cable',
    sku: 'CB-001',
    quantity: 4,
    unitPrice: 25,
  ),
];

final _draft = InventoryPurchaseOrderCreateDraft(
  supplierName: 'Jakarta Supply',
  expectedDeliveryDate: DateTime(2026, 6, 5),
  items: _items,
);
