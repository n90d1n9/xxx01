import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring.dart';
import 'package:kaysir/features/product/models/management_pack.dart';

void main() {
  test('availability authoring plan targets missing rules', () {
    final records = _catalogRecords();
    final template = productAvailabilityRuleTemplateFor(
      ProductAvailabilityRuleTemplateId.onlineStore,
    );

    final plan = buildProductAvailabilityRuleAuthoringPlan(
      records: records,
      template: template,
      target: ProductAvailabilityRuleAuthoringTarget.unconfigured,
    );

    expect(plan.targetProductCount, 1);
    expect(plan.changedProductCount, 1);
    expect(plan.unchangedProductCount, 0);
    expect(plan.targetCountLabel, '1 product');
    expect(plan.changeCountLabel, '1 change');
    expect(plan.previewProductLabel, 'Notebook');
    expect(plan.canApply, isTrue);

    final updatedProduct = plan.updatedProducts.single;
    expect(updatedProduct.name, 'Notebook');
    expect(updatedProduct.customAttributes['add_ons'], 'Pencil');
    expect(
      updatedProduct.customAttributes['available_channels'],
      'Online Store',
    );
    expect(updatedProduct.customAttributes['stock_policy'], 'allow_backorder');
    expect(plan.appliedMessage, '1 product updated with Online store');
  });

  test(
    'availability authoring plan identifies risk and skips matching rules',
    () {
      final records = _catalogRecords();
      final template = productAvailabilityRuleTemplateFor(
        ProductAvailabilityRuleTemplateId.counterService,
      );

      final riskPlan = buildProductAvailabilityRuleAuthoringPlan(
        records: records,
        template: template,
        target: ProductAvailabilityRuleAuthoringTarget.availabilityRisk,
      );

      expect(riskPlan.targetProductCount, 3);
      expect(riskPlan.changedProductCount, 3);
      expect(riskPlan.unchangedProductCount, 0);
      expect(
        riskPlan.previewProductLabel,
        'Empty Beans, Kiosk Snack, Notebook',
      );

      final allPlan = buildProductAvailabilityRuleAuthoringPlan(
        records: records,
        template: template,
        target: ProductAvailabilityRuleAuthoringTarget.allProducts,
      );

      expect(allPlan.targetProductCount, 4);
      expect(allPlan.changedProductCount, 3);
      expect(allPlan.unchangedProductCount, 1);
      expect(allPlan.unchangedCountLabel, '1 already matched');
      expect(
        productAvailabilityRuleAuthoringTargetTitle(
          ProductAvailabilityRuleAuthoringTarget.stockAttention,
        ),
        'Stock attention',
      );
    },
  );

  test('availability template registry composes active pack contributions', () {
    const freshShelfOverride = ProductAvailabilityRuleTemplate(
      id: ProductAvailabilityRuleTemplateId.freshShelf,
      title: 'Duplicate fresh shelf',
      subtitle: 'Duplicate template should be ignored.',
      attributes: {'available_channels': 'Duplicate'},
    );
    const freshShelf = ProductAvailabilityRuleTemplate(
      id: ProductAvailabilityRuleTemplateId.freshShelf,
      title: 'Fresh shelf',
      subtitle: 'Fresh goods selling with expiry-aware stock gates.',
      attributes: {
        'available_channels': 'POS, Online Store',
        'stock_policy': 'in_stock_only',
      },
    );
    const contribution = ProductAvailabilityRuleTemplateContribution(
      id: 'freshness_templates',
      title: 'Freshness templates',
      isActive: _freshnessPackOnly,
      templates: [freshShelf, freshShelfOverride],
    );

    final coreRegistry = ProductAvailabilityRuleTemplateRegistry(
      pack: coreProductManagementPack,
      contributions: const [contribution],
    );
    final groceryRegistry = ProductAvailabilityRuleTemplateRegistry(
      pack: groceryFreshGoodsProductManagementPack,
      contributions: const [contribution],
    );

    expect(coreRegistry.hasContributions, isFalse);
    expect(
      coreRegistry.templateIds,
      isNot(contains(ProductAvailabilityRuleTemplateId.freshShelf)),
    );
    expect(groceryRegistry.contributionCount, 1);
    expect(groceryRegistry.templateCount, 7);
    expect(groceryRegistry.sourceCount, 2);
    expect(groceryRegistry.coreTemplateCount, 6);
    expect(groceryRegistry.contributedTemplateCount, 1);
    expect(groceryRegistry.ignoredTemplateCount, 1);
    expect(groceryRegistry.templateCountLabel, '7 templates');
    expect(groceryRegistry.sourceCountLabel, '2 sources');
    expect(groceryRegistry.contributionCountLabel, '1 contribution');
    expect(groceryRegistry.coreTemplateCountLabel, '6 core templates');
    expect(
      groceryRegistry.contributedTemplateCountLabel,
      '1 contributed template',
    );
    expect(groceryRegistry.ignoredTemplateCountLabel, '1 duplicate skipped');
    expect(groceryRegistry.sourceSummaries.map((source) => source.title), [
      'Core templates',
      'Freshness templates',
    ]);
    expect(
      groceryRegistry.sourceSummaries.map((source) => source.templateCount),
      [6, 1],
    );
    expect(groceryRegistry.templateIds, [
      ProductAvailabilityRuleTemplateId.counterService,
      ProductAvailabilityRuleTemplateId.onlineStore,
      ProductAvailabilityRuleTemplateId.marketplace,
      ProductAvailabilityRuleTemplateId.kiosk,
      ProductAvailabilityRuleTemplateId.wholesale,
      ProductAvailabilityRuleTemplateId.temporarilyPaused,
      ProductAvailabilityRuleTemplateId.freshShelf,
    ]);
    expect(groceryRegistry.templates.last.title, 'Fresh shelf');
    expect(groceryRegistry.entries.last.sourceLabel, 'Freshness templates');
  });

  test('availability template contribution normalizes extension outputs', () {
    const blankTemplate = ProductAvailabilityRuleTemplate(
      id: ProductAvailabilityRuleTemplateId(' '),
      title: 'Blank template',
      subtitle: 'Should be ignored.',
      attributes: {'available_channels': 'Invalid'},
    );
    const blankTitleTemplate = ProductAvailabilityRuleTemplate(
      id: ProductAvailabilityRuleTemplateId('coffee_blank_title'),
      title: ' ',
      subtitle: 'Should be ignored.',
      attributes: {'available_channels': 'Invalid'},
    );
    const coffeeTemplate = ProductAvailabilityRuleTemplate(
      id: ProductAvailabilityRuleTemplateId('coffee_counter'),
      title: 'Coffee counter',
      subtitle: 'Counter-service coffee availability.',
      attributes: {'available_channels': 'Counter'},
    );
    const contribution = ProductAvailabilityRuleTemplateContribution(
      id: ' coffee_templates ',
      title: ' Coffee templates ',
      templates: [blankTemplate, blankTitleTemplate, coffeeTemplate],
    );
    const blankContribution = ProductAvailabilityRuleTemplateContribution(
      id: ' ',
      title: 'Blank templates',
      templates: [coffeeTemplate],
    );

    final templates = contribution.templatesFor(coreProductManagementPack);
    final registry = ProductAvailabilityRuleTemplateRegistry(
      pack: coreProductManagementPack,
      baseTemplates: const [],
      contributions: const [contribution, blankContribution],
    );

    expect(contribution.normalizedId, 'coffee_templates');
    expect(contribution.titleLabel, 'Coffee templates');
    expect(contribution.hasTemplates, isTrue);
    expect(contribution.isActiveFor(coreProductManagementPack), isTrue);
    expect(templates, [coffeeTemplate]);
    expect(() => templates.clear(), throwsUnsupportedError);
    expect(blankContribution.isActiveFor(coreProductManagementPack), isFalse);
    expect(blankContribution.templatesFor(coreProductManagementPack), isEmpty);
    expect(registry.contributionCount, 1);
    expect(registry.templateIds, [
      ProductAvailabilityRuleTemplateId('coffee_counter'),
    ]);
    expect(registry.entries.single.sourceId, 'coffee_templates');
    expect(registry.entries.single.sourceLabel, 'Coffee templates');
  });
}

