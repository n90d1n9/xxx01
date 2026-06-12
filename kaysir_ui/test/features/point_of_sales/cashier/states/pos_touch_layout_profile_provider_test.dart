import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_touch_layout_profiles.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile_catalog.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_product_runtime_pack_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_touch_layout_profile_provider.dart';

void main() {
  test('touch layout profile provider exposes the runtime pack catalog', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(posTouchLayoutProfileCatalogProvider),
      same(defaultPOSProductRuntimePack.touchLayoutProfileCatalog),
    );
    expect(
      container.read(posTouchLayoutProfileCatalogProvider),
      same(defaultPOSTouchLayoutProfileCatalog),
    );
    expect(
      container.read(posTouchLayoutProfileProvider).id,
      'core_counter_touch',
    );
    expect(container.read(posTouchLayoutProfileCatalogIssuesProvider), isEmpty);
  });

  test(
    'touch layout profile controller switches profile and layout preference',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(posTouchLayoutProfileControllerProvider)
          .select('coffee_counter_touch');

      expect(
        container.read(selectedPOSTouchLayoutProfileIdProvider),
        'coffee_counter_touch',
      );
      expect(
        container.read(posTouchLayoutProfileProvider).productLine,
        'Coffee Shop',
      );
      expect(
        container.read(posLayoutPreferenceProvider),
        POSLayoutPreference.checkout,
      );
    },
  );

  test('recommended profile uses active experience and viewport width', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final recommended = container.read(
      recommendedPOSTouchLayoutProfileProvider(1280),
    );

    expect(recommended.id, 'core_counter_touch');
  });

  test('runtime pack override can replace touch layout profile catalog', () {
    const customProfile = POSTouchLayoutProfile(
      id: 'custom_touch',
      label: 'Custom Touch',
      description: 'Custom product-specific touch layout.',
      productLine: 'Custom',
      preferredLayout: POSLayoutPreference.compact,
      density: POSTouchLayoutDensity.compact,
      orderPanelPlacement: POSTouchOrderPanelPlacement.bottom,
      catalogEmphasis: POSTouchCatalogEmphasis.categoryFirst,
      groups: [
        POSQuickButtonGroup(
          id: 'custom_group',
          label: 'Custom',
          description: 'Custom quick actions.',
          surface: POSQuickButtonSurface.primaryGrid,
          buttons: [
            POSQuickButton(
              id: 'custom_category',
              label: 'Custom',
              description: 'Open custom category.',
              intent: POSQuickButtonIntent.category('custom'),
              surface: POSQuickButtonSurface.primaryGrid,
            ),
          ],
        ),
      ],
    );
    const catalog = POSTouchLayoutProfileCatalog(
      defaultProfileId: 'custom_touch',
      profiles: [customProfile],
    );
    final pack = defaultPOSProductRuntimePack.copyWith(
      id: 'custom_pack',
      label: 'Custom Pack',
      touchLayoutProfileCatalog: catalog,
    );
    final registry = POSProductRuntimePackRegistry(
      defaultPackId: pack.id,
      packs: [pack],
    );
    final container = ProviderContainer(
      overrides: [
        posProductRuntimePackRegistryProvider.overrideWithValue(registry),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(posTouchLayoutProfileCatalogProvider), same(catalog));
    expect(container.read(posTouchLayoutProfileProvider).id, 'custom_touch');
    expect(
      container.read(
        posTouchLayoutSurfaceGroupsProvider(POSQuickButtonSurface.primaryGrid),
      ),
      hasLength(1),
    );
  });
}
