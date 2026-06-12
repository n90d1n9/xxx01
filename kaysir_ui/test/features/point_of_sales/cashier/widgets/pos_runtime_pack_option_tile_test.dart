import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_availability.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_preview.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_runtime_pack_option_tile.dart';

void main() {
  testWidgets('runtime pack section header renders reusable counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: POSRuntimePackSectionHeader(title: 'Online', count: 2),
        ),
      ),
    );

    expect(find.text('Online'), findsOneWidget);
    expect(find.text('2 packs'), findsOneWidget);
  });

  testWidgets('runtime pack option tile renders reusable switch preview', (
    tester,
  ) async {
    final pack = _onlinePack();
    final plan = POSProductRuntimePackSwitchPlan.resolve(
      pack: pack,
      currentExperienceId: 'standard_cashier',
      currentCommerceChannelId: 'in_store',
    );
    final availability = POSProductRuntimePackSwitchAvailability.evaluate(
      plan: plan,
      currentPack: defaultPOSProductRuntimePack,
      order: null,
    );
    final preview = POSProductRuntimePackSwitchPreview.evaluate(
      availability: availability,
      currentLayoutPreference: POSLayoutPreference.auto,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSRuntimePackOptionTile(
            pack: pack,
            plan: plan,
            availability: availability,
            preview: preview,
          ),
        ),
      ),
    );

    expect(find.text('Online Pack'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Available'), findsWidgets);
    expect(find.text('1 mode | 1 channel'), findsWidgets);
    expect(find.text('Switches mode and channel'), findsOneWidget);
    expect(find.text('Quick Checkout / Web store'), findsWidgets);
    expect(find.text('Kaysir Core to Online'), findsOneWidget);
    expect(find.text('Auto to Checkout'), findsOneWidget);
    expect(find.byIcon(Icons.splitscreen_outlined), findsOneWidget);
  });
}

POSProductRuntimePack _onlinePack() {
  final quickCheckoutProfile = defaultPOSProductRuntimePack
      .productProfileCatalog
      .profiles
      .firstWhere((profile) => profile.experience.id == 'quick_checkout');
  final webChannel = defaultPOSProductRuntimePack.commerceChannelRegistry
      .channelForId('web_store');

  return defaultPOSProductRuntimePack.copyWith(
    id: 'online_pack',
    label: 'Online Pack',
    productLine: 'Online',
    productProfileCatalog: POSProductProfileCatalog(
      profiles: [quickCheckoutProfile],
    ),
    commerceChannelRegistry: POSCommerceChannelRegistry(
      defaultChannelId: webChannel.id,
      channels: [webChannel],
    ),
  );
}
