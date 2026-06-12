import 'management_pack.dart';
import 'product_module_contribution_activation_summary.dart';
import 'product_availability_rule_authoring.dart';
import 'management_module_brief.dart';
import 'product_workspace_action_contribution.dart';
import 'product_workspace_recommendation.dart';
import 'product_workspace_setup_readiness_contribution.dart';

/// Predicate used by contribution manifests to opt into selected packs.
typedef ProductModuleContributionPredicate =
    bool Function(ProductManagementPack pack);

/// Declarative contribution point for product-management behavior modules.
class ProductModuleContributionManifest {
  const ProductModuleContributionManifest({
    required this.id,
    required this.title,
    required this.description,
    this.isActive,
    this.activeReasonLabel,
    this.inactiveReasonLabel,
    this.actionContributions = const [],
    this.setupReadinessContributions = const [],
    this.recommendationContributions = const [],
    this.moduleBriefResolvers = const [],
    this.availabilityRuleTemplateContributions = const [],
  });

  final String id;
  final String title;
  final String description;
  final ProductModuleContributionPredicate? isActive;
  final String? activeReasonLabel;
  final String? inactiveReasonLabel;
  final List<ProductWorkspaceActionContribution> actionContributions;
  final List<ProductWorkspaceSetupReadinessContribution>
  setupReadinessContributions;
  final List<ProductWorkspaceRecommendationContribution>
  recommendationContributions;
  final List<ProductManagementModuleBriefResolver> moduleBriefResolvers;
  final List<ProductAvailabilityRuleTemplateContribution>
  availabilityRuleTemplateContributions;

  String get normalizedId => id.trim();

  String get titleLabel {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isNotEmpty) return normalizedTitle;
    if (normalizedId.isNotEmpty) return _readableModuleId(normalizedId);

    return 'Untitled module';
  }

  String get descriptionLabel => description.trim();

  bool isActiveFor(ProductManagementPack pack) {
    return isActive?.call(pack) ?? true;
  }

  String activationReasonFor(ProductManagementPack pack) {
    if (isActiveFor(pack)) {
      return _normalizedLabel(
        activeReasonLabel,
        fallback: 'Enabled for ${pack.title}',
      );
    }

    return _normalizedLabel(
      inactiveReasonLabel,
      fallback: 'Not enabled for ${pack.title}',
    );
  }

  bool get hasContributions {
    return actionContributions.isNotEmpty ||
        setupReadinessContributions.isNotEmpty ||
        recommendationContributions.isNotEmpty ||
        moduleBriefResolvers.isNotEmpty ||
        availabilityRuleTemplateContributions.isNotEmpty;
  }
}

String _normalizedLabel(String? value, {required String fallback}) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return fallback;

  return normalized;
}

/// Source metadata attached to each contribution exposed by a module manifest.
class ProductModuleContributionSource {
  const ProductModuleContributionSource({
    required this.id,
    required this.title,
    required this.description,
  });

  factory ProductModuleContributionSource.fromManifest(
    ProductModuleContributionManifest manifest,
  ) {
    return ProductModuleContributionSource(
      id: manifest.normalizedId,
      title: manifest.titleLabel,
      description: manifest.descriptionLabel,
    );
  }

  final String id;
  final String title;
  final String description;

  String get normalizedId => id.trim();

  String get titleLabel {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isNotEmpty) return normalizedTitle;
    if (normalizedId.isNotEmpty) return _readableModuleId(normalizedId);

    return 'Untitled module';
  }

  String get descriptionLabel => description.trim();
}

/// Hook family used by module contribution registry diagnostics.
enum ProductModuleContributionHookKind {
  action,
  setupReadiness,
  recommendation,
  moduleBriefAction,
  availabilityTemplate,
}