bool _freshnessPackOnly(ProductManagementPack pack) {
  return pack.id == ProductManagementPackId.groceryFreshGoods;
}

List<InventoryProductCatalogRecord> _catalogRecords() {
  final stockRecords = buildInventoryStockRecords(
    inventoryItems: _inventoryItems,
    products: _products,
    warehouses: _warehouses,
  );

  return buildInventoryProductCatalogRecords(
    products: _products,
    stockRecords: stockRecords,
  );
}

final _products = [
  Product(
    id: 'p1',
    name: 'Notebook',
    sku: 'NOTE',
    category: 'Stationery',
    description: 'Paper notebook',
    barcode: '111',
    price: 3,
    customAttributes: const {'add_ons': 'Pencil'},
  ),
  Product(
    id: 'p2',
    name: 'Latte',
    sku: 'LATTE',
    category: 'Coffee',
    description: 'Hot latte',
    barcode: '222',
    price: 5,
    customAttributes: const {
      'available_channels': 'POS',
      'sales_status': 'active',
      'stock_policy': 'in_stock_only',
      'fulfillment_modes': 'pickup',
    },
  ),
  Product(
    id: 'p3',
    name: 'Kiosk Snack',
    sku: 'SNACK',
    category: 'Snacks',
    description: 'Counter snack',
    barcode: '333',
    price: 10,
    customAttributes: const {
      'enabled_channels': 'kiosk',
      'disabled_channels': 'kiosk',
    },
  ),
  Product(
    id: 'p4',
    name: 'Empty Beans',
    sku: 'BEANS',
    category: 'Coffee',
    description: 'Out of stock beans',
    barcode: '444',
    price: 12,
    customAttributes: const {
      'available_channels': 'POS',
      'stock_policy': 'stock_required',
    },
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
    currentQuantity: 8,
    reorderPoint: 2,
    reorderQuantity: 4,
  ),
  InventoryItem(
    id: 'i2',
    productId: 'p2',
    warehouseId: 'w1',
    currentQuantity: 12,
    reorderPoint: 4,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i3',
    productId: 'p3',
    warehouseId: 'w1',
    currentQuantity: 5,
    reorderPoint: 1,
    reorderQuantity: 4,
  ),
  InventoryItem(
    id: 'i4',
    productId: 'p4',
    warehouseId: 'w1',
    currentQuantity: 0,
    reorderPoint: 4,
    reorderQuantity: 8,
  ),
];
