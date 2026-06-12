import 'package:kaysir/core/features/feature_routes.dart';

import '../billing_routes.dart';

/// Severity for route contract issues discovered during billing route audits.
enum BillingRouteContractIssueSeverity { blocker, warning }

/// Stable issue kinds emitted by billing route contract audits.
enum BillingRouteContractIssueKind {
  duplicateRouteName,
  duplicatePath,

  /// Duplicate route identity for local navigation or extension ownership.
  duplicateDestination,
  missingRouteMetadata,
  routeOutsideManagementPath,
  rootRouteNameMismatch,
  rootTitleMismatch,
  rootPathMismatch,
  missingRootSidebarPosition,
  missingRootPageBuilder,
  missingRootDescription,
  missingFeatureRoute,
  unexpectedFeatureRoute,
  featureRoutePathMismatch,
  featureRouteTitleMismatch,
  featureRouteSubtitleMismatch,
  featureRouteDescriptionMismatch,
  featureRouteIconMismatch,
  missingFeatureSidebarPosition,
  missingFeaturePageBuilder,
  featureRouteOrderMismatch,
}

/// Describes a single mismatch in the billing route definition contract.
class BillingRouteContractIssue {
  final BillingRouteContractIssueKind kind;
  final BillingRouteContractIssueSeverity severity;
  final String routeName;
  final String message;
  final List<String> details;

  BillingRouteContractIssue({
    required this.kind,
    required this.severity,
    required this.routeName,
    required this.message,
    Iterable<String> details = const [],
  }) : details = List.unmodifiable(details);

  bool get isBlocker => severity == BillingRouteContractIssueSeverity.blocker;

  bool get isWarning => severity == BillingRouteContractIssueSeverity.warning;
}

/// Audits generated billing feature routes against the source route registry.
class BillingRouteContractReport {
  final FeatureRoutes rootRoute;
  final List<BillingManagementRouteDefinition> routeDefinitions;
  final List<BillingRouteContractIssue> issues;

  BillingRouteContractReport({
    required this.rootRoute,
    required Iterable<BillingManagementRouteDefinition> routeDefinitions,
    required Iterable<BillingRouteContractIssue> issues,
  }) : routeDefinitions = List.unmodifiable(routeDefinitions),
       issues = List.unmodifiable(issues);

  factory BillingRouteContractReport.forFeatureRoute({
    required FeatureRoutes rootRoute,
    Iterable<BillingManagementRouteDefinition> routeDefinitions =
        BillingRoutes.sidebarRoutes,
  }) {
    final definitions = routeDefinitions.toList(growable: false);
    return BillingRouteContractReport(
      rootRoute: rootRoute,
      routeDefinitions: definitions,
      issues: [
        ..._definitionIssues(definitions),
        ..._featureRouteIssues(
          rootRoute,
          definitions,
          requirePageBuilders: true,
        ),
      ],
    );
  }

  /// Builds a contract report directly from the billing route registry.
  factory BillingRouteContractReport.forRouteRegistry({
    Iterable<BillingManagementRouteDefinition> routeDefinitions =
        BillingRoutes.sidebarRoutes,
  }) {
    final definitions = routeDefinitions.toList(growable: false);
    final rootRoute = _routeRegistryRoot(definitions);
    return BillingRouteContractReport(
      rootRoute: rootRoute,
      routeDefinitions: definitions,
      issues: [
        ..._definitionIssues(definitions),
        ..._featureRouteIssues(
          rootRoute,
          definitions,
          requirePageBuilders: false,
        ),
      ],
    );
  }

  bool get isComplete => issues.isEmpty;

  bool get isReady => blockerIssues.isEmpty;

  bool get hasWarnings => warningIssues.isNotEmpty;

  int get issueCount => issues.length;

  List<BillingRouteContractIssue> get blockerIssues {
    return List.unmodifiable(issues.where((issue) => issue.isBlocker));
  }

  List<BillingRouteContractIssue> get warningIssues {
    return List.unmodifiable(issues.where((issue) => issue.isWarning));
  }

  List<BillingManagementRouteDefinition> get expectedChildDefinitions {
    return List.unmodifiable(
      routeDefinitions.where(
        (definition) => definition.path != BillingRoutes.managementPath,
      ),
    );
  }

