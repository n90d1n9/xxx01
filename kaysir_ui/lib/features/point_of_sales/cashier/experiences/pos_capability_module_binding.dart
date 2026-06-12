import 'pos_experience_action_policy.dart';
import 'pos_feature_module.dart';

class POSCapabilityModuleBinding {
  final POSExperienceAction action;
  final String capabilityLabel;
  final POSFeatureModule module;

  const POSCapabilityModuleBinding({
    required this.action,
    required this.capabilityLabel,
    required this.module,
  });
}

abstract final class POSCapabilityModuleBindings {
  static const all = [
    POSCapabilityModuleBinding(
      action: POSExperienceAction.barcodeScanning,
      capabilityLabel: 'Barcode scanning',
      module: POSFeatureModules.barcodeScanning,
    ),
    POSCapabilityModuleBinding(
      action: POSExperienceAction.customerSelection,
      capabilityLabel: 'Customer selection',
      module: POSFeatureModules.customerSelection,
    ),
    POSCapabilityModuleBinding(
      action: POSExperienceAction.heldOrders,
      capabilityLabel: 'Held orders',
      module: POSFeatureModules.heldOrders,
    ),
    POSCapabilityModuleBinding(
      action: POSExperienceAction.promotions,
      capabilityLabel: 'Promotions',
      module: POSFeatureModules.promotions,
    ),
    POSCapabilityModuleBinding(
      action: POSExperienceAction.payments,
      capabilityLabel: 'Payments',
      module: POSFeatureModules.payments,
    ),
    POSCapabilityModuleBinding(
      action: POSExperienceAction.newOrders,
      capabilityLabel: 'New orders',
      module: POSFeatureModules.newOrders,
    ),
    POSCapabilityModuleBinding(
      action: POSExperienceAction.layoutSwitching,
      capabilityLabel: 'Layout switching',
      module: POSFeatureModules.layoutSwitching,
    ),
  ];
}
