import '../../models/pos_quick_button.dart';
import '../../models/pos_touch_layout_profile.dart';
import '../../states/pos_layout_strategy.dart';
import '../pos_experience_manifest.dart';

/// Touch profile for table service and counter-service restaurant workflows.
const restaurantServiceTouchLayoutProfile = POSTouchLayoutProfile(
  id: 'restaurant_service_touch',
  label: 'Restaurant Service Touch',
  description:
      'Course-aware menu profile for tables, modifiers, split bills, and service flow.',
  productLine: 'Restaurant',
  preferredLayout: POSLayoutPreference.counter,
  density: POSTouchLayoutDensity.comfortable,
  orderPanelPlacement: POSTouchOrderPanelPlacement.right,
  catalogEmphasis: POSTouchCatalogEmphasis.menuFirst,
  minTileExtent: 104,
  maxGridColumns: 6,
  supportedFormFactors: [
    POSExperienceFormFactor.desktop,
    POSExperienceFormFactor.tablet,
  ],
  traits: ['table-service', 'course-aware', 'modifiers'],
  groups: [
    POSQuickButtonGroup(
      id: 'restaurant_menu',
      label: 'Menu',
      description: 'Course and menu section shortcuts for service teams.',
      surface: POSQuickButtonSurface.primaryGrid,
      buttons: [
        POSQuickButton(
          id: 'restaurant_starters',
          label: 'Starters',
          description: 'Open starters and small plates.',
          intent: POSQuickButtonIntent.category('starters'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'tapas',
          priority: 10,
        ),
        POSQuickButton(
          id: 'restaurant_mains',
          label: 'Mains',
          description: 'Open main course menu items.',
          intent: POSQuickButtonIntent.category('mains'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'restaurant',
          priority: 20,
        ),
        POSQuickButton(
          id: 'restaurant_modifiers',
          label: 'Mods',
          description: 'Open cooking, side, and allergy modifiers.',
          intent: POSQuickButtonIntent.modifierSet('service_modifiers'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'tune',
          priority: 30,
          requiredTraits: ['modifiers'],
        ),
        POSQuickButton(
          id: 'restaurant_fire_course',
          label: 'Fire',
          description: 'Send or fire the selected course.',
          intent: POSQuickButtonIntent.customFlow(targetId: 'fire_course'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'local_fire_department',
          priority: 40,
          requiredTraits: ['course-aware'],
        ),
      ],
    ),
    POSQuickButtonGroup(
      id: 'restaurant_commands',
      label: 'Service Commands',
      description: 'Table-service shortcuts for checks and guests.',
      surface: POSQuickButtonSurface.commandBar,
      buttons: [
        POSQuickButton(
          id: 'restaurant_table',
          label: 'Table',
          description: 'Attach or switch the active table.',
          intent: POSQuickButtonIntent.customFlow(targetId: 'select_table'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'table_restaurant',
          priority: 10,
        ),
        POSQuickButton(
          id: 'restaurant_split',
          label: 'Split',
          description: 'Open split check tools.',
          intent: POSQuickButtonIntent.customFlow(targetId: 'split_check'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'call_split',
          priority: 20,
        ),
        POSQuickButton(
          id: 'restaurant_payment',
          label: 'Pay',
          description: 'Open payment for the active check.',
          intent: POSQuickButtonIntent.commandAction('payment'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'payments',
          priority: 30,
        ),
      ],
    ),
  ],
);