extension ProductModuleContributionHookKindLabels
    on ProductModuleContributionHookKind {
  String get label {
    return switch (this) {
      ProductModuleContributionHookKind.action => 'Workspace action',
      ProductModuleContributionHookKind.setupReadiness => 'Setup readiness',
      ProductModuleContributionHookKind.recommendation => 'Recommendation',
      ProductModuleContributionHookKind.moduleBriefAction =>
        'Module brief action',
      ProductModuleContributionHookKind.availabilityTemplate =>
        'Availability template',
    };
  }
}

/// Priority level used to triage product module registry diagnostics.
enum ProductModuleContributionDiagnosticSeverity {
  info,
  warning,
  error;

  String get label {
    return switch (this) {
      ProductModuleContributionDiagnosticSeverity.info => 'Info',
      ProductModuleContributionDiagnosticSeverity.warning => 'Warning',
      ProductModuleContributionDiagnosticSeverity.error => 'Error',
    };
  }

  int get sortRank {
    return switch (this) {
      ProductModuleContributionDiagnosticSeverity.error => 0,
      ProductModuleContributionDiagnosticSeverity.warning => 1,
      ProductModuleContributionDiagnosticSeverity.info => 2,
    };
  }
}

/// Registry diagnostic emitted when multiple modules reuse one hook ID.
class ProductModuleContributionDuplicateHookDiagnostic {
  ProductModuleContributionDuplicateHookDiagnostic({
    required this.kind,
    required this.hookId,
    required List<ProductModuleContributionSource> sources,
  }) : sources = List.unmodifiable(sources);

  final ProductModuleContributionHookKind kind;
  final String hookId;
  final List<ProductModuleContributionSource> sources;

  int get occurrenceCount => sources.length;
  String get kindLabel => kind.label;
  String get occurrenceCountLabel => _countLabel(occurrenceCount, 'source');
  ProductModuleContributionDiagnosticSeverity get severity =>
      ProductModuleContributionDiagnosticSeverity.warning;
  String get severityLabel => severity.label;

  String get sourceLabel {
    return sources.map((source) => source.titleLabel).join(', ');
  }

  String get message {
    return '$kindLabel "$hookId" is registered by $sourceLabel';
  }

  String get resolutionGuidance {
    return 'Give "$hookId" a unique ${kindLabel.toLowerCase()} id in all but '
        'one module, or consolidate the shared behavior into a single module.';
  }
}

/// Reason a module contribution manifest was ignored while merging.
enum ProductModuleContributionIgnoredManifestReason { blankId, duplicateId }

extension ProductModuleContributionIgnoredManifestReasonLabels
    on ProductModuleContributionIgnoredManifestReason {
  String get label {
    return switch (this) {
      ProductModuleContributionIgnoredManifestReason.blankId =>
        'Blank module id',
      ProductModuleContributionIgnoredManifestReason.duplicateId =>
        'Duplicate module id',
    };
  }
}

/// Registry diagnostic emitted when a manifest cannot be registered.
class ProductModuleContributionIgnoredManifestDiagnostic {
  const ProductModuleContributionIgnoredManifestDiagnostic({
    required this.reason,
    required this.source,
    this.existingSource,
  });

  final ProductModuleContributionIgnoredManifestReason reason;
  final ProductModuleContributionSource source;
  final ProductModuleContributionSource? existingSource;

  String get reasonLabel => reason.label;
  ProductModuleContributionDiagnosticSeverity get severity =>
      ProductModuleContributionDiagnosticSeverity.error;
  String get severityLabel => severity.label;

  String get manifestLabel {
    final sourceId = source.normalizedId;
    if (sourceId.isNotEmpty) return sourceId;

    return source.titleLabel;
  }

  String get message {
    return switch (reason) {
      ProductModuleContributionIgnoredManifestReason.blankId =>
        '${source.titleLabel} was ignored because its module id is blank.',
      ProductModuleContributionIgnoredManifestReason.duplicateId =>
        '${source.titleLabel} was ignored because ${existingSource?.titleLabel ?? 'another module'} '
            'already registered "${source.normalizedId}".',
    };
  }

