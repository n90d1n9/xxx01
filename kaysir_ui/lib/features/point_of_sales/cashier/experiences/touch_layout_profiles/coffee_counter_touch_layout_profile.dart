import '../../models/pos_quick_button.dart';
import '../../models/pos_touch_layout_profile.dart';
import '../../states/pos_layout_strategy.dart';
import '../pos_experience_manifest.dart';

/// Touch profile for quick-service coffee, tea, pastry, and add-on modifiers.
const coffeeCounterTouchLayoutProfile = POSTouchLayoutProfile(
  id: 'coffee_counter_touch',
  label: 'Coffee Counter Touch',
  description:
      'Menu-board profile for drink categories, add-ons, and quick tendering.',
  productLine: 'Coffee Shop',
  preferredLayout: POSLayoutPreference.checkout,
  density: POSTouchLayoutDensity.spacious,
  orderPanelPlacement: POSTouchOrderPanelPlacement.right,
  catalogEmphasis: POSTouchCatalogEmphasis.menuFirst,
  minTileExtent: 112,
  maxGridColumns: 5,
  supportedFormFactors: [
    POSExperienceFormFactor.desktop,
    POSExperienceFormFactor.tablet,
  ],
  traits: ['menu-first', 'modifiers', 'quick-service'],
  groups: [
    POSQuickButtonGroup(
      id: 'coffee_menu',
      label: 'Menu',
      description: 'Drink and pastry menu shortcuts for coffee counters.',
      surface: POSQuickButtonSurface.primaryGrid,
      buttons: [
        POSQuickButton(
          id: 'coffee_espresso',
          label: 'Espresso',
          description: 'Open espresso-based drinks.',
          intent: POSQuickButtonIntent.category('espresso'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'coffee',
          priority: 10,
        ),
        POSQuickButton(
          id: 'coffee_cold_bar',
          label: 'Cold Bar',
          description: 'Open iced drinks and cold brew options.',
          intent: POSQuickButtonIntent.category('cold_bar'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'ac_unit',
          priority: 20,
        ),
        POSQuickButton(
          id: 'coffee_pastry',
          label: 'Pastry',
          description: 'Open pastry and bakery add-on items.',
          intent: POSQuickButtonIntent.category('pastry'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'bakery_dining',
          priority: 30,
        ),
        POSQuickButton(
          id: 'coffee_milk_mods',
          label: 'Milk',
          description: 'Open milk and alternative milk modifiers.',
          intent: POSQuickButtonIntent.modifierSet('milk_options'),
          surface: POSQuickButtonSurface.primaryGrid,
          iconKey: 'local_cafe',
          priority: 40,
          requiredTraits: ['modifiers'],
        ),
      ],
    ),
    POSQuickButtonGroup(
      id: 'coffee_commands',
      label: 'Counter Commands',
      description: 'Shortcuts for quick-service coffee checkout.',
      surface: POSQuickButtonSurface.commandBar,
      buttons: [
        POSQuickButton(
          id: 'coffee_new_order',
          label: 'New',
          description: 'Start a fresh coffee order.',
          intent: POSQuickButtonIntent.commandAction('new_order'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'add_shopping_cart',
          priority: 10,
        ),
        POSQuickButton(
          id: 'coffee_name_order',
          label: 'Name',
          description: 'Attach a customer name to the order.',
          intent: POSQuickButtonIntent.customerAction('name_order'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'badge',
          priority: 20,
        ),
        POSQuickButton(
          id: 'coffee_payment',
          label: 'Pay',
          description: 'Open payment for quick coffee checkout.',
          intent: POSQuickButtonIntent.commandAction('payment'),
          surface: POSQuickButtonSurface.commandBar,
          iconKey: 'payments',
          priority: 30,
        ),
      ],
    ),
  ],
);
