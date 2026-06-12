import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/widgets/management_pack_selector_panel.dart';

void main() {
  testWidgets('product pack selector renders packs and delegates selection', (
    tester,
  ) async {
    ProductManagementPackId? selectedPackId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackSelectorPanel(
            packs: [
              coreProductManagementPack,
              groceryFreshGoodsProductManagementPack,
            ],
            selectedPack: coreProductManagementPack,
            onChanged: (packId) => selectedPackId = packId,
          ),
        ),
      ),
    );

    expect(find.text('Product pack mode'), findsOneWidget);
    expect(find.text('Core Catalog'), findsWidgets);
    expect(find.text('Grocery Fresh Goods'), findsWidgets);
    expect(find.text('2 packs'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('9 fields'), findsOneWidget);
    expect(find.text('4 required'), findsOneWidget);

    await tester.tap(find.text('Grocery Fresh Goods').first);

    expect(selectedPackId, ProductManagementPackId.groceryFreshGoods);
  });
}