  String get resolutionGuidance {
    return switch (reason) {
      ProductModuleContributionIgnoredManifestReason.blankId =>
        'Set a stable non-empty manifest id before registering ${source.titleLabel}.',
      ProductModuleContributionIgnoredManifestReason.duplicateId =>
        'Rename ${source.titleLabel} or merge it with '
            '${existingSource?.titleLabel ?? 'the existing module'} so every module '
            'manifest id stays unique.',
    };
  }
}

/// Registry that merges product module manifests and exposes typed hooks.
class ProductModuleContributionRegistry {
  factory ProductModuleContributionRegistry.fromManifests(
    List<ProductModuleContributionManifest> manifests,
  ) {
    final mergeResult = _mergeManifests(manifests);

    return ProductModuleContributionRegistry._(
      manifests: mergeResult.manifests,
      ignoredManifestDiagnostics: mergeResult.ignoredDiagnostics,
    );
  }

  const ProductModuleContributionRegistry._({
    required this.manifests,
    required this.ignoredManifestDiagnostics,
  });

  final List<ProductModuleContributionManifest> manifests;
  final List<ProductModuleContributionIgnoredManifestDiagnostic>
  ignoredManifestDiagnostics;

  bool get isEmpty => manifests.isEmpty;
  bool get isNotEmpty => manifests.isNotEmpty;
  int get manifestCount => manifests.length;
  int get ignoredManifestCount => ignoredManifestDiagnostics.length;
  bool get hasIgnoredManifestDiagnostics =>
      ignoredManifestDiagnostics.isNotEmpty;

  String get ignoredManifestDiagnosticCountLabel {
    return _countLabel(ignoredManifestDiagnostics.length, 'ignored manifest');
  }

  List<String> get manifestIds {
    return List.unmodifiable(
      manifests.map((manifest) => manifest.normalizedId),
    );
  }

  List<ProductModuleContributionDuplicateHookDiagnostic>
  get duplicateHookDiagnostics {
    return _buildDuplicateHookDiagnostics(manifests);
  }

  bool get hasDuplicateHookDiagnostics => duplicateHookDiagnostics.isNotEmpty;

  String get duplicateHookDiagnosticCountLabel {
    return _countLabel(duplicateHookDiagnostics.length, 'duplicate hook');
  }

  List<ProductWorkspaceActionContribution> get actionContributions {
    return List.unmodifiable([
      for (final manifest in manifests) ...manifest.actionContributions,
    ]);
  }

  List<ProductWorkspaceSetupReadinessContribution>
  get setupReadinessContributions {
    return List.unmodifiable([
      for (final manifest in manifests) ...manifest.setupReadinessContributions,
    ]);
  }

  List<ProductWorkspaceRecommendationContribution>
  get recommendationContributions {
    return List.unmodifiable([
      for (final manifest in manifests) ...manifest.recommendationContributions,
    ]);
  }

  List<ProductManagementModuleBriefResolver> get moduleBriefResolvers {
    return List.unmodifiable([
      for (final manifest in manifests) ...manifest.moduleBriefResolvers,
    ]);
  }

  List<ProductAvailabilityRuleTemplateContribution>
  get availabilityRuleTemplateContributions {
    return List.unmodifiable([
      for (final manifest in manifests)
        ...manifest.availabilityRuleTemplateContributions,
    ]);
  }

  List<ProductModuleContributionManifest> activeManifestsFor(
    ProductManagementPack pack,
  ) {
    return List.unmodifiable(
      manifests.where((manifest) => manifest.isActiveFor(pack)),
    );
  }

  List<ProductManagementModuleBriefResolver> moduleBriefResolversFor(
    ProductManagementPack pack,
  ) {
    return List.unmodifiable([
      for (final manifest in activeManifestsFor(pack))
        ...manifest.moduleBriefResolvers,
    ]);
  }

