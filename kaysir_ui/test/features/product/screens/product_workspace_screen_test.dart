import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_route_state.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/screens/product_workspace_screen.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/sales_channel_definition_provider.dart';
import 'package:kaysir/features/product/widgets/experience_profile_scope.dart';
import 'package:kaysir/features/product/widgets/management_mode_status_panel.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('product workspace summarizes catalog health and shortcuts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_workspace());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Product Workspace'), findsOneWidget);
    expect(find.text('Catalog command center'), findsOneWidget);
    expect(find.text('Setup targets'), findsOneWidget);
    expect(find.text('0/1 active'), findsOneWidget);
    expect(find.text('1 needs attention'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Workspace shortcuts');

    expect(find.text('Workspace shortcuts'), findsOneWidget);
    expect(find.text('Catalog & review'), findsOneWidget);
    expect(find.text('Stock operations'), findsOneWidget);
    expect(find.text('Audit & control'), findsOneWidget);
    expect(find.text('Product Catalog'), findsOneWidget);
    expect(find.text('Stock Movements'), findsOneWidget);
    expect(find.text('Add Stock Movement'), findsOneWidget);
    expect(find.text('Stock Opname'), findsOneWidget);
    expect(find.text('Scan Product'), findsOneWidget);
    expect(find.text('Discrepancy Report'), findsOneWidget);
    expect(find.text('Attention Review'), findsOneWidget);
    expect(find.text('Inventory Dashboard'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Workspace pulse'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Workspace pulse'), findsOneWidget);
    expect(find.text('Catalog setup'), findsOneWidget);
    expect(find.text('Workflow readiness'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Recommended next steps'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Recommended next steps'), findsOneWidget);
    expect(find.text('Clear launch queue'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Catalog views'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Catalog views'), findsOneWidget);
    expect(find.text('All Products'), findsOneWidget);
    expect(find.text('Attention Queue'), findsOneWidget);
    expect(find.text('In Stock'), findsOneWidget);
    expect(find.text('Untracked Setup'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Catalog quality'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Catalog quality'), findsOneWidget);
    expect(find.text('0/3 ready, 3 products need setup'), findsOneWidget);
    expect(find.text('0% complete'), findsOneWidget);
    expect(find.text('missing description'), findsOneWidget);
    expect(find.text('missing scan code'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Product pack mode'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Active product mode'), findsOneWidget);
    expect(find.text('Default mode'), findsOneWidget);
    expect(find.text('Product pack mode'), findsOneWidget);
    expect(find.text('Core Catalog'), findsAtLeastNWidgets(1));
    expect(find.text('Grocery Fresh Goods'), findsAtLeastNWidgets(1));
    expect(find.text('2 packs'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Product-line presets'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Product-line presets'), findsOneWidget);
    expect(find.text('Core Omni Retail'), findsOneWidget);
    expect(find.text('Counter Service Catalog'), findsOneWidget);
    expect(find.text('Digital Commerce Catalog'), findsOneWidget);
    expect(find.text('4 presets'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Channel strategy'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Channel strategy'), findsOneWidget);
    expect(find.text('Omni Retail'), findsAtLeastNWidgets(1));
    expect(find.text('Counter Service'), findsAtLeastNWidgets(1));
    expect(find.text('Digital Commerce'), findsAtLeastNWidgets(1));
    expect(find.text('Omni Retail profile'), findsOneWidget);
    expect(find.text('Current strategy'), findsOneWidget);
    expect(find.text('0/4 channels ready'), findsAtLeastNWidgets(1));
    expect(find.text('25% product coverage'), findsAtLeastNWidgets(1));
    expect(find.text('9 product-channel gaps'), findsAtLeastNWidgets(1));
    expect(
      find.text('Self-Service Kiosk: Fix missing scan code'),
      findsAtLeastNWidgets(1),
    );

    await tester.scrollUntilVisible(
      find.text('Runtime packs'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Runtime packs'), findsOneWidget);
    expect(find.text('Default Product Channels'), findsAtLeastNWidgets(1));
    expect(find.text('Single pack'), findsOneWidget);
    expect(find.text('1 pack'), findsOneWidget);
    expect(find.text('3 profiles'), findsAtLeastNWidgets(1));

    await tester.scrollUntilVisible(
      find.text('Pack contribution bundle'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Pack contribution bundle'), findsOneWidget);
    expect(find.text('Data contract'), findsAtLeastNWidgets(1));
    expect(find.text('Behavior contract'), findsOneWidget);
    expect(find.text('0/5 active hooks'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Pack readiness'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Pack readiness'), findsOneWidget);
    expect(find.text('Core Catalog readiness'), findsOneWidget);
    expect(find.text('Review data'), findsOneWidget);
    expect(find.text('Workflow availability'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Active strategy'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Active strategy'), findsOneWidget);
    expect(find.text('Omni Retail strategy'), findsOneWidget);
    expect(find.text('Self-Service Kiosk queue'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Launch priorities'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Launch priorities'), findsOneWidget);
    expect(find.text('Self-Service Kiosk'), findsAtLeastNWidgets(1));
    expect(find.text('Fix missing scan code'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Channel readiness'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Channel readiness'), findsOneWidget);
    expect(find.text('POS Checkout'), findsAtLeastNWidgets(1));
    expect(find.text('Online Store'), findsAtLeastNWidgets(1));
    expect(find.text('Marketplace'), findsAtLeastNWidgets(1));
    expect(find.text('Self-Service Kiosk'), findsAtLeastNWidgets(1));
    expect(find.text('2 stock not sellable'), findsAtLeastNWidgets(2));
    expect(find.text('3 missing scan code'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Product attention'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Product attention'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Notebook'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);
  });

  testWidgets('product workspace reflects scoped experience profile', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _workspace(experienceProfile: productFreshGoodsExperienceProfile),
    );

    expect(find.text('Fresh Goods'), findsAtLeastNWidgets(1));
    expect(find.text('Fresh inventory operations'), findsOneWidget);
    expect(
      find.textContaining('Fresh-goods product workspace for expiry'),
      findsOneWidget,
    );
  });

  testWidgets('product workspace switches active product pack mode', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = MemoryProductManagementPackPreferencesStore();
    await tester.pumpWidget(_workspace(preferencesStore: store));

    await tester.scrollUntilVisible(
      find.text('Product pack mode'),
      420,
      scrollable: _pageScrollable(),
    );
    final groceryPackOption = find.text('Grocery Fresh Goods').first;
    await tester.ensureVisible(groceryPackOption);
    await tester.pumpAndSettle();
    await tester.tap(groceryPackOption);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Channel strategy'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Fresh Goods Grocery'), findsAtLeastNWidgets(1));

    await tester.scrollUntilVisible(
      find.text('Pack readiness'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Grocery Fresh Goods readiness'), findsOneWidget);
    expect(find.text('Freshness control'), findsAtLeastNWidgets(1));
    expect(store.snapshot, {
      'selectedPackId': 'grocery_fresh_goods',
      'selectedChannelProfileId': 'grocery_fresh_goods',
    });
  });

  testWidgets('product workspace applies product-line presets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = MemoryProductManagementPackPreferencesStore();
    await tester.pumpWidget(_workspace(preferencesStore: store));

    await tester.scrollUntilVisible(
      find.text('Product-line presets'),
      420,
      scrollable: _pageScrollable(),
    );
    final groceryPreset = find.byKey(
      const ValueKey('management-pack-preset-fresh_goods_grocery'),
    );
    await tester.scrollUntilVisible(
      groceryPreset,
      420,
      scrollable: _pageScrollable(),
    );
    await tester.pumpAndSettle();
    await tester.tap(groceryPreset);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Channel strategy'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Fresh Goods Grocery'), findsAtLeastNWidgets(1));

    await tester.scrollUntilVisible(
      find.text('Pack readiness'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Grocery Fresh Goods readiness'), findsOneWidget);
    expect(store.snapshot, {
      'selectedPackId': 'grocery_fresh_goods',
      'selectedChannelProfileId': 'grocery_fresh_goods',
    });
  });

  testWidgets('product workspace hydrates persisted product-line selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = MemoryProductManagementPackPreferencesStore(
      initialSnapshot: const {
        'selectedPackId': 'grocery_fresh_goods',
        'selectedChannelProfileId': 'grocery_fresh_goods',
      },
    );

    await tester.pumpWidget(_workspace(preferencesStore: store));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Channel strategy'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Fresh Goods Grocery'), findsAtLeastNWidgets(1));

    await tester.scrollUntilVisible(
      find.text('Pack readiness'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Grocery Fresh Goods readiness'), findsOneWidget);
  });

  testWidgets('product workspace resets active product mode to default', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = MemoryProductManagementPackPreferencesStore(
      initialSnapshot: const {
        'selectedPackId': 'grocery_fresh_goods',
        'selectedChannelProfileId': 'grocery_fresh_goods',
      },
    );

    await tester.pumpWidget(_workspace(preferencesStore: store));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Active product mode'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Custom mode'), findsOneWidget);
    expect(find.text('Fresh Goods Grocery'), findsAtLeastNWidgets(1));

    final resetButton = find.descendant(
      of: find.byType(ProductManagementModeStatusPanel),
      matching: find.widgetWithText(TextButton, 'Reset'),
    );
    await tester.ensureVisible(resetButton);
    await tester.pumpAndSettle();
    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    expect(store.snapshot, {
      'selectedPackId': 'core_catalog',
      'selectedChannelProfileId': 'omni_retail',
    });
  });

  testWidgets('product workspace shortcuts navigate to product module routes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = _workspaceRouter();
    await tester.pumpWidget(_workspaceRouterApp(router));

    await _scrollTextIntoView(tester, 'Add Product');
    await tester.tap(find.text('Add Product'));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/products/new',
    );
    expect(find.text('Add product route reached'), findsOneWidget);

    router.go(ProductRoutes.workspacePath);
    await tester.pumpAndSettle();

    await _scrollTextIntoView(tester, 'Stock Movements');
    await tester.tap(find.text('Stock Movements'));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/products/stock-movements',
    );
    expect(find.text('Stock movements route reached'), findsOneWidget);

    router.go(ProductRoutes.workspacePath);
    await tester.pumpAndSettle();

    await _scrollTextIntoView(tester, 'Add Stock Movement');
    await tester.tap(find.text('Add Stock Movement'));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/products/stock-movements/new',
    );
    expect(find.text('Add stock movement route reached'), findsOneWidget);

    router.go(ProductRoutes.workspacePath);
    await tester.pumpAndSettle();

    await _scrollTextIntoView(tester, 'Stock Opname');
    await tester.tap(find.text('Stock Opname'));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/products/stock-opname',
    );
    expect(find.text('Stock opname route reached'), findsOneWidget);

    router.go(ProductRoutes.workspacePath);
    await tester.pumpAndSettle();

    await _scrollTextIntoView(tester, 'Scan Product');
    await tester.tap(find.text('Scan Product'));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/products/stock-opname/scan',
    );
    expect(find.text('Scan product route reached'), findsOneWidget);

    router.go(ProductRoutes.workspacePath);
    await tester.pumpAndSettle();

    await _scrollTextIntoView(tester, 'Discrepancy Report');
    await tester.tap(find.text('Discrepancy Report'));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/products/discrepancy-report',
    );
    expect(find.text('Discrepancy report route reached'), findsOneWidget);

    router.go(ProductRoutes.workspacePath);
    await tester.pumpAndSettle();

    await _scrollTextIntoView(tester, 'Attention Review');
    await tester.tap(find.text('Attention Review'));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/products?filter=attention&review=Attention+Review',
    );
    expect(find.text('Catalog route reached'), findsOneWidget);
  });

  testWidgets('product workspace issue pills navigate to issue review', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = _workspaceRouter();
    await tester.pumpWidget(_workspaceRouterApp(router));

    final issuePill = find.byKey(
      const ValueKey('product-channel-issue-kiosk-stockNotSellable'),
    );

    await tester.scrollUntilVisible(
      issuePill,
      420,
      scrollable: _pageScrollable(),
    );
    await tester.drag(_pageScrollable(), const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(issuePill);
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/products?filter=attention&review=Self-Service+Kiosk&reason=stock+not+sellable',
    );
    expect(find.text('Catalog route reached'), findsOneWidget);
  });

  testWidgets('product workspace launch priority navigates to top blocker', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = _workspaceRouter();
    await tester.pumpWidget(_workspaceRouterApp(router));

    await tester.scrollUntilVisible(
      find.text('Fix missing scan code'),
      420,
      scrollable: _pageScrollable(),
    );
    await tester.drag(_pageScrollable(), const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fix missing scan code'));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/products?filter=in_stock&q=Missing+scan+code&review=Self-Service+Kiosk&reason=missing+scan+code',
    );
    expect(find.text('Catalog route reached'), findsOneWidget);
  });

  testWidgets('product workspace cancels channel profile strategy switch', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_workspace());

    await tester.scrollUntilVisible(
      find.text('Channel strategy'),
      420,
      scrollable: _pageScrollable(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Counter Service').first);
    await tester.pumpAndSettle();

    expect(find.text('Switch channel strategy?'), findsOneWidget);
    expect(find.text('Counter Service profile'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Channel readiness'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Online Store'), findsAtLeastNWidgets(1));
  });

  testWidgets('product workspace switches channel profile strategy', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_workspace());

    await tester.scrollUntilVisible(
      find.text('Channel strategy'),
      420,
      scrollable: _pageScrollable(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Counter Service').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Switch profile'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Channel readiness'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('POS Checkout'), findsAtLeastNWidgets(1));
    expect(find.text('Self-Service Kiosk'), findsAtLeastNWidgets(1));
    expect(find.text('Online Store'), findsNothing);
    expect(find.text('Marketplace'), findsNothing);
  });

  testWidgets('product workspace applies initial channel profile', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _workspace(initialProfileId: ProductSalesChannelProfileId.counterService),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Channel readiness'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('POS Checkout'), findsAtLeastNWidgets(1));
    expect(find.text('Self-Service Kiosk'), findsAtLeastNWidgets(1));
    expect(find.text('Online Store'), findsNothing);
    expect(find.text('Marketplace'), findsNothing);
  });

  testWidgets('product workspace applies product mode route parameters', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = MemoryProductManagementPackPreferencesStore(
      initialSnapshot: const {
        'selectedPackId': 'core_catalog',
        'selectedChannelProfileId': 'counter_service',
      },
    );
    final router = _workspaceRouter(
      initialLocation: ProductRoutes.workspaceUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
    );

    await tester.pumpWidget(
      _workspaceRouterApp(router, preferencesStore: store),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Active product mode'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Grocery Fresh Goods'), findsAtLeastNWidgets(1));
    expect(find.text('Fresh Goods Grocery'), findsAtLeastNWidgets(1));
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/product-workspace?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(store.snapshot, {
      'selectedPackId': 'grocery_fresh_goods',
      'selectedChannelProfileId': 'grocery_fresh_goods',
    });
  });

  testWidgets('product workspace applies experience route parameter', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = _workspaceRouter(
      initialLocation: ProductRoutes.workspaceUri(
        experience: 'fresh-goods',
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
    );

    await tester.pumpWidget(_workspaceRouterApp(router));
    await tester.pumpAndSettle();

    expect(find.text('Fresh Goods'), findsAtLeastNWidgets(1));
    expect(find.text('Fresh inventory operations'), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/product-workspace?experience=fresh_goods&pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
  });

  testWidgets('product workspace preserves active mode in catalog links', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = _workspaceRouter(
      initialLocation: ProductRoutes.workspaceUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
    );
    await tester.pumpWidget(_workspaceRouterApp(router));
    await tester.pumpAndSettle();

    await _scrollTextIntoView(tester, 'Attention Review');
    await tester.tap(find.text('Attention Review'));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/products?filter=attention&review=Attention+Review&pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(find.text('Catalog route reached'), findsOneWidget);
  });

  testWidgets('product workspace setup deep link shows target notice', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = _workspaceRouter(
      initialLocation: ProductRoutes.workspaceSetupUri(
        ProductWorkspaceSetupTarget.freshness,
      ),
    );
    await tester.pumpWidget(_workspaceRouterApp(router));
    await tester.pumpAndSettle();

    expect(find.text('Freshness control setup unavailable'), findsOneWidget);
    expect(find.text('Not in pack'), findsAtLeastNWidgets(1));
    expect(find.text('Switch to Grocery Fresh Goods'), findsAtLeastNWidgets(1));
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/product-workspace?setup=freshness',
    );

    await tester.tap(find.text('Switch to Grocery Fresh Goods').first);
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/product-workspace?setup=freshness',
    );
    expect(find.text('Freshness control setup'), findsAtLeastNWidgets(1));
    expect(find.text('Active setup'), findsAtLeastNWidgets(1));
    expect(find.text('Review freshness data'), findsAtLeastNWidgets(1));
    expect(
      find.text('Grocery Fresh Goods activated for setup.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'product workspace setup action preserves active mode in catalog',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1180, 920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final router = _workspaceRouter(
        initialLocation: ProductRoutes.workspaceSetupUri(
          ProductWorkspaceSetupTarget.freshness,
          pack: ProductManagementPackId.groceryFreshGoods,
          profile: groceryFreshGoodsProfileId,
        ),
      );
      await tester.pumpWidget(_workspaceRouterApp(router));
      await tester.pumpAndSettle();

      final setupAction = find.text('Review freshness data').first;
      await tester.ensureVisible(setupAction);
      await tester.pumpAndSettle();
      await tester.tap(setupAction);
      await tester.pumpAndSettle();

      final uri = router.routerDelegate.currentConfiguration.uri;
      expect(uri.path, ProductRoutes.catalogPath);
      expect(
        uri.queryParameters[ProductRoutes.catalogPackQueryKey],
        productManagementPackQueryValue(
          ProductManagementPackId.groceryFreshGoods,
        ),
      );
      expect(
        uri.queryParameters[ProductRoutes.catalogProfileQueryKey],
        productSalesChannelProfileQueryValue(groceryFreshGoodsProfileId),
      );
      expect(
        uri.queryParameters[ProductRoutes.catalogReviewTitleQueryKey],
        'Freshness setup',
      );
      expect(find.text('Catalog route reached'), findsOneWidget);
    },
  );

  testWidgets('product workspace accepts custom channel definitions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _workspaceWithChannelProfile(
        ProductSalesChannelProfile(
          id: ProductSalesChannelProfileId.counterService,
          title: 'Wholesale Pack',
          subtitle: 'Case-pack products ready for partner ordering',
          definitions: [
            ProductSalesChannelDefinition(
              channel: ProductSalesChannel.marketplace,
              title: 'Wholesale Readiness',
              subtitle: 'Case-pack products ready for partner ordering',
              readyWhen: (record) => record.categoryLabel == 'Accessories',
              reviewFilter: InventoryProductCatalogFilter.all,
              issueDefinitions: [
                ProductSalesChannelIssueDefinition(
                  blocker: ProductSalesChannelBlocker.missingCategory,
                  label: 'not wholesale tagged',
                  reviewFilter: InventoryProductCatalogFilter.all,
                  matches: (record) => record.categoryLabel != 'Accessories',
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Channel readiness'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Channel readiness'), findsOneWidget);
    expect(find.text('Wholesale Readiness'), findsAtLeastNWidgets(1));
    expect(find.text('2 not wholesale tagged'), findsOneWidget);
    expect(find.text('POS Checkout'), findsNothing);
  });

  testWidgets('product workspace quality issues navigate to catalog review', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = _workspaceRouter();
    await tester.pumpWidget(_workspaceRouterApp(router));

    final qualityIssue = find.byKey(
      const ValueKey('product-catalog-quality-missingDescription'),
    );
    final reviewButton = find.descendant(
      of: qualityIssue,
      matching: find.text('Review'),
    );

    await tester.scrollUntilVisible(
      qualityIssue,
      420,
      scrollable: _pageScrollable(),
    );
    await tester.ensureVisible(reviewButton);
    await tester.pumpAndSettle();

    await tester.tap(reviewButton);
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/products?q=No+description&review=Catalog+quality&reason=missing+description',
    );
    expect(find.text('Catalog route reached'), findsOneWidget);
  });
}

