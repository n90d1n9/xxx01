import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/edition.dart';
import 'package:kaysir/features/product/models/edition_readiness.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/experience_profile_launch_target.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/widgets/edition_launcher_panel.dart';

void main() {
  testWidgets('product edition launcher renders registered editions', (
    tester,
  ) async {
    ProductEdition? selectedEdition;
    ProductExperienceProfileLaunchTarget? selectedTarget;

    await tester.binding.setSurfaceSize(const Size(1120, 820));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductEditionLauncherPanel(
            editions: defaultProductEditions,
            readiness: assessProductEditionRegistryReadiness(
              defaultProductEditionRegistry,
            ),
            onEditionSelected: (edition, target) {
              selectedEdition = edition;
              selectedTarget = target;
            },
          ),
        ),
      ),
    );

    expect(find.text('Product editions'), findsOneWidget);
    expect(find.text('8 editions'), findsOneWidget);
    expect(find.text('All editions ready'), findsOneWidget);
    expect(find.text('7 segments'), findsOneWidget);
    expect(find.text('Reusable editions'), findsOneWidget);
    expect(find.text('Fresh goods'), findsOneWidget);
    expect(find.text('Commerce'), findsOneWidget);
    expect(find.text('Operations'), findsAtLeastNWidgets(1));
    expect(find.text('Core Retail'), findsOneWidget);
    expect(find.text('Grocery Fresh Goods'), findsOneWidget);
    expect(find.text('Self-Service Kiosk'), findsOneWidget);
    expect(find.text('Edition mode'), findsWidgets);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Open workspace'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('product-edition-grocery_fresh_goods')),
    );
    await tester.pump();

    expect(selectedEdition, groceryFreshGoodsProductEdition);
    expect(
      selectedTarget?.uri,
      '/product-workspace?experience=fresh_goods&pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
  });

  testWidgets('product edition launcher supports an empty registry', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProductEditionLauncherPanel(editions: [])),
      ),
    );

    expect(find.text('Product editions'), findsOneWidget);
    expect(find.text('0 editions'), findsOneWidget);
    expect(find.text('0 segments'), findsOneWidget);
    expect(
      find.text('No product editions are registered yet.'),
      findsOneWidget,
    );
  });

  testWidgets('product edition launcher blocks invalid edition launches', (
    tester,
  ) async {
    const edition = ProductEdition(
      id: ProductEditionId('broken_kiosk'),
      title: 'Broken Kiosk',
      subtitle: 'Invalid channel',
      description: 'A kiosk edition with a channel not available for its pack.',
      kind: ProductEditionKind.kiosk,
      experienceProfileId: ProductExperienceProfileId.catalogOperations,
      managementPackId: ProductManagementPackId.groceryFreshGoods,
      channelProfileId: ProductSalesChannelProfileId.counterService,
      capabilityLabels: ['Kiosk flow'],
    );
    const registry = ProductEditionRegistry([edition]);
    ProductEdition? selectedEdition;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductEditionLauncherPanel(
            editions: registry.editions,
            readiness: assessProductEditionRegistryReadiness(registry),
            onEditionSelected: (edition, target) => selectedEdition = edition,
          ),
        ),
      ),
    );

    expect(find.text('1 blocked'), findsOneWidget);
    expect(find.text('Broken Kiosk'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Resolve edition setup'), findsOneWidget);
    expect(
      find.textContaining('Channel profile counter_service is not available'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('product-edition-broken_kiosk')),
    );
    await tester.pump();

    expect(selectedEdition, isNull);
  });
}
