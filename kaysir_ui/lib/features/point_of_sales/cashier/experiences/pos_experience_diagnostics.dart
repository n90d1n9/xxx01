import '../states/pos_layout_provider.dart';
import '../utils/pos_command_actions.dart';
import '../utils/pos_shell_shortcuts.dart';
import 'pos_behavior_set.dart';
import 'pos_cart_behavior.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_behavior.dart';
import 'pos_commerce_channel_registry.dart';
import 'pos_data_contract.dart';
import 'pos_experience.dart';
import 'pos_experience_action_policy.dart';
import 'pos_experience_launch_checklist.dart';
import 'pos_experience_manifest.dart';
import 'pos_experience_registry.dart';
import 'pos_experience_screen_fit.dart';
import 'pos_feature_module.dart';
import 'pos_product_profile.dart';
import 'pos_product_runtime_pack.dart';

export 'pos_experience_screen_fit.dart';

class POSExperienceDiagnostics {
  final String requestedExperienceId;
  final POSExperience experience;
  final bool usedFallback;
  final String? fallbackReason;
  final double viewportWidth;
  final POSLayoutPreference layoutPreference;
  final POSLayoutStrategy resolvedLayout;
  final POSLayoutStrategySpec resolvedLayoutSpec;
  final POSProductRuntimePackResolution? runtimePackResolution;
  final List<POSProductRuntimePackRegistryIssue> runtimePackRegistryIssues;
  final List<POSProductRuntimePackIssue> runtimePackIssues;
  final List<POSLayoutStrategyRegistryIssue> layoutStrategyIssues;
  final List<POSLayoutStrategyRendererRegistryIssue> layoutRendererIssues;
  final POSExperienceManifest manifest;
  final POSExperienceScreenFitDiagnostic screenFit;
  final POSExperienceLaunchChecklist launchChecklist;
  final POSProductProfile? productProfile;
  final POSProductProfileValidationReport? productProfileValidationReport;
  final List<POSProductProfileIssue> productProfileCatalogIssues;
  final POSCommerceChannel? commerceChannel;
  final List<POSCommerceChannelRegistryIssue> commerceChannelRegistryIssues;
  final List<POSCommerceChannelBehaviorRegistryIssue>
  commerceChannelBehaviorRegistryIssues;
  final List<POSCommandActionRegistryIssue> commandActionRegistryIssues;
  final List<POSShellShortcutRegistryIssue> shortcutRegistryIssues;
  final List<POSDataTraitContract> dataContracts;
  final List<POSFeatureModule> modules;
  final List<POSCapabilityDiagnostic> capabilities;
  final List<POSActionDiagnostic> actions;
  final List<POSBehaviorDiagnostic> behaviors;
  final List<POSExperienceRegistryIssue> registryIssues;
  final POSExperienceReadinessDiagnostic readiness;

  const POSExperienceDiagnostics._({
    required this.requestedExperienceId,
    required this.experience,
    required this.usedFallback,
    required this.fallbackReason,
    required this.viewportWidth,
    required this.layoutPreference,
    required this.resolvedLayout,
    required this.resolvedLayoutSpec,
    required this.runtimePackResolution,
    required this.runtimePackRegistryIssues,
    required this.runtimePackIssues,
    required this.layoutStrategyIssues,
    required this.layoutRendererIssues,
    required this.manifest,
    required this.screenFit,
    required this.launchChecklist,
    required this.productProfile,
    required this.productProfileValidationReport,
    required this.productProfileCatalogIssues,
    required this.commerceChannel,
    required this.commerceChannelRegistryIssues,
    required this.commerceChannelBehaviorRegistryIssues,
    required this.commandActionRegistryIssues,
    required this.shortcutRegistryIssues,
    required this.dataContracts,
    required this.modules,
    required this.capabilities,
    required this.actions,
    required this.behaviors,
    required this.registryIssues,
    required this.readiness,
  });

