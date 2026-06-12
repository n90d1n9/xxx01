import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

void main() {
  test('runtime pack switch plan preserves compatible selections', () {
    final plan = POSProductRuntimePackSwitchPlan.resolve(
      pack: defaultPOSProductRuntimePack,
      currentExperienceId: 'standard_cashier',
      currentCommerceChannelId: 'in_store',
    );

    expect(plan.preservesSelections, isTrue);
    expect(plan.preservesExperience, isTrue);
    expect(plan.preservesCommerceChannel, isTrue);
    expect(plan.experience?.id, 'standard_cashier');
    expect(plan.commerceChannel?.id, 'in_store');
    expect(plan.layoutPreference, POSLayoutPreference.auto);
    expect(plan.impactLabel, 'Keeps current mode and channel');
    expect(plan.selectionLabel, 'Standard Cashier / In-store');
  });

  test('runtime pack switch plan falls back to pack defaults', () {
    final onlinePack = _onlinePack();

    final plan = POSProductRuntimePackSwitchPlan.resolve(
      pack: onlinePack,
      currentExperienceId: 'standard_cashier',
      currentCommerceChannelId: 'kiosk',
    );

    expect(plan.preservesSelections, isFalse);
    expect(plan.preservesExperience, isFalse);
    expect(plan.preservesCommerceChannel, isFalse);
    expect(plan.experience?.id, 'quick_checkout');
    expect(plan.commerceChannel?.id, 'web_store');
    expect(plan.layoutPreference, POSLayoutPreference.checkout);
    expect(plan.impactLabel, 'Switches mode and channel');
    expect(plan.selectionLabel, 'Quick Checkout / Web store');
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