  List<FeatureRoutes> get actualSidebarRoutes {
    return List.unmodifiable(
      rootRoute.items.where(
        (route) => route.position.contains(MenuPosition.sidebar),
      ),
    );
  }

  List<String> get expectedSidebarPaths {
    return List.unmodifiable(
      expectedChildDefinitions.map((definition) => definition.path),
    );
  }

  List<String> get actualSidebarPaths {
    return List.unmodifiable(
      actualSidebarRoutes
          .map((route) => _nonBlank(route.path))
          .whereType<String>(),
    );
  }

  bool hasIssueKind(BillingRouteContractIssueKind kind) {
    return issueForKind(kind) != null;
  }

  BillingRouteContractIssue? issueForKind(BillingRouteContractIssueKind kind) {
    for (final issue in issues) {
      if (issue.kind == kind) return issue;
    }

    return null;
  }

  String get summaryLabel {
    if (isComplete) {
      return 'Billing route contract is complete across '
          '${routeDefinitions.length} ${_plural(routeDefinitions.length, 'route')}.';
    }
    if (blockerIssues.isNotEmpty) {
      return 'Billing route contract has ${blockerIssues.length} '
          '${_plural(blockerIssues.length, 'blocker')} and '
          '${warningIssues.length} ${_plural(warningIssues.length, 'warning')}.';
    }

    return 'Billing route contract has ${warningIssues.length} '
        '${_plural(warningIssues.length, 'warning')}.';
  }
}

FeatureRoutes _routeRegistryRoot(
  List<BillingManagementRouteDefinition> definitions,
) {
  return FeatureRoutes(
    name: BillingRoutes.managementRouteName,
    title: BillingRoutes.managementTitle,
    subtitle: BillingRoutes.managementSubtitle,
    description: BillingRoutes.managementDescription,
    icon: 'billing',
    path: BillingRoutes.managementPath,
    position: const [MenuPosition.sidebar],
    items: definitions
        .where((definition) => definition.path != BillingRoutes.managementPath)
        .map(_featureRouteForDefinition)
        .toList(growable: false),
  );
}

FeatureRoutes _featureRouteForDefinition(
  BillingManagementRouteDefinition definition,
) {
  return FeatureRoutes(
    name: definition.routeName,
    title: definition.title,
    subtitle: definition.subtitle,
    description: definition.description,
    icon: definition.icon,
    path: definition.path,
    position: const [MenuPosition.sidebar],
  );
}

List<BillingRouteContractIssue> _definitionIssues(
  List<BillingManagementRouteDefinition> definitions,
) {
  return [
    ..._duplicateDefinitionIssues(
      definitions,
      label: 'route name',
      valueOf: (definition) => definition.routeName,
      kind: BillingRouteContractIssueKind.duplicateRouteName,
    ),
    ..._duplicateDefinitionIssues(
      definitions,
      label: 'path',
      valueOf: (definition) => definition.path,
      kind: BillingRouteContractIssueKind.duplicatePath,
    ),
    ..._duplicateDefinitionIssues(
      definitions,
      label: 'route identity',
      valueOf: (definition) => definition.resolvedRouteIdentityKey,
      kind: BillingRouteContractIssueKind.duplicateDestination,
    ),
    for (final definition in definitions) ...[
      if (!_isRouteMetadataComplete(definition))
        BillingRouteContractIssue(
          kind: BillingRouteContractIssueKind.missingRouteMetadata,
          severity: BillingRouteContractIssueSeverity.warning,
          routeName: definition.routeName,
          message: '${definition.routeName} has incomplete route metadata.',
          details: _missingDefinitionFields(definition),
        ),
      if (!_isInsideManagementPath(definition.path))
        BillingRouteContractIssue(
          kind: BillingRouteContractIssueKind.routeOutsideManagementPath,
          severity: BillingRouteContractIssueSeverity.blocker,
          routeName: definition.routeName,
          message:
              '${definition.routeName} must stay under ${BillingRoutes.managementPath}.',
          details: [definition.path],
        ),
    ],
  ];
}