  factory POSExperienceDiagnostics.from({
    required POSExperienceResolution resolution,
    required double viewportWidth,
    required POSLayoutPreference layoutPreference,
    required POSLayoutStrategy resolvedLayout,
    required List<POSExperienceRegistryIssue> registryIssues,
    POSProductRuntimePackResolution? runtimePackResolution,
    List<POSProductRuntimePackRegistryIssue> runtimePackRegistryIssues =
        const [],
    List<POSProductRuntimePackIssue> runtimePackIssues = const [],
    POSLayoutStrategyRegistry layoutStrategyRegistry =
        defaultPOSLayoutStrategyRegistry,
    List<POSLayoutStrategyRegistryIssue> layoutStrategyIssues = const [],
    List<POSLayoutStrategyRendererRegistryIssue> layoutRendererIssues =
        const [],
    POSProductProfile? productProfile,
    POSProductProfileValidationReport? productProfileValidationReport,
    POSExperienceLaunchChecklist? launchChecklist,
    POSCommerceChannel? commerceChannel,
    List<POSCommerceChannelRegistryIssue> commerceChannelRegistryIssues =
        const [],
    List<POSCommerceChannelBehaviorRegistryIssue>
        commerceChannelBehaviorRegistryIssues =
        const [],
    List<POSCommandActionRegistryIssue> commandActionRegistryIssues = const [],
    List<POSShellShortcutRegistryIssue> shortcutRegistryIssues = const [],
  }) {
    final experience = resolution.experience;
    final actions = _actionDiagnostics(
      experience,
      commerceChannel: commerceChannel,
    );
    final screenFit = POSExperienceScreenFitDiagnostic.from(
      viewportWidth: viewportWidth,
      manifest: experience.manifest,
    );
    final resolvedLaunchChecklist =
        launchChecklist ??
        productProfile?.launchChecklist ??
        POSExperienceLaunchChecklist.evaluate(experience: experience);
    final resolvedLayoutStrategyIssues =
        List<POSLayoutStrategyRegistryIssue>.unmodifiable(layoutStrategyIssues);
    final resolvedLayoutRendererIssues =
        List<POSLayoutStrategyRendererRegistryIssue>.unmodifiable(
          layoutRendererIssues,
        );
    final resolvedCommerceChannelRegistryIssues =
        List<POSCommerceChannelRegistryIssue>.unmodifiable(
          commerceChannelRegistryIssues,
        );
    final resolvedCommerceChannelBehaviorRegistryIssues =
        List<POSCommerceChannelBehaviorRegistryIssue>.unmodifiable(
          commerceChannelBehaviorRegistryIssues,
        );
    final resolvedCommandActionRegistryIssues =
        List<POSCommandActionRegistryIssue>.unmodifiable(
          commandActionRegistryIssues,
        );
    final resolvedShortcutRegistryIssues =
        List<POSShellShortcutRegistryIssue>.unmodifiable(
          shortcutRegistryIssues,
        );
    final resolvedProductProfileCatalogIssues =
        List<POSProductProfileIssue>.unmodifiable(
          _productProfileCatalogIssuesForDiagnostics(
            productProfileValidationReport,
            productProfile: productProfile,
          ),
        );
    final resolvedRuntimePackRegistryIssues =
        List<POSProductRuntimePackRegistryIssue>.unmodifiable(
          runtimePackRegistryIssues.where(
            _isRuntimePackRegistryIssueForDiagnostics,
          ),
        );
    final resolvedRuntimePackIssues =
        List<POSProductRuntimePackIssue>.unmodifiable(
          runtimePackIssues.where(_isRuntimePackIssueForDiagnostics),
        );

    return POSExperienceDiagnostics._(
      requestedExperienceId: resolution.requestedId,
      experience: experience,
      usedFallback: resolution.usedFallback,
      fallbackReason: resolution.fallbackReason,
      viewportWidth: viewportWidth,
      layoutPreference: layoutPreference,
      resolvedLayout: resolvedLayout,
      resolvedLayoutSpec: layoutStrategyRegistry.specForStrategy(
        resolvedLayout,
      ),
      runtimePackResolution: runtimePackResolution,
      runtimePackRegistryIssues: resolvedRuntimePackRegistryIssues,
      runtimePackIssues: resolvedRuntimePackIssues,
      layoutStrategyIssues: resolvedLayoutStrategyIssues,
      layoutRendererIssues: resolvedLayoutRendererIssues,
      manifest: experience.manifest,
      screenFit: screenFit,
      launchChecklist: resolvedLaunchChecklist,
      productProfile: productProfile,
      productProfileValidationReport: productProfileValidationReport,
      productProfileCatalogIssues: resolvedProductProfileCatalogIssues,
      commerceChannel: commerceChannel,
      commerceChannelRegistryIssues: resolvedCommerceChannelRegistryIssues,
      commerceChannelBehaviorRegistryIssues:
          resolvedCommerceChannelBehaviorRegistryIssues,
      commandActionRegistryIssues: resolvedCommandActionRegistryIssues,
      shortcutRegistryIssues: resolvedShortcutRegistryIssues,
      dataContracts: POSDataTraitContracts.forTraits(
        experience.manifest.dataTraits,
        extraContracts: productProfile?.extraDataContracts ?? const [],
      ),
      modules: List.unmodifiable(experience.modules),
      capabilities: _capabilityDiagnostics(experience.capabilities),
      actions: actions,
      behaviors: _behaviorDiagnostics(experience.behaviors),
      registryIssues: List.unmodifiable(registryIssues),
      readiness: POSExperienceReadinessDiagnostic.resolve(
        usedFallback: resolution.usedFallback,
        fallbackReason: resolution.fallbackReason,
        releaseStage: experience.manifest.releaseStage,
        runtimePackIssueCount:
            resolvedRuntimePackRegistryIssues.length +
            resolvedRuntimePackIssues.length +
            ((runtimePackResolution?.usedFallback ?? false) ? 1 : 0),
        registryIssues: registryIssues,
        productProfileCatalogIssueCount:
            resolvedProductProfileCatalogIssues.length,
        commerceChannelIssueCount:
            resolvedCommerceChannelRegistryIssues.length +
            resolvedCommerceChannelBehaviorRegistryIssues.length,
        commandActionIssueCount: resolvedCommandActionRegistryIssues.length,
        shortcutIssueCount: resolvedShortcutRegistryIssues.length,
        layoutIssueCount:
            resolvedLayoutStrategyIssues.length +
            resolvedLayoutRendererIssues.length,
        actions: actions,
        screenFit: screenFit,
        launchChecklist: resolvedLaunchChecklist,
        includeLaunchChecklist: productProfile != null,
      ),
    );
  }

