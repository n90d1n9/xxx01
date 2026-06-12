import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_behavior_set.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_factory.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_feature_module.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

import 'pos_experience_mode_harness.dart';

void main() {
  test(
    'factory creates quick checkout vertical modes from reusable defaults',
    () {
      final cafeMode = POSExperienceFactory.quickCheckout(
        id: 'counter_cafe',
        label: 'Counter Cafe',
        description: 'Touch-first cafe counter for menu items and fast tender.',
        manifest: const POSExperienceManifest(
          productLine: 'Kaysir Cafe',
          archetypeKey: 'counter_cafe',
          archetypeLabel: 'Counter cafe',
          releaseStage: POSExperienceReleaseStage.preview,
          supportedFormFactors: [
            POSExperienceFormFactor.tablet,
            POSExperienceFormFactor.kiosk,
            POSExperienceFormFactor.mobile,
          ],
          traits: ['modifiers', 'queue-friendly', 'fast-tender'],
          dataTraits: ['menu', 'orders', 'payments'],
        ),
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

      expectValidPOSExperienceMode(
        cafeMode,
        requiredModules: const [
          POSFeatureModules.catalogBrowsing,
          POSFeatureModules.cartManagement,
          POSFeatureModules.payments,
          POSFeatureModules.customerSelection,
        ],
        requiredFormFactors: const [
          POSExperienceFormFactor.tablet,
          POSExperienceFormFactor.kiosk,
        ],
      );
      expect(cafeMode.preferredLayout, POSLayoutPreference.checkout);
      expect(cafeMode.behaviors, same(POSBehaviorSet.quickCheckout));
      expect(cafeMode.capabilities.customerSelection, isTrue);
      expect(cafeMode.capabilities.promotions, isFalse);
    },
  );

  test('factory extends an existing mode without losing behavior defaults', () {
    final retailMode = POSExperienceFactory.fromBase(
      base: defaultPOSExperience,
      id: 'fashion_retail',
      label: 'Fashion Retail',
      description: 'Full-service retail counter for variants and customers.',
      manifest: defaultPOSExperience.manifest.copyWith(
        productLine: 'Kaysir Retail',
        archetypeKey: 'fashion_retail',
        archetypeLabel: 'Fashion retail',
        traits: ['variants', 'returns', 'customer-led'],
        dataTraits: ['catalog', 'orders', 'customers', 'inventory'],
      ),
    );

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
    expect(retailMode.behaviors, same(defaultPOSExperience.behaviors));
    expect(retailMode.manifest.productLine, 'Kaysir Retail');
    expect(retailMode.hasModule(POSFeatureModules.promotions.id), isTrue);
  });

  test('factory protects created module lists from later mutation', () {
    final mode = POSExperienceFactory.assistedService(
      id: 'repair_counter',
      label: 'Repair Counter',
      description: 'Assisted repair order counter for service jobs.',
      manifest: const POSExperienceManifest(
        productLine: 'Kaysir Service',
        archetypeKey: 'repair_counter',
        archetypeLabel: 'Repair counter',
        releaseStage: POSExperienceReleaseStage.experimental,
        supportedFormFactors: [
          POSExperienceFormFactor.desktop,
          POSExperienceFormFactor.tablet,
        ],
        traits: ['service-ticket', 'customer-led'],
        dataTraits: ['orders', 'customers', 'payments'],
      ),
    );

    expect(
      () => mode.modules.add(POSFeatureModules.promotions),
      throwsUnsupportedError,
    );
  });
}
