import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_trait.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_behavior_set.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_factory.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_feature_module.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

import 'pos_experience_mode_harness.dart';

void main() {
  test('recipe builds vertical quick checkout modes from launch metadata', () {
    final recipe = POSExperienceRecipe.quickCheckout(
      id: 'counter_cafe',
      label: 'Counter Cafe',
      description: 'Touch-first cafe counter for menu items and fast tender.',
      productLine: 'Kaysir Cafe',
      archetypeKey: 'counter_cafe',
      archetypeLabel: 'Counter cafe',
      supportedFormFactors: const [
        POSExperienceFormFactor.tablet,
        POSExperienceFormFactor.kiosk,
        POSExperienceFormFactor.mobile,
      ],
      traits: const ['modifiers', 'queue-friendly', 'fast-tender'],
      dataTraits: const [
        POSDataTraitKeys.menu,
        POSDataTraitKeys.orders,
        POSDataTraitKeys.payments,
        POSDataTraitKeys.modifierGroups,
      ],
      capabilities: const POSExperienceCapabilities(
        customerSelection: true,
        heldOrders: false,
        promotions: false,
        newOrders: false,
        layoutSwitching: false,
      ),
      modules: const [
        ...POSFeatureModules.quickCheckout,
        POSFeatureModules.customerSelection,
      ],
    );

    final cafeMode = POSExperienceFactory.fromRecipe(recipe);

    expectValidPOSExperienceMode(
      cafeMode,
      requiredModules: const [
        POSFeatureModules.catalogBrowsing,
        POSFeatureModules.cartManagement,
        POSFeatureModules.customerSelection,
        POSFeatureModules.payments,
      ],
      requiredFormFactors: const [
        POSExperienceFormFactor.tablet,
        POSExperienceFormFactor.kiosk,
      ],
    );
    expect(recipe.archetype, POSExperienceRecipeArchetype.quickCheckout);
    expect(recipe.requiresDataTrait(POSDataTraitKeys.modifierGroups), isTrue);
    expect(cafeMode.preferredLayout, POSLayoutPreference.checkout);
    expect(cafeMode.behaviors, same(POSBehaviorSet.quickCheckout));
    expect(cafeMode.manifest.productLine, 'Kaysir Cafe');
    expect(cafeMode.capabilities.customerSelection, isTrue);
  });

  test(
    'recipe copyWith keeps archetype defaults while changing product traits',
    () {
      final base = POSExperienceRecipe.standardCashier(
        id: 'fashion_retail',
        label: 'Fashion Retail',
        description: 'Full-service retail counter for variants and customers.',
        productLine: 'Kaysir Retail',
        archetypeKey: 'fashion_retail',
        archetypeLabel: 'Fashion retail',
      );
      final recipe = base.copyWith(
        traits: const ['variants', 'returns', 'customer-led'],
        dataTraits: const [
          POSDataTraitKeys.catalog,
          POSDataTraitKeys.orders,
          POSDataTraitKeys.customers,
          POSDataTraitKeys.inventory,
          POSDataTraitKeys.variants,
        ],
      );

      final retailMode = recipe.toExperience();

      expectValidPOSExperienceMode(
        retailMode,
        requiredModules: const [
          POSFeatureModules.catalogBrowsing,
          POSFeatureModules.customerSelection,
          POSFeatureModules.payments,
        ],
        requiredFormFactors: const [
          POSExperienceFormFactor.desktop,
          POSExperienceFormFactor.tablet,
        ],
      );
      expect(recipe.archetype, POSExperienceRecipeArchetype.standardCashier);
      expect(recipe.requiresDataTrait(POSDataTraitKeys.variants), isTrue);
      expect(retailMode.hasModule(POSFeatureModules.promotions.id), isTrue);
      expect(retailMode.behaviors, same(POSBehaviorSet.standard));
    },
  );

  test('recipe protects built experience lists from later mutation', () {
    final modules = [...POSFeatureModules.assistedService];
    final dataTraits = [
      POSDataTraitKeys.orders,
      POSDataTraitKeys.customers,
      POSDataTraitKeys.payments,
    ];
    final recipe = POSExperienceRecipe.assistedService(
      id: 'repair_counter',
      label: 'Repair Counter',
      description: 'Assisted repair order counter for service jobs.',
      productLine: 'Kaysir Service',
      archetypeKey: 'repair_counter',
      archetypeLabel: 'Repair counter',
      releaseStage: POSExperienceReleaseStage.experimental,
      modules: modules,
      dataTraits: dataTraits,
    );

    final mode = recipe.toExperience();
    modules.clear();
    dataTraits.clear();

    expect(mode.modules, isNotEmpty);
    expect(mode.manifest.dataTraits, contains('orders'));
    expect(
      () => mode.modules.add(POSFeatureModules.promotions),
      throwsUnsupportedError,
    );
    expect(
      () => mode.manifest.dataTraits.add('mutated'),
      throwsUnsupportedError,
    );
  });
}
