import '../billing_routes.dart';
import 'billing_route_page_builder_registry.dart';

/// Severity for billing route extension manifest readiness issues.
enum BillingRouteExtensionManifestIssueSeverity { blocker, warning }

/// Stable issue kinds emitted while auditing route extension manifests.
enum BillingRouteExtensionManifestIssueKind {
  duplicateManifestId,
  duplicatePageBuilder,
  missingPageBuilder,
  orphanPageBuilder,
}

/// Describes a manifest contribution that needs cleanup before release.
class BillingRouteExtensionManifestIssue {
  final BillingRouteExtensionManifestIssueKind kind;
  final BillingRouteExtensionManifestIssueSeverity severity;
  final String manifestId;
  final String message;
  final List<String> details;

  BillingRouteExtensionManifestIssue({
    required this.kind,
    required this.severity,
    required this.manifestId,
    required this.message,
    Iterable<String> details = const [],
  }) : details = List.unmodifiable(details);

  bool get isBlocker =>
      severity == BillingRouteExtensionManifestIssueSeverity.blocker;

  bool get isWarning =>
      severity == BillingRouteExtensionManifestIssueSeverity.warning;
}

/// Declares billing route extensions and their executable page builders.
class BillingRouteExtensionManifest {
  final String id;
  final List<BillingManagementRouteDefinition> routeDefinitions;
  final Map<String, BillingRoutePageBuilder> pageBuildersByRouteIdentityKey;

  BillingRouteExtensionManifest({
    required String id,
    Iterable<BillingManagementRouteDefinition> routeDefinitions = const [],
    Map<String, BillingRoutePageBuilder> pageBuildersByRouteIdentityKey =
        const {},
  }) : id = _validatedManifestId(id),
       routeDefinitions = List.unmodifiable(routeDefinitions),
       pageBuildersByRouteIdentityKey = Map.unmodifiable(
         _normalizedPageBuilders(pageBuildersByRouteIdentityKey),
       );

  bool get isEmpty =>
      routeDefinitions.isEmpty && pageBuildersByRouteIdentityKey.isEmpty;

  bool get isNotEmpty => !isEmpty;

  List<String> get routeIdentityKeys {
    return List.unmodifiable(
      routeDefinitions.map((route) => route.resolvedRouteIdentityKey),
    );
  }

  List<BillingManagementRouteDefinition> get missingPageBuilderDefinitions {
    return List.unmodifiable(
      routeDefinitions.where(
        (route) =>
            !pageBuildersByRouteIdentityKey.containsKey(
              route.resolvedRouteIdentityKey,
            ),
      ),
    );
  }

  bool hasPageBuilderFor(BillingManagementRouteDefinition routeDefinition) {
    return pageBuildersByRouteIdentityKey.containsKey(
      routeDefinition.resolvedRouteIdentityKey,
    );
  }

  BillingRoutePageBuilder? pageBuilderFor(
    BillingManagementRouteDefinition routeDefinition,
  ) {
    return pageBuildersByRouteIdentityKey[routeDefinition
        .resolvedRouteIdentityKey];
  }
}

/// Audits manifest route and builder contributions before they are composed.
class BillingRouteExtensionManifestReport {
  final List<BillingRouteExtensionManifest> manifests;
  final List<BillingRouteExtensionManifestIssue> issues;

  BillingRouteExtensionManifestReport({
    required Iterable<BillingRouteExtensionManifest> manifests,
    required Iterable<BillingRouteExtensionManifestIssue> issues,
  }) : manifests = List.unmodifiable(manifests),
       issues = List.unmodifiable(issues);

  factory BillingRouteExtensionManifestReport.forManifests(
    Iterable<BillingRouteExtensionManifest> manifests,
  ) {
    final manifestList = manifests.toList(growable: false);
    return BillingRouteExtensionManifestReport(
      manifests: manifestList,
      issues: _manifestIssues(manifestList),
    );
  }

  bool get isReady => blockerIssues.isEmpty;

  bool get hasIssues => issues.isNotEmpty;

  int get manifestCount => manifests.length;

  int get routeCount {
    return manifests.fold<int>(
      0,
      (total, manifest) => total + manifest.routeDefinitions.length,
    );
  }

  int get pageBuilderCount {
    return manifests.fold<int>(
      0,
      (total, manifest) =>
          total + manifest.pageBuildersByRouteIdentityKey.length,
    );
  }

  List<BillingRouteExtensionManifestIssue> get blockerIssues {
    return List.unmodifiable(issues.where((issue) => issue.isBlocker));
  }

  List<BillingRouteExtensionManifestIssue> get warningIssues {
    return List.unmodifiable(issues.where((issue) => issue.isWarning));
  }

  String get summaryLabel {
    if (issues.isEmpty) {
      return 'Billing route extension manifests are ready across '
          '$manifestCount ${_plural(manifestCount, 'manifest')}.';
    }

    return 'Billing route extension manifests have ${blockerIssues.length} '
        '${_plural(blockerIssues.length, 'blocker')} and '
        '${warningIssues.length} ${_plural(warningIssues.length, 'warning')}.';
  }

