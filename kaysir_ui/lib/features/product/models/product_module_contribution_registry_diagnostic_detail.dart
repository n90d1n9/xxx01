import 'product_module_contribution_manifest.dart';

/// Detail payload shown when inspecting one product module registry diagnostic.
class ProductModuleContributionRegistryDiagnosticDetail {
  ProductModuleContributionRegistryDiagnosticDetail({
    required this.title,
    required this.issueLabel,
    required this.message,
    required this.resolutionGuidance,
    required this.severity,
    List<ProductModuleContributionRegistryDiagnosticAction> nextActions =
        const [],
    List<ProductModuleContributionRegistryDiagnosticDetailRow> metadata =
        const [],
    List<ProductModuleContributionRegistryDiagnosticSourceDetail> sources =
        const [],
  }) : nextActions = List.unmodifiable(nextActions),
       metadata = List.unmodifiable(metadata),
       sources = List.unmodifiable(sources);

  factory ProductModuleContributionRegistryDiagnosticDetail.fromDuplicateHook(
    ProductModuleContributionDuplicateHookDiagnostic diagnostic,
  ) {
    return ProductModuleContributionRegistryDiagnosticDetail(
      title: '${diagnostic.kindLabel} / ${diagnostic.hookId}',
      issueLabel: 'Duplicate hook id',
      message: diagnostic.message,
      resolutionGuidance: diagnostic.resolutionGuidance,
      severity: diagnostic.severity,
      nextActions: [
        ProductModuleContributionRegistryDiagnosticAction(
          title: 'Choose the owning module',
          description:
              'Keep "${diagnostic.hookId}" on the module that should own the '
              '${diagnostic.kindLabel.toLowerCase()} behavior.',
        ),
        ProductModuleContributionRegistryDiagnosticAction(
          title: 'Rename duplicate hooks',
          description:
              'Give the remaining ${diagnostic.kindLabel.toLowerCase()} hooks '
              'unique ids scoped to their module or workflow.',
        ),
        const ProductModuleContributionRegistryDiagnosticAction(
          title: 'Retest the active pack',
          description:
              'Refresh the management pack and confirm the duplicate hook '
              'warning disappears from registry diagnostics.',
        ),
      ],
      metadata: [
        ProductModuleContributionRegistryDiagnosticDetailRow(
          label: 'Hook kind',
          value: diagnostic.kindLabel,
        ),
        ProductModuleContributionRegistryDiagnosticDetailRow(
          label: 'Hook id',
          value: diagnostic.hookId,
        ),
        ProductModuleContributionRegistryDiagnosticDetailRow(
          label: 'Occurrences',
          value: diagnostic.occurrenceCountLabel,
        ),
      ],
      sources: [
        for (final source in diagnostic.sources)
          ProductModuleContributionRegistryDiagnosticSourceDetail.fromSource(
            source,
            roleLabel: 'Registered source',
          ),
      ],
    );
  }

  factory ProductModuleContributionRegistryDiagnosticDetail.fromIgnoredManifest(
    ProductModuleContributionIgnoredManifestDiagnostic diagnostic,
  ) {
    return ProductModuleContributionRegistryDiagnosticDetail(
      title: '${diagnostic.reasonLabel} / ${diagnostic.manifestLabel}',
      issueLabel: 'Ignored manifest',
      message: diagnostic.message,
      resolutionGuidance: diagnostic.resolutionGuidance,
      severity: diagnostic.severity,
      nextActions: _ignoredManifestActionsFor(diagnostic),
      metadata: [
        ProductModuleContributionRegistryDiagnosticDetailRow(
          label: 'Reason',
          value: diagnostic.reasonLabel,
        ),
        ProductModuleContributionRegistryDiagnosticDetailRow(
          label: 'Manifest id',
          value:
              diagnostic.source.normalizedId.isEmpty
                  ? 'Missing id'
                  : diagnostic.source.normalizedId,
        ),
        ProductModuleContributionRegistryDiagnosticDetailRow(
          label: 'Manifest title',
          value: diagnostic.source.titleLabel,
        ),
        if (diagnostic.existingSource != null)
          ProductModuleContributionRegistryDiagnosticDetailRow(
            label: 'Existing module',
            value: diagnostic.existingSource!.titleLabel,
          ),
      ],
      sources: [
        ProductModuleContributionRegistryDiagnosticSourceDetail.fromSource(
          diagnostic.source,
          roleLabel: 'Ignored manifest',
        ),
        if (diagnostic.existingSource != null)
          ProductModuleContributionRegistryDiagnosticSourceDetail.fromSource(
            diagnostic.existingSource!,
            roleLabel: 'Registered module',
          ),
      ],
    );
  }

