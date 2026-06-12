import '../../inventory/models/inventory_product_catalog.dart';
import 'product_availability_rule_authoring.dart';
import 'product_catalog_quality.dart';
import 'product_channel_launch_priority.dart';
import 'management_pack.dart';
import 'management_module_brief.dart';
import 'management_suite_destination.dart';
import 'product_module_contribution_activation_summary.dart';
import 'product_module_contribution_manifest.dart';
import 'product_module_contribution_registry_health_summary.dart';
import 'product_workspace_action_contribution.dart';
import 'product_workspace_action_group.dart';
import 'product_workspace_action_summary.dart';
import 'product_workspace_recommendation.dart';
import 'sales_channel_strategy_brief.dart';
import 'product_workspace_setup_readiness_contribution.dart';

/// Types of extension output contributed by product management modules.
enum ProductManagementPackContributionKind {
  workspaceAction,
  setupReadiness,
  recommendation,
  moduleBriefAction,
  availabilityTemplate,
}

/// Normalized contribution metadata shown in pack contract surfaces.
class ProductManagementPackContributionSummary {
  ProductManagementPackContributionSummary({
    required this.id,
    required this.kind,
    required this.title,
    required this.detailLabel,
    required this.statusLabel,
    required this.isActive,
    required this.outputCount,
    List<String> outputLabels = const [],
    this.sourceId,
    this.sourceTitle,
  }) : outputLabels = List.unmodifiable(outputLabels);

  final String id;
  final ProductManagementPackContributionKind kind;
  final String title;
  final String detailLabel;
  final String statusLabel;
  final bool isActive;
  final int outputCount;
  final List<String> outputLabels;
  final String? sourceId;
  final String? sourceTitle;

  bool get hasSource {
    final normalizedTitle = sourceTitle?.trim();
    return normalizedTitle != null && normalizedTitle.isNotEmpty;
  }

  String get kindLabel {
    return kind.label;
  }

  String get sourceLabel {
    if (!hasSource) return 'Unassigned module';

    return sourceTitle!.trim();
  }

  String get provenanceLabel {
    if (!hasSource) return kindLabel;

    return '$kindLabel | $sourceLabel';
  }

  String get outputPreviewLabel {
    if (!isActive) return detailLabel;
    if (outputLabels.isEmpty) return detailLabel;
    if (outputLabels.length == 1) return outputLabels.first;

    return '${outputLabels.first} +${outputLabels.length - 1} more';
  }
}

extension ProductManagementPackContributionKindLabels
    on ProductManagementPackContributionKind {
  String get label {
    switch (this) {
      case ProductManagementPackContributionKind.workspaceAction:
        return 'Workspace action';
      case ProductManagementPackContributionKind.setupReadiness:
        return 'Setup readiness';
      case ProductManagementPackContributionKind.recommendation:
        return 'Recommendation';
      case ProductManagementPackContributionKind.moduleBriefAction:
        return 'Module brief action';
      case ProductManagementPackContributionKind.availabilityTemplate:
        return 'Availability template';
    }
  }

  String get pluralLabel {
    switch (this) {
      case ProductManagementPackContributionKind.workspaceAction:
        return 'Workspace actions';
      case ProductManagementPackContributionKind.setupReadiness:
        return 'Setup readiness';
      case ProductManagementPackContributionKind.recommendation:
        return 'Recommendations';
      case ProductManagementPackContributionKind.moduleBriefAction:
        return 'Module brief actions';
      case ProductManagementPackContributionKind.availabilityTemplate:
        return 'Availability templates';
    }
  }
}

