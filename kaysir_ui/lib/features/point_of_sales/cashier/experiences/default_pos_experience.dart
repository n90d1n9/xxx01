import '../states/pos_layout_provider.dart';
import 'pos_behavior_set.dart';
import 'pos_data_trait.dart';
import 'pos_experience.dart';
import 'pos_experience_manifest.dart';
import 'pos_experience_registry.dart';
import 'pos_feature_module.dart';

const defaultPOSExperience = POSExperience(
  id: 'standard_cashier',
  label: 'Standard Cashier',
  description: 'Full cashier workspace for catalog, cart, payment, and holds.',
  preferredLayout: POSLayoutPreference.auto,
  capabilities: POSExperienceCapabilities(),
  modules: POSFeatureModules.standardCashier,
  behaviors: POSBehaviorSet.standard,
  manifest: POSExperienceManifest(
    productLine: 'Kaysir Core',
    archetypeKey: 'general_commerce',
    archetypeLabel: 'General commerce',
    releaseStage: POSExperienceReleaseStage.stable,
    supportedFormFactors: [
      POSExperienceFormFactor.desktop,
      POSExperienceFormFactor.tablet,
      POSExperienceFormFactor.mobile,
    ],
    traits: ['operator-led', 'full-service', 'multi-action'],
    dataTraits: [
      ...POSDataTraitKeys.standardCommerce,
      POSDataTraitKeys.promotions,
    ],
  ),
);

const quickCheckoutPOSExperience = POSExperience(
  id: 'quick_checkout',
  label: 'Quick Checkout',
  description: 'Tender-first flow for fast checkout and constrained screens.',
  preferredLayout: POSLayoutPreference.checkout,
  capabilities: POSExperienceCapabilities(
    customerSelection: false,
    heldOrders: false,
    promotions: false,
    newOrders: false,
    layoutSwitching: false,
  ),
  modules: POSFeatureModules.quickCheckout,
  behaviors: POSBehaviorSet.quickCheckout,
  manifest: POSExperienceManifest(
    productLine: 'Kaysir Core',
    archetypeKey: 'quick_sale',
    archetypeLabel: 'Quick sale',
    releaseStage: POSExperienceReleaseStage.preview,
    supportedFormFactors: [
      POSExperienceFormFactor.kiosk,
      POSExperienceFormFactor.tablet,
      POSExperienceFormFactor.mobile,
    ],
    traits: ['touch-first', 'fast-tender', 'constrained-actions'],
    dataTraits: POSDataTraitKeys.quickCheckout,
  ),
);

const assistedServicePOSExperience = POSExperience(
  id: 'assisted_service',
  label: 'Assisted Service',
  description: 'Guided counter flow for customer-led service orders.',
  preferredLayout: POSLayoutPreference.auto,
  capabilities: POSExperienceCapabilities(
    barcodeScanning: false,
    promotions: false,
  ),
  modules: POSFeatureModules.assistedService,
  behaviors: POSBehaviorSet.assistedService,
  manifest: POSExperienceManifest(
    productLine: 'Kaysir Core',
    archetypeKey: 'assisted_service',
    archetypeLabel: 'Assisted service',
    releaseStage: POSExperienceReleaseStage.preview,
    supportedFormFactors: [
      POSExperienceFormFactor.desktop,
      POSExperienceFormFactor.tablet,
    ],
    traits: ['customer-led', 'service-lines', 'guided-closeout'],
    dataTraits: POSDataTraitKeys.assistedService,
  ),
);

const defaultPOSExperienceRegistry = POSExperienceRegistry(
  experiences: [
    defaultPOSExperience,
    quickCheckoutPOSExperience,
    assistedServicePOSExperience,
  ],
);
