import '../models/billing_business_domain_profile.dart';
import 'billing_navigation_coverage_issue.dart';
import 'billing_navigation_destination.dart';

const _billingNavigationCoverageIssuePriority = [
  BillingNavigationCoverageIssueKind.unavailable,
  BillingNavigationCoverageIssueKind.missingPlan,
  BillingNavigationCoverageIssueKind.unreachable,
];

class BillingNavigationCoverageSummary {
  final List<BillingNavigationCoverageIssue> issues;
  final List<BillingNavigationCoverageIssueGroup> domainGroups;

  factory BillingNavigationCoverageSummary({
    required Iterable<BillingNavigationCoverageIssue> issues,
  }) {
    final issueList = List<BillingNavigationCoverageIssue>.unmodifiable(issues);
    return BillingNavigationCoverageSummary._(
      issues: issueList,
      domainGroups: _groupIssuesByDomain(issueList),
    );
  }

  const BillingNavigationCoverageSummary._({
    required this.issues,
    required this.domainGroups,
  });

  bool get hasIssues => issues.isNotEmpty;

  bool get isComplete => issues.isEmpty;

  int get issueCount => issues.length;

  int get domainCount => domainGroups.length;

  int get unavailableIssueCount {
    return issueCountFor(BillingNavigationCoverageIssueKind.unavailable);
  }

  int get missingPlanIssueCount {
    return issueCountFor(BillingNavigationCoverageIssueKind.missingPlan);
  }

  int get unreachableIssueCount {
    return issueCountFor(BillingNavigationCoverageIssueKind.unreachable);
  }

  BillingNavigationCoverageIssueKind? get primaryKind {
    return _primaryKindFor(issues);
  }

  List<String> get domainKeys {
    return List.unmodifiable(domainGroups.map((group) => group.domainKey));
  }

  List<BillingNavigationDestinationId> get destinationIds {
    return _uniqueDestinationIds(issues);
  }

  String get summaryLabel {
    if (isComplete) return 'Billing navigation coverage is complete.';

    return '$issueCount navigation ${_plural(issueCount, 'gap')} across '
        '$domainCount ${_plural(domainCount, 'domain')}.';
  }

  int issueCountFor(BillingNavigationCoverageIssueKind kind) {
    return issues.where((issue) => issue.kind == kind).length;
  }

  List<BillingNavigationCoverageIssue> issuesForKind(
    BillingNavigationCoverageIssueKind kind,
  ) {
    return List.unmodifiable(issues.where((issue) => issue.kind == kind));
  }

  BillingNavigationCoverageIssueGroup? groupForDomain(String domain) {
    final key = billingBusinessDomainKey(domain);

    for (final group in domainGroups) {
      if (group.domainKey == key) return group;
    }

    return null;
  }

  BillingNavigationCoverageIssueGroup requireGroupForDomain(String domain) {
    final group = groupForDomain(domain);
    if (group == null) {
      throw StateError(
        'No billing navigation coverage issue group is available for $domain.',
      );
    }

    return group;
  }

  List<BillingNavigationCoverageIssue> issuesForDomain(String domain) {
    return groupForDomain(domain)?.issues ??
        const <BillingNavigationCoverageIssue>[];
  }
}

class BillingNavigationCoverageIssueGroup {
  final String domainKey;
  final String domainLabel;
  final List<BillingNavigationCoverageIssue> issues;

  BillingNavigationCoverageIssueGroup._({
    required this.domainKey,
    required this.domainLabel,
    required Iterable<BillingNavigationCoverageIssue> issues,
  }) : issues = List.unmodifiable(issues);

  bool get hasIssues => issues.isNotEmpty;

  bool get isComplete => issues.isEmpty;

  int get issueCount => issues.length;

  int get unavailableIssueCount {
    return issueCountFor(BillingNavigationCoverageIssueKind.unavailable);
  }

  int get missingPlanIssueCount {
    return issueCountFor(BillingNavigationCoverageIssueKind.missingPlan);
  }

  int get unreachableIssueCount {
    return issueCountFor(BillingNavigationCoverageIssueKind.unreachable);
  }

  BillingNavigationCoverageIssueKind? get primaryKind {
    return _primaryKindFor(issues);
  }

  List<BillingNavigationDestinationId> get destinationIds {
    return _uniqueDestinationIds(issues);
  }

  String get summaryLabel {
    if (isComplete) return '$domainLabel navigation coverage is complete.';

    return '$domainLabel has $issueCount navigation '
        '${_plural(issueCount, 'gap')}.';
  }

  int issueCountFor(BillingNavigationCoverageIssueKind kind) {
    return issues.where((issue) => issue.kind == kind).length;
  }

  List<BillingNavigationCoverageIssue> issuesForKind(
    BillingNavigationCoverageIssueKind kind,
  ) {
    return List.unmodifiable(issues.where((issue) => issue.kind == kind));
  }
}

class _BillingNavigationCoverageIssueGroupBucket {
  final String domainKey;
  final String domainLabel;
  final List<BillingNavigationCoverageIssue> issues;

  _BillingNavigationCoverageIssueGroupBucket({
    required this.domainKey,
    required this.domainLabel,
  }) : issues = [];
}

List<BillingNavigationCoverageIssueGroup> _groupIssuesByDomain(
  List<BillingNavigationCoverageIssue> issues,
) {
  final bucketsByDomain =
      <String, _BillingNavigationCoverageIssueGroupBucket>{};
  final orderedBuckets = <_BillingNavigationCoverageIssueGroupBucket>[];

  for (final issue in issues) {
    var bucket = bucketsByDomain[issue.domainKey];
    if (bucket == null) {
      bucket = _BillingNavigationCoverageIssueGroupBucket(
        domainKey: issue.domainKey,
        domainLabel: issue.domainLabel,
      );
      bucketsByDomain[issue.domainKey] = bucket;
      orderedBuckets.add(bucket);
    }

    bucket.issues.add(issue);
  }

  return List.unmodifiable(
    orderedBuckets.map(
      (bucket) => BillingNavigationCoverageIssueGroup._(
        domainKey: bucket.domainKey,
        domainLabel: bucket.domainLabel,
        issues: bucket.issues,
      ),
    ),
  );
}

BillingNavigationCoverageIssueKind? _primaryKindFor(
  Iterable<BillingNavigationCoverageIssue> issues,
) {
  for (final kind in _billingNavigationCoverageIssuePriority) {
    if (issues.any((issue) => issue.kind == kind)) return kind;
  }

  return null;
}

List<BillingNavigationDestinationId> _uniqueDestinationIds(
  Iterable<BillingNavigationCoverageIssue> issues,
) {
  final seen = <BillingNavigationDestinationId>{};
  final destinationIds = <BillingNavigationDestinationId>[];

  for (final issue in issues) {
    if (seen.add(issue.destinationId)) destinationIds.add(issue.destinationId);
  }

  return List.unmodifiable(destinationIds);
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
