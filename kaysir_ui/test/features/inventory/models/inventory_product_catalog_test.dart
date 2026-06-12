import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_saved_view.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_preferences.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_sort.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_view_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_view_mode.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildInventoryProductCatalogRecords aggregates stock by product', () {
    final records = buildInventoryProductCatalogRecords(
      products: _products,
      stockRecords: _stockRecords,
    );

    expect(records.map((record) => record.productName), [
      'Adapter',
      'Cable',
      'Notebook',
      'Laptop',
    ]);
    expect(records.first.status, InventoryProductCatalogStatus.outOfStock);
    expect(records[1].status, InventoryProductCatalogStatus.lowStock);
    expect(records[2].status, InventoryProductCatalogStatus.untracked);
    expect(records.last.status, InventoryProductCatalogStatus.inStock);
    expect(records.last.totalQuantity, 14);
    expect(records.last.warehouseCount, 2);
    expect(records.last.inventoryValue, 1400);
  });

  test('summarizeInventoryProductCatalogRecords totals catalog health', () {
    final summary = summarizeInventoryProductCatalogRecords(
      buildInventoryProductCatalogRecords(
        products: _products,
        stockRecords: _stockRecords,
      ),
    );

    expect(summary.productCount, 4);
    expect(summary.trackedProductCount, 3);
    expect(summary.inStockProductCount, 1);
    expect(summary.untrackedProductCount, 1);
    expect(summary.attentionProductCount, 3);
    expect(summary.totalQuantity, 16);
    expect(summary.totalInventoryValue, 1450);
    expect(summary.categoryCount, 3);
  });

  test('summarizeInventoryProductCatalogSelection totals selected impact', () {
    final records = buildInventoryProductCatalogRecords(
      products: _products,
      stockRecords: _stockRecords,
    );
    final summary = summarizeInventoryProductCatalogSelection(
      records: records,
      selectedProductIds: {'p1', 'p2', 'p4'},
    );

    expect(summary.productCount, 3);
    expect(summary.trackedProductCount, 2);
    expect(summary.untrackedProductCount, 1);
    expect(summary.attentionProductCount, 2);
    expect(summary.totalQuantity, 16);
    expect(summary.totalShortage, 3);
    expect(summary.totalInventoryValue, 1450);
    expect(summary.categoryCount, 3);
    expect(summary.qualityIssueProductCount, 3);
    expect(summary.missingSkuCount, 0);
    expect(summary.missingCategoryCount, 0);
    expect(summary.missingDescriptionCount, 3);
    expect(summary.missingPriceCount, 0);
    expect(summary.missingScanCodeCount, 3);
    expect(summary.qualityIssueCount, 6);
    expect(
      summary.repairCountFor(
        InventoryProductCatalogRepairTarget.anyQualityIssue,
      ),
      3,
    );
    expect(
      summary.repairCountFor(
        InventoryProductCatalogRepairTarget.missingDescription,
      ),
      3,
    );
    expect(summary.hasAttention, isTrue);
    expect(summary.hasQualityIssues, isTrue);
  });

  test('inventoryProductCatalogRecordNeedsRepair resolves repair targets', () {
    final records = buildInventoryProductCatalogRecords(
      products: [
        Product(
          id: 'p1',
          name: 'Ready',
          sku: 'RD-001',
          category: 'Retail',
          description: 'Ready listing',
          barcode: '8990001',
          price: 12,
        ),
        Product(id: 'p2', name: 'Repair me', price: 0),
      ],
      stockRecords: const [],
    );

    final readyRecord = records.firstWhere((record) => record.id == 'p1');
    final repairRecord = records.firstWhere((record) => record.id == 'p2');

    expect(
      inventoryProductCatalogRecordNeedsRepair(
        readyRecord,
        InventoryProductCatalogRepairTarget.anyQualityIssue,
      ),
      isFalse,
    );
    expect(
      inventoryProductCatalogRecordNeedsRepair(
        readyRecord,
        InventoryProductCatalogRepairTarget.missingDescription,
      ),
      isFalse,
    );
    expect(
      inventoryProductCatalogRecordNeedsRepair(
        repairRecord,
        InventoryProductCatalogRepairTarget.anyQualityIssue,
      ),
      isTrue,
    );
    expect(
      inventoryProductCatalogRecordNeedsRepair(
        repairRecord,
        InventoryProductCatalogRepairTarget.missingSku,
      ),
      isTrue,
    );
    expect(
      inventoryProductCatalogRecordNeedsRepair(
        repairRecord,
        InventoryProductCatalogRepairTarget.missingPrice,
      ),
      isTrue,
    );
    expect(
      inventoryProductCatalogRecordNeedsRepair(
        repairRecord,
        InventoryProductCatalogRepairTarget.missingScanCode,
      ),
      isTrue,
    );
  });

  test('filterInventoryProductCatalogRecords applies query and status', () {
    final records = buildInventoryProductCatalogRecords(
      products: _products,
      stockRecords: _stockRecords,
    );

    expect(
      filterInventoryProductCatalogRecords(
        records: records,
        query: 'north',
        filter: InventoryProductCatalogFilter.all,
      ).map((record) => record.productName),
      ['Laptop'],
    );
    expect(
      filterInventoryProductCatalogRecords(
        records: records,
        query: 'stationery',
        filter: InventoryProductCatalogFilter.untracked,
      ).single.productName,
      'Notebook',
    );
    expect(
      filterInventoryProductCatalogRecords(
        records: records,
        query: 'laptop',
        filter: InventoryProductCatalogFilter.attention,
      ),
      isEmpty,
    );
  });

  test('sortInventoryProductCatalogTableRecords orders table columns', () {
    final records = buildInventoryProductCatalogRecords(
      products: _products,
      stockRecords: _stockRecords,
    );

    expect(
      sortInventoryProductCatalogTableRecords(
        records: records,
        column: InventoryProductCatalogTableColumn.product,
        ascending: true,
      ).map((record) => record.productName),
      ['Adapter', 'Cable', 'Laptop', 'Notebook'],
    );
    expect(
      sortInventoryProductCatalogTableRecords(
        records: records,
        column: InventoryProductCatalogTableColumn.stock,
        ascending: false,
      ).map((record) => record.productName),
      ['Laptop', 'Cable', 'Adapter', 'Notebook'],
    );
    expect(
      sortInventoryProductCatalogTableRecords(
        records: records,
        column: InventoryProductCatalogTableColumn.status,
        ascending: true,
      ).map((record) => record.productName),
      ['Adapter', 'Cable', 'Notebook', 'Laptop'],
    );

    final sortState = const InventoryProductCatalogTableSortState(
      column: InventoryProductCatalogTableColumn.price,
      ascending: false,
    );
    final restoredSortState = InventoryProductCatalogTableSortState.fromJson(
      sortState.toJson(),
    );
    expect(restoredSortState.matches(sortState), isTrue);
    expect(restoredSortState.column.key, 'price');

    final fallbackSortState = InventoryProductCatalogTableSortState.fromJson({
      'column': 'margin',
      'ascending': 'desc',
    });
    expect(
      fallbackSortState.column,
      InventoryProductCatalogTableColumn.product,
    );
    expect(fallbackSortState.ascending, isTrue);
  });

  test(
    'InventoryProductCatalogTablePreferences toggles presentation columns',
    () {
      const preferences = InventoryProductCatalogTablePreferences();

      expect(
        preferences.isVisible(
          InventoryProductCatalogTableOptionalColumn.signals,
        ),
        isTrue,
      );
      expect(preferences.density.label, 'Comfort');
      expect(InventoryProductCatalogTableDensity.compact.dataRowMinHeight, 56);
      expect(
        InventoryProductCatalogTableOptionalColumn.stock.sortableColumn,
        InventoryProductCatalogTableColumn.stock,
      );
      expect(
        InventoryProductCatalogTableOptionalColumn.signals.sortableColumn,
        isNull,
      );

      final withoutSignals = preferences.toggleColumn(
        InventoryProductCatalogTableOptionalColumn.signals,
      );
      expect(
        withoutSignals.isVisible(
          InventoryProductCatalogTableOptionalColumn.signals,
        ),
        isFalse,
      );

      final compact = withoutSignals.copyWith(
        density: InventoryProductCatalogTableDensity.compact,
      );
      expect(compact.density.label, 'Compact');
      expect(
        compact.isVisible(InventoryProductCatalogTableOptionalColumn.signals),
        isFalse,
      );
      expect(compact.isContributionVisible('launch-fit'), isTrue);
      expect(
        compact.isContributionVisible('launch-fit', defaultVisible: false),
        isFalse,
      );

      final withoutLaunchFit = compact.toggleContributionColumn('launch-fit');
      expect(withoutLaunchFit.isContributionVisible('launch-fit'), isFalse);
      expect(withoutLaunchFit.hiddenContributionIds, {'launch-fit'});
      expect(withoutLaunchFit.activePresetLabel, 'Custom');

      final restoredWithoutLaunchFit =
          InventoryProductCatalogTablePreferences.fromJson(
            withoutLaunchFit.toJson(),
          );
      expect(restoredWithoutLaunchFit.matches(withoutLaunchFit), isTrue);
      expect(
        restoredWithoutLaunchFit.isContributionVisible('launch-fit'),
        isFalse,
      );

      final restoredLaunchFit = withoutLaunchFit.toggleContributionColumn(
        'launch-fit',
      );
      expect(restoredLaunchFit.isContributionVisible('launch-fit'), isTrue);
      expect(restoredLaunchFit.hiddenContributionIds, isEmpty);

      final withOptInLaunchFit = compact.toggleContributionColumn(
        'launch-fit',
        defaultVisible: false,
      );
      expect(
        withOptInLaunchFit.isContributionVisible(
          'launch-fit',
          defaultVisible: false,
        ),
        isTrue,
      );
      expect(withOptInLaunchFit.visibleContributionIds, {'launch-fit'});
      expect(withOptInLaunchFit.hiddenContributionIds, isEmpty);

      final restoredWithOptInLaunchFit =
          InventoryProductCatalogTablePreferences.fromJson(
            withOptInLaunchFit.toJson(),
          );
      expect(restoredWithOptInLaunchFit.matches(withOptInLaunchFit), isTrue);
      expect(
        restoredWithOptInLaunchFit.isContributionVisible(
          'launch-fit',
          defaultVisible: false,
        ),
        isTrue,
      );

      final withoutOptInLaunchFit = withOptInLaunchFit.toggleContributionColumn(
        'launch-fit',
        defaultVisible: false,
      );
      expect(
        withoutOptInLaunchFit.isContributionVisible(
          'launch-fit',
          defaultVisible: false,
        ),
        isFalse,
      );
      expect(withoutOptInLaunchFit.visibleContributionIds, isEmpty);

      final helperTableViewState = InventoryProductCatalogTablePreset
          .pricing
          .viewState
          .hideContributionColumn('product-channel-fit')
          .showContributionColumn('expiry-risk', defaultVisible: false);
      expect(
        helperTableViewState.preferences.isContributionVisible(
          'product-channel-fit',
        ),
        isFalse,
      );
      expect(
        helperTableViewState.preferences.isContributionVisible(
          'expiry-risk',
          defaultVisible: false,
        ),
        isTrue,
      );

      final helperPresentationState = InventoryProductCatalogPresentationPreset
          .pricing
          .presentationState
          .hideContributionColumn('product-channel-fit')
          .showContributionColumn('expiry-risk', defaultVisible: false);
      expect(
        helperPresentationState
            .tableViewState
            .preferences
            .hiddenContributionIds,
        {'product-channel-fit'},
      );
      expect(
        helperPresentationState
            .tableViewState
            .preferences
            .visibleContributionIds,
        {'expiry-risk'},
      );

      final pricingPreset =
          InventoryProductCatalogTablePreset.pricing.preferences;
      expect(
        pricingPreset.matchingPreset,
        InventoryProductCatalogTablePreset.pricing,
      );
      expect(pricingPreset.activePresetLabel, 'Pricing');
      expect(pricingPreset.isCustom, isFalse);
      expect(
        pricingPreset.density,
        InventoryProductCatalogTableDensity.compact,
      );
      expect(
        pricingPreset.isVisible(
          InventoryProductCatalogTableOptionalColumn.price,
        ),
        isTrue,
      );
      expect(
        pricingPreset.isVisible(
          InventoryProductCatalogTableOptionalColumn.stock,
        ),
        isFalse,
      );

      final channelSignals =
          InventoryProductCatalogTablePreset.channelSignals.preferences;
      expect(
        channelSignals.isVisible(
          InventoryProductCatalogTableOptionalColumn.signals,
        ),
        isTrue,
      );
      expect(
        channelSignals.isVisible(
          InventoryProductCatalogTableOptionalColumn.price,
        ),
        isFalse,
      );

      final custom = channelSignals.copyWith(
        density: InventoryProductCatalogTableDensity.compact,
      );
      expect(custom.matchingPreset, isNull);
      expect(custom.activePresetLabel, 'Custom');
      expect(custom.isCustom, isTrue);

      final restoredPricing = InventoryProductCatalogTablePreferences.fromJson(
        pricingPreset.toJson(),
      );
      expect(restoredPricing.matches(pricingPreset), isTrue);
      expect(restoredPricing.activePresetLabel, 'Pricing');

      final fallback = InventoryProductCatalogTablePreferences.fromJson({
        'density': 'dense',
        'visibleColumns': ['stock', 'unknown-column'],
        'hiddenContributionIds': [' launch-fit ', '', 42],
        'visibleContributionIds': [' opt-in-fit ', '', 42],
      });
      expect(fallback.density, InventoryProductCatalogTableDensity.comfortable);
      expect(
        fallback.isVisible(InventoryProductCatalogTableOptionalColumn.stock),
        isTrue,
      );
      expect(
        fallback.isVisible(InventoryProductCatalogTableOptionalColumn.price),
        isFalse,
      );
      expect(fallback.isContributionVisible('launch-fit'), isFalse);
      expect(
        fallback.isContributionVisible('opt-in-fit', defaultVisible: false),
        isTrue,
      );
      expect(
        pricingPreset.supportsSortColumn(
          InventoryProductCatalogTableColumn.price,
        ),
        isTrue,
      );
      expect(
        pricingPreset.supportsSortColumn(
          InventoryProductCatalogTableColumn.stock,
        ),
        isFalse,
      );

      final pricingViewState =
          InventoryProductCatalogTablePreset.pricing.viewState;
      expect(
        pricingViewState.sortState.column,
        InventoryProductCatalogTableColumn.price,
      );
      expect(pricingViewState.sortState.ascending, isFalse);
      expect(
        InventoryProductCatalogTableViewState.fromJson(
          pricingViewState.toJson(),
        ).matches(pricingViewState),
        isTrue,
      );

      final normalized =
          InventoryProductCatalogTableViewState(
            preferences: pricingPreset,
            sortState: const InventoryProductCatalogTableSortState(
              column: InventoryProductCatalogTableColumn.stock,
              ascending: false,
            ),
          ).normalized;
      expect(
        normalized.sortState.column,
        InventoryProductCatalogTableColumn.product,
      );
      expect(normalized.sortState.ascending, isTrue);

      final presentationState = InventoryProductCatalogPresentationState(
        viewMode: InventoryProductCatalogViewMode.table,
        tableViewState: pricingViewState,
      );
      expect(
        InventoryProductCatalogPresentationState.fromJson(
          presentationState.toJson(),
        ).matches(presentationState),
        isTrue,
      );

      final pricingPresentationState =
          InventoryProductCatalogPresentationPreset.pricing.presentationState;
      expect(
        pricingPresentationState.viewMode,
        InventoryProductCatalogViewMode.table,
      );
      expect(
        pricingPresentationState.tableViewState.matches(
          InventoryProductCatalogTablePreset.pricing.viewState,
        ),
        isTrue,
      );
      expect(
        pricingPresentationState.matchingPreset,
        InventoryProductCatalogPresentationPreset.pricing,
      );
      expect(
        InventoryProductCatalogPresentationState.defaults.matchingPreset,
        InventoryProductCatalogPresentationPreset.cards,
      );

      final savedView = InventoryProductCatalogSavedView(
        id: 'pricing-review',
        label: 'Pricing review',
        description: 'Margin and price audit',
        presentationState: pricingPresentationState,
      );
      expect(
        InventoryProductCatalogSavedView.fromJson(
          savedView.toJson(),
        ).matches(savedView),
        isTrue,
      );

      final normalizedSavedViews = normalizeInventoryProductCatalogSavedViews([
        const InventoryProductCatalogSavedView(
          id: '',
          label: '',
          presentationState: InventoryProductCatalogPresentationState.defaults,
        ),
        savedView,
        InventoryProductCatalogSavedView(
          id: savedView.id,
          label: 'Updated pricing view',
          presentationState: pricingPresentationState,
        ),
      ]);
      expect(normalizedSavedViews, hasLength(1));
      expect(normalizedSavedViews.single.label, 'Updated pricing view');
    },
  );

  test('filterInventoryProductCatalogRecords matches custom attributes', () {
    final records = buildInventoryProductCatalogRecords(
      products: [
        Product(
          id: 'p1',
          name: 'Beans',
          category: 'Coffee',
          price: 18,
          customAttributes: const {'supplier': 'Local Roaster'},
        ),
        Product(
          id: 'p2',
          name: 'Kettle',
          category: 'Equipment',
          price: 45,
          customAttributes: const {'vendor': 'Acme Supply'},
        ),
      ],
      stockRecords: const [],
    );

    expect(
      filterInventoryProductCatalogRecords(
        records: records,
        query: 'local roaster',
        filter: InventoryProductCatalogFilter.all,
      ).single.productName,
      'Beans',
    );
  });

  test(
    'filterInventoryProductCatalogRecords matches quality review labels',
    () {
      final records = buildInventoryProductCatalogRecords(
        products: [
          Product(
            id: 'p1',
            name: 'Ready',
            sku: 'RD-001',
            category: 'Retail',
            description: 'Ready listing',
            barcode: '8990001',
            price: 12,
          ),
          Product(
            id: 'p2',
            name: 'Missing price',
            sku: 'MP-001',
            category: 'Retail',
            description: 'Needs price',
            barcode: '8990002',
            price: 0,
          ),
          Product(
            id: 'p3',
            name: 'Missing scan',
            sku: 'MS-001',
            category: 'Retail',
            description: 'Needs scan code',
            price: 8,
          ),
        ],
        stockRecords: const [],
      );

      expect(
        filterInventoryProductCatalogRecords(
          records: records,
          query: 'Missing price',
          filter: InventoryProductCatalogFilter.all,
        ).single.productName,
        'Missing price',
      );
      expect(
        filterInventoryProductCatalogRecords(
          records: records,
          query: 'Missing scan code',
          filter: InventoryProductCatalogFilter.all,
        ).single.productName,
        'Missing scan',
      );
    },
  );

  test('product catalog labels cover statuses and filters', () {
    expect(
      inventoryProductCatalogStatusLabel(
        InventoryProductCatalogStatus.untracked,
      ),
      'Untracked',
    );
    expect(
      inventoryProductCatalogStatusLabel(
        InventoryProductCatalogStatus.outOfStock,
      ),
      'Out of stock',
    );
    expect(
      inventoryProductCatalogFilterLabel(
        InventoryProductCatalogFilter.attention,
      ),
      'Attention',
    );
  });

  test('product catalog filter query values round trip safely', () {
    expect(
      inventoryProductCatalogFilterQueryValue(
        InventoryProductCatalogFilter.attention,
      ),
      'attention',
    );
    expect(
      inventoryProductCatalogFilterFromQuery('in-stock'),
      InventoryProductCatalogFilter.inStock,
    );
    expect(
      inventoryProductCatalogFilterFromQuery('review'),
      InventoryProductCatalogFilter.attention,
    );
    expect(
      inventoryProductCatalogFilterFromQuery('unknown'),
      InventoryProductCatalogFilter.all,
    );
  });
}

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
    name: 'Adapter',
    sku: 'AD-001',
    category: 'Accessories',
    price: 20,
  ),
  Product(
    id: 'p4',
    name: 'Notebook',
    sku: 'NB-001',
    category: 'Stationery',
    price: 5,
  ),
];

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
  Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
];

final _stockRecords = buildInventoryStockRecords(
  products: _products,
  warehouses: _warehouses,
  inventoryItems: [
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
      productId: 'p1',
      warehouseId: 'w2',
      currentQuantity: 4,
      reorderPoint: 2,
      reorderQuantity: 6,
    ),
    InventoryItem(
      id: 'i3',
      productId: 'p2',
      warehouseId: 'w1',
      currentQuantity: 2,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
    InventoryItem(
      id: 'i4',
      productId: 'p3',
      warehouseId: 'w1',
      currentQuantity: 0,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
  ],
);
