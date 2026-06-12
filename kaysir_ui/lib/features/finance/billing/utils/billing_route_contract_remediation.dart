import 'billing_route_contract.dart';

/// Action categories used to remediate billing route contract issues.
enum BillingRouteContractRemediationActionKind {
  cleanupRegistry,
  alignRouteIdentity,
  alignRoutePath,
  alignRouteMetadata,
  restoreSidebarCoverage,
  attachPageBuilder,
  registerFeatureRoute,
  removeUnexpectedRoute,
  restoreRouteOrder,
  enrichSearchMetadata,
}

/// A concrete action suggested by the billing route contract diagnostics.
class BillingRouteContractRemediationAction {
  final String id;
  final BillingRouteContractRemediationActionKind kind;
  final BillingRouteContractIssueSeverity severity;
  final String routeName;
  final String label;
  final String detail;
  final List<String> facts;
  final int priority;

  BillingRouteContractRemediationAction({
    required this.id,
    required this.kind,
    required this.severity,
    required this.routeName,
    required this.label,
    required this.detail,
    Iterable<String> facts = const [],
    required this.priority,
  }) : facts = List.unmodifiable(facts);

  bool get isBlocker => severity == BillingRouteContractIssueSeverity.blocker;

  bool get isWarning => severity == BillingRouteContractIssueSeverity.warning;

  String get severityLabel => isBlocker ? 'Blocker' : 'Warning';

  String get kindLabel {
    return switch (kind) {
      BillingRouteContractRemediationActionKind.cleanupRegistry =>
        'Registry cleanup',
      BillingRouteContractRemediationActionKind.alignRouteIdentity =>
        'Route identity',
      BillingRouteContractRemediationActionKind.alignRoutePath => 'Route path',
      BillingRouteContractRemediationActionKind.alignRouteMetadata =>
        'Route metadata',
      BillingRouteContractRemediationActionKind.restoreSidebarCoverage =>
        'Sidebar coverage',
      BillingRouteContractRemediationActionKind.attachPageBuilder =>
        'Page builder',
      BillingRouteContractRemediationActionKind.registerFeatureRoute =>
        'Feature route',
      BillingRouteContractRemediationActionKind.removeUnexpectedRoute =>
        'Route registry',
      BillingRouteContractRemediationActionKind.restoreRouteOrder =>
        'Route order',
      BillingRouteContractRemediationActionKind.enrichSearchMetadata =>
        'Search metadata',
    };
  }
}

/// Prioritized remediation plan for a billing route contract report.
class BillingRouteContractRemediationPlan {
  final BillingRouteContractReport report;
  final List<BillingRouteContractRemediationAction> actions;

  BillingRouteContractRemediationPlan({
    required this.report,
    required Iterable<BillingRouteContractRemediationAction> actions,
  }) : actions = List.unmodifiable(_sortActions(actions));

  factory BillingRouteContractRemediationPlan.forReport(
    BillingRouteContractReport report,
  ) {
    return BillingRouteContractRemediationPlan(
      report: report,
      actions: report.issues.indexed.map(
        (entry) => _actionForIssue(entry.$2, index: entry.$1),
      ),
    );
  }

  bool get isEmpty => actions.isEmpty;

  bool get hasBlockers => blockerActions.isNotEmpty;

  bool get hasWarnings => warningActions.isNotEmpty;

  int get actionCount => actions.length;

  List<BillingRouteContractRemediationAction> get blockerActions {
    return List.unmodifiable(actions.where((action) => action.isBlocker));
  }

  List<BillingRouteContractRemediationAction> get warningActions {
    return List.unmodifiable(actions.where((action) => action.isWarning));
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'Billing route contract has no remediation actions.';
    }
    if (hasBlockers) {
      return '${blockerActions.length} '
          '${_plural(blockerActions.length, 'route blocker')} should be '
          'cleared before release.';
    }

    return '${warningActions.length} '
        '${_plural(warningActions.length, 'route hardening action')} can '
        'improve billing navigation quality.';
  }
}