/// Aggregates all active and registered contributions for one management pack.
class ProductManagementPackContributionBundle {
  ProductManagementPackContributionBundle({
    required this.managementPack,
    required List<ProductWorkspaceActionGroup> workspaceActionGroups,
    required List<ProductManagementPackContributionSummary> actionContributions,
    List<ProductManagementPackContributionSummary> setupReadinessContributions =
        const [],
    required List<ProductManagementPackContributionSummary>
    recommendationContributions,
    List<ProductManagementPackContributionSummary> moduleBriefContributions =
        const [],
    List<ProductManagementPackContributionSummary>
        availabilityTemplateContributions =
        const [],
    List<ProductModuleContributionActivationSummary> moduleActivationSummaries =
        const [],
    List<ProductModuleContributionIgnoredManifestDiagnostic>
        ignoredManifestDiagnostics =
        const [],
    List<ProductModuleContributionDuplicateHookDiagnostic>
        duplicateHookDiagnostics =
        const [],
  }) : workspaceActionGroups = List.unmodifiable(workspaceActionGroups),
       actionContributions = List.unmodifiable(actionContributions),
       setupReadinessContributions = List.unmodifiable(
         setupReadinessContributions,
       ),
       recommendationContributions = List.unmodifiable(
         recommendationContributions,
       ),
       moduleBriefContributions = List.unmodifiable(moduleBriefContributions),
       availabilityTemplateContributions = List.unmodifiable(
         availabilityTemplateContributions,
       ),
       moduleActivationSummaries = List.unmodifiable(moduleActivationSummaries),
       ignoredManifestDiagnostics = List.unmodifiable(
         ignoredManifestDiagnostics,
       ),
       duplicateHookDiagnostics = List.unmodifiable(duplicateHookDiagnostics);

  final ProductManagementPack managementPack;
  final List<ProductWorkspaceActionGroup> workspaceActionGroups;
  final List<ProductManagementPackContributionSummary> actionContributions;
  final List<ProductManagementPackContributionSummary>
  setupReadinessContributions;
  final List<ProductManagementPackContributionSummary>
  recommendationContributions;
  final List<ProductManagementPackContributionSummary> moduleBriefContributions;
  final List<ProductManagementPackContributionSummary>
  availabilityTemplateContributions;
  final List<ProductModuleContributionActivationSummary>
  moduleActivationSummaries;
  final List<ProductModuleContributionIgnoredManifestDiagnostic>
  ignoredManifestDiagnostics;
  final List<ProductModuleContributionDuplicateHookDiagnostic>
  duplicateHookDiagnostics;

  List<ProductManagementPackContributionSummary> get moduleContributions {
    return List.unmodifiable([
      ...actionContributions,
      ...setupReadinessContributions,
      ...recommendationContributions,
      ...moduleBriefContributions,
      ...availabilityTemplateContributions,
    ]);
  }

  List<ProductManagementPackContributionSummary> get activeModuleContributions {
    return List.unmodifiable(
      moduleContributions.where((contribution) => contribution.isActive),
    );
  }

  List<ProductManagementPackField> get requiredFields {
    return managementPack.requiredFields;
  }

  List<ProductManagementPackField> get optionalFields {
    return List.unmodifiable(
      managementPack.fields.where((field) => !field.required),
    );
  }

  int get fieldCount => managementPack.fields.length;
  int get requiredFieldCount => requiredFields.length;
  int get capabilityCount => managementPack.capabilities.length;
  int get profilePackCount => managementPack.profilePacks.length;
  int get workspaceActionGroupCount => workspaceActionGroups.length;
  int get moduleContributionCount => moduleContributions.length;
  int get activeModuleContributionCount => activeModuleContributions.length;

  ProductModuleContributionRegistryHealthSummary
  get moduleRegistryHealthSummary {
    return ProductModuleContributionRegistryHealthSummary.fromDiagnostics(
      ignoredManifestDiagnostics: ignoredManifestDiagnostics,
      duplicateHookDiagnostics: duplicateHookDiagnostics,
    );
  }

  int get moduleRegistryDiagnosticCount =>
      moduleRegistryHealthSummary.issueCount;

  bool get hasActiveModuleContributions => activeModuleContributionCount > 0;
  bool get hasIgnoredManifestDiagnostics =>
      ignoredManifestDiagnostics.isNotEmpty;
  bool get hasDuplicateHookDiagnostics => duplicateHookDiagnostics.isNotEmpty;
  bool get hasModuleRegistryDiagnostics =>
      moduleRegistryHealthSummary.hasIssues;

  String get subtitleLabel {
    return '${managementPack.title} | ${managementPack.businessModelLabel} | '
        '${managementPack.operatorFocusLabel}';
  }

  String get fieldCountLabel => _countLabel(fieldCount, 'field');
  String get requiredFieldCountLabel {
    return _countLabel(requiredFieldCount, 'required field');
  }