List<BillingRouteContractIssue> _featureRouteIssues(
  FeatureRoutes rootRoute,
  List<BillingManagementRouteDefinition> definitions, {
  required bool requirePageBuilders,
}) {
  final expectedChildren = definitions
      .where((definition) => definition.path != BillingRoutes.managementPath)
      .toList(growable: false);
  final expectedRouteNames = {
    for (final definition in expectedChildren) definition.routeName,
  };
  final actualChildren = rootRoute.items
      .where((route) => route.position.contains(MenuPosition.sidebar))
      .toList(growable: false);
  final actualByRouteName = <String, FeatureRoutes>{};
  for (final route in actualChildren) {
    final routeName = _nonBlank(route.routeName);
    if (routeName != null) actualByRouteName[routeName] = route;
  }

  return [
    ..._rootRouteIssues(rootRoute, requirePageBuilders: requirePageBuilders),
    for (final definition in expectedChildren)
      ..._childRouteIssues(
        definition,
        actualByRouteName[definition.routeName],
        requirePageBuilders: requirePageBuilders,
      ),
    for (final route in actualChildren)
      if (!expectedRouteNames.contains(route.routeName))
        BillingRouteContractIssue(
          kind: BillingRouteContractIssueKind.unexpectedFeatureRoute,
          severity: BillingRouteContractIssueSeverity.blocker,
          routeName: route.routeName ?? route.title ?? 'unknown',
          message:
              '${route.routeName ?? route.title ?? 'Unknown route'} is not declared in BillingRoutes.sidebarRoutes.',
          details: [if (route.path != null) route.path!],
        ),
    if (_hasSamePathSet(expectedChildren, actualChildren) &&
        !_hasSamePathOrder(expectedChildren, actualChildren))
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.featureRouteOrderMismatch,
        severity: BillingRouteContractIssueSeverity.warning,
        routeName: BillingRoutes.managementRouteName,
        message: 'Billing sidebar route order differs from the route registry.',
        details: [
          'expected=${expectedChildren.map((route) => route.path).join(',')}',
          'actual=${actualChildren.map((route) => route.path).join(',')}',
        ],
      ),
  ];
}

List<BillingRouteContractIssue> _rootRouteIssues(
  FeatureRoutes rootRoute, {
  required bool requirePageBuilders,
}) {
  return [
    if (rootRoute.routeName != BillingRoutes.managementRouteName)
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.rootRouteNameMismatch,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: rootRoute.routeName ?? 'unknown',
        message: 'Billing root route name must match the management route.',
        details: [
          'expected=${BillingRoutes.managementRouteName}',
          'actual=${rootRoute.routeName ?? 'unknown'}',
        ],
      ),
    if (rootRoute.title != BillingRoutes.managementTitle)
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.rootTitleMismatch,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: rootRoute.routeName ?? BillingRoutes.managementRouteName,
        message: 'Billing root route title must match the management label.',
        details: [
          'expected=${BillingRoutes.managementTitle}',
          'actual=${rootRoute.title ?? 'unknown'}',
        ],
      ),
    if (rootRoute.path != BillingRoutes.managementPath)
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.rootPathMismatch,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: rootRoute.routeName ?? BillingRoutes.managementRouteName,
        message: 'Billing root route path must match the management path.',
        details: [
          'expected=${BillingRoutes.managementPath}',
          'actual=${rootRoute.path ?? 'unknown'}',
        ],
      ),
    if (!rootRoute.position.contains(MenuPosition.sidebar))
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.missingRootSidebarPosition,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: rootRoute.routeName ?? BillingRoutes.managementRouteName,
        message: 'Billing root route must be visible from the sidebar.',
      ),
    if (requirePageBuilders && rootRoute.pageBuilder == null)
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.missingRootPageBuilder,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: rootRoute.routeName ?? BillingRoutes.managementRouteName,
        message: 'Billing root route must provide a page builder.',
      ),
    if (_nonBlank(rootRoute.description) == null)
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.missingRootDescription,
        severity: BillingRouteContractIssueSeverity.warning,
        routeName: rootRoute.routeName ?? BillingRoutes.managementRouteName,
        message: 'Billing root route should include search metadata.',
      ),
  ];
}