  List<ProductModuleContributionActivationSummary> activationSummariesFor(
    ProductManagementPack pack,
  ) {
    return List.unmodifiable([
      for (final manifest in manifests)
        ProductModuleContributionActivationSummary(
          id: manifest.normalizedId,
          title: manifest.titleLabel,
          description: manifest.descriptionLabel,
          isActive: manifest.isActiveFor(pack),
          reasonLabel: manifest.activationReasonFor(pack),
          actionContributionCount: manifest.actionContributions.length,
          setupReadinessContributionCount:
              manifest.setupReadinessContributions.length,
          recommendationContributionCount:
              manifest.recommendationContributions.length,
          moduleBriefResolverCount: manifest.moduleBriefResolvers.length,
          availabilityTemplateContributionCount:
              manifest.availabilityRuleTemplateContributions.length,
        ),
    ]);
  }

  ProductModuleContributionSource? sourceForActionContribution(
    String contributionId,
  ) {
    return _sourceForContribution(
      contributionId: contributionId,
      contributionIdsFor:
          (manifest) => manifest.actionContributions.map(
            (contribution) => contribution.normalizedId,
          ),
    );
  }

  ProductModuleContributionSource? sourceForSetupReadinessContribution(
    String contributionId,
  ) {
    return _sourceForContribution(
      contributionId: contributionId,
      contributionIdsFor:
          (manifest) => manifest.setupReadinessContributions.map(
            (contribution) => contribution.normalizedId,
          ),
    );
  }

  ProductModuleContributionSource? sourceForRecommendationContribution(
    String contributionId,
  ) {
    return _sourceForContribution(
      contributionId: contributionId,
      contributionIdsFor:
          (manifest) => manifest.recommendationContributions.map(
            (contribution) => contribution.normalizedId,
          ),
    );
  }

  ProductModuleContributionSource? sourceForModuleBriefResolver(
    ProductManagementModuleBriefResolver resolver,
  ) {
    final resolverId = resolver.id.trim();
    if (resolverId.isNotEmpty) {
      for (final manifest in manifests) {
        for (final candidate in manifest.moduleBriefResolvers) {
          if (candidate.contributionId.trim() == resolverId) {
            return ProductModuleContributionSource.fromManifest(manifest);
          }
        }
      }
    }

    for (final manifest in manifests) {
      for (final candidate in manifest.moduleBriefResolvers) {
        if (identical(candidate, resolver)) {
          return ProductModuleContributionSource.fromManifest(manifest);
        }
      }
    }

    for (final manifest in manifests) {
      for (final candidate in manifest.moduleBriefResolvers) {
        if (candidate.destination == resolver.destination) {
          return ProductModuleContributionSource.fromManifest(manifest);
        }
      }
    }

    return null;
  }

  ProductModuleContributionSource?
  sourceForAvailabilityRuleTemplateContribution(String contributionId) {
    return _sourceForContribution(
      contributionId: contributionId,
      contributionIdsFor:
          (manifest) => manifest.availabilityRuleTemplateContributions.map(
            (contribution) => contribution.normalizedId,
          ),
    );
  }

  ProductModuleContributionSource? _sourceForContribution({
    required String contributionId,
    required Iterable<String> Function(
      ProductModuleContributionManifest manifest,
    )
    contributionIdsFor,
  }) {
    final normalizedId = contributionId.trim();
    if (normalizedId.isEmpty) return null;

    for (final manifest in manifests) {
      for (final id in contributionIdsFor(manifest)) {
        if (id.trim() == normalizedId) {
          return ProductModuleContributionSource.fromManifest(manifest);
        }
      }
    }

    return null;
  }
}