  int get runtimeActionIssueCount {
    return actions.where((action) => action.missingRequiredModule).length;
  }

  int get runtimeScreenIssueCount => screenFit.supported ? 0 : 1;

  bool get runtimePackUsedFallback {
    return runtimePackResolution?.usedFallback ?? false;
  }

  String? get runtimePackFallbackReason {
    return runtimePackResolution?.fallbackReason;
  }

  int get runtimePackIssueCount {
    return runtimePackRegistryIssues.length +
        runtimePackIssues.length +
        (runtimePackUsedFallback ? 1 : 0);
  }

  String get runtimePackLabel {
    return runtimePackResolution?.pack.label ?? 'Not supplied';
  }

  String get runtimePackId {
    return runtimePackResolution?.pack.id ?? 'none';
  }

  String get runtimePackProductLine {
    return runtimePackResolution?.pack.productLine ?? 'Not supplied';
  }

  String get runtimePackDescription {
    return runtimePackResolution?.pack.description ??
        'No runtime pack supplied.';
  }

  String get runtimePackHealthLabel {
    if (runtimePackIssueCount > 0) {
      return '$runtimePackIssueCount issue${runtimePackIssueCount == 1 ? '' : 's'}';
    }

    return runtimePackResolution == null ? 'Not supplied' : 'Valid';
  }

  int get layoutIssueCount {
    return layoutStrategyIssues.length + layoutRendererIssues.length;
  }

  int get commerceChannelIssueCount {
    return commerceChannelRegistryIssues.length +
        commerceChannelBehaviorRegistryIssues.length;
  }