Finder _pageScrollable() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down,
  );
}

Future<void> _scrollTextIntoView(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    420,
    scrollable: _pageScrollable(),
  );
  await tester.pumpAndSettle();
}

Widget _workspace({
  ProductManagementPackId? initialPackId,
  ProductSalesChannelProfileId? initialProfileId,
  ProductManagementPackPreferencesStore? preferencesStore,
  ProductExperienceProfile? experienceProfile,
}) {
  return _workspaceWithChannelProfile(
    null,
    initialPackId: initialPackId,
    initialProfileId: initialProfileId,
    preferencesStore: preferencesStore,
    experienceProfile: experienceProfile,
  );
}

Widget _workspaceRouterApp(
  GoRouter router, {
  ProductManagementPackPreferencesStore? preferencesStore,
}) {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(_products)),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(_warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_inventoryItems),
      ),
      _memoryPreferencesRepositoryOverride(preferencesStore),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

GoRouter _workspaceRouter({
  String initialLocation = ProductRoutes.workspacePath,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: ProductRoutes.workspacePath,
        builder: (context, state) {
          final routeState = ProductWorkspaceRouteState.fromQueryParameters(
            state.uri.queryParameters,
          );
          final experienceProfile =
              routeState.experienceProfileValue == null
                  ? null
                  : defaultProductExperienceProfileRegistry.profileForValue(
                    routeState.experienceProfileValue!,
                  );
          final workspace = ProductWorkspaceScreen(
            initialPackId: routeState.packId,
            initialChannelProfileId: routeState.channelProfileId,
            initialSetupTargetId: routeState.setupTargetId,
          );

          if (experienceProfile == null) return workspace;

          return ProductExperienceProfileScope(
            profile: experienceProfile,
            child: workspace,
          );
        },
      ),
      GoRoute(
        path: ProductRoutes.catalogPath,
        builder: (context, state) => const Text('Catalog route reached'),
      ),
      GoRoute(
        path: ProductRoutes.addProductPath,
        builder: (context, state) => const Text('Add product route reached'),
      ),
      GoRoute(
        path: ProductRoutes.stockMovementsPath,
        builder:
            (context, state) => const Text('Stock movements route reached'),
      ),
      GoRoute(
        path: ProductRoutes.addStockMovementPath,
        builder:
            (context, state) => const Text('Add stock movement route reached'),
      ),
      GoRoute(
        path: ProductRoutes.stockOpnamePath,
        builder: (context, state) => const Text('Stock opname route reached'),
      ),
      GoRoute(
        path: ProductRoutes.scanProductPath,
        builder: (context, state) => const Text('Scan product route reached'),
      ),
      GoRoute(
        path: ProductRoutes.discrepancyReportPath,
        builder:
            (context, state) => const Text('Discrepancy report route reached'),
      ),
    ],
  );
}

