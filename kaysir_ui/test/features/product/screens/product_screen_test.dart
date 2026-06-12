import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_saved_view.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_preferences.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_view_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_view_mode.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_form_fields.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_workspace.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_table_column_contribution.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_catalog_saved_view_contribution.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/screens/product_screen.dart';
import 'package:kaysir/features/product/states/product_catalog_saved_view_contribution_provider.dart';
import 'package:kaysir/features/product/states/product_catalog_table_column_contribution_provider.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/product_provider.dart'
    as product_state;
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';
import 'package:kaysir/features/product/widgets/experience_profile_scope.dart';
import 'package:kaysir/features/product/widgets/management_mode_status_panel.dart';
import 'package:kaysir/features/product/widgets/management_suite_navigation.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('product screen renders the shared product catalog workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productScreen());

    expect(find.text('Products'), findsWidgets);
    expect(find.byType(InventoryProductCatalogWorkspace), findsOneWidget);
    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Product Directory'), findsOneWidget);
    expect(find.text('Product Operations'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('POS Checkout: Ready'), findsOneWidget);
    expect(find.text('POS Checkout: 1 issue'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'cable');
    await tester.pump();

    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Product management'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.byType(ProductManagementSuiteNavigation), findsOneWidget);
    expect(find.text('Product management'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Active strategy'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Active strategy'), findsOneWidget);
    expect(find.text('Omni Retail strategy'), findsOneWidget);
    expect(find.text('Self-Service Kiosk queue'), findsOneWidget);
  });

  testWidgets(
    'product screen scopes suite navigation from experience profile',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1180, 920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _productScreen(experienceProfile: productFreshGoodsExperienceProfile),
      );

      await tester.scrollUntilVisible(
        find.text('Product management'),
        420,
        scrollable: _pageScrollable(),
      );

      final navigation = tester.widget<ProductManagementSuiteNavigation>(
        find.byType(ProductManagementSuiteNavigation),
      );
      final destinations = [
        for (final section in navigation.sections)
          for (final item in section.items) item.destination,
      ];

      expect(
        destinations,
        contains(ProductManagementSuiteDestination.freshnessReview),
      );
      expect(
        destinations,
        contains(ProductManagementSuiteDestination.availabilityManagement),
      );
      expect(
        destinations,
        isNot(contains(ProductManagementSuiteDestination.pricingManagement)),
      );
      expect(
        destinations,
        isNot(contains(ProductManagementSuiteDestination.strategy)),
      );
    },
  );

  testWidgets('product screen supports advanced table list view', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productScreen());

    await tester.tap(find.text('Table'));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Signals'), findsOneWidget);
    expect(find.text('Quality'), findsOneWidget);
    expect(find.text('Channel fit'), findsOneWidget);
    expect(find.text('POS Checkout: Ready'), findsOneWidget);
    expect(find.text('Online Store: 2 issues'), findsOneWidget);

    await tester.tap(find.byTooltip('Apply table preset'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-table-preset-pricing')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Stock'), findsNothing);

    await tester.tap(find.byTooltip('Apply table preset'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-table-preset-operations')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
    expect(find.text('Signals'), findsOneWidget);

    await tester.tap(find.text('Stock'));
    await tester.pump();
    await tester.tap(find.text('Stock'));
    await tester.pump();

    expect(_topOf(tester, 'Laptop') < _topOf(tester, 'Cable'), isTrue);

    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();

    expect(find.text('1 selected'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Duplicate Laptop'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Duplicate Laptop'));
    await tester.pumpAndSettle();

    expect(find.text('Copy of Laptop'), findsOneWidget);
    expect(find.text('Laptop duplicated as Copy of Laptop'), findsOneWidget);
  });

  testWidgets('product screen uses injected table column contributions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _productScreen(
        catalogTableColumnContributions: const [
          InventoryProductCatalogTableColumnContribution(
            id: 'launch-fit',
            label: 'Launch fit',
            tooltip: 'Custom product module table column',
            cellBuilder: _launchFitCell,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Table'));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Launch fit'), findsOneWidget);
    expect(find.text('Laptop launch lane'), findsOneWidget);
    expect(find.text('Cable launch lane'), findsOneWidget);
    expect(find.text('Quality'), findsNothing);
  });

  testWidgets('product screen hydrates persisted advanced table state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final tableViewState = InventoryProductCatalogTablePreset.pricing.viewState;
    final store = MemoryProductManagementPackPreferencesStore(
      initialSnapshot: {
        'selectedPackId': 'core_catalog',
        'selectedChannelProfileId': 'omni_retail',
        'catalogViewMode': InventoryProductCatalogViewMode.table.key,
        'catalogTableViewState': tableViewState.toJson(),
      },
    );

    await tester.pumpWidget(_productScreen(preferencesStore: store));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Stock'), findsNothing);
    expect(_topOf(tester, 'Laptop') < _topOf(tester, 'Cable'), isTrue);

    final preferences = ProductManagementPackPreferences.fromJson(
      store.snapshot!,
    );
    expect(preferences.catalogViewMode, InventoryProductCatalogViewMode.table);
    expect(preferences.catalogTableViewState.matches(tableViewState), isTrue);
    expect(store.snapshot?['catalogPresentationState'], isA<Map>());
    expect(store.snapshot?['catalogViewMode'], isNull);
    expect(store.snapshot?['catalogTableViewState'], isNull);
  });

  testWidgets('product screen persists advanced table state changes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = MemoryProductManagementPackPreferencesStore();
    await tester.pumpWidget(_productScreen(preferencesStore: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Table'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Apply table preset'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-table-preset-pricing')),
    );
    await tester.pumpAndSettle();

    final preferences = ProductManagementPackPreferences.fromJson(
      store.snapshot!,
    );
    expect(preferences.catalogViewMode, InventoryProductCatalogViewMode.table);
    expect(store.snapshot?['catalogPresentationState'], isA<Map>());
    expect(store.snapshot?['catalogViewMode'], isNull);
    expect(store.snapshot?['catalogTableViewState'], isNull);
    expect(
      preferences.catalogTableViewState.matches(
        InventoryProductCatalogTablePreset.pricing.viewState,
      ),
      isTrue,
    );
  });

  testWidgets('product screen persists catalog presentation reset', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = MemoryProductManagementPackPreferencesStore(
      initialSnapshot: {
        'selectedPackId': 'core_catalog',
        'selectedChannelProfileId': 'omni_retail',
        'catalogViewMode': InventoryProductCatalogViewMode.table.key,
        'catalogTableViewState':
            InventoryProductCatalogTablePreset.pricing.viewState.toJson(),
      },
    );

    await tester.pumpWidget(_productScreen(preferencesStore: store));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsOneWidget);
    await tester.tap(find.byTooltip('Reset catalog view'));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsNothing);
    final preferences = ProductManagementPackPreferences.fromJson(
      store.snapshot!,
    );
    expect(preferences.catalogViewMode, InventoryProductCatalogViewMode.cards);
    expect(
      preferences.catalogTableViewState.matches(
        const InventoryProductCatalogTableViewState(),
      ),
      isTrue,
    );
    expect(store.snapshot, {
      'selectedPackId': 'core_catalog',
      'selectedChannelProfileId': 'omni_retail',
    });
  });

  testWidgets('product screen saves and applies catalog saved views', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = MemoryProductManagementPackPreferencesStore();
    await tester.pumpWidget(_productScreen(preferencesStore: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Table'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Apply table preset'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-table-preset-pricing')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-catalog-save-current-view')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Saved view 1 saved'), findsOneWidget);
    var preferences = ProductManagementPackPreferences.fromJson(
      store.snapshot!,
    );
    expect(preferences.catalogSavedViews, hasLength(1));
    expect(preferences.catalogSavedViews.single.label, 'Saved view 1');
    expect(preferences.activeCatalogSavedViewId, 'saved-view-1');

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-rename-saved-view-saved-view-1',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('product-catalog-saved-view-name-field')),
      'Pricing audit',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Rename'));
    await tester.pumpAndSettle();

    expect(find.text('Pricing audit renamed'), findsOneWidget);
    preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);
    expect(preferences.catalogSavedViews.single.label, 'Pricing audit');

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-default-saved-view-saved-view-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pricing audit set as startup view'), findsOneWidget);
    preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);
    expect(preferences.defaultCatalogSavedViewId, 'saved-view-1');

    await tester.tap(find.byTooltip('Reset catalog view'));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsNothing);
    preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);
    expect(preferences.activeCatalogSavedViewId, isNull);
    expect(preferences.defaultCatalogSavedViewId, 'saved-view-1');

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pricing audit'));
    await tester.pumpAndSettle();

    expect(find.text('Pricing audit applied'), findsOneWidget);
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Stock'), findsNothing);
    preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);
    expect(preferences.activeCatalogSavedViewId, 'saved-view-1');

    await tester.tap(find.byTooltip('Reset catalog view'));
    await tester.pumpAndSettle();
    expect(find.byType(DataTable), findsNothing);
    preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);
    expect(preferences.defaultCatalogSavedViewId, 'saved-view-1');
    expect(
      preferences.startupCatalogPresentationState.matches(
        InventoryProductCatalogPresentationPreset.pricing.presentationState,
      ),
      isTrue,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(_productScreen(preferencesStore: store));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Stock'), findsNothing);

    await tester.tap(find.byTooltip('Apply table preset'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-table-preset-operations')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-update-saved-view-saved-view-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pricing audit updated'), findsOneWidget);
    preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);
    expect(preferences.catalogSavedViews, hasLength(1));
    expect(preferences.catalogSavedViews.single.label, 'Pricing audit');
    expect(
      preferences.catalogSavedViews.single.description,
      'Operations table',
    );
    expect(
      preferences.catalogSavedViews.single.presentationState.matches(
        InventoryProductCatalogPresentationPreset
            .operationsTable
            .presentationState,
      ),
      isTrue,
    );
    expect(preferences.activeCatalogSavedViewId, 'saved-view-1');
    expect(preferences.defaultCatalogSavedViewId, 'saved-view-1');

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-delete-saved-view-saved-view-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pricing audit deleted'), findsOneWidget);
    expect(find.byType(DataTable), findsOneWidget);
    preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);
    expect(preferences.catalogSavedViews, isEmpty);
    expect(preferences.activeCatalogSavedViewId, isNull);
    expect(preferences.defaultCatalogSavedViewId, isNull);
  });

  testWidgets('product screen exposes business-mode starter catalog views', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = MemoryProductManagementPackPreferencesStore();
    await tester.pumpWidget(_productScreen(preferencesStore: store));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();

    expect(find.text('Mode views'), findsOneWidget);
    expect(find.text('Channel views'), findsOneWidget);
    expect(find.text('Pack views'), findsOneWidget);
    expect(find.text('Omni Retail overview'), findsOneWidget);
    expect(find.text('Omni readiness'), findsOneWidget);
    expect(find.text('Stock control'), findsOneWidget);
    expect(find.text('Price guardrails'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-update-saved-view-starter-core_catalog.omni_retail.omni-readiness',
        ),
      ),
      findsNothing,
    );

    await tester.tap(find.text('Omni readiness'));
    await tester.pumpAndSettle();

    expect(find.text('Omni readiness applied'), findsOneWidget);
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Signals'), findsOneWidget);

    var preferences = ProductManagementPackPreferences.fromJson(
      store.snapshot!,
    );
    expect(preferences.catalogSavedViews, isEmpty);
    expect(preferences.activeCatalogSavedViewId, isNull);
    expect(
      preferences.catalogPresentationState.matches(
        InventoryProductCatalogPresentationPreset
            .channelSignals
            .presentationState,
      ),
      isTrue,
    );

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-copy-saved-view-starter-core_catalog.omni_retail.omni-readiness',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Omni readiness copy saved as editable view'),
      findsOneWidget,
    );
    preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);
    expect(preferences.catalogSavedViews, hasLength(1));
    expect(preferences.catalogSavedViews.single.id, 'saved-view-1');
    expect(preferences.catalogSavedViews.single.label, 'Omni readiness copy');
    expect(preferences.activeCatalogSavedViewId, 'saved-view-1');

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    expect(find.text('My views'), findsOneWidget);
    expect(find.text('Mode views'), findsOneWidget);
    expect(find.text('Channel views'), findsOneWidget);
    expect(find.text('Pack views'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-rename-saved-view-saved-view-1',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-default-saved-view-starter-core_catalog.omni_retail.omni-readiness',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Omni readiness set as startup view'), findsOneWidget);
    preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);
    expect(preferences.catalogSavedViews, hasLength(2));
    expect(
      preferences.catalogSavedViews.map((view) => view.id),
      contains('starter-core_catalog.omni_retail.omni-readiness'),
    );
    expect(
      preferences.defaultCatalogSavedViewId,
      'starter-core_catalog.omni_retail.omni-readiness',
    );
  });

  testWidgets('product screen uses injected saved view contributions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _productScreen(
        catalogSavedViewContributions: [
          const ProductCatalogSavedViewContribution(
            id: 'test-launch-board',
            sectionLabel: 'Launch views',
            buildViews: _testLaunchBoardViews,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();

    expect(find.text('Launch views'), findsOneWidget);
    expect(find.text('Launch board'), findsOneWidget);
    expect(find.text('Omni readiness'), findsNothing);
    expect(find.text('Price guardrails'), findsNothing);

    await tester.tap(find.text('Launch board'));
    await tester.pumpAndSettle();

    expect(find.text('Launch board applied'), findsOneWidget);
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Operations'), findsOneWidget);
  });

  testWidgets('product screen can add products through the shared workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productScreen());

    await tester.tap(find.byTooltip('Add product'));
    await tester.pumpAndSettle();

    expect(find.text('Add Product'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Scanner');
    await tester.enterText(fields.at(1), 'SC-001');
    await tester.enterText(fields.at(2), 'Hardware');
    await tester.enterText(fields.at(3), '80');
    await tester.enterText(fields.at(4), '4');
    await tester.enterText(fields.at(5), 'Barcode scanner');
    await tester.enterText(
      find.byKey(const ValueKey('product-pack-field-barcode')),
      '8990003',
    );
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Add product'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add product'));
    await tester.pumpAndSettle();

    expect(find.text('Scanner'), findsOneWidget);
    expect(find.textContaining('SC-001'), findsOneWidget);
    expect(find.text('Scanner added to catalog'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Scanner'), findsNothing);
  });

  testWidgets('product screen opens pack editor for pack field quick fixes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _productScreen(
        products: [
          Product(
            id: 'p1',
            name: 'Spinach',
            sku: 'SP-001',
            category: 'Fresh',
            description: 'Leafy greens',
            barcode: '8990001',
            price: 12,
          ),
        ],
        managementPacks: [
          coreProductManagementPack,
          groceryFreshGoodsProductManagementPack,
        ],
      ),
    );

    final expiryBadge = find.byKey(
      const ValueKey('product-catalog-quality-badge-p1-missing_expiry_date'),
    );
    await tester.scrollUntilVisible(
      expiryBadge,
      420,
      scrollable: _pageScrollable(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fix expiry date'), findsOneWidget);

    await tester.tap(expiryBadge);
    await tester.pumpAndSettle();

    expect(find.text('Edit Product'), findsOneWidget);
    expect(find.text('Grocery Fresh Goods data'), findsOneWidget);

    final expiryField = find.byKey(
      const ValueKey('product-pack-field-expiry_date'),
    );
    final expiryInput = tester.widget<EditableText>(
      find.descendant(of: expiryField, matching: find.byType(EditableText)),
    );
    expect(expiryInput.autofocus, isTrue);

    await tester.enterText(
      find.byKey(const ValueKey('product-pack-field-expiry_date')),
      '2026-07-01',
    );
    await tester.enterText(
      find.byKey(const ValueKey('product-pack-field-batch_number')),
      'B-01',
    );
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Update product'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Update product'));
    await tester.pumpAndSettle();

    expect(find.text('Spinach updated'), findsOneWidget);
    expect(expiryBadge, findsNothing);
    expect(find.text('Quality ready'), findsOneWidget);
  });

  testWidgets('product screen can bulk update selected product category', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productScreen());

    await tester.tap(find.byTooltip('Select Cable'));
    await tester.pump();

    expect(find.text('1 selected'), findsOneWidget);
    expect(find.text('1 attention item'), findsOneWidget);
    expect(find.text('0 units'), findsOneWidget);
    expect(find.text('1 category'), findsOneWidget);

    await tester.tap(find.text('Change category'));
    await tester.pumpAndSettle();

    final fields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.first, 'Hardware');
    await tester.tap(find.widgetWithText(FilledButton, 'Apply category'));
    await tester.pumpAndSettle();

    expect(find.textContaining('CB-001 | Hardware'), findsOneWidget);
    expect(find.text('1 selected'), findsNothing);
    expect(find.text('1 product moved to Hardware'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('CB-001 | Accessories'), findsOneWidget);
  });

  testWidgets('product screen can duplicate products and undo the copy', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productScreen());

    await tester.tap(find.byTooltip('Duplicate Laptop'));
    await tester.pumpAndSettle();

    expect(find.text('Copy of Laptop'), findsOneWidget);
    expect(find.textContaining('LT-001-COPY'), findsOneWidget);
    expect(find.text('Laptop duplicated as Copy of Laptop'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Copy of Laptop'), findsNothing);
  });

  testWidgets('product screen can quick fix product quality issues', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productScreen());

    final mainScrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    final quickFixBadge = find.byKey(
      const ValueKey('product-catalog-quality-badge-p1-missingScanCode'),
    );
    await tester.scrollUntilVisible(
      quickFixBadge,
      420,
      scrollable: mainScrollable,
    );
    await tester.pumpAndSettle();

    await tester.tap(quickFixBadge);
    await tester.pumpAndSettle();

    expect(find.text('Edit Product'), findsOneWidget);
    final barcodeField = tester.widget<InventoryFormTextField>(
      find.byKey(const ValueKey('inventory-product-dialog-barcode-field')),
    );
    expect(barcodeField.focusNode?.hasFocus, isTrue);

    final fields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.at(5), '8990001');
    await tester.tap(find.widgetWithText(FilledButton, 'Update product'));
    await tester.pumpAndSettle();

    expect(find.text('Laptop updated'), findsOneWidget);
    expect(quickFixBadge, findsNothing);
  });

  testWidgets('product screen can bulk update selected product prices', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productScreen());

    await tester.tap(find.byTooltip('Select Laptop'));
    await tester.pump();

    expect(find.text('1 selected'), findsOneWidget);
    expect(find.text('Update price'), findsOneWidget);

    await tester.tap(find.text('Update price'));
    await tester.pumpAndSettle();

    expect(find.text('Update selected prices'), findsOneWidget);

    final fields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.first, '150');
    await tester.pump();

    expect(find.text(r'$100.00 -> $150.00'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Apply prices'));
    await tester.pumpAndSettle();

    expect(find.text(r'$1,500.00'), findsWidgets);
    expect(find.text('1 selected'), findsNothing);
    expect(find.text('1 product price updated'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text(r'$1,000.00'), findsWidgets);
  });

  testWidgets('product screen bulk updates sync product module state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _productScreenContainer(products: _products);
    addTearDown(container.dispose);

    await tester.pumpWidget(_productScreenWithContainer(container));

    await tester.tap(find.byTooltip('Select Laptop'));
    await tester.pump();
    await tester.tap(find.text('Update price'));
    await tester.pumpAndSettle();

    final priceField = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(priceField.first, '150');
    await tester.tap(find.widgetWithText(FilledButton, 'Apply prices'));
    await tester.pumpAndSettle();

    expect(_inventoryProduct(container, 'p1').price, 150);
    expect(_productStateProduct(container, 'p1').price, 150);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(_inventoryProduct(container, 'p1').price, 100);
    expect(_productStateProduct(container, 'p1').price, 100);
  });

  testWidgets('product screen can bulk generate missing SKUs and undo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _productScreen(
        products: [
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
            category: 'Accessories',
            description: 'USB-C cable',
            price: 25,
          ),
        ],
      ),
    );

    await tester.tap(find.byTooltip('Select Cable'));
    await tester.pump();

    expect(find.text('Generate SKU (1)'), findsOneWidget);

    await tester.tap(find.text('Generate SKU (1)'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'cat');
    await tester.pump();

    expect(find.text('No SKU -> CAT-CABLE'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Generate SKUs'));
    await tester.pumpAndSettle();

    expect(find.textContaining('CAT-CABLE | Accessories'), findsOneWidget);
    expect(find.text('1 product assigned SKU'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No SKU | Accessories'), findsOneWidget);
  });

  testWidgets('product screen can bulk generate missing shortcuts and undo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _productScreen(
        products: [
          Product(
            id: 'p1',
            name: 'Laptop',
            sku: 'LT-001',
            category: 'Electronics',
            description: 'Workstation',
            shortcutKey: 'K1',
            price: 100,
          ),
          Product(
            id: 'p2',
            name: 'Cable',
            sku: 'CB-001',
            category: 'Accessories',
            description: 'USB-C cable',
            price: 25,
          ),
        ],
      ),
    );

    final missingScanCodeBadge = find.byKey(
      const ValueKey('product-catalog-quality-badge-p2-missingScanCode'),
    );
    expect(missingScanCodeBadge, findsOneWidget);

    await tester.tap(find.byTooltip('Select Cable'));
    await tester.pump();

    expect(find.text('Generate shortcut (1)'), findsOneWidget);

    await tester.tap(find.text('Generate shortcut (1)'));
    await tester.pumpAndSettle();

    expect(find.text('No scan code -> K2'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Generate shortcuts'));
    await tester.pumpAndSettle();

    expect(find.text('1 product assigned shortcut'), findsOneWidget);
    expect(missingScanCodeBadge, findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(missingScanCodeBadge, findsOneWidget);
  });

  testWidgets('product screen can bulk fill missing descriptions and undo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _productScreen(
        products: [
          Product(
            id: 'p1',
            name: 'Laptop',
            sku: 'LT-001',
            category: 'Electronics',
            description: 'Workstation',
            barcode: '8990001',
            price: 100,
          ),
          Product(
            id: 'p2',
            name: 'Cable',
            sku: 'CB-001',
            category: 'Accessories',
            price: 25,
          ),
        ],
      ),
    );

    final missingDescriptionBadge = find.byKey(
      const ValueKey('product-catalog-quality-badge-p2-missingDescription'),
    );
    expect(missingDescriptionBadge, findsOneWidget);

    expect(find.text('Repair candidates'), findsOneWidget);
    expect(find.text('Quality issue (1)'), findsOneWidget);
    expect(find.text('Missing description (1)'), findsOneWidget);

    await tester.tap(find.text('Missing description (1)'));
    await tester.pump();

    expect(find.text('1 selected'), findsOneWidget);
    expect(find.text('Fill description (1)'), findsOneWidget);

    await tester.tap(find.text('Fill description (1)'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      '{name} shelf-ready for {category}.',
    );
    await tester.pump();

    expect(
      find.text('No description -> Cable shelf-ready for Accessories.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Fill descriptions'));
    await tester.pumpAndSettle();

    expect(find.text('1 product description filled'), findsOneWidget);
    expect(
      find.textContaining(
        'CB-001 | Accessories | Cable shelf-ready for Accessories.',
      ),
      findsOneWidget,
    );
    expect(missingDescriptionBadge, findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('CB-001 | Accessories | No description'),
      findsOneWidget,
    );
    expect(missingDescriptionBadge, findsOneWidget);
  });

  testWidgets('product screen can bulk delete selected products', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productScreen());

    await tester.tap(find.byTooltip('Select Cable'));
    await tester.pump();

    expect(find.text('1 selected'), findsOneWidget);
    expect(find.text('1 attention item'), findsOneWidget);

    await tester.tap(find.text('Delete selected'));
    await tester.pumpAndSettle();

    expect(find.text('Delete selected products?'), findsOneWidget);
    expect(
      find.text('This will remove 1 selected product from the catalog.'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('1 attention item'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(Dialog), matching: find.text('0 units')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('1 category'),
      ),
      findsOneWidget,
    );

    final confirmDelete = find.descendant(
      of: find.byType(Dialog),
      matching: find.widgetWithText(FilledButton, 'Delete selected'),
    );
    await tester.tap(confirmDelete);
    await tester.pumpAndSettle();

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Cable'), findsNothing);
    expect(find.text('1 selected'), findsNothing);
    expect(find.text('1 product deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Cable'), findsOneWidget);
  });

  testWidgets('product screen applies initial catalog filters', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _productScreen(initialFilter: InventoryProductCatalogFilter.attention),
    );

    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);

    await tester.tap(find.text('All (2)'));
    await tester.pump();

    expect(find.text('Laptop'), findsOneWidget);
  });

  testWidgets('product screen applies initial review target', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _productScreen(
        initialReviewTarget: const ProductCatalogReviewTarget(
          filter: InventoryProductCatalogFilter.attention,
          query: 'cable',
          title: 'Route review',
        ),
      ),
    );

    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);
    expect(find.text('Attention (1)'), findsOneWidget);
    expect(find.text('Route review'), findsOneWidget);
    expect(find.text('Search "cable"'), findsOneWidget);
    expect(find.text('1 of 2 products'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear review target'));
    await tester.pump();

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Route review'), findsNothing);
    expect(find.text('All (2)'), findsOneWidget);
  });

  testWidgets('product screen applies tile channel badge review filters', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productScreen());

    await tester.tap(find.text('Online Store: 2 issues'));
    await tester.pump();

    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);
    expect(find.text('Attention (1)'), findsOneWidget);
    expect(find.text('Online Store: stock not sellable'), findsOneWidget);
    expect(find.text('1 of 2 products'), findsOneWidget);
    expect(
      find.text('Reviewing Online Store: stock not sellable'),
      findsOneWidget,
    );
  });

  testWidgets('product screen applies channel readiness review filters', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productScreen());

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);

    final mainScrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(
      find.text('POS Checkout'),
      500,
      scrollable: mainScrollable,
    );
    await tester.pump();
    await tester.tap(find.text('POS Checkout'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Cable'),
      -500,
      scrollable: mainScrollable,
    );
    await tester.pump();

    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Attention (1)'),
      -500,
      scrollable: mainScrollable,
    );
    await tester.pump();

    expect(find.text('Attention (1)'), findsOneWidget);
  });

  testWidgets('product screen hydrates persisted channel profile selection', (
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

    await tester.pumpWidget(_productScreen(preferencesStore: store));
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
    expect(store.snapshot, {
      'selectedPackId': 'core_catalog',
      'selectedChannelProfileId': 'counter_service',
    });
  });

  testWidgets('product screen applies product mode route parameters', (
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

    await tester.pumpWidget(
      _productScreen(
        initialPackId: ProductManagementPackId.groceryFreshGoods,
        initialChannelProfileId: groceryFreshGoodsProfileId,
        preferencesStore: store,
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Active product mode'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Grocery Fresh Goods'), findsAtLeastNWidgets(1));
    expect(find.text('Fresh Goods Grocery'), findsAtLeastNWidgets(1));
    expect(store.snapshot, {
      'selectedPackId': 'grocery_fresh_goods',
      'selectedChannelProfileId': 'grocery_fresh_goods',
    });
  });

  testWidgets('product screen persists channel profile strategy switches', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = MemoryProductManagementPackPreferencesStore();
    await tester.pumpWidget(_productScreen(preferencesStore: store));

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

    expect(store.snapshot, {
      'selectedPackId': 'core_catalog',
      'selectedChannelProfileId': 'counter_service',
    });
  });

  testWidgets('product screen resets active product mode to default', (
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

    await tester.pumpWidget(_productScreen(preferencesStore: store));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Active product mode'),
      420,
      scrollable: _pageScrollable(),
    );

    expect(find.text('Custom mode'), findsOneWidget);

    final resetButton = find.descendant(
      of: find.byType(ProductManagementModeStatusPanel),
      matching: find.widgetWithText(TextButton, 'Reset'),
    );
    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    expect(find.text('Default mode'), findsOneWidget);
    expect(store.snapshot, {
      'selectedPackId': 'core_catalog',
      'selectedChannelProfileId': 'omni_retail',
    });
  });
}