  int get commerceChannelBehaviorIssueCount {
    return commerceChannelBehaviorRegistryIssues.length;
  }

  int get productProfileCatalogIssueCount {
    return productProfileCatalogIssues.length;
  }

  int get commandActionIssueCount => commandActionRegistryIssues.length;

  int get shortcutIssueCount => shortcutRegistryIssues.length;

  bool get _registryReportsCurrentActionIssue {
    return registryIssues.any(
      (issue) =>
          issue.experienceId == experience.id &&
          issue.type ==
              POSExperienceRegistryIssueType.enabledCapabilityMissingModule,
    );
  }

  int get warningCount {
    final actionIssueCount =
        _registryReportsCurrentActionIssue ? 0 : runtimeActionIssueCount;
    final launchIssueCount =
        isProductProfileBacked ? _profileLaunchIssueCount : 0;
    final count =
        runtimePackIssueCount +
        registryIssues.length +
        productProfileCatalogIssueCount +
        commerceChannelIssueCount +
        commandActionIssueCount +
        shortcutIssueCount +
        layoutIssueCount +
        (usedFallback ? 1 : 0) +
        actionIssueCount +
        runtimeScreenIssueCount +
        launchIssueCount;

    if (count > 0) return count;
    return readiness.needsAttention ? 1 : 0;
  }

  bool get hasWarnings => warningCount > 0;

  String get statusLabel => readiness.label;

  bool get isProductProfileBacked => productProfile != null;

  String get productProfileLabel => productProfile?.label ?? 'Experience only';

  String get productProfileCatalogLabel {
    final report = productProfileValidationReport;
    if (report == null) return 'Not supplied';
    if (productProfileCatalogIssueCount > 0) {
      return '$productProfileCatalogIssueCount issue${productProfileCatalogIssueCount == 1 ? '' : 's'}';
    }

    return report.statusLabel;
  }

  String get commerceChannelLabel => commerceChannel?.label ?? 'No channel';

  String get commerceChannelLayoutLabel {
    return commerceChannel?.preferredLayout.label ?? 'Not selected';
  }

  int get _profileLaunchIssueCount {
    return launchChecklist.items
        .where((item) => item.status != POSLaunchCheckStatus.passed)
        .where((item) => item.area != POSLaunchCheckArea.registry)
        .where((item) => item.area != POSLaunchCheckArea.actions)
        .length;
  }

  String get layoutSummary {
    return '${layoutPreference.label} / ${resolvedLayout.label}';
  }

  String get layoutContractSummary {
    return '${resolvedLayoutSpec.label}: ${resolvedLayoutSpec.slotSummary}';
  }

  String get commerceChannelSummary {
    final channel = commerceChannel;
    if (channel == null) return 'No commerce channel selected.';

    return '${channel.label}: ${channel.description}';
  }
}

bool _isRuntimePackRegistryIssueForDiagnostics(
  POSProductRuntimePackRegistryIssue issue,
) {
  return issue.type != POSProductRuntimePackRegistryIssueType.packIssue;
}

bool _isRuntimePackIssueForDiagnostics(POSProductRuntimePackIssue issue) {
  switch (issue.type) {
    case POSProductRuntimePackIssueType.blankPackId:
    case POSProductRuntimePackIssueType.blankPackLabel:
    case POSProductRuntimePackIssueType.blankPackDescription:
      return true;
    case POSProductRuntimePackIssueType.productProfileCatalogIssue:
    case POSProductRuntimePackIssueType.commerceChannelRegistryIssue:
    case POSProductRuntimePackIssueType.commerceChannelBehaviorIssue:
    case POSProductRuntimePackIssueType.layoutStrategyIssue:
    case POSProductRuntimePackIssueType.layoutRendererIssue:
    case POSProductRuntimePackIssueType.touchLayoutProfileIssue:
    case POSProductRuntimePackIssueType.commandActionIssue:
    case POSProductRuntimePackIssueType.shortcutIssue:
      return false;
  }
}