Widget _workspaceWithChannelProfile(
  ProductSalesChannelProfile? profile, {
  ProductManagementPackId? initialPackId,
  ProductSalesChannelProfileId? initialProfileId,
  ProductManagementPackPreferencesStore? preferencesStore,
  ProductExperienceProfile? experienceProfile,
}) {
  final workspace = ProductWorkspaceScreen(
    initialPackId: initialPackId,
    initialChannelProfileId: initialProfileId,
  );

  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(_products)),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(_warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_inventoryItems),
      ),
      _memoryPreferencesRepositoryOverride(preferencesStore),
      if (profile != null)
        productSalesChannelProfilesProvider.overrideWithValue([profile]),
    ],
    child: MaterialApp(
      home:
          experienceProfile == null
              ? workspace
              : ProductExperienceProfileScope(
                profile: experienceProfile,
                child: workspace,
              ),
    ),
  );
}

dynamic _memoryPreferencesRepositoryOverride(
  ProductManagementPackPreferencesStore? store,
) {
  return productManagementPackPreferencesRepositoryProvider.overrideWithValue(
    ProductManagementPackPreferencesRepository(
      store: store ?? MemoryProductManagementPackPreferencesStore(),
    ),
  );
}

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    category: 'Electronics',
    description: 'Workstation',
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

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
];

final _inventoryItems = [
  InventoryItem(
    id: 'i1',
    productId: 'p1',
    warehouseId: 'w1',
    currentQuantity: 10,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i2',
    productId: 'p2',
    warehouseId: 'w1',
    currentQuantity: 2,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
];

class _SeededProducts extends ProductsNotifier {
  _SeededProducts(List<Product> products) {
    state = products;
  }
}

class _SeededWarehouses extends WarehousesNotifier {
  _SeededWarehouses(List<Warehouse> warehouses) {
    state = warehouses;
  }
}

class _SeededInventoryItems extends InventoryItemsNotifier {
  _SeededInventoryItems(List<InventoryItem> items) {
    state = items;
  }
}