Finder _pageScrollable() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down,
  );
}

double _topOf(WidgetTester tester, String text) {
  return tester.getTopLeft(find.text(text)).dy;
}

Widget _launchFitCell(
  BuildContext context,
  InventoryProductCatalogRecord record,
) {
  return Text('${record.productName} launch lane');
}

Widget _productScreen({
  InventoryProductCatalogFilter initialFilter =
      InventoryProductCatalogFilter.all,
  String initialQuery = '',
  ProductCatalogReviewTarget? initialReviewTarget,
  ProductManagementPackId? initialPackId,
  ProductSalesChannelProfileId? initialChannelProfileId,
  List<Product>? products,
  List<ProductManagementPack>? managementPacks,
  List<ProductCatalogSavedViewContribution>? catalogSavedViewContributions,
  List<InventoryProductCatalogTableColumnContribution>?
  catalogTableColumnContributions,
  ProductManagementPackPreferencesStore? preferencesStore,
  ProductExperienceProfile? experienceProfile,
}) {
  final resolvedPreferencesStore =
      preferencesStore ?? _preferencesStoreForManagementPacks(managementPacks);

  final screen = ProductsScreen(
    initialFilter: initialFilter,
    initialQuery: initialQuery,
    initialReviewTarget: initialReviewTarget,
    initialPackId: initialPackId,
    initialChannelProfileId: initialChannelProfileId,
  );

  return ProviderScope(
    overrides: [
      productsProvider.overrideWith(
        (ref) => _SeededProducts(products ?? _products),
      ),
      product_state.productsProvider.overrideWith(
        (ref) => product_state.ProductsNotifier(
          ref,
          initialProducts: products ?? _products,
          loadOnStart: false,
        ),
      ),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(_warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_inventoryItems),
      ),
      _memoryPreferencesRepositoryOverride(resolvedPreferencesStore),
      if (managementPacks != null)
        productManagementPacksProvider.overrideWithValue(managementPacks),
      if (managementPacks != null)
        productManagementPackIdProvider.overrideWith(
          (ref) => _packIdNotifier(
            managementPacks.last.id,
            managementPacks,
            resolvedPreferencesStore,
          ),
        ),
      if (catalogSavedViewContributions != null)
        productCatalogSavedViewContributionsProvider.overrideWithValue(
          catalogSavedViewContributions,
        ),
      if (catalogTableColumnContributions != null)
        productCatalogTableColumnContributionsProvider.overrideWithValue(
          catalogTableColumnContributions,
        ),
    ],
    child: MaterialApp(
      home:
          experienceProfile == null
              ? screen
              : ProductExperienceProfileScope(
                profile: experienceProfile,
                child: screen,
              ),
    ),
  );
}

