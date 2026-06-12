import '../../models/pos_quick_button.dart';
import '../../models/pos_touch_layout_profile.dart';
import '../../states/pos_layout_strategy.dart';
import '../pos_experience_manifest.dart';

/// Scanner-first layout profile for grocery, minimarket, and fresh goods lanes.
const groceryScannerTouchLayoutProfile = POSTouchLayoutProfile(
  id: 'grocery_scanner_touch',
  label: 'Grocery Scanner Touch',
  description:
      'Compact scanner-led profile with fresh, weighed, and packaged item shortcuts.',
  productLine: 'Grocery',
  preferredLayout: POSLayoutPreference.counter,
  density: POSTouchLayoutDensity.compact,
  orderPanelPlacement: POSTouchOrderPanelPlacement.right,
  catalogEmphasis: POSTouchCatalogEmphasis.scannerFirst,
  minTileExtent: 88,
  maxGridColumns: 8,
  supportedFormFactors: [
    POSExperienceFormFactor.desktop,
    POSExperienceFormFactor.tablet,
  ],
  traits: ['scanner-first', 'fresh-goods', 'weighted-items'],
  groups: [
    POSQuickButtonGroup(
      id: 'grocery_departments',
      label: 'Departments',
      description: 'Fast PLU and department access for grocery lanes.',
      surface: POSQuickButtonSurface.primaryGrid,
      buttons: [
        POSQuickButton(
          id: 'grocery_produce',
          label: 'Produce',
          description: 'Open fresh produce and weighted PLU shortcuts.',
          intent: POSQuickButtonIntent.category('produce'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'nutrition',
          priority: 10,
          requiredTraits: ['fresh-goods'],
        ),
        POSQuickButton(
          id: 'grocery_bakery',
          label: 'Bakery',
          description: 'Open bakery and prepared bread shortcuts.',
          intent: POSQuickButtonIntent.category('bakery'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'bakery_dining',
          priority: 20,
        ),
        POSQuickButton(
          id: 'grocery_weigh_item',
          label: 'Weigh Item',
          description: 'Start a scale-assisted weighted item flow.',
          intent: POSQuickButtonIntent.customFlow(targetId: 'weigh_item'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'scale',
          priority: 30,
          requiredTraits: ['weighted-items'],
        ),
        POSQuickButton(
          id: 'grocery_markdown',
          label: 'Markdown',
          description: 'Apply approved markdown discount flow.',
          intent: POSQuickButtonIntent.discount('grocery_markdown'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'percent',
          priority: 40,
        ),
      ],
    ),
    POSQuickButtonGroup(
      id: 'grocery_commands',
      label: 'Lane Commands',
      description: 'Command shortcuts tuned for fast grocery lanes.',
      surface: POSQuickButtonSurface.commandBar,
      buttons: [
        POSQuickButton(
          id: 'grocery_scan',
          label: 'Scan',
          description: 'Keep barcode scanning as the primary lane action.',
          intent: POSQuickButtonIntent.commandAction('scan'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'barcode_scanner',
          priority: 10,
          requiredTraits: ['scanner-first'],
        ),
        POSQuickButton(
          id: 'grocery_price_check',
          label: 'Price Check',
          description: 'Open a product lookup without adding to the order.',
          intent: POSQuickButtonIntent.customFlow(targetId: 'price_check'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'search',
          priority: 20,
        ),
        POSQuickButton(
          id: 'grocery_payment',
          label: 'Pay',
          description: 'Open payment for the grocery order.',
          intent: POSQuickButtonIntent.commandAction('payment'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'payments',
          priority: 30,
        ),
      ],
    ),
  ],
);