_ProductModuleContributionManifestMergeResult _mergeManifests(
  List<ProductModuleContributionManifest> manifests,
) {
  final seenIds = <String>{};
  final sourceById = <String, ProductModuleContributionSource>{};
  final merged = <ProductModuleContributionManifest>[];
  final ignoredDiagnostics =
      <ProductModuleContributionIgnoredManifestDiagnostic>[];

  for (final manifest in manifests) {
    final normalizedId = manifest.normalizedId;
    final source = ProductModuleContributionSource.fromManifest(manifest);

    if (normalizedId.isEmpty) {
      ignoredDiagnostics.add(
        ProductModuleContributionIgnoredManifestDiagnostic(
          reason: ProductModuleContributionIgnoredManifestReason.blankId,
          source: source,
        ),
      );
      continue;
    }

    if (seenIds.contains(normalizedId)) {
      ignoredDiagnostics.add(
        ProductModuleContributionIgnoredManifestDiagnostic(
          reason: ProductModuleContributionIgnoredManifestReason.duplicateId,
          source: source,
          existingSource: sourceById[normalizedId],
        ),
      );
      continue;
    }

    seenIds.add(normalizedId);
    sourceById[normalizedId] = source;
    merged.add(manifest);
  }

  return _ProductModuleContributionManifestMergeResult(
    manifests: List.unmodifiable(merged),
    ignoredDiagnostics: List.unmodifiable(ignoredDiagnostics),
  );
}

class _ProductModuleContributionManifestMergeResult {
  const _ProductModuleContributionManifestMergeResult({
    required this.manifests,
    required this.ignoredDiagnostics,
  });

  final List<ProductModuleContributionManifest> manifests;
  final List<ProductModuleContributionIgnoredManifestDiagnostic>
  ignoredDiagnostics;
}

List<ProductModuleContributionDuplicateHookDiagnostic>
_buildDuplicateHookDiagnostics(
  List<ProductModuleContributionManifest> manifests,
) {
  final hookEntries = <_ProductModuleContributionHookEntry>[];

  for (final manifest in manifests) {
    for (final contribution in manifest.actionContributions) {
      hookEntries.add(
        _ProductModuleContributionHookEntry(
          kind: ProductModuleContributionHookKind.action,
          hookId: contribution.id,
          manifest: manifest,
        ),
      );
    }
    for (final contribution in manifest.setupReadinessContributions) {
      hookEntries.add(
        _ProductModuleContributionHookEntry(
          kind: ProductModuleContributionHookKind.setupReadiness,
          hookId: contribution.id,
          manifest: manifest,
        ),
      );
    }
    for (final contribution in manifest.recommendationContributions) {
      hookEntries.add(
        _ProductModuleContributionHookEntry(
          kind: ProductModuleContributionHookKind.recommendation,
          hookId: contribution.id,
          manifest: manifest,
        ),
      );
    }
    for (final resolver in manifest.moduleBriefResolvers) {
      hookEntries.add(
        _ProductModuleContributionHookEntry(
          kind: ProductModuleContributionHookKind.moduleBriefAction,
          hookId: resolver.contributionId,
          manifest: manifest,
        ),
      );
    }
    for (final contribution in manifest.availabilityRuleTemplateContributions) {
      hookEntries.add(
        _ProductModuleContributionHookEntry(
          kind: ProductModuleContributionHookKind.availabilityTemplate,
          hookId: contribution.id,
          manifest: manifest,
        ),
      );
    }
  }

  final grouped = <String, List<_ProductModuleContributionHookEntry>>{};
  for (final entry in hookEntries) {
    final normalizedId = entry.hookId.trim();
    if (normalizedId.isEmpty) continue;

    grouped
        .putIfAbsent(
          '${entry.kind.name}:$normalizedId',
          () => <_ProductModuleContributionHookEntry>[],
        )
        .add(entry);
  }

  return List.unmodifiable([
    for (final entries in grouped.values)
      if (entries.length > 1)
        ProductModuleContributionDuplicateHookDiagnostic(
          kind: entries.first.kind,
          hookId: entries.first.hookId.trim(),
          sources: [
            for (final entry in entries)
              ProductModuleContributionSource.fromManifest(entry.manifest),
          ],
        ),
  ]);
}

String _readableModuleId(String id) {
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

class _ProductModuleContributionHookEntry {
  const _ProductModuleContributionHookEntry({
    required this.kind,
    required this.hookId,
    required this.manifest,
  });

  final ProductModuleContributionHookKind kind;
  final String hookId;
  final ProductModuleContributionManifest manifest;
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