  String get capabilityCountLabel {
    return _countLabel(capabilityCount, 'capability', 'capabilities');
  }

  String get profilePackCountLabel {
    return _countLabel(profilePackCount, 'channel pack');
  }

  String get workspaceActionGroupCountLabel {
    return _countLabel(workspaceActionGroupCount, 'workspace group');
  }

  String get moduleContributionStatusLabel {
    if (moduleContributionCount == 0) return 'No extension hooks';

    return '$activeModuleContributionCount/$moduleContributionCount '
        'active hooks';
  }

  String get duplicateHookDiagnosticCountLabel {
    return _countLabel(duplicateHookDiagnostics.length, 'duplicate hook');
  }

  String get ignoredManifestDiagnosticCountLabel {
    return _countLabel(ignoredManifestDiagnostics.length, 'ignored manifest');
  }

  String get moduleRegistryDiagnosticCountLabel {
    return moduleRegistryHealthSummary.countLabel;
  }
}

/// Builds the contribution bundle for the active pack workspace context.
ProductManagementPackContributionBundle
buildProductManagementPackContributionBundle({
  required ProductManagementPack managementPack,
  required InventoryProductCatalogSummary summary,
  required ProductCatalogQualitySummary qualitySummary,
  required ProductWorkspaceActionSummary actionSummary,
  required ProductSalesChannelStrategyBrief strategyBrief,
  required List<ProductWorkspaceActionGroup> workspaceActionGroups,
  ProductChannelLaunchPriority? primaryLaunchPriority,
  List<ProductWorkspaceActionContribution> actionContributions = const [],
  ProductWorkspaceSetupReadinessContributionBundle?
  setupReadinessContributionBundle,
  List<ProductWorkspaceRecommendationContribution> recommendationContributions =
      const [],
  ProductModuleContributionRegistry? moduleContributionRegistry,
}) {
  final activeSetupTargetIds = {
    for (final contribution in actionContributions)
      for (final target in contribution.setupTargetsFor(managementPack))
        target.normalizedId,
  };
  final recommendationContext = ProductWorkspaceRecommendationContext(
    managementPack: managementPack,
    summary: summary,
    qualitySummary: qualitySummary,
    actionSummary: actionSummary,
    strategyBrief: strategyBrief,
    primaryLaunchPriority: primaryLaunchPriority,
  );
  final moduleBriefResolvers =
      moduleContributionRegistry?.moduleBriefResolvers ??
      const <ProductManagementModuleBriefResolver>[];
  final activeModuleBriefResolvers =
      moduleContributionRegistry?.moduleBriefResolversFor(managementPack) ??
      const <ProductManagementModuleBriefResolver>[];

  return ProductManagementPackContributionBundle(
    managementPack: managementPack,
    workspaceActionGroups: workspaceActionGroups,
    actionContributions: [
      for (final contribution in actionContributions)
        _summarizeActionContribution(
          contribution: contribution,
          managementPack: managementPack,
          summary: summary,
          source: moduleContributionRegistry?.sourceForActionContribution(
            contribution.normalizedId,
          ),
        ),
    ],
    setupReadinessContributions: [
      for (final contribution
          in setupReadinessContributionBundle?.contributions ??
              const <ProductWorkspaceSetupReadinessContribution>[])
        _summarizeSetupReadinessContribution(
          contribution: contribution,
          activeSetupTargetIds: activeSetupTargetIds,
          source: moduleContributionRegistry
              ?.sourceForSetupReadinessContribution(contribution.normalizedId),
        ),
    ],
    recommendationContributions: [
      for (final contribution in recommendationContributions)
        _summarizeRecommendationContribution(
          contribution: contribution,
          context: recommendationContext,
          source: moduleContributionRegistry
              ?.sourceForRecommendationContribution(contribution.normalizedId),
        ),
    ],
    moduleBriefContributions: [
      for (final resolver in moduleBriefResolvers)
        _summarizeModuleBriefResolver(
          resolver: resolver,
          isActive: activeModuleBriefResolvers.any(
            (activeResolver) => identical(activeResolver, resolver),
          ),
          source: moduleContributionRegistry?.sourceForModuleBriefResolver(
            resolver,
          ),
        ),
    ],
    availabilityTemplateContributions: [
      for (final contribution
          in moduleContributionRegistry
                  ?.availabilityRuleTemplateContributions ??
              const <ProductAvailabilityRuleTemplateContribution>[])
        _summarizeAvailabilityTemplateContribution(
          contribution: contribution,
          managementPack: managementPack,
          source: moduleContributionRegistry
              ?.sourceForAvailabilityRuleTemplateContribution(
                contribution.normalizedId,
              ),
        ),
    ],
    moduleActivationSummaries:
        moduleContributionRegistry?.activationSummariesFor(managementPack) ??
        const [],
    ignoredManifestDiagnostics:
        moduleContributionRegistry?.ignoredManifestDiagnostics ?? const [],
    duplicateHookDiagnostics:
        moduleContributionRegistry?.duplicateHookDiagnostics ?? const [],
  );
}

