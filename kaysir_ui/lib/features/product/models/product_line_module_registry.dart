import 'management_pack.dart';
import 'product_line_module_definition.dart';
import 'product_module_contribution_manifest.dart';
import 'product_workspace_setup_target.dart';

/// Reason a product-line module definition was skipped by the registry.
enum ProductLineModuleRegistryDiagnosticReason { blankId, duplicateId }

extension ProductLineModuleRegistryDiagnosticReasonLabels
    on ProductLineModuleRegistryDiagnosticReason {
  String get label {
    return switch (this) {
      ProductLineModuleRegistryDiagnosticReason.blankId => 'Blank module id',
      ProductLineModuleRegistryDiagnosticReason.duplicateId =>
        'Duplicate module id',
    };
  }
}

/// Diagnostic emitted when a product-line definition cannot be registered.
class ProductLineModuleRegistryDiagnostic {
  const ProductLineModuleRegistryDiagnostic({
    required this.reason,
    required this.id,
    required this.title,
    required this.description,
    this.existingTitle,
  });

  final ProductLineModuleRegistryDiagnosticReason reason;
  final String id;
  final String title;
  final String description;
  final String? existingTitle;

  String get normalizedId => id.trim();
  String get titleLabel {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isNotEmpty) return normalizedTitle;
    if (normalizedId.isNotEmpty) return _readableId(normalizedId);

    return 'Untitled product line module';
  }

  String get descriptionLabel => description.trim();
  String get reasonLabel => reason.label;

  String get moduleLabel {
    if (normalizedId.isNotEmpty) return normalizedId;

    return titleLabel;
  }

  String get message {
    return switch (reason) {
      ProductLineModuleRegistryDiagnosticReason.blankId =>
        '$titleLabel was ignored because its product-line module id is blank.',
      ProductLineModuleRegistryDiagnosticReason.duplicateId =>
        '$titleLabel was ignored because ${existingTitle ?? 'another module'} '
            'already registered "$normalizedId".',
    };
  }

  String get resolutionGuidance {
    return switch (reason) {
      ProductLineModuleRegistryDiagnosticReason.blankId =>
        'Set a stable non-empty product-line module id before registering $titleLabel.',
      ProductLineModuleRegistryDiagnosticReason.duplicateId =>
        'Rename $titleLabel or merge it with '
            '${existingTitle ?? 'the existing module'} so product-line module '
            'ids stay unique.',
    };
  }
}

/// Registry for resolving reusable product-line definitions and manifests.
class ProductLineModuleRegistry {
  factory ProductLineModuleRegistry({
    required List<ProductLineModuleDefinition> definitions,
  }) {
    final mergeResult = _mergeDefinitions(definitions);

    return ProductLineModuleRegistry._(
      definitions: mergeResult.definitions,
      ignoredDefinitionDiagnostics: mergeResult.ignoredDiagnostics,
    );
  }

  const ProductLineModuleRegistry._({
    required this.definitions,
    required this.ignoredDefinitionDiagnostics,
  });

  final List<ProductLineModuleDefinition> definitions;
  final List<ProductLineModuleRegistryDiagnostic> ignoredDefinitionDiagnostics;

  bool get isEmpty => definitions.isEmpty;
  bool get isNotEmpty => definitions.isNotEmpty;
  int get moduleCount => definitions.length;
  int get ignoredDefinitionCount => ignoredDefinitionDiagnostics.length;
  bool get hasIgnoredDefinitionDiagnostics =>
      ignoredDefinitionDiagnostics.isNotEmpty;

  String get moduleCountLabel => _countLabel(moduleCount, 'module');
  String get ignoredDefinitionCountLabel {
    return _countLabel(ignoredDefinitionCount, 'ignored module');
  }

  List<String> get definitionIds {
    return List.unmodifiable(
      definitions.map((definition) => definition.normalizedId),
    );
  }

  List<ProductModuleContributionManifest> get manifests {
    return List.unmodifiable([
      for (final definition in definitions) definition.toManifest(),
    ]);
  }

  ProductModuleContributionRegistry toContributionRegistry() {
    return ProductModuleContributionRegistry.fromManifests(manifests);
  }

  ProductLineModuleDefinition? definitionOrNull(String id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;

    for (final definition in definitions) {
      if (definition.normalizedId == normalizedId) return definition;
    }

    return null;
  }

  ProductLineModuleDefinition? definitionForSetupTarget(String setupTargetId) {
    final normalizedTargetId = setupTargetId.trim();
    if (normalizedTargetId.isEmpty) return null;

    for (final definition in definitions) {
      if (definition.setupTarget.normalizedId == normalizedTargetId) {
        return definition;
      }
    }

    return null;
  }

  List<ProductLineModuleDefinition> activeDefinitionsFor(
    ProductManagementPack pack,
  ) {
    return List.unmodifiable(
      definitions.where((definition) => definition.isActiveFor(pack)),
    );
  }

  List<ProductModuleContributionManifest> activeManifestsFor(
    ProductManagementPack pack,
  ) {
    return List.unmodifiable([
      for (final definition in activeDefinitionsFor(pack))
        definition.toManifest(),
    ]);
  }

  List<ProductWorkspaceSetupTarget> setupTargetsFor(
    ProductManagementPack pack,
  ) {
    return List.unmodifiable([
      for (final definition in activeDefinitionsFor(pack))
        definition.setupTarget,
    ]);
  }
}

_ProductLineModuleRegistryMergeResult _mergeDefinitions(
  List<ProductLineModuleDefinition> definitions,
) {
  final seenIds = <String>{};
  final titleById = <String, String>{};
  final merged = <ProductLineModuleDefinition>[];
  final ignoredDiagnostics = <ProductLineModuleRegistryDiagnostic>[];

  for (final definition in definitions) {
    final normalizedId = definition.normalizedId;
    final diagnostic = ProductLineModuleRegistryDiagnostic(
      reason: ProductLineModuleRegistryDiagnosticReason.blankId,
      id: definition.id,
      title: definition.title,
      description: definition.description,
    );

    if (normalizedId.isEmpty) {
      ignoredDiagnostics.add(diagnostic);
      continue;
    }

    if (seenIds.contains(normalizedId)) {
      ignoredDiagnostics.add(
        ProductLineModuleRegistryDiagnostic(
          reason: ProductLineModuleRegistryDiagnosticReason.duplicateId,
          id: definition.id,
          title: definition.title,
          description: definition.description,
          existingTitle: titleById[normalizedId],
        ),
      );
      continue;
    }

    seenIds.add(normalizedId);
    titleById[normalizedId] = definition.titleLabel;
    merged.add(definition);
  }

  return _ProductLineModuleRegistryMergeResult(
    definitions: List.unmodifiable(merged),
    ignoredDiagnostics: List.unmodifiable(ignoredDiagnostics),
  );
}

class _ProductLineModuleRegistryMergeResult {
  const _ProductLineModuleRegistryMergeResult({
    required this.definitions,
    required this.ignoredDiagnostics,
  });

  final List<ProductLineModuleDefinition> definitions;
  final List<ProductLineModuleRegistryDiagnostic> ignoredDiagnostics;
}

String _readableId(String id) {
  final words =
      id
          .split(RegExp(r'[_\-\s]+'))
          .where((part) => part.trim().isNotEmpty)
          .toList();
  if (words.isEmpty) return 'Product line module';

  return words.map(_capitalize).join(' ');
}

String _capitalize(String value) {
  if (value.isEmpty) return value;

  return '${value[0].toUpperCase()}${value.substring(1)}';
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