List<BillingRouteContractIssue> _childRouteIssues(
  BillingManagementRouteDefinition definition,
  FeatureRoutes? route, {
  required bool requirePageBuilders,
}) {
  if (route == null) {
    return [
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.missingFeatureRoute,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: definition.routeName,
        message:
            '${definition.title} is declared but missing from the billing sidebar.',
        details: [definition.path],
      ),
    ];
  }

  return [
    if (route.path != definition.path)
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.featureRoutePathMismatch,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: definition.routeName,
        message: '${definition.title} uses a path that differs from registry.',
        details: ['expected=${definition.path}', 'actual=${route.path}'],
      ),
    if (route.title != definition.title)
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.featureRouteTitleMismatch,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: definition.routeName,
        message: '${definition.routeName} title differs from registry.',
        details: ['expected=${definition.title}', 'actual=${route.title}'],
      ),
    if (route.subtitle != definition.subtitle)
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.featureRouteSubtitleMismatch,
        severity: BillingRouteContractIssueSeverity.warning,
        routeName: definition.routeName,
        message: '${definition.routeName} subtitle differs from registry.',
        details: [
          'expected=${definition.subtitle}',
          'actual=${route.subtitle}',
        ],
      ),
    if (route.description != definition.description)
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.featureRouteDescriptionMismatch,
        severity: BillingRouteContractIssueSeverity.warning,
        routeName: definition.routeName,
        message: '${definition.routeName} description differs from registry.',
        details: [
          'expected=${definition.description}',
          'actual=${route.description}',
        ],
      ),
    if (route.icon != definition.icon)
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.featureRouteIconMismatch,
        severity: BillingRouteContractIssueSeverity.warning,
        routeName: definition.routeName,
        message: '${definition.routeName} icon differs from registry.',
        details: ['expected=${definition.icon}', 'actual=${route.icon}'],
      ),
    if (!route.position.contains(MenuPosition.sidebar))
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.missingFeatureSidebarPosition,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: definition.routeName,
        message: '${definition.title} must be visible from the sidebar.',
      ),
    if (requirePageBuilders && route.pageBuilder == null)
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.missingFeaturePageBuilder,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: definition.routeName,
        message: '${definition.title} must provide a page builder.',
      ),
  ];
}

List<BillingRouteContractIssue> _duplicateDefinitionIssues(
  List<BillingManagementRouteDefinition> definitions, {
  required String label,
  required String Function(BillingManagementRouteDefinition) valueOf,
  required BillingRouteContractIssueKind kind,
}) {
  final grouped = <String, List<BillingManagementRouteDefinition>>{};
  for (final definition in definitions) {
    grouped.putIfAbsent(valueOf(definition), () => []).add(definition);
  }

  return [
    for (final entry in grouped.entries)
      if (entry.value.length > 1)
        BillingRouteContractIssue(
          kind: kind,
          severity: BillingRouteContractIssueSeverity.blocker,
          routeName: entry.value.first.routeName,
          message: 'Billing route registry has duplicate $label ${entry.key}.',
          details: entry.value.map((definition) => definition.routeName),
        ),
  ];
}

bool _isRouteMetadataComplete(BillingManagementRouteDefinition definition) {
  return _missingDefinitionFields(definition).isEmpty;
}

List<String> _missingDefinitionFields(
  BillingManagementRouteDefinition definition,
) {
  return [
    if (_nonBlank(definition.name) == null) 'name',
    if (_nonBlank(definition.routeName) == null) 'routeName',
    if (_nonBlank(definition.title) == null) 'title',
    if (_nonBlank(definition.subtitle) == null) 'subtitle',
    if (_nonBlank(definition.description) == null) 'description',
    if (_nonBlank(definition.icon) == null) 'icon',
    if (_nonBlank(definition.path) == null) 'path',
  ];
}

bool _isInsideManagementPath(String path) {
  return path == BillingRoutes.managementPath ||
      path.startsWith('${BillingRoutes.managementPath}/');
}

bool _hasSamePathSet(
  List<BillingManagementRouteDefinition> expected,
  List<FeatureRoutes> actual,
) {
  return expected
          .map((route) => route.path)
          .toSet()
          .containsAll(actual.map((route) => route.path)) &&
      actual
          .map((route) => route.path)
          .toSet()
          .containsAll(expected.map((route) => route.path));
}

bool _hasSamePathOrder(
  List<BillingManagementRouteDefinition> expected,
  List<FeatureRoutes> actual,
) {
  final expectedPaths = expected.map((route) => route.path).toList();
  final actualPaths = actual.map((route) => route.path).toList();
  if (expectedPaths.length != actualPaths.length) return false;

  for (var index = 0; index < expectedPaths.length; index += 1) {
    if (expectedPaths[index] != actualPaths[index]) return false;
  }

  return true;
}

String? _nonBlank(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