BillingRouteContractRemediationAction _actionForIssue(
  BillingRouteContractIssue issue, {
  required int index,
}) {
  final kind = _actionKindForIssue(issue.kind);

  return BillingRouteContractRemediationAction(
    id: '${issue.routeName}:${issue.kind.name}:$index',
    kind: kind,
    severity: issue.severity,
    routeName: issue.routeName,
    label: _actionLabel(issue, kind),
    detail: _actionDetail(issue, kind),
    facts: issue.details,
    priority: _actionPriority(issue.kind),
  );
}

BillingRouteContractRemediationActionKind _actionKindForIssue(
  BillingRouteContractIssueKind kind,
) {
  return switch (kind) {
    BillingRouteContractIssueKind.duplicateRouteName ||
    BillingRouteContractIssueKind.duplicatePath ||
    BillingRouteContractIssueKind.duplicateDestination =>
      BillingRouteContractRemediationActionKind.cleanupRegistry,
    BillingRouteContractIssueKind.rootRouteNameMismatch ||
    BillingRouteContractIssueKind.rootTitleMismatch =>
      BillingRouteContractRemediationActionKind.alignRouteIdentity,
    BillingRouteContractIssueKind.rootPathMismatch ||
    BillingRouteContractIssueKind.routeOutsideManagementPath ||
    BillingRouteContractIssueKind.featureRoutePathMismatch =>
      BillingRouteContractRemediationActionKind.alignRoutePath,
    BillingRouteContractIssueKind.missingRouteMetadata ||
    BillingRouteContractIssueKind.featureRouteTitleMismatch ||
    BillingRouteContractIssueKind.featureRouteSubtitleMismatch ||
    BillingRouteContractIssueKind.featureRouteDescriptionMismatch ||
    BillingRouteContractIssueKind.featureRouteIconMismatch =>
      BillingRouteContractRemediationActionKind.alignRouteMetadata,
    BillingRouteContractIssueKind.missingRootSidebarPosition ||
    BillingRouteContractIssueKind.missingFeatureSidebarPosition =>
      BillingRouteContractRemediationActionKind.restoreSidebarCoverage,
    BillingRouteContractIssueKind.missingRootPageBuilder ||
    BillingRouteContractIssueKind.missingFeaturePageBuilder =>
      BillingRouteContractRemediationActionKind.attachPageBuilder,
    BillingRouteContractIssueKind.missingFeatureRoute =>
      BillingRouteContractRemediationActionKind.registerFeatureRoute,
    BillingRouteContractIssueKind.unexpectedFeatureRoute =>
      BillingRouteContractRemediationActionKind.removeUnexpectedRoute,
    BillingRouteContractIssueKind.featureRouteOrderMismatch =>
      BillingRouteContractRemediationActionKind.restoreRouteOrder,
    BillingRouteContractIssueKind.missingRootDescription =>
      BillingRouteContractRemediationActionKind.enrichSearchMetadata,
  };
}

String _actionLabel(
  BillingRouteContractIssue issue,
  BillingRouteContractRemediationActionKind kind,
) {
  return switch (kind) {
    BillingRouteContractRemediationActionKind.cleanupRegistry =>
      'Clean up ${issue.routeName} route registry',
    BillingRouteContractRemediationActionKind.alignRouteIdentity =>
      'Align ${issue.routeName} route identity',
    BillingRouteContractRemediationActionKind.alignRoutePath =>
      'Align ${issue.routeName} route path',
    BillingRouteContractRemediationActionKind.alignRouteMetadata =>
      'Align ${issue.routeName} route metadata',
    BillingRouteContractRemediationActionKind.restoreSidebarCoverage =>
      'Restore ${issue.routeName} sidebar coverage',
    BillingRouteContractRemediationActionKind.attachPageBuilder =>
      'Attach ${issue.routeName} page builder',
    BillingRouteContractRemediationActionKind.registerFeatureRoute =>
      'Register ${issue.routeName} feature route',
    BillingRouteContractRemediationActionKind.removeUnexpectedRoute =>
      'Resolve unexpected ${issue.routeName} route',
    BillingRouteContractRemediationActionKind.restoreRouteOrder =>
      'Restore billing sidebar route order',
    BillingRouteContractRemediationActionKind.enrichSearchMetadata =>
      'Add ${issue.routeName} search metadata',
  };
}