Widget _productScreenWithContainer(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: ProductsScreen()),
  );
}

ProviderContainer _productScreenContainer({
  required List<Product> products,
  List<ProductManagementPack>? managementPacks,
}) {
  final preferencesStore = _preferencesStoreForManagementPacks(managementPacks);

  return ProviderContainer(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(products)),
      product_state.productsProvider.overrideWith(
        (ref) => product_state.ProductsNotifier(
          ref,
          initialProducts: products,
          loadOnStart: false,
        ),
      ),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(_warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_inventoryItems),
      ),
      _memoryPreferencesRepositoryOverride(preferencesStore),
      if (managementPacks != null)
        productManagementPacksProvider.overrideWithValue(managementPacks),
      if (managementPacks != null)
        productManagementPackIdProvider.overrideWith(
          (ref) => _packIdNotifier(
            managementPacks.last.id,
            managementPacks,
            preferencesStore,
          ),
        ),
    ],
  );
}

ProductManagementPackIdNotifier _packIdNotifier(
  ProductManagementPackId packId,
  List<ProductManagementPack> packs,
  ProductManagementPackPreferencesStore preferencesStore,
) {
  return ProductManagementPackIdNotifier(
    repository: ProductManagementPackPreferencesRepository(
      store: preferencesStore,
    ),
    registry: ProductManagementPackRegistry.fromPacks(packs),
    initialPackId: packId,
    autoHydrate: false,
  );
}

