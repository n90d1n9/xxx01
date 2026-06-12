import 'billing_route_extension_manifest.dart';

/// Action categories used to remediate billing route extension manifest issues.
enum BillingRouteExtensionManifestRemediationActionKind {
  attachPageBuilder,
  deduplicateManifestId,
  deduplicatePageBuilder,
  resolveOrphanBuilder,
}

/// A concrete action suggested by route extension manifest diagnostics.
class BillingRouteExtensionManifestRemediationAction {
  final String id;
  final BillingRouteExtensionManifestRemediationActionKind kind;
  final BillingRouteExtensionManifestIssueSeverity severity;
  final String manifestId;
  final String label;
  final String detail;
  final List<String> facts;
  final int priority;

  BillingRouteExtensionManifestRemediationAction({
    required this.id,
    required this.kind,
    required this.severity,
    required this.manifestId,
    required this.label,
    required this.detail,
    Iterable<String> facts = const [],
    required this.priority,
  }) : facts = List.unmodifiable(facts);

  bool get isBlocker =>
      severity == BillingRouteExtensionManifestIssueSeverity.blocker;

  bool get isWarning =>
      severity == BillingRouteExtensionManifestIssueSeverity.warning;

  String get severityLabel => isBlocker ? 'Blocker' : 'Warning';

  String get kindLabel {
    return switch (kind) {
      BillingRouteExtensionManifestRemediationActionKind.attachPageBuilder =>
        'Page builder',
      BillingRouteExtensionManifestRemediationActionKind
          .deduplicateManifestId =>
        'Manifest id',
      BillingRouteExtensionManifestRemediationActionKind
          .deduplicatePageBuilder =>
        'Builder registry',
      BillingRouteExtensionManifestRemediationActionKind.resolveOrphanBuilder =>
        'Orphan builder',
    };
  }
}

/// Prioritized remediation plan for a route extension manifest report.
class BillingRouteExtensionManifestRemediationPlan {
  final BillingRouteExtensionManifestReport report;
  final List<BillingRouteExtensionManifestRemediationAction> actions;

  BillingRouteExtensionManifestRemediationPlan({
    required this.report,
    required Iterable<BillingRouteExtensionManifestRemediationAction> actions,
  }) : actions = List.unmodifiable(_sortActions(actions));

  factory BillingRouteExtensionManifestRemediationPlan.forReport(
    BillingRouteExtensionManifestReport report,
  ) {
    return BillingRouteExtensionManifestRemediationPlan(
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

  List<BillingRouteExtensionManifestRemediationAction> get blockerActions {
    return List.unmodifiable(actions.where((action) => action.isBlocker));
  }

  List<BillingRouteExtensionManifestRemediationAction> get warningActions {
    return List.unmodifiable(actions.where((action) => action.isWarning));
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'Billing route extension manifests have no remediation actions.';
    }
    if (hasBlockers) {
      return '${blockerActions.length} '
          '${_plural(blockerActions.length, 'manifest blocker')} should be '
          'cleared before release.';
    }

    return '${warningActions.length} '
        '${_plural(warningActions.length, 'manifest hardening action')} can '
        'improve extension pack quality.';
  }
}

BillingRouteExtensionManifestRemediationAction _actionForIssue(
  BillingRouteExtensionManifestIssue issue, {
  required int index,
}) {
  final kind = _actionKindForIssue(issue.kind);

  return BillingRouteExtensionManifestRemediationAction(
    id: '${issue.manifestId}:${issue.kind.name}:$index',
    kind: kind,
    severity: issue.severity,
    manifestId: issue.manifestId,
    label: _actionLabel(issue, kind),
    detail: _actionDetail(issue, kind),
    facts: issue.details,
    priority: _actionPriority(issue.kind),
  );
}

BillingRouteExtensionManifestRemediationActionKind _actionKindForIssue(
  BillingRouteExtensionManifestIssueKind kind,
) {
  return switch (kind) {
    BillingRouteExtensionManifestIssueKind.missingPageBuilder =>
      BillingRouteExtensionManifestRemediationActionKind.attachPageBuilder,
    BillingRouteExtensionManifestIssueKind.duplicateManifestId =>
      BillingRouteExtensionManifestRemediationActionKind.deduplicateManifestId,
    BillingRouteExtensionManifestIssueKind.duplicatePageBuilder =>
      BillingRouteExtensionManifestRemediationActionKind.deduplicatePageBuilder,
    BillingRouteExtensionManifestIssueKind.orphanPageBuilder =>
      BillingRouteExtensionManifestRemediationActionKind.resolveOrphanBuilder,
  };
}

String _actionLabel(
  BillingRouteExtensionManifestIssue issue,
  BillingRouteExtensionManifestRemediationActionKind kind,
) {
  return switch (kind) {
    BillingRouteExtensionManifestRemediationActionKind.attachPageBuilder =>
      'Attach ${issue.manifestId} page builder',
    BillingRouteExtensionManifestRemediationActionKind.deduplicateManifestId =>
      'Deduplicate ${issue.manifestId} manifest id',
    BillingRouteExtensionManifestRemediationActionKind.deduplicatePageBuilder =>
      'Deduplicate ${issue.manifestId} page builder',
    BillingRouteExtensionManifestRemediationActionKind.resolveOrphanBuilder =>
      'Resolve ${issue.manifestId} orphan builder',
  };
}

String _actionDetail(
  BillingRouteExtensionManifestIssue issue,
  BillingRouteExtensionManifestRemediationActionKind kind,
) {
  return switch (kind) {
    BillingRouteExtensionManifestRemediationActionKind.attachPageBuilder =>
      'Add an executable page builder for every route definition declared by this manifest.',
    BillingRouteExtensionManifestRemediationActionKind.deduplicateManifestId =>
      'Give each extension manifest a stable unique id before it is registered.',
    BillingRouteExtensionManifestRemediationActionKind.deduplicatePageBuilder =>
      'Keep one page builder per route identity key or merge the duplicated builder registrations.',
    BillingRouteExtensionManifestRemediationActionKind.resolveOrphanBuilder =>
      'Remove the unused page builder or add the matching route definition to the manifest.',
  };
}

int _actionPriority(BillingRouteExtensionManifestIssueKind kind) {
  return switch (kind) {
    BillingRouteExtensionManifestIssueKind.duplicateManifestId => 10,
    BillingRouteExtensionManifestIssueKind.duplicatePageBuilder => 20,
    BillingRouteExtensionManifestIssueKind.missingPageBuilder => 30,
    BillingRouteExtensionManifestIssueKind.orphanPageBuilder => 80,
  };
}

List<BillingRouteExtensionManifestRemediationAction> _sortActions(
  Iterable<BillingRouteExtensionManifestRemediationAction> actions,
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

int _severityRank(BillingRouteExtensionManifestIssueSeverity severity) {
  return switch (severity) {
    BillingRouteExtensionManifestIssueSeverity.blocker => 0,
    BillingRouteExtensionManifestIssueSeverity.warning => 1,
  };
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
