import '../billing_routes.dart';
import 'billing_route_definition_registry.dart';
import 'billing_route_page_builder_registry.dart';

/// Severity for executable billing route registration issues.
enum BillingRouteExecutionIssueSeverity { blocker, warning }

/// Stable issue kinds emitted by billing route execution audits.
enum BillingRouteExecutionIssueKind { missingExplicitPageBuilder }

/// Describes a route that is declared but not backed by an explicit builder.
class BillingRouteExecutionIssue {
  final BillingRouteExecutionIssueKind kind;
  final BillingRouteExecutionIssueSeverity severity;
  final BillingManagementRouteDefinition routeDefinition;
  final String message;
  final List<String> details;

  BillingRouteExecutionIssue({
    required this.kind,
    required this.severity,
    required this.routeDefinition,
    required this.message,
    Iterable<String> details = const [],
  }) : details = List.unmodifiable(details);

  bool get isBlocker => severity == BillingRouteExecutionIssueSeverity.blocker;

  String get routeName => routeDefinition.routeName;
}

/// Audits whether composed billing routes have executable page builders.
class BillingRouteExecutionReport {
  final BillingRouteDefinitionRegistry routeDefinitionRegistry;
  final BillingRoutePageBuilderRegistry pageBuilderRegistry;
  final List<BillingRouteExecutionIssue> issues;

  BillingRouteExecutionReport({
    required this.routeDefinitionRegistry,
    required this.pageBuilderRegistry,
    required Iterable<BillingRouteExecutionIssue> issues,
  }) : issues = List.unmodifiable(issues);

  factory BillingRouteExecutionReport.forRegistry({
    BillingRouteDefinitionRegistry? routeDefinitionRegistry,
    BillingRoutePageBuilderRegistry? pageBuilderRegistry,
  }) {
    final resolvedRouteRegistry =
        routeDefinitionRegistry ?? BillingRouteDefinitionRegistry.standard();
    final resolvedPageBuilderRegistry =
        pageBuilderRegistry ?? BillingRoutePageBuilderRegistry.standard();

    return BillingRouteExecutionReport(
      routeDefinitionRegistry: resolvedRouteRegistry,
      pageBuilderRegistry: resolvedPageBuilderRegistry,
      issues: _executionIssues(
        routeDefinitionRegistry: resolvedRouteRegistry,
        pageBuilderRegistry: resolvedPageBuilderRegistry,
      ),
    );
  }

  bool get isReady => issues.isEmpty;

  bool get hasIssues => issues.isNotEmpty;

  int get routeCount => routeDefinitionRegistry.routeCount;

  int get explicitBuilderCount {
    return routeDefinitionRegistry.routeDefinitions
        .where(pageBuilderRegistry.hasPageBuilderFor)
        .length;
  }

  int get fallbackBuilderCount => routeCount - explicitBuilderCount;

  List<BillingManagementRouteDefinition> get fallbackRouteDefinitions {
    return List.unmodifiable(
      routeDefinitionRegistry.routeDefinitions.where(
        (route) => !pageBuilderRegistry.hasPageBuilderFor(route),
      ),
    );
  }

  String get summaryLabel {
    if (isReady) {
      return 'Billing route execution is ready across '
          '$routeCount ${_plural(routeCount, 'route')}.';
    }

    return 'Billing route execution has ${issues.length} '
        '${_plural(issues.length, 'builder blocker')}.';
  }
}

List<BillingRouteExecutionIssue> _executionIssues({
  required BillingRouteDefinitionRegistry routeDefinitionRegistry,
  required BillingRoutePageBuilderRegistry pageBuilderRegistry,
}) {
  return [
    for (final route in routeDefinitionRegistry.routeDefinitions)
      if (!pageBuilderRegistry.hasPageBuilderFor(route))
        BillingRouteExecutionIssue(
          kind: BillingRouteExecutionIssueKind.missingExplicitPageBuilder,
          severity: BillingRouteExecutionIssueSeverity.blocker,
          routeDefinition: route,
          message: '${route.title} uses the fallback billing route page.',
          details: [
            'routeName=${route.routeName}',
            'routeIdentityKey=${route.resolvedRouteIdentityKey}',
            'path=${route.path}',
          ],
        ),
  ];
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
