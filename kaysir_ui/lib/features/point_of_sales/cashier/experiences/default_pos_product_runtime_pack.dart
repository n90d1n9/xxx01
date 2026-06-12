import '../utils/pos_command_actions.dart';
import '../utils/pos_shell_shortcuts.dart';
import '../widgets/pos_layout_strategy_pack.dart';
import 'default_pos_commerce_channel_behaviors.dart';
import 'default_pos_commerce_channels.dart';
import 'default_pos_product_profiles.dart';
import 'pos_product_runtime_pack.dart';

final defaultPOSProductRuntimePack = POSProductRuntimePack(
  id: 'kaysir_core',
  label: 'Kaysir Core POS',
  description:
      'Shared Kaysir point-of-sale runtime for cashier, checkout, assisted service, and ecommerce profiles.',
  productLine: 'Kaysir Core',
  productProfileCatalog: defaultPOSProductProfileCatalog,
  commerceChannelRegistry: defaultPOSCommerceChannelRegistry,
  commerceChannelBehaviorRegistry: defaultPOSCommerceChannelBehaviorRegistry,
  layoutStrategyPack: defaultPOSLayoutStrategyPack,
  commandActionRegistry: defaultPOSCommandActionRegistry,
  shortcutRegistry: defaultPOSShellShortcutRegistry,
);

final defaultPOSProductRuntimePackRegistry = POSProductRuntimePackRegistry(
  defaultPackId: defaultPOSProductRuntimePack.id,
  packs: [defaultPOSProductRuntimePack],
);