ProductManagementPackContributionSummary _summarizeModuleBriefResolver({
  required ProductManagementModuleBriefResolver resolver,
  required bool isActive,
  ProductModuleContributionSource? source,
}) {
  final destination = productModuleDestinationForSuiteDestination(
    resolver.destination,
  );
  final destinationTitle =
      destination?.title ?? _readableContributionId(resolver.destination.name);
  final title = _moduleBriefResolverTitle(
    resolver: resolver,
    destinationTitle: destinationTitle,
  );
  final detailLabel = _moduleBriefResolverDetail(
    resolver: resolver,
    isActive: isActive,
  );

  return ProductManagementPackContributionSummary(
    id: _normalizedContributionId(resolver.contributionId),
    kind: ProductManagementPackContributionKind.moduleBriefAction,
    title: title,
    detailLabel: detailLabel,
    statusLabel: isActive ? 'Active' : 'Inactive',
    isActive: isActive,
    outputCount: isActive ? 1 : 0,
    outputLabels: [destinationTitle],
    sourceId: source?.id,
    sourceTitle: source?.title,
  );
}

String _moduleBriefResolverTitle({
  required ProductManagementModuleBriefResolver resolver,
  required String destinationTitle,
}) {
  if (resolver.hasTitle) return resolver.title.trim();

  return '$destinationTitle brief action';
}

String _moduleBriefResolverDetail({
  required ProductManagementModuleBriefResolver resolver,
  required bool isActive,
}) {
  if (!isActive) return 'Pack inactive';
  if (resolver.hasDescription) return resolver.description.trim();

  return 'Overrides suite next action';
}

ProductManagementPackContributionSummary _summarizeSetupReadinessContribution({
  required ProductWorkspaceSetupReadinessContribution contribution,
  required Set<String> activeSetupTargetIds,
  ProductModuleContributionSource? source,
}) {
  final isActive = contribution.coversAnyTarget(activeSetupTargetIds);
  final targetIds = contribution.normalizedTargetIds;
  final outputLabels =
      targetIds.isEmpty
          ? [_readableContributionId(contribution.id)]
          : targetIds.map(_readableContributionId).toList();

  return ProductManagementPackContributionSummary(
    id: contribution.normalizedId,
    kind: ProductManagementPackContributionKind.setupReadiness,
    title: _readableContributionId(contribution.id),
    detailLabel: _setupReadinessContributionDetail(
      contribution: contribution,
      isActive: isActive,
    ),
    statusLabel: isActive ? 'Monitoring' : 'Inactive',
    isActive: isActive,
    outputCount: isActive ? outputLabels.length : 0,
    outputLabels: outputLabels,
    sourceId: source?.id,
    sourceTitle: source?.title,
  );
}

ProductManagementPackContributionSummary _summarizeActionContribution({
  required ProductWorkspaceActionContribution contribution,
  required ProductManagementPack managementPack,
  required InventoryProductCatalogSummary summary,
  ProductModuleContributionSource? source,
}) {
  final isActive = contribution.isActiveFor(managementPack);
  final groups = contribution.groupsFor(managementPack, summary);
  final shortcutCount = groups.fold<int>(
    0,
    (total, group) => total + group.shortcutCount,
  );
  final outputLabels = groups.map((group) => group.title).toList();

  return ProductManagementPackContributionSummary(
    id: contribution.normalizedId,
    kind: ProductManagementPackContributionKind.workspaceAction,
    title:
        outputLabels.isEmpty
            ? _readableContributionId(contribution.id)
            : outputLabels.first,
    detailLabel:
        isActive
            ? _actionContributionDetail(shortcutCount, groups.length)
            : 'Pack capability inactive',
    statusLabel:
        isActive ? (shortcutCount == 0 ? 'Listening' : 'Active') : 'Inactive',
    isActive: isActive,
    outputCount: shortcutCount,
    outputLabels: outputLabels,
    sourceId: source?.id,
    sourceTitle: source?.title,
  );
}