List<POSProductProfileIssue> _productProfileCatalogIssuesForDiagnostics(
  POSProductProfileValidationReport? report, {
  required POSProductProfile? productProfile,
}) {
  if (report == null) return const [];

  return report.issues
      .where((issue) {
        if (issue.type == POSProductProfileIssueType.registryIssue) {
          return false;
        }

        final currentProfileId = productProfile?.id;
        final isCurrentProfileLaunchBlocker =
            issue.type == POSProductProfileIssueType.blockedLaunch &&
            currentProfileId != null &&
            issue.profileId == currentProfileId;
        if (isCurrentProfileLaunchBlocker) return false;

        return true;
      })
      .toList(growable: false);
}

enum POSExperienceReadinessLevel {
  ready,
  preview,
  experimental,
  screenMismatch,
  fallback,
  degraded,
  needsAttention,
}

class POSExperienceReadinessDiagnostic {
  final POSExperienceReadinessLevel level;
  final String label;
  final String message;

  const POSExperienceReadinessDiagnostic({
    required this.level,
    required this.label,
    required this.message,
  });

  factory POSExperienceReadinessDiagnostic.resolve({
    required bool usedFallback,
    required String? fallbackReason,
    required POSExperienceReleaseStage releaseStage,
    required int runtimePackIssueCount,
    required List<POSExperienceRegistryIssue> registryIssues,
    required int productProfileCatalogIssueCount,
    required int commerceChannelIssueCount,
    required int commandActionIssueCount,
    required int shortcutIssueCount,
    required int layoutIssueCount,
    required List<POSActionDiagnostic> actions,
    required POSExperienceScreenFitDiagnostic screenFit,
    required POSExperienceLaunchChecklist launchChecklist,
    required bool includeLaunchChecklist,
  }) {
    if (runtimePackIssueCount > 0) {
      return POSExperienceReadinessDiagnostic(
        level: POSExperienceReadinessLevel.needsAttention,
        label: 'Needs attention',
        message:
            '$runtimePackIssueCount runtime pack issue${runtimePackIssueCount == 1 ? '' : 's'} found before this mode can be considered release-ready.',
      );
    }

    if (registryIssues.isNotEmpty) {
      return POSExperienceReadinessDiagnostic(
        level: POSExperienceReadinessLevel.needsAttention,
        label: 'Needs attention',
        message:
            '${registryIssues.length} registry issue${registryIssues.length == 1 ? '' : 's'} found before this mode can be considered release-ready.',
      );
    }

    if (commerceChannelIssueCount > 0) {
      return POSExperienceReadinessDiagnostic(
        level: POSExperienceReadinessLevel.needsAttention,
        label: 'Needs attention',
        message:
            '$commerceChannelIssueCount commerce channel issue${commerceChannelIssueCount == 1 ? '' : 's'} found before this mode can be considered release-ready.',
      );
    }

    if (productProfileCatalogIssueCount > 0) {
      return POSExperienceReadinessDiagnostic(
        level: POSExperienceReadinessLevel.needsAttention,
        label: 'Needs attention',
        message:
            '$productProfileCatalogIssueCount product profile catalog issue${productProfileCatalogIssueCount == 1 ? '' : 's'} found before this mode can be considered release-ready.',
      );
    }

    if (layoutIssueCount > 0) {
      return POSExperienceReadinessDiagnostic(
        level: POSExperienceReadinessLevel.needsAttention,
        label: 'Needs attention',
        message:
            '$layoutIssueCount layout issue${layoutIssueCount == 1 ? '' : 's'} found before this mode can be considered release-ready.',
      );
    }

    if (commandActionIssueCount > 0) {
      return POSExperienceReadinessDiagnostic(
        level: POSExperienceReadinessLevel.needsAttention,
        label: 'Needs attention',
        message:
            '$commandActionIssueCount command action issue${commandActionIssueCount == 1 ? '' : 's'} found before this mode can be considered release-ready.',
      );
    }

    if (shortcutIssueCount > 0) {
      return POSExperienceReadinessDiagnostic(
        level: POSExperienceReadinessLevel.needsAttention,
        label: 'Needs attention',
        message:
            '$shortcutIssueCount shortcut issue${shortcutIssueCount == 1 ? '' : 's'} found before this mode can be considered release-ready.',
      );
    }

    if (usedFallback) {
      return POSExperienceReadinessDiagnostic(
        level: POSExperienceReadinessLevel.fallback,
        label: 'Default mode',
        message: fallbackReason ?? 'Default POS mode is active.',
      );
    }

    final missingModuleCount =
        actions.where((action) => action.missingRequiredModule).length;
    if (missingModuleCount > 0) {
      return POSExperienceReadinessDiagnostic(
        level: POSExperienceReadinessLevel.degraded,
        label: 'Degraded',
        message:
            '$missingModuleCount enabled action${missingModuleCount == 1 ? '' : 's'} missing required module support.',
      );
    }

    if (!screenFit.supported) {
      return POSExperienceReadinessDiagnostic(
        level: POSExperienceReadinessLevel.screenMismatch,
        label: 'Screen mismatch',
        message: screenFit.message,
      );
    }

    if (includeLaunchChecklist && launchChecklist.failureCount > 0) {
      return POSExperienceReadinessDiagnostic(
        level: POSExperienceReadinessLevel.needsAttention,
        label: 'Needs attention',
        message:
            '${launchChecklist.failureCount} launch blocker${launchChecklist.failureCount == 1 ? '' : 's'} must be resolved before this product profile is release-ready.',
      );
    }

    switch (releaseStage) {
      case POSExperienceReleaseStage.experimental:
        return const POSExperienceReadinessDiagnostic(
          level: POSExperienceReadinessLevel.experimental,
          label: 'Experimental',
          message:
              'Mode contract is valid, but this mode should stay behind controlled rollout.',
        );
      case POSExperienceReleaseStage.preview:
        return const POSExperienceReadinessDiagnostic(
          level: POSExperienceReadinessLevel.preview,
          label: 'Preview',
          message:
              'Mode contract is valid. Validate product-specific workflow before production rollout.',
        );
      case POSExperienceReleaseStage.stable:
        return const POSExperienceReadinessDiagnostic(
          level: POSExperienceReadinessLevel.ready,
          label: 'Ready',
          message:
              'Mode contract is valid and enabled actions are backed by modules.',
        );
    }
  }

