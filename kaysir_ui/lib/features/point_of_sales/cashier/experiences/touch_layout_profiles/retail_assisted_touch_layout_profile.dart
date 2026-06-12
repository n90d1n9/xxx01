import '../../models/pos_quick_button.dart';
import '../../models/pos_touch_layout_profile.dart';
import '../../states/pos_layout_strategy.dart';
import '../pos_experience_manifest.dart';

/// Touch profile for assisted retail selling and clienteling counters.
const retailAssistedTouchLayoutProfile = POSTouchLayoutProfile(
  id: 'retail_assisted_touch',
  label: 'Retail Assisted Touch',
  description:
      'Assisted-selling profile for scan, browse, customer lookup, and returns.',
  productLine: 'Retail',
  preferredLayout: POSLayoutPreference.counter,
  density: POSTouchLayoutDensity.comfortable,
  orderPanelPlacement: POSTouchOrderPanelPlacement.right,
  catalogEmphasis: POSTouchCatalogEmphasis.assistedSelling,
  minTileExtent: 100,
  maxGridColumns: 6,
  supportedFormFactors: [
    POSExperienceFormFactor.desktop,
    POSExperienceFormFactor.tablet,
  ],
  traits: ['assisted-selling', 'clienteling', 'returns'],
  groups: [
    POSQuickButtonGroup(
      id: 'retail_catalog',
      label: 'Catalog',
      description: 'Assisted retail catalog and selling shortcuts.',
      surface: POSQuickButtonSurface.primaryGrid,
      buttons: [
        POSQuickButton(
          id: 'retail_new_arrivals',
          label: 'New',
          description: 'Open new arrivals and featured items.',
          intent: POSQuickButtonIntent.category('new_arrivals'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'auto_awesome',
          priority: 10,
        ),
        POSQuickButton(
          id: 'retail_accessories',
          label: 'Accessories',
          description: 'Open accessory and add-on categories.',
          intent: POSQuickButtonIntent.category('accessories'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'category',
          priority: 20,
        ),
        POSQuickButton(
          id: 'retail_client_lookup',
          label: 'Client',
          description: 'Lookup customer profile and preferences.',
          intent: POSQuickButtonIntent.customerAction('client_lookup'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'person_search',
          priority: 30,
          requiredTraits: ['clienteling'],
        ),
        POSQuickButton(
          id: 'retail_return',
          label: 'Return',
          description: 'Start a guided return or exchange flow.',
          intent: POSQuickButtonIntent.customFlow(targetId: 'return_exchange'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'assignment_return',
          priority: 40,
          requiredTraits: ['returns'],
        ),
      ],
    ),
    POSQuickButtonGroup(
      id: 'retail_commands',
      label: 'Retail Commands',
      description: 'Checkout and assisted selling command shortcuts.',
      surface: POSQuickButtonSurface.commandBar,
      buttons: [
        POSQuickButton(
          id: 'retail_scan',
          label: 'Scan',
          description: 'Scan item barcode or SKU.',
          intent: POSQuickButtonIntent.commandAction('scan'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'qr_code_scanner',
          priority: 10,
        ),
        POSQuickButton(
          id: 'retail_promo',
          label: 'Promo',
          description: 'Open promotion and voucher tools.',
          intent: POSQuickButtonIntent.commandAction('promotions'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'discount',
          priority: 20,
        ),
        POSQuickButton(
          id: 'retail_payment',
          label: 'Pay',
          description: 'Open payment and receipt flow.',
          intent: POSQuickButtonIntent.commandAction('payment'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'payments',
          priority: 30,
        ),
      ],
    ),
  ],
);
