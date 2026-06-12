import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/widgets/product_availability_rule_template_source_panel.dart';

void main() {
  testWidgets(
    'availability template source panel renders registry provenance',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductAvailabilityRuleTemplateSourcePanel(
                registry: _registry,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Template sources'), findsOneWidget);
      expect(
        find.textContaining('Grocery Fresh Goods | 7 templates available'),
        findsOneWidget,
      );
      expect(find.text('2 sources'), findsOneWidget);
      expect(find.text('1 contribution'), findsOneWidget);
      expect(find.text('1 duplicate skipped'), findsOneWidget);
      expect(find.text('6 core templates'), findsOneWidget);
      expect(find.text('1 contributed template'), findsOneWidget);
      expect(find.text('Core templates'), findsOneWidget);
      expect(find.text('Core rule templates'), findsOneWidget);
      expect(find.text('Freshness templates'), findsOneWidget);
      expect(find.text('Module rule templates'), findsOneWidget);
      expect(find.text('1 template'), findsOneWidget);
    },
  );

  testWidgets('availability template source panel delegates source selection', (
    tester,
  ) async {
    var selectedSourceId = productAvailabilityRuleTemplateAllSourceId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductAvailabilityRuleTemplateSourcePanel(
              registry: _registry,
              selectedSourceId: selectedSourceId,
              onSourceSelected: (sourceId) => selectedSourceId = sourceId,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Freshness templates'));
    await tester.pump();

    expect(selectedSourceId, 'freshness_templates');

    await tester.tap(find.text('All templates'));
    await tester.pump();

    expect(selectedSourceId, productAvailabilityRuleTemplateAllSourceId);
  });
}

final _registry = ProductAvailabilityRuleTemplateRegistry(
  pack: groceryFreshGoodsProductManagementPack,
  contributions: const [
    ProductAvailabilityRuleTemplateContribution(
      id: 'freshness_templates',
      title: 'Freshness templates',
      isActive: _freshnessPackOnly,
      templates: [
        ProductAvailabilityRuleTemplate(
          id: ProductAvailabilityRuleTemplateId.freshShelf,
          title: 'Fresh shelf',
          subtitle: 'Fresh goods selling with expiry-aware stock gates.',
          attributes: {
            'available_channels': 'POS, Online Store',
            'stock_policy': 'in_stock_only',
          },
        ),
        ProductAvailabilityRuleTemplate(
          id: ProductAvailabilityRuleTemplateId.freshShelf,
          title: 'Duplicate fresh shelf',
          subtitle: 'Duplicate template should be ignored.',
          attributes: {'available_channels': 'Duplicate'},
        ),
      ],
    ),
  ],
);

bool _freshnessPackOnly(ProductManagementPack pack) {
  return pack.id == ProductManagementPackId.groceryFreshGoods;
}
