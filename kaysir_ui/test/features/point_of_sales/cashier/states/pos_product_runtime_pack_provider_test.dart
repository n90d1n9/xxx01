import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_behavior.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_command_action_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_product_runtime_pack_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_shell_shortcut_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_touch_layout_profile_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_command_actions.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_shell_shortcuts.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_host.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_pack_provider.dart';

void main() {
  test('runtime pack provider exposes the default Kaysir core pack', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(posProductRuntimePackProvider),
      same(defaultPOSProductRuntimePack),
    );
    expect(
      container.read(posProductRuntimePackRegistryIssuesProvider),
      isEmpty,
    );
    expect(container.read(posProductRuntimePackIssuesProvider), isEmpty);
    expect(
      container
          .read(posProductRuntimePackCatalogProvider)
          .sections
          .single
          .packs,
      [defaultPOSProductRuntimePack],
    );
    expect(
      container.read(posProductProfileCatalogProvider),
      same(defaultPOSProductRuntimePack.productProfileCatalog),
    );
    expect(
      container.read(posCommerceChannelRegistryProvider),
      same(defaultPOSProductRuntimePack.commerceChannelRegistry),
    );
    expect(
      container.read(posCommerceChannelBehaviorRegistryProvider),
      same(defaultPOSProductRuntimePack.commerceChannelBehaviorRegistry),
    );
    expect(
      container.read(posCommerceChannelBehaviorRegistryIssuesProvider),
      isEmpty,
    );
    expect(
      container.read(posCommerceChannelBehaviorProfileProvider)?.channelId,
      'in_store',
    );
    expect(
      container.read(posLayoutStrategyPackProvider),
      same(defaultPOSProductRuntimePack.layoutStrategyPack),
    );
    expect(
      container.read(posTouchLayoutProfileCatalogProvider),
      same(defaultPOSProductRuntimePack.touchLayoutProfileCatalog),
    );
    expect(
      container.read(posCommandActionRegistryProvider),
      same(defaultPOSProductRuntimePack.commandActionRegistry),
    );
    expect(
      container.read(posShellShortcutRegistryProvider),
      same(defaultPOSProductRuntimePack.shortcutRegistry),
    );
  });

  test('active runtime pack drives downstream POS registries', () {
    final profileCatalog = POSProductProfileCatalog(
      profiles: [
        defaultPOSProductRuntimePack.productProfileCatalog.profiles.first
            .copyWith(id: 'custom_cashier_profile'),
      ],
    );
    final channel = defaultPOSProductRuntimePack.commerceChannelRegistry
        .channelForId('kiosk');
    final channelRegistry = POSCommerceChannelRegistry(
      defaultChannelId: channel.id,
      channels: [channel],
    );
    final behaviorRegistry = POSCommerceChannelBehaviorRegistry(
      profiles: [
        POSCommerceChannelBehaviorProfile(
          channelId: channel.id,
          modules: const [
            POSCommerceChannelBehaviorModules.selfServiceFlow,
            POSCommerceChannelBehaviorModules.pickupQueue,
          ],
        ),
      ],
    );
    final layoutPack = POSLayoutStrategyPack.withRenderers(
      strategyRegistry: _checkoutOnlyStrategies,
      renderers: const [
        POSLayoutStrategyRenderer(
          strategy: POSLayoutStrategy.checkout,
          builder: _fakeLayoutBuilder,
        ),
      ],
    );
    final commandRegistry = POSCommandActionRegistry(
      specs: [POSCommandActionRegistry.defaultSpecs.first],
    );
    final shortcutRegistry = POSShellShortcutRegistry(
      specs: [POSShellShortcutRegistry.defaultSpecs.first],
    );
    final customPack = defaultPOSProductRuntimePack.copyWith(
      id: 'custom_pack',
      label: 'Custom Pack',
      productProfileCatalog: profileCatalog,
      commerceChannelRegistry: channelRegistry,
      commerceChannelBehaviorRegistry: behaviorRegistry,
      layoutStrategyPack: layoutPack,
      commandActionRegistry: commandRegistry,
      shortcutRegistry: shortcutRegistry,
    );
    final registry = POSProductRuntimePackRegistry(
      defaultPackId: customPack.id,
      packs: [customPack],
    );
    final container = ProviderContainer(
      overrides: [
        posProductRuntimePackRegistryProvider.overrideWithValue(registry),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(posProductRuntimePackProvider), same(customPack));
    expect(
      container.read(posProductProfileCatalogProvider),
      same(profileCatalog),
    );
    expect(
      container.read(posCommerceChannelRegistryProvider),
      same(channelRegistry),
    );
    expect(
      container.read(posCommerceChannelBehaviorRegistryProvider),
      same(behaviorRegistry),
    );
    expect(container.read(posCommerceChannelProvider), same(channel));
    expect(
      container.read(posCommerceChannelBehaviorProfileProvider)?.channelId,
      'kiosk',
    );
    expect(
      container.read(posCommerceChannelBehaviorModulesProvider),
      contains(POSCommerceChannelBehaviorModules.selfServiceFlow),
    );
    expect(container.read(posLayoutStrategyPackProvider), same(layoutPack));
    expect(
      container.read(posTouchLayoutProfileCatalogProvider),
      same(defaultPOSProductRuntimePack.touchLayoutProfileCatalog),
    );
    expect(
      container.read(posCommandActionRegistryProvider),
      same(commandRegistry),
    );
    expect(
      container.read(posShellShortcutRegistryProvider),
      same(shortcutRegistry),
    );
  });

  test('selected runtime pack can switch product wiring at runtime', () {
    final customPack = defaultPOSProductRuntimePack.copyWith(
      id: 'secondary_pack',
      label: 'Secondary Pack',
      productProfileCatalog: POSProductProfileCatalog(
        profiles: [
          defaultPOSProductRuntimePack.productProfileCatalog.profiles.first
              .copyWith(id: 'secondary_profile'),
        ],
      ),
    );
    final registry = POSProductRuntimePackRegistry(
      defaultPackId: defaultPOSProductRuntimePack.id,
      packs: [defaultPOSProductRuntimePack, customPack],
    );
    final container = ProviderContainer(
      overrides: [
        posProductRuntimePackRegistryProvider.overrideWithValue(registry),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(posProductRuntimePackProvider),
      same(defaultPOSProductRuntimePack),
    );

    container.read(selectedPOSProductRuntimePackIdProvider.notifier).state =
        customPack.id;

    expect(container.read(posProductRuntimePackProvider), same(customPack));
    expect(
      container.read(posProductProfileCatalogProvider),
      same(customPack.productProfileCatalog),
    );
  });

  test('runtime pack switch controller resets dependent selections safely', () {
    final quickCheckoutProfile = defaultPOSProductRuntimePack
        .productProfileCatalog
        .profiles
        .firstWhere((profile) => profile.experience.id == 'quick_checkout');
    final webChannel = defaultPOSProductRuntimePack.commerceChannelRegistry
        .channelForId('web_store');
    final onlinePack = defaultPOSProductRuntimePack.copyWith(
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
    final registry = POSProductRuntimePackRegistry(
      defaultPackId: defaultPOSProductRuntimePack.id,
      packs: [defaultPOSProductRuntimePack, onlinePack],
    );
    final container = ProviderContainer(
      overrides: [
        posProductRuntimePackRegistryProvider.overrideWithValue(registry),
      ],
    );
    addTearDown(container.dispose);

    container.read(selectedPOSCommerceChannelIdProvider.notifier).state =
        'kiosk';
    container.read(posLayoutPreferenceProvider.notifier).state =
        POSLayoutPreference.counter;

    final controller = container.read(
      posProductRuntimePackSwitchControllerProvider,
    );
    final plan = controller.planFor(onlinePack);

    expect(plan.impactLabel, 'Switches mode and channel');
    expect(plan.selectionLabel, 'Quick Checkout / Web store');

    controller.apply(onlinePack);

    expect(container.read(posProductRuntimePackProvider), same(onlinePack));
    expect(container.read(posExperienceProvider).id, 'quick_checkout');
    expect(container.read(posCommerceChannelProvider).id, 'web_store');
    expect(
      container.read(posLayoutPreferenceProvider),
      POSLayoutPreference.checkout,
    );
  });
}

const _checkoutOnlyStrategies = POSLayoutStrategyRegistry(
  strategies: [
    POSLayoutStrategySpec(
      id: 'runtime_checkout',
      strategy: POSLayoutStrategy.checkout,
      preference: POSLayoutPreference.checkout,
      label: 'Runtime Checkout',
      description: 'Pack-specific checkout layout.',
      autoMinWidth: 0,
      slots: [POSLayoutSlot.checkout],
    ),
  ],
);

Widget _fakeLayoutBuilder(POSLayoutStrategyBuildScope scope) {
  return const SizedBox.shrink();
}
