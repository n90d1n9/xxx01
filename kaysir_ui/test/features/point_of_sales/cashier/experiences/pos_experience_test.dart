import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/ecommerce/pos/pos_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_action_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_feature_module.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

void main() {
  test('default POS experience preserves the current cashier capabilities', () {
    expect(defaultPOSExperience.id, 'standard_cashier');
    expect(defaultPOSExperience.preferredLayout, POSLayoutPreference.auto);
    expect(defaultPOSExperience.capabilities.barcodeScanning, isTrue);
    expect(defaultPOSExperience.capabilities.customerSelection, isTrue);
    expect(defaultPOSExperience.capabilities.heldOrders, isTrue);
    expect(defaultPOSExperience.capabilities.promotions, isTrue);
    expect(defaultPOSExperience.capabilities.payments, isTrue);
    expect(defaultPOSExperience.capabilities.newOrders, isTrue);
    expect(defaultPOSExperience.capabilities.layoutSwitching, isTrue);
    expect(defaultPOSExperience.behaviors.catalog.actionLabel, 'Add');
    expect(
      defaultPOSExperience.cartBehavior.mergeStrategy.name,
      'mergeByProduct',
    );
    expect(
      defaultPOSExperience.checkoutBehavior.completeButtonLabel,
      'Complete order',
    );
    expect(defaultPOSExperience.paymentBehavior.defaultMethod, 'Cash');
    expect(defaultPOSExperience.orderSyncBehavior.drainLimit, 20);
    expect(defaultPOSExperience.manifest.productLine, 'Kaysir Core');
    expect(defaultPOSExperience.manifest.archetypeKey, 'general_commerce');
    expect(
      defaultPOSExperience.manifest.supportsFormFactor(
        POSExperienceFormFactor.desktop,
      ),
      isTrue,
    );
    expect(
      defaultPOSExperience.hasModule(POSFeatureModules.payments.id),
      isTrue,
    );
    expect(
      defaultPOSExperience.moduleIds,
      contains(POSFeatureModules.layoutSwitching.id),
    );
  });

  test(
    'POS experience capabilities can be specialized by vertical product',
    () {
      const kioskCapabilities = POSExperienceCapabilities(
        barcodeScanning: false,
        customerSelection: false,
        heldOrders: false,
        promotions: true,
        payments: true,
        newOrders: false,
        layoutSwitching: false,
      );

      final coffeeCapabilities = kioskCapabilities.copyWith(
        customerSelection: true,
        heldOrders: true,
      );

      expect(coffeeCapabilities.barcodeScanning, isFalse);
      expect(coffeeCapabilities.customerSelection, isTrue);
      expect(coffeeCapabilities.heldOrders, isTrue);
      expect(coffeeCapabilities.newOrders, isFalse);
    },
  );

  test(
    'POS experience registry resolves experiences and registered modules',
    () {
      expect(
        defaultPOSExperienceRegistry.resolve(quickCheckoutPOSExperience.id),
        quickCheckoutPOSExperience,
      );
      expect(
        defaultPOSExperienceRegistry.resolve('missing_experience'),
        defaultPOSExperience,
      );
      expect(
        defaultPOSExperienceRegistry.modules.map((module) => module.id),
        containsAll([
          POSFeatureModules.catalogBrowsing.id,
          POSFeatureModules.cartManagement.id,
          POSFeatureModules.payments.id,
        ]),
      );
    },
  );

  test('POS experience provider selects registered profiles by id', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(posExperienceProvider), defaultPOSExperience);

    container.read(selectedPOSExperienceIdProvider.notifier).state =
        quickCheckoutPOSExperience.id;

    expect(container.read(posExperienceProvider), quickCheckoutPOSExperience);
    expect(
      container.read(posBehaviorSetProvider),
      quickCheckoutPOSExperience.behaviors,
    );
    expect(
      container.read(posExperienceModulesProvider),
      POSFeatureModules.quickCheckout,
    );
    final catalog = container.read(posExperienceCatalogProvider);
    final coreSection = catalog.sections.singleWhere(
      (section) => section.productLine == 'Kaysir Core',
    );
    final ecommerceSection = catalog.sections.singleWhere(
      (section) => section.productLine == 'Kaysir ',
    );

    expect(coreSection.experienceCount, 3);
    expect(ecommerceSection.experienceCount, 1);
    expect(ecommerceSection.experiences.single, ecommercePOSExperience);
    expect(container.read(posCartBehaviorProvider).maxQuantityPerLine, 99);
    expect(
      container.read(posPaymentBehaviorProvider).allowPartialPayments,
      isFalse,
    );
    expect(
      container.read(posCheckoutBehaviorProvider).autoCompleteOnFinalPayment,
      isTrue,
    );
    expect(
      container.read(posOrderSaveOutboxSyncBehaviorProvider).queueTitle,
      'Quick sale sync queue',
    );
    expect(
      container
          .read(posOrderSaveOutboxSyncBehaviorProvider)
          .retryFailedByDefault,
      isFalse,
    );
    expect(
      container.read(posExperienceResolutionProvider).usedFallback,
      isFalse,
    );
    expect(container.read(posExperienceRegistryIssuesProvider), isEmpty);

    container.read(selectedPOSExperienceIdProvider.notifier).state = 'unknown';

    expect(container.read(posExperienceProvider), defaultPOSExperience);
    expect(
      container.read(posExperienceResolutionProvider).usedFallback,
      isTrue,
    );
  });

  test(
    'POS experience copyWith can replace a behavior set or one behavior',
    () {
      final quickCheckout = defaultPOSExperience.copyWith(
        behaviors: quickCheckoutPOSExperience.behaviors,
      );
      final assistedCart = defaultPOSExperience.copyWith(
        cartBehavior: assistedServicePOSExperience.cartBehavior,
      );
      final kioskManifest = defaultPOSExperience.copyWith(
        manifest: quickCheckoutPOSExperience.manifest,
      );
      final manualSync = defaultPOSExperience.copyWith(
        orderSyncBehavior: quickCheckoutPOSExperience.orderSyncBehavior,
      );

      expect(quickCheckout.catalogBehavior.actionLabel, 'Quick add');
      expect(quickCheckout.paymentBehavior.allowPartialPayments, isFalse);
      expect(assistedCart.cartBehavior.mergeStrategy.name, 'alwaysNewLine');
      expect(
        assistedCart.catalogBehavior,
        defaultPOSExperience.catalogBehavior,
      );
      expect(kioskManifest.manifest.archetypeKey, 'quick_sale');
      expect(manualSync.orderSyncBehavior.queueTitle, 'Quick sale sync queue');
      expect(manualSync.catalogBehavior, defaultPOSExperience.catalogBehavior);
    },
  );

  test('POS experience action policy centralizes action availability', () {
    const standardPolicy = POSExperienceActionPolicy(
      experience: defaultPOSExperience,
    );
    const quickCheckoutPolicy = POSExperienceActionPolicy(
      experience: quickCheckoutPOSExperience,
    );

    expect(standardPolicy.allows(POSExperienceAction.heldOrders), isTrue);
    expect(quickCheckoutPolicy.allows(POSExperienceAction.heldOrders), isFalse);
    expect(quickCheckoutPolicy.allows(POSExperienceAction.payments), isTrue);
    expect(
      quickCheckoutPolicy.unsupportedMessage(
        POSExperienceAction.layoutSwitching,
      ),
      'Layout switching is not enabled for Quick Checkout mode',
    );
  });

  test(
    'POS experience action policy respects commerce channel capabilities',
    () {
      final marketplace = defaultPOSCommerceChannelRegistry.channelForId(
        'marketplace',
      );
      final policy = POSExperienceActionPolicy(
        experience: defaultPOSExperience,
        commerceChannel: marketplace,
      );

      expect(policy.allows(POSExperienceAction.payments), isFalse);
      expect(policy.allows(POSExperienceAction.promotions), isFalse);
      expect(policy.allows(POSExperienceAction.customerSelection), isFalse);
      expect(policy.allows(POSExperienceAction.newOrders), isTrue);
      expect(policy.channelAllows(POSExperienceAction.payments), isFalse);
      expect(
        policy.unsupportedMessage(POSExperienceAction.payments),
        'Payments is not supported for Marketplace channel',
      );
    },
  );

  test('POS experience action policy requires backing modules at runtime', () {
    final misconfigured = defaultPOSExperience.copyWith(
      modules:
          defaultPOSExperience.modules
              .where((module) => module.id != POSFeatureModules.payments.id)
              .toList(),
    );
    final policy = POSExperienceActionPolicy(experience: misconfigured);
    final availability = policy.availability(POSExperienceAction.payments);

    expect(policy.capabilityAllows(POSExperienceAction.payments), isTrue);
    expect(availability.moduleRegistered, isFalse);
    expect(availability.allowed, isFalse);
    expect(policy.allows(POSExperienceAction.payments), isFalse);
    expect(
      policy.unsupportedMessage(POSExperienceAction.payments),
      'Payments is unavailable for Standard Cashier mode because module "payments" is not registered',
    );
  });
}
