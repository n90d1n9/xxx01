import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring.dart';
import 'package:kaysir/features/product/widgets/product_availability_rule_authoring_panel.dart';

void main() {
  testWidgets('availability rule authoring panel previews and applies plan', (
    tester,
  ) async {
    ProductAvailabilityRuleAuthoringPlan? appliedPlan;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductAvailabilityRuleAuthoringPanel(
              records: _records,
              onApply: (plan) => appliedPlan = plan,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Rule authoring'), findsOneWidget);
    expect(find.text('Counter service'), findsAtLeastNWidgets(1));
    expect(find.text('Missing rules'), findsOneWidget);
    expect(find.text('1 change'), findsAtLeastNWidgets(1));
    expect(find.text('Notebook'), findsOneWidget);

    await tester.tap(find.text('Apply template'));
    await tester.pump();

    expect(
      appliedPlan?.template.id,
      ProductAvailabilityRuleTemplateId.counterService,
    );
    expect(
      appliedPlan?.target,
      ProductAvailabilityRuleAuthoringTarget.unconfigured,
    );
    expect(appliedPlan?.changedProductCount, 1);
    expect(
      appliedPlan
          ?.updatedProducts
          .single
          .customAttributes['available_channels'],
      'POS',
    );
  });

  testWidgets('availability rule authoring panel filters template sources', (
    tester,
  ) async {
    ProductAvailabilityRuleAuthoringPlan? appliedPlan;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductAvailabilityRuleAuthoringPanel(
              records: _records,
              templateEntries: _sourceEntries,
              onApply: (plan) => appliedPlan = plan,
            ),
          ),
        ),
      ),
    );

    expect(find.text('All templates (2)'), findsOneWidget);
    expect(find.text('Core templates (1)'), findsOneWidget);
    expect(find.text('Freshness availability templates (1)'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(ChoiceChip, 'Freshness availability templates (1)'),
    );
    await tester.pump();

    expect(find.text('Fresh shelf'), findsAtLeastNWidgets(1));
    expect(find.text('Freshness availability templates'), findsOneWidget);

    await tester.tap(find.text('Apply template'));
    await tester.pump();

    expect(
      appliedPlan?.template.id,
      ProductAvailabilityRuleTemplateId.freshShelf,
    );
    expect(
      appliedPlan?.updatedProducts.single.customAttributes['freshness_status'],
      'Fresh',
    );
  });

  testWidgets('availability rule authoring panel follows controlled source', (
    tester,
  ) async {
    ProductAvailabilityRuleAuthoringPlan? appliedPlan;
    var selectedSourceId = 'freshness_availability_templates';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return ProductAvailabilityRuleAuthoringPanel(
                  records: _records,
                  templateEntries: _sourceEntries,
                  selectedSourceId: selectedSourceId,
                  onSourceChanged:
                      (sourceId) => setState(() => selectedSourceId = sourceId),
                  onApply: (plan) => appliedPlan = plan,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Fresh shelf'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Apply template'));
    await tester.pump();

    expect(
      appliedPlan?.template.id,
      ProductAvailabilityRuleTemplateId.freshShelf,
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Core templates (1)'));
    await tester.pump();

    expect(selectedSourceId, productAvailabilityRuleTemplateCoreSourceId);
    expect(find.text('Counter service'), findsAtLeastNWidgets(1));
  });

  testWidgets(
    'availability rule authoring panel delegates template selection',
    (tester) async {
      ProductAvailabilityRuleAuthoringPlan? appliedPlan;
      var selectedTemplateId = ProductAvailabilityRuleTemplateId.counterService;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return ProductAvailabilityRuleAuthoringPanel(
                    records: _records,
                    templateEntries: _sourceEntries,
                    selectedTemplateId: selectedTemplateId,
                    onTemplateChanged:
                        (templateId) =>
                            setState(() => selectedTemplateId = templateId),
                    onApply: (plan) => appliedPlan = plan,
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Counter service').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fresh shelf').last);
      await tester.pumpAndSettle();

      expect(selectedTemplateId, ProductAvailabilityRuleTemplateId.freshShelf);

      await tester.tap(find.text('Apply template'));
      await tester.pump();

      expect(
        appliedPlan?.template.id,
        ProductAvailabilityRuleTemplateId.freshShelf,
      );
    },
  );

  testWidgets('availability rule authoring panel follows controlled target', (
    tester,
  ) async {
    ProductAvailabilityRuleAuthoringPlan? appliedPlan;
    var selectedTarget = ProductAvailabilityRuleAuthoringTarget.allProducts;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    ProductAvailabilityRuleAuthoringPanel(
                      records: _records,
                      selectedTarget: selectedTarget,
                      onTargetChanged:
                          (target) => setState(() => selectedTarget = target),
                      onApply: (plan) => appliedPlan = plan,
                    ),
                    TextButton(
                      onPressed:
                          () => setState(
                            () =>
                                selectedTarget =
                                    ProductAvailabilityRuleAuthoringTarget
                                        .availabilityRisk,
                          ),
                      child: const Text('External target'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('All products'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Apply template'));
    await tester.pump();

    expect(
      appliedPlan?.target,
      ProductAvailabilityRuleAuthoringTarget.allProducts,
    );

    await tester.tap(find.text('External target'));
    await tester.pumpAndSettle();

    expect(find.text('Availability risk'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Availability risk').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Missing rules').last);
    await tester.pumpAndSettle();

    expect(selectedTarget, ProductAvailabilityRuleAuthoringTarget.unconfigured);

    await tester.tap(find.text('Apply template'));
    await tester.pump();

    expect(
      appliedPlan?.target,
      ProductAvailabilityRuleAuthoringTarget.unconfigured,
    );
  });
}

final _records = [
  InventoryProductCatalogRecord(
    product: Product(
      id: 'p1',
      name: 'Notebook',
      sku: 'NOTE',
      category: 'Stationery',
      price: 3,
    ),
    stockRecords: const [],
  ),
  InventoryProductCatalogRecord(
    product: Product(
      id: 'p2',
      name: 'Latte',
      sku: 'LATTE',
      category: 'Coffee',
      price: 5,
      customAttributes: const {
        'available_channels': 'POS',
        'sales_status': 'active',
        'stock_policy': 'in_stock_only',
        'fulfillment_modes': 'pickup',
      },
    ),
    stockRecords: const [],
  ),
];

final _sourceEntries = [
  ProductAvailabilityRuleTemplateEntry(
    template: productAvailabilityRuleTemplateFor(
      ProductAvailabilityRuleTemplateId.counterService,
    ),
  ),
  const ProductAvailabilityRuleTemplateEntry(
    sourceId: 'freshness_availability_templates',
    sourceTitle: 'Freshness availability templates',
    contributionId: 'freshness_availability_templates',
    contributionTitle: 'Freshness availability templates',
    template: ProductAvailabilityRuleTemplate(
      id: ProductAvailabilityRuleTemplateId.freshShelf,
      title: 'Fresh shelf',
      subtitle: 'Fresh goods selling with expiry-aware stock gates.',
      attributes: {
        'available_channels': 'POS, Online Store',
        'stock_policy': 'in_stock_only',
        'freshness_status': 'Fresh',
      },
    ),
  ),
];
