import '../../models/pos_quick_button.dart';
import '../../models/pos_touch_layout_profile.dart';
import '../../states/pos_layout_strategy.dart';
import '../pos_experience_manifest.dart';

/// General purpose cashier touch profile for mixed retail counters.
const coreCounterTouchLayoutProfile = POSTouchLayoutProfile(
  id: 'core_counter_touch',
  label: 'Core Counter Touch',
  description:
      'Balanced product-first touch workspace for standard cashier counters.',
  productLine: 'Kaysir Core',
  preferredLayout: POSLayoutPreference.auto,
  density: POSTouchLayoutDensity.comfortable,
  orderPanelPlacement: POSTouchOrderPanelPlacement.right,
  catalogEmphasis: POSTouchCatalogEmphasis.favoritesFirst,
  minTileExtent: 104,
  maxGridColumns: 6,
  supportedFormFactors: [
    POSExperienceFormFactor.desktop,
    POSExperienceFormFactor.tablet,
    POSExperienceFormFactor.mobile,
  ],
  traits: ['operator-led', 'full-service', 'touch-first'],
  groups: [
    POSQuickButtonGroup(
      id: 'core_favorites',
      label: 'Favorites',
      description: 'Common catalog shortcuts for daily counter work.',
      surface: POSQuickButtonSurface.primaryGrid,
      buttons: [
        POSQuickButton(
          id: 'core_category_favorites',
          label: 'Favorites',
          description: 'Open the cashier favorite products category.',
          intent: POSQuickButtonIntent.category('favorites'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'star',
          priority: 10,
          tags: ['catalog', 'favorites'],
        ),
        POSQuickButton(
          id: 'core_category_top_sellers',
          label: 'Top Sellers',
          description: 'Open products that are sold most frequently.',
          intent: POSQuickButtonIntent.category('top_sellers'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'trending_up',
          priority: 20,
          tags: ['catalog', 'velocity'],
        ),
        POSQuickButton(
          id: 'core_category_services',
          label: 'Services',
          description: 'Open service and non-stock item shortcuts.',
          intent: POSQuickButtonIntent.category('services'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'room_service',
          priority: 30,
          tags: ['catalog', 'service'],
        ),
      ],
    ),
    POSQuickButtonGroup(
      id: 'core_commands',
      label: 'Commands',
      description: 'High-frequency cashier command shortcuts.',
      surface: POSQuickButtonSurface.commandBar,
      buttons: [
        POSQuickButton(
          id: 'core_scan',
          label: 'Scan',
          description: 'Start barcode or SKU scanning.',
          intent: POSQuickButtonIntent.commandAction('scan'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'qr_code_scanner',
          priority: 10,
        ),
        POSQuickButton(
          id: 'core_hold_order',
          label: 'Hold',
          description: 'Hold the active order for later resume.',
          intent: POSQuickButtonIntent.commandAction('hold_order'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'pause_circle',
          priority: 20,
        ),
        POSQuickButton(
          id: 'core_payment',
          label: 'Pay',
          description: 'Open tendering and complete payment.',
          intent: POSQuickButtonIntent.commandAction('payment'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'payments',
          priority: 30,
        ),
      ],
    ),
  ],
);