  bool get needsAttention {
    switch (level) {
      case POSExperienceReadinessLevel.ready:
      case POSExperienceReadinessLevel.preview:
        return false;
      case POSExperienceReadinessLevel.experimental:
      case POSExperienceReadinessLevel.screenMismatch:
      case POSExperienceReadinessLevel.fallback:
      case POSExperienceReadinessLevel.degraded:
      case POSExperienceReadinessLevel.needsAttention:
        return true;
    }
  }
}

class POSCapabilityDiagnostic {
  final String label;
  final bool enabled;

  const POSCapabilityDiagnostic({required this.label, required this.enabled});
}

class POSBehaviorDiagnostic {
  final String label;
  final String summary;

  const POSBehaviorDiagnostic({required this.label, required this.summary});
}

class POSActionDiagnostic {
  final POSExperienceAction action;
  final String label;
  final bool capabilityEnabled;
  final bool moduleRegistered;
  final bool channelAllowed;
  final String requiredModuleId;
  final String? requiredChannelCapabilityLabel;

  const POSActionDiagnostic({
    required this.action,
    required this.label,
    required this.capabilityEnabled,
    required this.moduleRegistered,
    required this.channelAllowed,
    required this.requiredModuleId,
    this.requiredChannelCapabilityLabel,
  });

  bool get available => capabilityEnabled && moduleRegistered && channelAllowed;

  bool get missingRequiredModule {
    return capabilityEnabled && channelAllowed && !moduleRegistered;
  }

  String get statusLabel {
    if (available) return 'Available';
    if (!capabilityEnabled) return 'Capability off';
    if (!channelAllowed) return 'Channel off';
    return 'Missing module';
  }

