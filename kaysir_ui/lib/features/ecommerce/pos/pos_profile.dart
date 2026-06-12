import '../../point_of_sales/cashier/experiences/pos_behavior_set.dart';
import '../../point_of_sales/cashier/experiences/pos_cart_behavior.dart';
import '../../point_of_sales/cashier/experiences/pos_catalog_behavior.dart';
import '../../point_of_sales/cashier/experiences/pos_checkout_behavior.dart';
import '../../point_of_sales/cashier/experiences/pos_data_contract.dart';
import '../../point_of_sales/cashier/experiences/pos_data_trait.dart';
import '../../point_of_sales/cashier/experiences/pos_experience.dart';
import '../../point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import '../../point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import '../../point_of_sales/cashier/experiences/pos_feature_module.dart';
import '../../point_of_sales/cashier/experiences/pos_payment_behavior.dart';
import '../../point_of_sales/cashier/experiences/pos_product_profile.dart';
import '../../point_of_sales/cashier/states/pos_layout_provider.dart';
import '../../point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';

const ecommercePOSProductProfileId = 'kaysir_ecommerce_web_store';

const ecommercePOSDataAdapter = POSDataTraitAdapter(
  id: 'kaysir_ecommerce_checkout_adapter',
  label: 'Kaysir  checkout adapter',
  fieldsByTrait: {
    POSDataTraitKeys.catalog: ['product_id', 'product_name', 'price'],
    POSDataTraitKeys.orders: ['order_id', 'line_items', 'total', 'status'],
    POSDataTraitKeys.customers: ['customer_id', 'display_name', 'contact'],
    POSDataTraitKeys.payments: [
      'payment_method',
      'tendered_amount',
      'payment_status',
    ],
  },
);

const ecommercePOSBehaviorSet = POSBehaviorSet(
  catalog: POSCatalogBehavior(
    actionLabel: 'Add to cart',
    emptyMessage: 'No storefront products',
    requirePositivePrice: true,
  ),
  cart: POSCartBehavior(
    maxQuantityPerLine: 99,
    emptyCartTitle: 'Build online cart',
    emptyCartMessage: 'Add storefront items before checkout.',
  ),
  checkout: POSCheckoutBehavior(
    autoCompleteOnFinalPayment: true,
    showReceiptAfterCompletion: false,
    paymentButtonLabel: 'Pay online',
    completeButtonLabel: 'Confirm order',
    finalPaymentButtonLabel: 'Capture payment',
    partialPaymentButtonLabel: 'Record deposit',
    emptyStatusLabel: 'Build storefront order',
    needsPaymentStatusLabel: 'Awaiting online payment',
    readyStatusLabel: 'Paid for fulfillment',
    autoCompletedMessage: 'Online order paid and queued for fulfillment.',
  ),
  payment: POSPaymentBehavior(
    paymentMethods: ['Card', 'Cash', 'Mobile Pay'],
    defaultMethod: 'Card',
    allowPartialPayments: false,
    includeCashRoundSuggestions: false,
    partialPaymentMessage: 'Online checkout requires a complete payment.',
  ),
  orderSync: POSOrderSaveOutboxSyncBehavior.ecommerce,
);

const ecommercePOSExperience = POSExperience(
  id: 'web_store',
  label: ' Web Store',
  description:
      'Owned storefront checkout for customer orders, payments, and fulfillment handoff.',
  preferredLayout: POSLayoutPreference.checkout,
  capabilities: POSExperienceCapabilities(
    barcodeScanning: false,
    heldOrders: false,
    promotions: false,
    newOrders: false,
    layoutSwitching: false,
  ),
  modules: [
    POSFeatureModules.catalogBrowsing,
    POSFeatureModules.cartManagement,
    POSFeatureModules.customerSelection,
    POSFeatureModules.payments,
  ],
  behaviors: ecommercePOSBehaviorSet,
  manifest: POSExperienceManifest(
    productLine: 'Kaysir ',
    archetypeKey: 'web_store',
    archetypeLabel: 'Web store',
    releaseStage: POSExperienceReleaseStage.preview,
    supportedFormFactors: [
      POSExperienceFormFactor.desktop,
      POSExperienceFormFactor.tablet,
      POSExperienceFormFactor.mobile,
    ],
    traits: ['owned-online', 'async-order', 'customer-account'],
    dataTraits: [
      POSDataTraitKeys.catalog,
      POSDataTraitKeys.orders,
      POSDataTraitKeys.customers,
      POSDataTraitKeys.payments,
    ],
  ),
);

final ecommercePOSProductProfile = POSProductProfile(
  id: ecommercePOSProductProfileId,
  label: 'Kaysir  Web Store',
  description: ecommercePOSExperience.description,
  recipe: POSExperienceRecipe.fromExperience(ecommercePOSExperience),
  experienceOverride: ecommercePOSExperience,
  requiredModules: ecommercePOSExperience.modules,
  requiredFormFactors: ecommercePOSExperience.manifest.supportedFormFactors,
  requiredDataTraits: ecommercePOSExperience.manifest.dataTraits,
  dataAdapters: const [ecommercePOSDataAdapter],
);
