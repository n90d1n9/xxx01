import 'pos_commerce_channel.dart';
import 'pos_experience.dart';

enum POSExperienceAction {
  barcodeScanning,
  customerSelection,
  heldOrders,
  promotions,
  payments,
  newOrders,
  layoutSwitching,
}

class POSExperienceActionAvailability {
  final POSExperienceAction action;
  final bool capabilityEnabled;
  final bool moduleRegistered;
  final String actionLabel;
  final String requiredModuleId;
  final String experienceLabel;
  final bool channelAllowed;
  final String channelLabel;
  final String? requiredChannelCapabilityLabel;

  const POSExperienceActionAvailability({
    required this.action,
    required this.capabilityEnabled,
    required this.moduleRegistered,
    required this.actionLabel,
    required this.requiredModuleId,
    required this.experienceLabel,
    this.channelAllowed = true,
    this.channelLabel = '',
    this.requiredChannelCapabilityLabel,
  });

  bool get allowed => capabilityEnabled && moduleRegistered && channelAllowed;

  String get unsupportedMessage {
    if (!capabilityEnabled) {
      return '$actionLabel is not enabled for $experienceLabel mode';
    }

    if (!moduleRegistered) {
      return '$actionLabel is unavailable for $experienceLabel mode because module "$requiredModuleId" is not registered';
    }

    if (!channelAllowed) {
      return '$actionLabel is not supported for $channelLabel channel';
    }

    return '$actionLabel is available for $experienceLabel mode';
  }
}

class POSExperienceActionPolicy {
  final POSExperience experience;
  final POSCommerceChannel? commerceChannel;

  const POSExperienceActionPolicy({
    required this.experience,
    this.commerceChannel,
  });

  bool allows(POSExperienceAction action) {
    return availability(action).allowed;
  }

  POSExperienceActionAvailability availability(POSExperienceAction action) {
    final actionLabel = _actionLabel(action);
    final requiredModuleId = _requiredModuleId(action);
    final requiredChannelCapability = channelCapabilityFor(action);
    final channel = commerceChannel;

    return POSExperienceActionAvailability(
      action: action,
      capabilityEnabled: capabilityAllows(action),
      moduleRegistered: _hasModule(requiredModuleId),
      actionLabel: actionLabel,
      requiredModuleId: requiredModuleId,
      experienceLabel: experience.label,
      channelAllowed: channelAllows(action),
      channelLabel: channel?.label ?? '',
      requiredChannelCapabilityLabel: requiredChannelCapability?.label,
    );
  }

  bool capabilityAllows(POSExperienceAction action) {
    final capabilities = experience.capabilities;

    switch (action) {
      case POSExperienceAction.barcodeScanning:
        return capabilities.barcodeScanning;
      case POSExperienceAction.customerSelection:
        return capabilities.customerSelection;
      case POSExperienceAction.heldOrders:
        return capabilities.heldOrders;
      case POSExperienceAction.promotions:
        return capabilities.promotions;
      case POSExperienceAction.payments:
        return capabilities.payments;
      case POSExperienceAction.newOrders:
        return capabilities.newOrders;
      case POSExperienceAction.layoutSwitching:
        return capabilities.layoutSwitching;
    }
  }

  bool channelAllows(POSExperienceAction action) {
    final channel = commerceChannel;
    if (channel == null) return true;

    final requiredCapability = channelCapabilityFor(action);
    if (requiredCapability == null) return true;

    return channel.supportsCapability(requiredCapability);
  }

  POSCommerceChannelCapability? channelCapabilityFor(
    POSExperienceAction action,
  ) {
    switch (action) {
      case POSExperienceAction.customerSelection:
        return POSCommerceChannelCapability.customerIdentity;
      case POSExperienceAction.promotions:
        return POSCommerceChannelCapability.promotions;
      case POSExperienceAction.payments:
        return POSCommerceChannelCapability.payments;
      case POSExperienceAction.barcodeScanning:
      case POSExperienceAction.heldOrders:
      case POSExperienceAction.newOrders:
      case POSExperienceAction.layoutSwitching:
        return null;
    }
  }

  String unsupportedMessage(POSExperienceAction action) {
    return availability(action).unsupportedMessage;
  }

  bool _hasModule(String moduleId) {
    return experience.modules.any((module) => module.id.trim() == moduleId);
  }

  String _actionLabel(POSExperienceAction action) {
    switch (action) {
      case POSExperienceAction.barcodeScanning:
        return 'Scanning';
      case POSExperienceAction.customerSelection:
        return 'Customer selection';
      case POSExperienceAction.heldOrders:
        return 'Held orders';
      case POSExperienceAction.promotions:
        return 'Promotions';
      case POSExperienceAction.payments:
        return 'Payments';
      case POSExperienceAction.newOrders:
        return 'New orders';
      case POSExperienceAction.layoutSwitching:
        return 'Layout switching';
    }
  }

  String _requiredModuleId(POSExperienceAction action) {
    switch (action) {
      case POSExperienceAction.barcodeScanning:
        return 'barcode_scanning';
      case POSExperienceAction.customerSelection:
        return 'customer_selection';
      case POSExperienceAction.heldOrders:
        return 'held_orders';
      case POSExperienceAction.promotions:
        return 'promotions';
      case POSExperienceAction.payments:
        return 'payments';
      case POSExperienceAction.newOrders:
        return 'new_orders';
      case POSExperienceAction.layoutSwitching:
        return 'layout_switching';
    }
  }
}
