import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/widgets/management_mode_status_panel.dart';

void main() {
  testWidgets('product management mode status panel renders active context', (
    tester,
  ) async {
    var resetCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementModeStatusPanel(
            pack: groceryFreshGoodsProductManagementPack,
            channelProfile: groceryFreshGoodsProductSalesChannelProfile,
            canReset: true,
            onReset: () => resetCount += 1,
          ),
        ),
      ),
    );

    expect(find.text('Active product mode'), findsOneWidget);
    expect(find.text('Grocery Fresh Goods'), findsOneWidget);
    expect(find.text('Fresh Goods Grocery'), findsOneWidget);
    expect(find.text('Custom mode'), findsOneWidget);
    expect(find.text('Catalog basics'), findsOneWidget);
    expect(find.text('Expiry-aware selling'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Reset'));
    await tester.pump();

    expect(resetCount, 1);
  });

  testWidgets(
    'product management mode status panel disables reset at default',
    (tester) async {
      var resetCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductManagementModeStatusPanel(
              pack: coreProductManagementPack,
              channelProfile: omniRetailProductSalesChannelProfile,
              canReset: false,
              onReset: () => resetCount += 1,
            ),
          ),
        ),
      );

      expect(find.text('Default mode'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Reset'));
      await tester.pump();

      expect(resetCount, 0);
    },
  );
}
