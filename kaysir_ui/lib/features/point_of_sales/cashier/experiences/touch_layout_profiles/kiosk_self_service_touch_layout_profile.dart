import '../../models/pos_quick_button.dart';
import '../../models/pos_touch_layout_profile.dart';
import '../../states/pos_layout_strategy.dart';
import '../pos_experience_manifest.dart';

/// Large-tile self-service profile for kiosk and unattended ordering.
const kioskSelfServiceTouchLayoutProfile = POSTouchLayoutProfile(
  id: 'kiosk_self_service_touch',
  label: 'Kiosk Self Service Touch',
  description:
      'Large self-service touch profile for guided ordering and kiosk checkout.',
  productLine: 'Kiosk',
  preferredLayout: POSLayoutPreference.checkout,
  density: POSTouchLayoutDensity.kiosk,
  orderPanelPlacement: POSTouchOrderPanelPlacement.bottom,
  catalogEmphasis: POSTouchCatalogEmphasis.selfService,
  minTileExtent: 132,
  maxGridColumns: 4,
  showOrderPanelByDefault: false,
  supportsScannerInput: false,
  supportedFormFactors: [
    POSExperienceFormFactor.kiosk,
    POSExperienceFormFactor.tablet,
    POSExperienceFormFactor.mobile,
  ],
  traits: ['self-service', 'guided-ordering', 'large-touch'],
  groups: [
    POSQuickButtonGroup(
      id: 'kiosk_entry',
      label: 'Kiosk Entry',
      description: 'Large guided ordering shortcuts for self-service guests.',
      surface: POSQuickButtonSurface.kioskHero,
      buttons: [
        POSQuickButton(
          id: 'kiosk_start_order',
          label: 'Start',
          description: 'Begin a new self-service kiosk order.',
          intent: POSQuickButtonIntent.commandAction('new_order'),
          surface: POSQuickButtonSurface.kioskHero,
          iconKey: 'touch_app',
          priority: 10,
        ),
        POSQuickButton(
          id: 'kiosk_featured',
          label: 'Featured',
          description: 'Open featured self-service products.',
          intent: POSQuickButtonIntent.category('featured'),
          surface: POSQuickButtonSurface.kioskHero,
          iconKey: 'stars',
          priority: 20,
        ),
        POSQuickButton(
          id: 'kiosk_language',
          label: 'Language',
          description: 'Open kiosk language selector.',
          intent: POSQuickButtonIntent.customFlow(targetId: 'language_select'),
          surface: POSQuickButtonSurface.kioskHero,
          iconKey: 'translate',
          priority: 30,
        ),
      ],
    ),
    POSQuickButtonGroup(
      id: 'kiosk_checkout',
      label: 'Kiosk Checkout',
      description: 'Self-service order review and payment shortcuts.',
      surface: POSQuickButtonSurface.orderFooter,
      buttons: [
        POSQuickButton(
          id: 'kiosk_review',
          label: 'Review',
          description: 'Review current self-service order.',
          intent: POSQuickButtonIntent.customFlow(targetId: 'review_order'),
          surface: POSQuickButtonSurface.orderFooter,
          iconKey: 'receipt_long',
          priority: 10,
        ),
        POSQuickButton(
          id: 'kiosk_payment',
          label: 'Pay',
          description: 'Open kiosk checkout payment.',
          intent: POSQuickButtonIntent.commandAction('payment'),
          surface: POSQuickButtonSurface.orderFooter,
          iconKey: 'payments',
          priority: 20,
        ),
      ],
    ),
  ],
);