String _actionDetail(
  BillingRouteContractIssue issue,
  BillingRouteContractRemediationActionKind kind,
) {
  return switch (kind) {
    BillingRouteContractRemediationActionKind.cleanupRegistry =>
      'Keep BillingRoutes.sidebarRoutes unique for names, paths, and route identities.',
    BillingRouteContractRemediationActionKind.alignRouteIdentity =>
      'Make the generated route identity match BillingRoutes management constants.',
    BillingRouteContractRemediationActionKind.alignRoutePath =>
      'Keep billing paths under the management path and aligned with the route registry.',
    BillingRouteContractRemediationActionKind.alignRouteMetadata =>
      'Sync title, subtitle, description, and icon metadata from the route registry.',
    BillingRouteContractRemediationActionKind.restoreSidebarCoverage =>
      'Ensure the route is included in sidebar menu positions.',
    BillingRouteContractRemediationActionKind.attachPageBuilder =>
      'Add the missing page builder so the generated route can be opened.',
    BillingRouteContractRemediationActionKind.registerFeatureRoute =>
      'Create the generated feature route declared by the billing route registry.',
    BillingRouteContractRemediationActionKind.removeUnexpectedRoute =>
      'Remove the orphan route or add a matching route definition if it is intentional.',
    BillingRouteContractRemediationActionKind.restoreRouteOrder =>
      'Keep generated sidebar order aligned with BillingRoutes.sidebarRoutes.',
    BillingRouteContractRemediationActionKind.enrichSearchMetadata =>
      'Add description metadata so the route is discoverable in search and diagnostics.',
  };
}

int _actionPriority(BillingRouteContractIssueKind kind) {
  return switch (kind) {
    BillingRouteContractIssueKind.duplicateRouteName => 10,
    BillingRouteContractIssueKind.duplicatePath => 11,
    BillingRouteContractIssueKind.duplicateDestination => 12,
    BillingRouteContractIssueKind.routeOutsideManagementPath => 20,
    BillingRouteContractIssueKind.rootPathMismatch => 21,
    BillingRouteContractIssueKind.featureRoutePathMismatch => 22,
    BillingRouteContractIssueKind.rootRouteNameMismatch => 30,
    BillingRouteContractIssueKind.rootTitleMismatch => 31,
    BillingRouteContractIssueKind.missingFeatureRoute => 40,
    BillingRouteContractIssueKind.unexpectedFeatureRoute => 41,
    BillingRouteContractIssueKind.missingRootSidebarPosition => 50,
    BillingRouteContractIssueKind.missingFeatureSidebarPosition => 51,
    BillingRouteContractIssueKind.missingRootPageBuilder => 60,
    BillingRouteContractIssueKind.missingFeaturePageBuilder => 61,
    BillingRouteContractIssueKind.featureRouteTitleMismatch => 70,
    BillingRouteContractIssueKind.featureRouteSubtitleMismatch => 71,
    BillingRouteContractIssueKind.featureRouteDescriptionMismatch => 72,
    BillingRouteContractIssueKind.featureRouteIconMismatch => 73,
    BillingRouteContractIssueKind.missingRouteMetadata => 80,
    BillingRouteContractIssueKind.missingRootDescription => 81,
    BillingRouteContractIssueKind.featureRouteOrderMismatch => 90,
  };
}

List<BillingRouteContractRemediationAction> _sortActions(
  Iterable<BillingRouteContractRemediationAction> actions,
) {
  final sorted = actions.toList();
  sorted.sort((left, right) {
    final severity = _severityRank(
      left.severity,
    ).compareTo(_severityRank(right.severity));
    if (severity != 0) return severity;

    final priority = left.priority.compareTo(right.priority);
    if (priority != 0) return priority;

    return left.id.compareTo(right.id);
  });

  return sorted;
}

int _severityRank(BillingRouteContractIssueSeverity severity) {
  return switch (severity) {
    BillingRouteContractIssueSeverity.blocker => 0,
    BillingRouteContractIssueSeverity.warning => 1,
  };
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
