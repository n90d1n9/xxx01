import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_contract.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_trait.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_action_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_diagnostics.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_feature_module.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_command_actions.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_shell_shortcuts.dart';

void main() {
  test('diagnostics summarizes a preview POS experience', () {
    final diagnostics = POSExperienceDiagnostics.from(
      resolution: defaultPOSExperienceRegistry.resolveDetailed(
        quickCheckoutPOSExperience.id,
      ),
      viewportWidth: 900,
      layoutPreference: POSLayoutPreference.checkout,
      resolvedLayout: POSLayoutStrategy.checkout,
      registryIssues: const [],
      commerceChannel: defaultPOSCommerceChannelRegistry.channelForId(
        'web_store',
      ),
    );

    expect(diagnostics.experience, quickCheckoutPOSExperience);
    expect(diagnostics.statusLabel, 'Preview');
    expect(diagnostics.readiness.level, POSExperienceReadinessLevel.preview);
    expect(diagnostics.readiness.needsAttention, isFalse);
    expect(diagnostics.screenFit.formFactor, POSExperienceFormFactor.tablet);
    expect(diagnostics.screenFit.supported, isTrue);
    expect(diagnostics.warningCount, 0);
    expect(diagnostics.commerceChannelLabel, 'Web store');
    expect(diagnostics.commerceChannelLayoutLabel, 'Checkout');
    expect(
      diagnostics.commerceChannelSummary,
      contains('Owned online storefront'),
    );
    expect(diagnostics.layoutIssueCount, 0);
    expect(diagnostics.layoutStrategyIssues, isEmpty);
    expect(diagnostics.layoutRendererIssues, isEmpty);
    expect(diagnostics.layoutSummary, 'Checkout / Checkout');
    expect(diagnostics.resolvedLayoutSpec.id, 'checkout');
    expect(
      diagnostics.layoutContractSummary,
      'Checkout: Order + Checkout + Catalog',
    );
    expect(diagnostics.manifest.productLine, 'Kaysir Core');
    expect(diagnostics.manifest.archetypeKey, 'quick_sale');
    expect(diagnostics.manifest.releaseStage.label, 'Preview');
    expect(
      diagnostics.dataContracts.map((contract) => contract.traitKey),
      containsAll(['catalog', 'orders', 'payments']),
    );
    expect(
      diagnostics.modules.map((module) => module.id),
      containsAll(['catalog_browsing', 'cart_management', 'payments']),
    );
    expect(
      diagnostics.capabilities
          .where((capability) => !capability.enabled)
          .map((capability) => capability.label),
      containsAll(['Customer selection', 'Held orders', 'Promotions']),
    );
    expect(
      diagnostics.actions
          .where((action) => action.available)
          .map((action) => action.label),
      containsAll(['Scanning', 'Payments']),
    );
    expect(
      diagnostics.actions
          .where((action) => action.statusLabel == 'Capability off')
          .map((action) => action.label),
      containsAll(['Customer selection', 'Held orders', 'Promotions']),
    );
    expect(
      diagnostics.behaviors.map((behavior) => behavior.summary),
      contains('Quick add | requires price'),
    );
    expect(
      diagnostics.behaviors.map((behavior) => behavior.summary),
      contains('Batch 12 | Queued first | Keeps syncing | Auto after close'),
    );
  });

  test('diagnostics counts fallback and registry issues as warnings', () {
    const registryIssue = POSExperienceRegistryIssue(
      type: POSExperienceRegistryIssueType.duplicateExperienceId,
      experienceId: 'standard_cashier',
      message: 'Duplicate POS experience id "standard_cashier" found',
    );

    final diagnostics = POSExperienceDiagnostics.from(
      resolution: defaultPOSExperienceRegistry.resolveDetailed('unknown'),
      viewportWidth: 1280,
      layoutPreference: POSLayoutPreference.auto,
      resolvedLayout: POSLayoutStrategy.counter,
      registryIssues: const [registryIssue],
    );

    expect(diagnostics.experience, defaultPOSExperience);
    expect(diagnostics.usedFallback, isTrue);
    expect(diagnostics.statusLabel, 'Needs attention');
    expect(
      diagnostics.readiness.level,
      POSExperienceReadinessLevel.needsAttention,
    );
    expect(diagnostics.warningCount, 2);
    expect(diagnostics.fallbackReason, contains('not registered'));
    expect(diagnostics.readiness.message, contains('1 registry issue'));
  });

  test('diagnostics counts commerce channel issues as warnings', () {
    const channelIssue = POSCommerceChannelRegistryIssue(
      type: POSCommerceChannelRegistryIssueType.missingDefaultChannel,
      channelId: 'missing',
      message: 'Default POS commerce channel "missing" is not registered.',
    );

    final diagnostics = POSExperienceDiagnostics.from(
      resolution: defaultPOSExperienceRegistry.resolveDetailed(
        defaultPOSExperience.id,
      ),
      viewportWidth: 1280,
      layoutPreference: POSLayoutPreference.auto,
      resolvedLayout: POSLayoutStrategy.counter,
      registryIssues: const [],
      commerceChannelRegistryIssues: const [channelIssue],
    );

    expect(diagnostics.statusLabel, 'Needs attention');
    expect(diagnostics.commerceChannelIssueCount, 1);
    expect(diagnostics.warningCount, 1);
    expect(diagnostics.readiness.message, contains('commerce channel issue'));
  });

  test('diagnostics counts runtime pack issues as warnings', () {
    const registryIssue = POSProductRuntimePackRegistryIssue(
      type: POSProductRuntimePackRegistryIssueType.missingDefaultPack,
      packId: 'missing_pack',
      message:
          'Default POS product runtime pack "missing_pack" is not registered.',
    );
    final resolution = POSProductRuntimePackResolution(
      requestedId: 'missing_pack',
      pack: defaultPOSProductRuntimePack,
      usedFallback: true,
      fallbackReason:
          'POS product runtime pack "missing_pack" is not registered.',
    );

    final diagnostics = POSExperienceDiagnostics.from(
      resolution: defaultPOSExperienceRegistry.resolveDetailed(
        defaultPOSExperience.id,
      ),
      viewportWidth: 1280,
      layoutPreference: POSLayoutPreference.auto,
      resolvedLayout: POSLayoutStrategy.counter,
      registryIssues: const [],
      runtimePackResolution: resolution,
      runtimePackRegistryIssues: const [registryIssue],
    );

    expect(diagnostics.runtimePackLabel, 'Kaysir Core POS');
    expect(diagnostics.runtimePackId, 'kaysir_core');
    expect(diagnostics.runtimePackUsedFallback, isTrue);
    expect(diagnostics.runtimePackIssueCount, 2);
    expect(diagnostics.runtimePackHealthLabel, '2 issues');
    expect(diagnostics.statusLabel, 'Needs attention');
    expect(diagnostics.readiness.message, contains('2 runtime pack issues'));
    expect(diagnostics.warningCount, 2);
  });

  test('diagnostics counts product profile catalog issues as warnings', () {
    const catalogIssue = POSProductProfileIssue(
      type: POSProductProfileIssueType.blankProfileId,
      message: 'POS product profile id cannot be blank',
    );
    const validationReport = POSProductProfileValidationReport(
      issues: [catalogIssue],
      profileCount: 1,
      launchableCount: 1,
      blockedCount: 0,
    );

    final diagnostics = POSExperienceDiagnostics.from(
      resolution: defaultPOSExperienceRegistry.resolveDetailed(
        defaultPOSExperience.id,
      ),
      viewportWidth: 1280,
      layoutPreference: POSLayoutPreference.auto,
      resolvedLayout: POSLayoutStrategy.counter,
      registryIssues: const [],
      productProfileValidationReport: validationReport,
    );

    expect(diagnostics.statusLabel, 'Needs attention');
    expect(
      diagnostics.readiness.level,
      POSExperienceReadinessLevel.needsAttention,
    );
    expect(
      diagnostics.readiness.message,
      contains('1 product profile catalog issue'),
    );
    expect(diagnostics.productProfileCatalogLabel, '1 issue');
    expect(diagnostics.productProfileCatalogIssueCount, 1);
    expect(diagnostics.productProfileCatalogIssues, const [catalogIssue]);
    expect(diagnostics.warningCount, 1);
  });

  test(
    'diagnostics counts layout strategy and renderer issues as warnings',
    () {
      const strategyIssue = POSLayoutStrategyRegistryIssue(
        type: POSLayoutStrategyRegistryIssueType.emptySlots,
        strategyId: 'checkout',
        message:
            'POS layout strategy "Checkout" must declare at least one slot.',
      );
      const rendererIssue = POSLayoutStrategyRendererRegistryIssue(
        type: POSLayoutStrategyRendererRegistryIssueType.missingRenderer,
        strategy: POSLayoutStrategy.checkout,
        message: 'No POS layout renderer registered for checkout.',
      );

      final diagnostics = POSExperienceDiagnostics.from(
        resolution: defaultPOSExperienceRegistry.resolveDetailed(
          defaultPOSExperience.id,
        ),
        viewportWidth: 1280,
        layoutPreference: POSLayoutPreference.checkout,
        resolvedLayout: POSLayoutStrategy.checkout,
        registryIssues: const [],
        layoutStrategyIssues: const [strategyIssue],
        layoutRendererIssues: const [rendererIssue],
      );

      expect(diagnostics.statusLabel, 'Needs attention');
      expect(
        diagnostics.readiness.level,
        POSExperienceReadinessLevel.needsAttention,
      );
      expect(diagnostics.readiness.message, contains('2 layout issues'));
      expect(diagnostics.layoutIssueCount, 2);
      expect(diagnostics.warningCount, 2);
    },
  );

  test('diagnostics counts shortcut registry issues as warnings', () {
    const shortcutIssue = POSShellShortcutRegistryIssue(
      type: POSShellShortcutRegistryIssueType.duplicateShortcutActivator,
      shortcutId: 'F6',
      message: 'Duplicate POS shell shortcut binding "F6" found.',
    );

    final diagnostics = POSExperienceDiagnostics.from(
      resolution: defaultPOSExperienceRegistry.resolveDetailed(
        defaultPOSExperience.id,
      ),
      viewportWidth: 1280,
      layoutPreference: POSLayoutPreference.auto,
      resolvedLayout: POSLayoutStrategy.counter,
      registryIssues: const [],
      shortcutRegistryIssues: const [shortcutIssue],
    );

    expect(diagnostics.statusLabel, 'Needs attention');
    expect(
      diagnostics.readiness.level,
      POSExperienceReadinessLevel.needsAttention,
    );
    expect(diagnostics.readiness.message, contains('1 shortcut issue'));
    expect(diagnostics.shortcutIssueCount, 1);
    expect(diagnostics.warningCount, 1);
  });

  test('diagnostics counts command action registry issues as warnings', () {
    const commandIssue = POSCommandActionRegistryIssue(
      type: POSCommandActionRegistryIssueType.duplicateActionId,
      actionId: 'scan',
      message: 'Duplicate POS command action id "scan" found.',
    );

    final diagnostics = POSExperienceDiagnostics.from(
      resolution: defaultPOSExperienceRegistry.resolveDetailed(
        defaultPOSExperience.id,
      ),
      viewportWidth: 1280,
      layoutPreference: POSLayoutPreference.auto,
      resolvedLayout: POSLayoutStrategy.counter,
      registryIssues: const [],
      commandActionRegistryIssues: const [commandIssue],
    );

    expect(diagnostics.statusLabel, 'Needs attention');
    expect(
      diagnostics.readiness.level,
      POSExperienceReadinessLevel.needsAttention,
    );
    expect(diagnostics.readiness.message, contains('1 command action issue'));
    expect(diagnostics.commandActionIssueCount, 1);
    expect(diagnostics.warningCount, 1);
  });

  test('diagnostics reports missing modules for enabled actions', () {
    final misconfigured = defaultPOSExperience.copyWith(
      modules:
          defaultPOSExperience.modules
              .where((module) => module.id != POSFeatureModules.payments.id)
              .toList(),
    );
    final diagnostics = POSExperienceDiagnostics.from(
      resolution: POSExperienceResolution(
        requestedId: misconfigured.id,
        experience: misconfigured,
        usedFallback: false,
      ),
      viewportWidth: 1280,
      layoutPreference: POSLayoutPreference.auto,
      resolvedLayout: POSLayoutStrategy.counter,
      registryIssues: const [],
    );

    final paymentAction = diagnostics.actions.singleWhere(
      (action) => action.action == POSExperienceAction.payments,
    );

    expect(paymentAction.capabilityEnabled, isTrue);
    expect(paymentAction.moduleRegistered, isFalse);
    expect(paymentAction.available, isFalse);
    expect(paymentAction.statusLabel, 'Missing module');
    expect(paymentAction.detailLabel, 'Needs payments');
    expect(diagnostics.statusLabel, 'Degraded');
    expect(diagnostics.runtimeActionIssueCount, 1);
    expect(diagnostics.warningCount, 1);
    expect(diagnostics.readiness.level, POSExperienceReadinessLevel.degraded);
  });

  test('diagnostics reports channel-restricted actions without warnings', () {
    final diagnostics = POSExperienceDiagnostics.from(
      resolution: defaultPOSExperienceRegistry.resolveDetailed(
        defaultPOSExperience.id,
      ),
      viewportWidth: 1280,
      layoutPreference: POSLayoutPreference.auto,
      resolvedLayout: POSLayoutStrategy.counter,
      registryIssues: const [],
      commerceChannel: defaultPOSCommerceChannelRegistry.channelForId(
        'marketplace',
      ),
    );

    final paymentAction = diagnostics.actions.singleWhere(
      (action) => action.action == POSExperienceAction.payments,
    );

    expect(paymentAction.capabilityEnabled, isTrue);
    expect(paymentAction.moduleRegistered, isTrue);
    expect(paymentAction.channelAllowed, isFalse);
    expect(paymentAction.available, isFalse);
    expect(paymentAction.statusLabel, 'Channel off');
    expect(paymentAction.detailLabel, 'Needs Payments');
    expect(diagnostics.runtimeActionIssueCount, 0);
    expect(diagnostics.warningCount, 0);
    expect(diagnostics.statusLabel, 'Ready');
  });

  test('diagnostics marks experimental modes as attention signals', () {
    final experimental = defaultPOSExperience.copyWith(
      id: 'experimental_counter',
      manifest: defaultPOSExperience.manifest.copyWith(
        releaseStage: POSExperienceReleaseStage.experimental,
      ),
    );
    final diagnostics = POSExperienceDiagnostics.from(
      resolution: POSExperienceResolution(
        requestedId: experimental.id,
        experience: experimental,
        usedFallback: false,
      ),
      viewportWidth: 1280,
      layoutPreference: POSLayoutPreference.auto,
      resolvedLayout: POSLayoutStrategy.counter,
      registryIssues: const [],
    );

    expect(diagnostics.statusLabel, 'Experimental');
    expect(
      diagnostics.readiness.level,
      POSExperienceReadinessLevel.experimental,
    );
    expect(diagnostics.readiness.needsAttention, isTrue);
    expect(diagnostics.warningCount, 1);
  });

  test('diagnostics warns when the runtime screen is not supported', () {
    final diagnostics = POSExperienceDiagnostics.from(
      resolution: defaultPOSExperienceRegistry.resolveDetailed(
        quickCheckoutPOSExperience.id,
      ),
      viewportWidth: 1280,
      layoutPreference: POSLayoutPreference.checkout,
      resolvedLayout: POSLayoutStrategy.checkout,
      registryIssues: const [],
    );

    expect(diagnostics.screenFit.formFactor, POSExperienceFormFactor.desktop);
    expect(diagnostics.screenFit.supported, isFalse);
    expect(diagnostics.screenFit.statusLabel, 'Unsupported');
    expect(diagnostics.screenFit.supportedFormFactorLabel, contains('Kiosk'));
    expect(diagnostics.statusLabel, 'Screen mismatch');
    expect(
      diagnostics.readiness.level,
      POSExperienceReadinessLevel.screenMismatch,
    );
    expect(diagnostics.runtimeScreenIssueCount, 1);
    expect(diagnostics.warningCount, 1);
  });

  test('diagnostics uses product profile launch blockers when supplied', () {
    final mode = defaultPOSExperience.copyWith(
      id: 'profile_blocked',
      manifest: defaultPOSExperience.manifest.copyWith(
        dataTraits: const [POSDataTraitKeys.modifierGroups],
      ),
    );
    final profile = POSProductProfile(
      id: 'blocked_profile',
      label: 'Blocked Profile',
      description: 'Profile with an incomplete modifier adapter.',
      recipe: POSExperienceRecipe.fromExperience(mode),
      experienceOverride: mode,
      dataAdapters: const [
        POSDataTraitAdapter(
          id: 'incomplete_menu_api',
          label: 'Incomplete Menu API',
          fieldsByTrait: {
            POSDataTraitKeys.modifierGroups: ['group_id', 'option_id'],
          },
        ),
      ],
    );
    final diagnostics = POSExperienceDiagnostics.from(
      resolution: POSExperienceResolution(
        requestedId: mode.id,
        experience: mode,
        usedFallback: false,
      ),
      viewportWidth: 1280,
      layoutPreference: POSLayoutPreference.auto,
      resolvedLayout: POSLayoutStrategy.counter,
      registryIssues: const [],
      productProfile: profile,
    );

    expect(diagnostics.productProfileLabel, 'Blocked Profile');
    expect(diagnostics.isProductProfileBacked, isTrue);
    expect(diagnostics.launchChecklist.canLaunch, isFalse);
    expect(diagnostics.statusLabel, 'Needs attention');
    expect(diagnostics.readiness.message, contains('launch blocker'));
    expect(diagnostics.warningCount, 1);
  });

  test('runtime form factor resolver follows POS breakpoints', () {
    expect(resolvePOSRuntimeFormFactor(719), POSExperienceFormFactor.mobile);
    expect(resolvePOSRuntimeFormFactor(720), POSExperienceFormFactor.tablet);
    expect(resolvePOSRuntimeFormFactor(1119), POSExperienceFormFactor.tablet);
    expect(resolvePOSRuntimeFormFactor(1120), POSExperienceFormFactor.desktop);
  });
}