  String get detailLabel {
    if (available) return 'Module $requiredModuleId';
    if (!capabilityEnabled) return 'Disabled by mode';
    if (!channelAllowed) {
      final capability = requiredChannelCapabilityLabel;
      if (capability == null || capability.isEmpty) {
        return 'Disabled by channel';
      }

      return 'Needs $capability';
    }

    return 'Needs $requiredModuleId';
  }
}

List<POSCapabilityDiagnostic> _capabilityDiagnostics(
  POSExperienceCapabilities capabilities,
) {
  return [
    POSCapabilityDiagnostic(
      label: 'Barcode scanning',
      enabled: capabilities.barcodeScanning,
    ),
    POSCapabilityDiagnostic(
      label: 'Customer selection',
      enabled: capabilities.customerSelection,
    ),
    POSCapabilityDiagnostic(
      label: 'Held orders',
      enabled: capabilities.heldOrders,
    ),
    POSCapabilityDiagnostic(
      label: 'Promotions',
      enabled: capabilities.promotions,
    ),
    POSCapabilityDiagnostic(label: 'Payments', enabled: capabilities.payments),
    POSCapabilityDiagnostic(
      label: 'New orders',
      enabled: capabilities.newOrders,
    ),
    POSCapabilityDiagnostic(
      label: 'Layout switching',
      enabled: capabilities.layoutSwitching,
    ),
  ];
}

List<POSActionDiagnostic> _actionDiagnostics(
  POSExperience experience, {
  POSCommerceChannel? commerceChannel,
}) {
  final policy = POSExperienceActionPolicy(
    experience: experience,
    commerceChannel: commerceChannel,
  );

  return POSExperienceAction.values
      .map((action) {
        final availability = policy.availability(action);
        return POSActionDiagnostic(
          action: action,
          label: availability.actionLabel,
          capabilityEnabled: availability.capabilityEnabled,
          moduleRegistered: availability.moduleRegistered,
          channelAllowed: availability.channelAllowed,
          requiredModuleId: availability.requiredModuleId,
          requiredChannelCapabilityLabel:
              availability.requiredChannelCapabilityLabel,
        );
      })
      .toList(growable: false);
}

List<POSBehaviorDiagnostic> _behaviorDiagnostics(POSBehaviorSet behaviors) {
  return [
    POSBehaviorDiagnostic(
      label: 'Catalog',
      summary: [
        behaviors.catalog.actionLabel,
        if (behaviors.catalog.requirePositivePrice) 'requires price',
        if (behaviors.catalog.requireStockOnHand) 'requires stock',
      ].join(' | '),
    ),
    POSBehaviorDiagnostic(
      label: 'Cart',
      summary: [
        _mergeStrategyLabel(behaviors.cart.mergeStrategy),
        'step ${behaviors.cart.quantityStep}',
        if (behaviors.cart.maxQuantityPerLine != null)
          'max ${behaviors.cart.maxQuantityPerLine}',
        if (behaviors.cart.limitQuantityToAvailableStock) 'stock capped',
      ].join(' | '),
    ),
    POSBehaviorDiagnostic(
      label: 'Checkout',
      summary: [
        behaviors.checkout.completeButtonLabel,
        behaviors.checkout.autoCompleteOnFinalPayment
            ? 'auto closes final payment'
            : 'manual closeout',
        if (behaviors.checkout.showReceiptAfterCompletion) 'receipt',
      ].join(' | '),
    ),
    POSBehaviorDiagnostic(
      label: 'Payment',
      summary: [
        behaviors.payment.defaultMethod,
        '${behaviors.payment.paymentMethods.length} methods',
        behaviors.payment.allowPartialPayments
            ? 'partial allowed'
            : 'final only',
      ].join(' | '),
    ),
    POSBehaviorDiagnostic(
      label: 'Sync',
      summary: behaviors.orderSync.policyLabels.join(' | '),
    ),
  ];
}

String _mergeStrategyLabel(POSLineMergeStrategy strategy) {
  switch (strategy) {
    case POSLineMergeStrategy.mergeByProduct:
      return 'merge by product';
    case POSLineMergeStrategy.alwaysNewLine:
      return 'new line per selection';
  }
}
