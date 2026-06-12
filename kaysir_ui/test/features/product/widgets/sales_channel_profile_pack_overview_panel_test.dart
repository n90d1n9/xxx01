import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_pack_overview.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/widgets/sales_channel_profile_pack_overview_panel.dart';

void main() {
  testWidgets('profile pack overview panel renders runtime provenance', (
    tester,
  ) async {
    final overview = buildProductSalesChannelProfilePackOverview(
      packs: [defaultProductSalesChannelProfilePack],
      registry: defaultProductSalesChannelProfileRegistry,
      selectedProfile: omniRetailProductSalesChannelProfile,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductSalesChannelProfilePackOverviewPanel(overview: overview),
        ),
      ),
    );

    expect(find.text('Runtime packs'), findsOneWidget);
    expect(find.text('Single pack'), findsOneWidget);
    expect(find.text('1 pack'), findsOneWidget);
    expect(find.text('3 profiles'), findsAtLeastNWidgets(1));
    expect(find.text('Current source'), findsOneWidget);
    expect(find.text('Default Product Channels'), findsAtLeastNWidgets(1));
    expect(find.text('Current fallback'), findsOneWidget);
  });

  testWidgets('profile pack overview panel renders composed packs', (
    tester,
  ) async {
    const groceryProfileId = ProductSalesChannelProfileId('grocery_market');
    final groceryProfile = ProductSalesChannelProfile(
      id: groceryProfileId,
      title: 'Grocery Market',
      subtitle: 'Fresh goods and shelf scanning readiness',
      definitions: const [],
    );
    final groceryPack = ProductSalesChannelProfilePack(
      id: 'grocery_pack',
      title: 'Grocery Pack',
      profiles: [groceryProfile],
      fallbackProfileId: groceryProfileId,
    );
    final registry = ProductSalesChannelProfileRegistry.fromPacks([
      defaultProductSalesChannelProfilePack,
      groceryPack,
    ]);
    final overview = buildProductSalesChannelProfilePackOverview(
      packs: [defaultProductSalesChannelProfilePack, groceryPack],
      registry: registry,
      selectedProfile: groceryProfile,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductSalesChannelProfilePackOverviewPanel(overview: overview),
        ),
      ),
    );

    expect(find.text('Composable'), findsOneWidget);
    expect(find.text('2 packs'), findsOneWidget);
    expect(find.text('4 profiles'), findsOneWidget);
    expect(find.text('Grocery Pack'), findsAtLeastNWidgets(1));
    expect(find.text('Grocery Market'), findsAtLeastNWidgets(1));
    expect(find.text('Current fallback'), findsOneWidget);
  });
}
