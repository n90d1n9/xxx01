import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/ecommerce/pos/pos_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_profiles.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_contract.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_trait.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

void main() {
  test('switch state groups product profile options with decisions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(posModeSwitchStateProvider(1280));

    expect(state.isSingleOption, isFalse);
    expect(state.currentExperience, same(defaultPOSExperience));
    expect(state.sections.length, 2);

    final coreSection = state.sections.singleWhere(
      (section) => section.productLine == 'Kaysir Core',
    );
    final ecommerceSection = state.sections.singleWhere(
      (section) => section.productLine == 'Kaysir ',
    );

    expect(coreSection.optionCount, 3);
    expect(ecommerceSection.optionCount, 1);
    expect(ecommerceSection.options.single.id, ecommercePOSExperience.id);

    final quickCheckout = state.findOption(quickCheckoutPOSExperience.id);
    expect(quickCheckout, isNotNull);
    expect(quickCheckout!.selected, isFalse);
    expect(
      quickCheckout.decision.disposition,
      POSModeSwitchDisposition.confirm,
    );
    expect(quickCheckout.productProfile?.id, 'kaysir_core_quick_checkout');
  });

  test('switch controller applies selected mode and layout preference', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(posModeSwitchControllerProvider(800));
    final quickCheckout = controller.optionFor(quickCheckoutPOSExperience.id);

    expect(quickCheckout.canSwitch, isTrue);
    controller.apply(quickCheckout);

    expect(
      container.read(selectedPOSExperienceIdProvider),
      quickCheckoutPOSExperience.id,
    );
    expect(
      container.read(posLayoutPreferenceProvider),
      POSLayoutPreference.checkout,
    );
  });

  test('switch controller rejects blocked launch profiles', () {
    final blockedMode = defaultPOSExperience.copyWith(
      id: 'blocked_modifiers',
      label: 'Blocked Modifiers',
      manifest: defaultPOSExperience.manifest.copyWith(
        archetypeKey: 'blocked_modifiers',
        archetypeLabel: 'Blocked modifiers',
        releaseStage: POSExperienceReleaseStage.stable,
        dataTraits: const [POSDataTraitKeys.modifierGroups],
      ),
    );
    final blockedProfile = POSProductProfile(
      id: 'blocked_modifiers_profile',
      label: 'Blocked Modifiers Profile',
      description: 'Profile with incomplete modifier contract coverage.',
      recipe: POSExperienceRecipe.fromExperience(blockedMode),
      experienceOverride: blockedMode,
      requiredModules: blockedMode.modules,
      requiredFormFactors: blockedMode.manifest.supportedFormFactors,
      requiredDataTraits: blockedMode.manifest.dataTraits,
      dataAdapters: const [
        POSDataTraitAdapter(
          id: 'incomplete_menu_api',
          label: 'Incomplete Menu API',
          fieldsByTrait: {
            POSDataTraitKeys.modifierGroups: ['group_id', 'option_id'],
          },
        ),
      ],
    );
    final catalog = POSProductProfileCatalog(
      profiles: [defaultPOSProductProfiles.first, blockedProfile],
    );
    final container = ProviderContainer(
      overrides: [posProductProfileCatalogProvider.overrideWithValue(catalog)],
    );
    addTearDown(container.dispose);

    final controller = container.read(posModeSwitchControllerProvider(1280));
    final blockedOption = controller.optionFor(blockedMode.id);

    expect(blockedOption.canSwitch, isFalse);
    expect(blockedOption.decision.message, contains('Price delta'));
    expect(() => controller.apply(blockedOption), throwsStateError);
    expect(container.read(selectedPOSExperienceIdProvider), 'standard_cashier');
  });
}
