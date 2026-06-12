import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_channel_launch_priority.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_action_group.dart';
import 'package:kaysir/features/product/models/product_workspace_action_summary.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut_intent.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/widgets/product_channel_launch_priority_panel.dart';
import 'package:kaysir/features/product/widgets/workspace_header.dart';
import 'package:kaysir/features/product/widgets/workspace_actions.dart';
import 'package:kaysir/features/product/widgets/workspace_attention_panel.dart';

void main() {
  testWidgets('workspace header delegates catalog opening', (tester) async {
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceHeader(
            summary: _summary,
            onOpenCatalog: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('Catalog command center'), findsOneWidget);
    await tester.tap(find.text('Open catalog'));

    expect(opened, isTrue);
  });

  testWidgets('workspace actions delegate route intents', (tester) async {
    await _setLargeSurface(tester);

    ProductWorkspaceShortcutId? selectedShortcutId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceActions(
            shortcuts: buildProductWorkspaceShortcuts(_summary),
            onShortcutSelected: (shortcut) => selectedShortcutId = shortcut.id,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Stock Movements'));
    expect(selectedShortcutId, ProductWorkspaceShortcutId.stockMovements);

    await tester.tap(find.text('Attention Review'));
    expect(selectedShortcutId, ProductWorkspaceShortcutId.attentionReview);
  });

  testWidgets('workspace actions support custom copy and empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceActions(
            shortcuts: const [],
            onShortcutSelected: (_) {},
            title: 'Launchpad',
            subtitle: 'Role-ready product workflows',
            emptyTitle: 'No product workflows',
            emptyMessage: 'Enable a product pack to show shortcuts.',
          ),
        ),
      ),
    );

    expect(find.text('Launchpad'), findsOneWidget);
    expect(find.text('Role-ready product workflows'), findsOneWidget);
    expect(find.text('No product workflows'), findsOneWidget);
    expect(
      find.text('Enable a product pack to show shortcuts.'),
      findsOneWidget,
    );
    expect(find.text('Stock Movements'), findsNothing);
  });

  testWidgets('workspace actions support custom shortcut visuals', (
    tester,
  ) async {
    await _setLargeSurface(tester);

    ProductWorkspaceShortcutId? selectedShortcutId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceActions(
            shortcuts: buildProductWorkspaceShortcuts(
              _summary,
              includeAttentionReview: false,
            ),
            iconBuilder: (_) => Icons.rocket_launch_rounded,
            colorBuilder: (context, shortcut) => Colors.pink,
            onShortcutSelected: (shortcut) => selectedShortcutId = shortcut.id,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.rocket_launch_rounded), findsWidgets);

    await tester.tap(find.text('Product Catalog'));
    expect(selectedShortcutId, ProductWorkspaceShortcutId.catalog);
  });

  testWidgets('workspace actions render grouped shortcuts', (tester) async {
    await _setLargeSurface(tester);

    ProductWorkspaceShortcutId? selectedShortcutId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductWorkspaceActions(
              groups: buildProductWorkspaceActionGroups(_summary),
              onShortcutSelected:
                  (shortcut) => selectedShortcutId = shortcut.id,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Product management'), findsOneWidget);
    expect(find.text('Catalog & review'), findsOneWidget);
    expect(find.text('Stock operations'), findsOneWidget);
    expect(find.text('Freshness control'), findsOneWidget);
    expect(find.text('Audit & control'), findsOneWidget);
    expect(find.text('3 actions'), findsOneWidget);
    expect(find.text('4 actions'), findsOneWidget);
    expect(find.text('12 actions'), findsOneWidget);
    expect(find.text('1 action'), findsNWidgets(2));
    expect(find.text('21/21 ready'), findsOneWidget);
    expect(find.text('5 groups'), findsOneWidget);
    expect(find.text('Ready'), findsNWidgets(5));

    await tester.scrollUntilVisible(find.text('Discrepancy Report'), 220);
    await tester.tap(find.text('Discrepancy Report'));
    expect(selectedShortcutId, ProductWorkspaceShortcutId.discrepancyReport);
  });

  testWidgets('workspace actions render group readiness for gated modules', (
    tester,
  ) async {
    ProductWorkspaceActionSetupFocus? selectedSetupFocus;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceActions(
            groups: [
              ProductWorkspaceActionGroup(
                id: productWorkspaceFreshnessActionGroupId,
                title: 'Freshness control',
                subtitle: 'Expiry, batch, and freshness operations',
                shortcuts: [
                  const ProductWorkspaceShortcut(
                    id: ProductWorkspaceShortcutId.catalog,
                    title: 'Catalog',
                    subtitle: 'Open catalog',
                    status: 'Ready',
                  ),
                  ProductWorkspaceShortcut(
                    id: ProductWorkspaceShortcutId.freshnessQueue,
                    title: 'Freshness Queue',
                    subtitle: 'Connect freshness route',
                    status: 'Setup',
                    setupIntent: ProductWorkspaceShortcutIntent.route(
                      ProductRoutes.workspaceSetupUri(
                        ProductWorkspaceSetupTarget.freshness,
                      ),
                    ),
                    isEnabled: false,
                    disabledReason: 'Connect freshness route first',
                  ),
                ],
              ),
            ],
            onShortcutSelected: (_) {},
            onSetupFocusSelected: (focus) => selectedSetupFocus = focus,
          ),
        ),
      ),
    );

    expect(find.text('Partial'), findsOneWidget);
    expect(find.text('1/2 ready'), findsOneWidget);
    expect(find.text('1 group'), findsOneWidget);
    expect(find.text('1 setup'), findsOneWidget);
    expect(find.text('Set up Freshness Queue'), findsOneWidget);
    expect(find.text('2 actions'), findsOneWidget);
    expect(find.text('1 gated'), findsOneWidget);
    expect(find.text('Connect freshness route first'), findsOneWidget);

    await tester.tap(find.text('Set up Freshness Queue'));

    expect(
      selectedSetupFocus?.actionId,
      ProductWorkspaceShortcutId.freshnessQueue,
    );
    expect(selectedSetupFocus?.actionTitle, 'Freshness Queue');
    expect(
      selectedSetupFocus?.routePath,
      ProductRoutes.workspaceSetupUri(ProductWorkspaceSetupTarget.freshness),
    );
  });

  testWidgets('workspace actions render gated shortcuts without firing', (
    tester,
  ) async {
    ProductWorkspaceShortcutId? selectedShortcutId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceActions(
            shortcuts: const [
              ProductWorkspaceShortcut(
                id: ProductWorkspaceShortcutId.catalog,
                title: 'Wholesale Catalog',
                subtitle: 'Partner-ready catalog management',
                status: 'Setup',
                isEnabled: false,
                disabledReason: 'Enable wholesale pack first',
              ),
            ],
            onShortcutSelected: (shortcut) => selectedShortcutId = shortcut.id,
          ),
        ),
      ),
    );

    expect(find.text('Wholesale Catalog'), findsOneWidget);
    expect(find.text('Enable wholesale pack first'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

    await tester.tap(find.text('Wholesale Catalog'));
    expect(selectedShortcutId, isNull);
  });

  testWidgets('attention panel delegates review action and respects limit', (
    tester,
  ) async {
    var openedAttentionReview = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceAttentionPanel(
            records: _records,
            visibleLimit: 1,
            onReviewCatalog: () => openedAttentionReview = true,
          ),
        ),
      ),
    );

    expect(find.text('Product attention'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Notebook'), findsNothing);

    await tester.tap(find.text('Review catalog'));
    expect(openedAttentionReview, isTrue);
  });

  testWidgets('launch priority panel delegates selected channel work', (
    tester,
  ) async {
    ProductChannelLaunchPriority? selectedPriority;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductChannelLaunchPriorityPanel(
            priorities: buildProductChannelLaunchPriorities(_channelReadiness),
            onSelected: (priority) => selectedPriority = priority,
          ),
        ),
      ),
    );

    expect(find.text('Launch priorities'), findsOneWidget);
    expect(find.text('Self-Service Kiosk'), findsOneWidget);
    expect(find.text('Fix missing scan code'), findsOneWidget);
    expect(find.text('3 missing scan code first'), findsOneWidget);
    expect(find.text('Online Store'), findsOneWidget);
    expect(find.text('Review launch-ready catalog'), findsOneWidget);

    await tester.tap(find.text('Fix missing scan code'));

    expect(selectedPriority?.readiness.channel, ProductSalesChannel.kiosk);
    expect(
      selectedPriority?.primaryIssue?.blocker,
      ProductSalesChannelBlocker.missingScanCode,
    );
  });
}