ProductManagementPackContributionSummary _summarizeRecommendationContribution({
  required ProductWorkspaceRecommendationContribution contribution,
  required ProductWorkspaceRecommendationContext context,
  ProductModuleContributionSource? source,
}) {
  final isActive = contribution.isActiveFor(context);
  final recommendations =
      isActive
          ? contribution.recommendationsFor(context)
          : const <ProductWorkspaceRecommendation>[];
  final outputLabels =
      recommendations
          .map<String>((recommendation) => recommendation.title)
          .toList();

  return ProductManagementPackContributionSummary(
    id: contribution.normalizedId,
    kind: ProductManagementPackContributionKind.recommendation,
    title:
        outputLabels.isEmpty
            ? _readableContributionId(contribution.id)
            : outputLabels.first,
    detailLabel:
        isActive
            ? _recommendationContributionDetail(recommendations.length)
            : 'Pack capability inactive',
    statusLabel:
        isActive
            ? (recommendations.isEmpty ? 'Listening' : 'Active')
            : 'Inactive',
    isActive: isActive,
    outputCount: recommendations.length,
    outputLabels: outputLabels,
    sourceId: source?.id,
    sourceTitle: source?.title,
  );
}

ProductManagementPackContributionSummary
_summarizeAvailabilityTemplateContribution({
  required ProductAvailabilityRuleTemplateContribution contribution,
  required ProductManagementPack managementPack,
  ProductModuleContributionSource? source,
}) {
  final isActive = contribution.isActiveFor(managementPack);
  final templates = contribution.templatesFor(managementPack);
  final outputLabels = templates.map((template) => template.title).toList();

  return ProductManagementPackContributionSummary(
    id: contribution.normalizedId,
    kind: ProductManagementPackContributionKind.availabilityTemplate,
    title: contribution.titleLabel,
    detailLabel:
        isActive
            ? _availabilityTemplateContributionDetail(templates.length)
            : 'Pack capability inactive',
    statusLabel:
        isActive ? (templates.isEmpty ? 'Listening' : 'Active') : 'Inactive',
    isActive: isActive,
    outputCount: templates.length,
    outputLabels: outputLabels,
    sourceId: source?.id,
    sourceTitle: source?.title,
  );
}

String _setupReadinessContributionDetail({
  required ProductWorkspaceSetupReadinessContribution contribution,
  required bool isActive,
}) {
  if (!isActive) return 'Pack setup target inactive';
  if (!contribution.hasTargetScope) return 'Evaluator registry hook';

  return '${_countLabel(contribution.normalizedTargetIds.length, 'setup target')} '
      'monitored';
}

String _actionContributionDetail(int shortcutCount, int groupCount) {
  if (shortcutCount == 0) return 'Ready when matching actions appear';

  return '${_countLabel(shortcutCount, 'action')} across '
      '${_countLabel(groupCount, 'group')}';
}

String _recommendationContributionDetail(int recommendationCount) {
  if (recommendationCount == 0) {
    return 'Ready when matching gaps appear';
  }

  return _countLabel(recommendationCount, 'recommended step');
}

String _availabilityTemplateContributionDetail(int templateCount) {
  if (templateCount == 0) return 'Ready when matching templates appear';

  return _countLabel(templateCount, 'template');
}

String _normalizedContributionId(String id) {
  return id.trim();
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}

String _readableContributionId(String id) {
  final words =
      id
          .split(RegExp(r'[_\-\s]+'))
          .where((part) => part.trim().isNotEmpty)
          .toList();
  if (words.isEmpty) return id;

  return words.map(_capitalize).join(' ');
}

String _capitalize(String value) {
  if (value.isEmpty) return value;

  return '${value[0].toUpperCase()}${value.substring(1)}';
}