  final String title;
  final String issueLabel;
  final String message;
  final String resolutionGuidance;
  final ProductModuleContributionDiagnosticSeverity severity;
  final List<ProductModuleContributionRegistryDiagnosticAction> nextActions;
  final List<ProductModuleContributionRegistryDiagnosticDetailRow> metadata;
  final List<ProductModuleContributionRegistryDiagnosticSourceDetail> sources;

  bool get hasResolutionGuidance => resolutionGuidance.trim().isNotEmpty;
  bool get hasNextActions => nextActions.isNotEmpty;
  bool get hasMetadata => metadata.isNotEmpty;
  bool get hasSources => sources.isNotEmpty;
  String get severityLabel => severity.label;
  String get sourceCountLabel => _countLabel(sources.length, 'source');
  String get nextActionCountLabel => _countLabel(nextActions.length, 'action');

  String get reportText {
    final buffer =
        StringBuffer()
          ..writeln('Product module registry diagnostic')
          ..writeln('Title: $title')
          ..writeln('Severity: $severityLabel')
          ..writeln('Issue: $issueLabel')
          ..writeln('Message: $message');

    if (hasResolutionGuidance) {
      buffer.writeln('Recommended fix: $resolutionGuidance');
    }

    if (hasNextActions) {
      buffer.writeln('Next actions:');
      for (var index = 0; index < nextActions.length; index += 1) {
        final action = nextActions[index];
        buffer.writeln('${index + 1}. ${action.title}');
        buffer.writeln('   ${action.description}');
      }
    }

    if (hasMetadata) {
      buffer.writeln('Metadata:');
      for (final row in metadata) {
        buffer.writeln('- ${row.label}: ${row.value}');
      }
    }

    if (hasSources) {
      buffer.writeln('Affected sources:');
      for (final source in sources) {
        buffer.writeln('- ${source.roleLabel}: ${source.title} (${source.id})');
        if (source.description.trim().isNotEmpty) {
          buffer.writeln('  ${source.description}');
        }
      }
    }

    return buffer.toString().trimRight();
  }
}

/// One recommended remediation step for a registry diagnostic.
class ProductModuleContributionRegistryDiagnosticAction {
  const ProductModuleContributionRegistryDiagnosticAction({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

/// Key-value metadata row for one registry diagnostic detail.
class ProductModuleContributionRegistryDiagnosticDetailRow {
  const ProductModuleContributionRegistryDiagnosticDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

/// Source module information attached to a registry diagnostic detail.
class ProductModuleContributionRegistryDiagnosticSourceDetail {
  const ProductModuleContributionRegistryDiagnosticSourceDetail({
    required this.roleLabel,
    required this.id,
    required this.title,
    required this.description,
  });

  factory ProductModuleContributionRegistryDiagnosticSourceDetail.fromSource(
    ProductModuleContributionSource source, {
    required String roleLabel,
  }) {
    return ProductModuleContributionRegistryDiagnosticSourceDetail(
      roleLabel: roleLabel,
      id: source.normalizedId.isEmpty ? 'Missing id' : source.normalizedId,
      title: source.titleLabel,
      description: source.descriptionLabel,
    );
  }

  final String roleLabel;
  final String id;
  final String title;
  final String description;
}

List<ProductModuleContributionRegistryDiagnosticAction>
_ignoredManifestActionsFor(
  ProductModuleContributionIgnoredManifestDiagnostic diagnostic,
) {
  return switch (diagnostic.reason) {
    ProductModuleContributionIgnoredManifestReason.blankId => [
      ProductModuleContributionRegistryDiagnosticAction(
        title: 'Assign a stable module id',
        description:
            'Set a non-empty id on ${diagnostic.source.titleLabel} before the '
            'manifest is registered.',
      ),
      const ProductModuleContributionRegistryDiagnosticAction(
        title: 'Check manifest exports',
        description:
            'Confirm the module exports the same id through every registry '
            'entry point.',
      ),
      const ProductModuleContributionRegistryDiagnosticAction(
        title: 'Rebuild registry diagnostics',
        description:
            'Refresh the contribution registry and verify the ignored manifest '
            'error is gone.',
      ),
    ],
    ProductModuleContributionIgnoredManifestReason.duplicateId => [
      ProductModuleContributionRegistryDiagnosticAction(
        title: 'Pick one source of truth',
        description:
            'Compare ${diagnostic.source.titleLabel} with '
            '${diagnostic.existingSource?.titleLabel ?? 'the registered module'} '
            'and decide which module owns the behavior.',
      ),
      ProductModuleContributionRegistryDiagnosticAction(
        title: 'Rename or merge the duplicate',
        description:
            'Give ${diagnostic.source.titleLabel} a unique manifest id, or merge it '
            'with ${diagnostic.existingSource?.titleLabel ?? 'the existing module'}.',
      ),
      const ProductModuleContributionRegistryDiagnosticAction(
        title: 'Retest affected packs',
        description:
            'Reload each management pack that uses the module and confirm the '
            'manifest is active only once.',
      ),
    ],
  };
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