const _summary = InventoryProductCatalogSummary(
  productCount: 3,
  trackedProductCount: 2,
  inStockProductCount: 1,
  untrackedProductCount: 1,
  attentionProductCount: 2,
  totalQuantity: 12,
  totalInventoryValue: 1100,
  categoryCount: 2,
);

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    category: 'Electronics',
    price: 100,
  ),
  Product(
    id: 'p2',
    name: 'Cable',
    sku: 'CB-001',
    category: 'Accessories',
    price: 25,
  ),
  Product(
    id: 'p3',
    name: 'Notebook',
    sku: 'NB-001',
    category: 'Stationery',
    price: 5,
  ),
];

final _warehouse = Warehouse(
  id: 'w1',
  name: 'Main Warehouse',
  location: 'Jakarta',
);

final _records = buildInventoryProductCatalogRecords(
  products: _products,
  stockRecords: [
    InventoryStockRecord(
      item: InventoryItem(
        id: 'i1',
        productId: 'p1',
        warehouseId: 'w1',
        currentQuantity: 10,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
      product: _products[0],
      warehouse: _warehouse,
    ),
    InventoryStockRecord(
      item: InventoryItem(
        id: 'i2',
        productId: 'p2',
        warehouseId: 'w1',
        currentQuantity: 2,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
      product: _products[1],
      warehouse: _warehouse,
    ),
  ],
);

final _channelReadiness = [
  const ProductSalesChannelReadiness(
    channel: ProductSalesChannel.kiosk,
    title: 'Self-Service Kiosk',
    subtitle: 'Fast-scan products ready for assisted checkout',
    readyCount: 0,
    totalCount: 3,
    reviewFilter: InventoryProductCatalogFilter.inStock,
    issues: [
      ProductSalesChannelReadinessIssue(
        blocker: ProductSalesChannelBlocker.missingScanCode,
        label: 'missing scan code',
        count: 3,
        reviewFilter: InventoryProductCatalogFilter.inStock,
        reviewQuery: 'Missing scan code',
      ),
    ],
  ),
  const ProductSalesChannelReadiness(
    channel: ProductSalesChannel.onlineStore,
    title: 'Online Store',
    subtitle: 'SKU, product copy, and active stock',
    readyCount: 3,
    totalCount: 3,
    reviewFilter: InventoryProductCatalogFilter.all,
  ),
];

Future<void> _setLargeSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1180, 1100));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}