ProductManagementPackPreferencesStore _preferencesStoreForManagementPacks(
  List<ProductManagementPack>? managementPacks,
) {
  final selectedPack = managementPacks?.last;
  if (selectedPack == null) {
    return MemoryProductManagementPackPreferencesStore();
  }

  return MemoryProductManagementPackPreferencesStore(
    initialSnapshot: {
      'selectedPackId': selectedPack.id.value,
      'selectedChannelProfileId': selectedPack.defaultChannelProfileId.value,
    },
  );
}

Iterable<InventoryProductCatalogSavedView> _testLaunchBoardViews(
  ProductCatalogSavedViewContributionContext context,
) {
  return [
    context.starterView(
      suffix: 'launch-board',
      label: 'Launch board',
      description: 'Custom launch workflow',
      preset: InventoryProductCatalogPresentationPreset.operationsTable,
    ),
  ];
}

dynamic _memoryPreferencesRepositoryOverride(
  ProductManagementPackPreferencesStore store,
) {
  return productManagementPackPreferencesRepositoryProvider.overrideWithValue(
    ProductManagementPackPreferencesRepository(store: store),
  );
}

Product _inventoryProduct(ProviderContainer container, String id) {
  return container
      .read(productsProvider)
      .singleWhere((product) => product.id == id);
}

Product _productStateProduct(ProviderContainer container, String id) {
  return (container.read(product_state.productsProvider).products ??
          const <Product>[])
      .singleWhere((product) => product.id == id);
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