  bool hasIssueKind(BillingRouteExtensionManifestIssueKind kind) {
    return issues.any((issue) => issue.kind == kind);
  }
}

/// Flattens extension route definitions from billing route manifests.
List<BillingManagementRouteDefinition> billingRouteDefinitionsForManifests(
  Iterable<BillingRouteExtensionManifest> manifests,
) {
  return List.unmodifiable(
    manifests.expand((manifest) => manifest.routeDefinitions),
  );
}

/// Flattens extension page builders from manifests and rejects duplicates.
Map<String, BillingRoutePageBuilder> billingRoutePageBuildersForManifests(
  Iterable<BillingRouteExtensionManifest> manifests,
) {
  final pageBuilders = <String, BillingRoutePageBuilder>{};

  for (final manifest in manifests) {
    for (final entry in manifest.pageBuildersByRouteIdentityKey.entries) {
      if (pageBuilders.containsKey(entry.key)) {
        throw ArgumentError.value(
          entry.key,
          'routeIdentityKey',
          'is declared by more than one billing route extension manifest',
        );
      }

      pageBuilders[entry.key] = entry.value;
    }
  }

  return Map.unmodifiable(pageBuilders);
}

String _validatedManifestId(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, 'id', 'must not be blank');
  }
  if (normalized != value) {
    throw ArgumentError.value(
      value,
      'id',
      'must not contain leading or trailing whitespace',
    );
  }

  return normalized;
}

Map<String, BillingRoutePageBuilder> _normalizedPageBuilders(
  Map<String, BillingRoutePageBuilder> pageBuilders,
) {
  return {
    for (final entry in pageBuilders.entries)
      if (entry.key.trim().isNotEmpty) entry.key.trim(): entry.value,
  };
}

List<BillingRouteExtensionManifestIssue> _manifestIssues(
  List<BillingRouteExtensionManifest> manifests,
) {
  final issues = <BillingRouteExtensionManifestIssue>[
    ..._duplicateManifestIdIssues(manifests),
    ..._duplicatePageBuilderIssues(manifests),
  ];

  for (final manifest in manifests) {
    final routeIdentityKeys = manifest.routeIdentityKeys.toSet();

    for (final route in manifest.missingPageBuilderDefinitions) {
      issues.add(
        BillingRouteExtensionManifestIssue(
          kind: BillingRouteExtensionManifestIssueKind.missingPageBuilder,
          severity: BillingRouteExtensionManifestIssueSeverity.blocker,
          manifestId: manifest.id,
          message:
              '${route.routeName} is declared without a manifest page builder.',
          details: [
            'routeIdentityKey=${route.resolvedRouteIdentityKey}',
            'path=${route.path}',
          ],
        ),
      );
    }

    for (final builderKey in manifest.pageBuildersByRouteIdentityKey.keys) {
      if (!routeIdentityKeys.contains(builderKey)) {
        issues.add(
          BillingRouteExtensionManifestIssue(
            kind: BillingRouteExtensionManifestIssueKind.orphanPageBuilder,
            severity: BillingRouteExtensionManifestIssueSeverity.warning,
            manifestId: manifest.id,
            message:
                '$builderKey has a page builder but no route definition in ${manifest.id}.',
            details: ['routeIdentityKey=$builderKey'],
          ),
        );
      }
    }
  }

  return issues;
}

List<BillingRouteExtensionManifestIssue> _duplicateManifestIdIssues(
  List<BillingRouteExtensionManifest> manifests,
) {
  final grouped = <String, List<BillingRouteExtensionManifest>>{};
  for (final manifest in manifests) {
    grouped.putIfAbsent(manifest.id, () => []).add(manifest);
  }

  return [
    for (final entry in grouped.entries)
      if (entry.value.length > 1)
        BillingRouteExtensionManifestIssue(
          kind: BillingRouteExtensionManifestIssueKind.duplicateManifestId,
          severity: BillingRouteExtensionManifestIssueSeverity.blocker,
          manifestId: entry.key,
          message: '${entry.key} is declared by more than one manifest.',
          details: entry.value.map((manifest) => manifest.id),
        ),
  ];
}

List<BillingRouteExtensionManifestIssue> _duplicatePageBuilderIssues(
  List<BillingRouteExtensionManifest> manifests,
) {
  final grouped = <String, List<String>>{};
  for (final manifest in manifests) {
    for (final builderKey in manifest.pageBuildersByRouteIdentityKey.keys) {
      grouped.putIfAbsent(builderKey, () => []).add(manifest.id);
    }
  }

  return [
    for (final entry in grouped.entries)
      if (entry.value.length > 1)
        BillingRouteExtensionManifestIssue(
          kind: BillingRouteExtensionManifestIssueKind.duplicatePageBuilder,
          severity: BillingRouteExtensionManifestIssueSeverity.blocker,
          manifestId: entry.value.first,
          message:
              '${entry.key} has page builders in multiple billing route manifests.',
          details: [
            'routeIdentityKey=${entry.key}',
            'manifests=${entry.value.join(',')}',
          ],
        ),
  ];
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
