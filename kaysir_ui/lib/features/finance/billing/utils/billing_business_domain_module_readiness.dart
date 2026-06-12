import '../models/billing_business_domain_module.dart';
import '../models/billing_business_domain_profile.dart';
import '../models/billing_business_domain_screen_registry.dart';
import '../widgets/billing_domain_navigation_policy.dart';
import '../widgets/billing_navigation_coverage.dart';
import '../widgets/billing_navigation_destination.dart';

enum BillingDomainModuleReadinessIssueSeverity { blocker, warning }

enum BillingDomainModuleReadinessIssueKind {
  profileValidation,
  missingScreenRegistry,
  emptyScreenRegistry,
  missingRegisteredScreens,
  missingNavigationPolicy,
  missingLineItemAdapter,
  missingIssuePolicy,
  missingPaymentSchedulePolicy,
  navigationCoverage,
}

class BillingDomainModuleReadinessIssue {
  final BillingDomainModuleReadinessIssueKind kind;
  final BillingDomainModuleReadinessIssueSeverity severity;
  final String message;
  final List<String> details;

  BillingDomainModuleReadinessIssue({
    required this.kind,
    required this.severity,
    required this.message,
    Iterable<String> details = const [],
  }) : details = List.unmodifiable(details);

  bool get isBlocker {
    return severity == BillingDomainModuleReadinessIssueSeverity.blocker;
  }

  bool get isWarning {
    return severity == BillingDomainModuleReadinessIssueSeverity.warning;
  }
}

class BillingDomainModuleReadinessReport {
  final BillingBusinessDomainModule module;
  final BillingNavigationCoverageReport navigationCoverage;
  final List<BillingDomainModuleReadinessIssue> issues;

  BillingDomainModuleReadinessReport({
    required this.module,
    required this.navigationCoverage,
    required Iterable<BillingDomainModuleReadinessIssue> issues,
  }) : issues = List.unmodifiable(issues);

  factory BillingDomainModuleReadinessReport.forModule(
    BillingBusinessDomainModule module, {
    bool hasTenant = true,
    Iterable<BillingNavigationSurface> surfaces =
        billingNavigationCoverageSurfaces,
  }) {
    final navigationCoverage = BillingNavigationCoverageReport.forModule(
      module,
      hasTenant: hasTenant,
      surfaces: surfaces,
    );
    final issues = <BillingDomainModuleReadinessIssue>[
      ..._profileIssues(module.profile),
      ..._screenRegistryIssues(module),
      ..._navigationPolicyIssues(module),
      ..._lineItemAdapterIssues(module),
      ..._issuePolicyIssues(module),
      ..._navigationCoverageIssues(navigationCoverage),
    ];

    return BillingDomainModuleReadinessReport(
      module: module,
      navigationCoverage: navigationCoverage,
      issues: issues,
    );
  }

  String get domainKey => module.key;

  String get domainLabel => module.profile.label;

  bool get isReady => blockerIssues.isEmpty;

  bool get hasWarnings => warningIssues.isNotEmpty;

  int get blockerIssueCount => blockerIssues.length;

  int get warningIssueCount => warningIssues.length;

  List<BillingDomainModuleReadinessIssue> get blockerIssues {
    return List.unmodifiable(issues.where((issue) => issue.isBlocker));
  }

  List<BillingDomainModuleReadinessIssue> get warningIssues {
    return List.unmodifiable(issues.where((issue) => issue.isWarning));
  }

  BillingDomainModuleReadinessIssue? issueForKind(
    BillingDomainModuleReadinessIssueKind kind,
  ) {
    for (final issue in issues) {
      if (issue.kind == kind) return issue;
    }

    return null;
  }

  bool hasIssueKind(BillingDomainModuleReadinessIssueKind kind) {
    return issueForKind(kind) != null;
  }

  String get summaryLabel {
    if (isReady && !hasWarnings) {
      return '$domainLabel billing module is launch-ready.';
    }
    if (isReady) {
      return '$domainLabel billing module is launch-ready with '
          '$warningIssueCount ${_plural(warningIssueCount, 'warning')}.';
    }

    return '$domainLabel billing module has $blockerIssueCount '
        '${_plural(blockerIssueCount, 'blocker')} and $warningIssueCount '
        '${_plural(warningIssueCount, 'warning')}.';
  }
}

class BillingDomainModuleRegistryReadinessReport {
  final List<BillingDomainModuleReadinessReport> moduleReports;

  BillingDomainModuleRegistryReadinessReport({
    required Iterable<BillingDomainModuleReadinessReport> moduleReports,
  }) : moduleReports = List.unmodifiable(moduleReports);

  factory BillingDomainModuleRegistryReadinessReport.forRegistry(
    BillingBusinessDomainModuleRegistry registry, {
    bool hasTenant = true,
    Iterable<BillingNavigationSurface> surfaces =
        billingNavigationCoverageSurfaces,
  }) {
    return BillingDomainModuleRegistryReadinessReport(
      moduleReports: registry.modules.map(
        (module) => BillingDomainModuleReadinessReport.forModule(
          module,
          hasTenant: hasTenant,
          surfaces: surfaces,
        ),
      ),
    );
  }

  bool get isEmpty => moduleReports.isEmpty;

  bool get isReady => blockedModuleReports.isEmpty;

  bool get hasWarnings => warningIssues.isNotEmpty;

  int get blockerIssueCount => blockerIssues.length;

  int get warningIssueCount => warningIssues.length;

  List<String> get domainKeys {
    return List.unmodifiable(moduleReports.map((report) => report.domainKey));
  }

  List<String> get readyDomainKeys {
    return List.unmodifiable(
      moduleReports
          .where((report) => report.isReady)
          .map((report) => report.domainKey),
    );
  }

  List<String> get blockedDomainKeys {
    return List.unmodifiable(
      blockedModuleReports.map((report) => report.domainKey),
    );
  }

  List<BillingDomainModuleReadinessReport> get blockedModuleReports {
    return List.unmodifiable(moduleReports.where((report) => !report.isReady));
  }

  List<BillingDomainModuleReadinessIssue> get blockerIssues {
    return List.unmodifiable(
      moduleReports.expand((report) => report.blockerIssues),
    );
  }

  List<BillingDomainModuleReadinessIssue> get warningIssues {
    return List.unmodifiable(
      moduleReports.expand((report) => report.warningIssues),
    );
  }

  BillingDomainModuleReadinessReport? reportForDomain(String domain) {
    final key = billingBusinessDomainKey(domain);

    for (final report in moduleReports) {
      if (report.domainKey == key) return report;
    }

    return null;
  }

  BillingDomainModuleReadinessReport requireReportForDomain(String domain) {
    final report = reportForDomain(domain);
    if (report == null) {
      throw StateError(
        'No billing module readiness report is available for $domain.',
      );
    }

    return report;
  }

  String get summaryLabel {
    if (isEmpty) return 'No billing domain modules are registered.';
    if (isReady && !hasWarnings) {
      return '${moduleReports.length} billing '
          '${_plural(moduleReports.length, 'module')} '
          '${_beVerb(moduleReports.length)} launch-ready.';
    }
    if (isReady) {
      return '${moduleReports.length} billing '
          '${_plural(moduleReports.length, 'module')} '
          '${_beVerb(moduleReports.length)} launch-ready with '
          '$warningIssueCount ${_plural(warningIssueCount, 'warning')}.';
    }

    return '${blockedModuleReports.length} of ${moduleReports.length} billing '
        '${_plural(moduleReports.length, 'module')} '
        '${_needVerb(blockedModuleReports.length)} attention.';
  }
}

List<BillingDomainModuleReadinessIssue> _profileIssues(
  BillingBusinessDomainProfile profile,
) {
  return List.unmodifiable(
    profile.validationErrors.map(
      (error) => BillingDomainModuleReadinessIssue(
        kind: BillingDomainModuleReadinessIssueKind.profileValidation,
        severity: BillingDomainModuleReadinessIssueSeverity.blocker,
        message: error,
      ),
    ),
  );
}

List<BillingDomainModuleReadinessIssue> _screenRegistryIssues(
  BillingBusinessDomainModule module,
) {
  final screenRegistry = module.screenRegistry;
  if (screenRegistry == null) {
    return [
      BillingDomainModuleReadinessIssue(
        kind: BillingDomainModuleReadinessIssueKind.missingScreenRegistry,
        severity: BillingDomainModuleReadinessIssueSeverity.blocker,
        message:
            '${module.profile.label} needs a screen registry before release.',
      ),
    ];
  }

  if (screenRegistry.isEmpty) {
    return [
      BillingDomainModuleReadinessIssue(
        kind: BillingDomainModuleReadinessIssueKind.emptyScreenRegistry,
        severity: BillingDomainModuleReadinessIssueSeverity.blocker,
        message:
            '${module.profile.label} screen registry has no registered screens.',
      ),
    ];
  }

  final missingDestinationIds = _missingRegisteredDestinationIds(
    module,
    screenRegistry,
  );
  if (missingDestinationIds.isEmpty) return const [];

  return [
    BillingDomainModuleReadinessIssue(
      kind: BillingDomainModuleReadinessIssueKind.missingRegisteredScreens,
      severity: BillingDomainModuleReadinessIssueSeverity.blocker,
      message:
          '${module.profile.label} is missing registered screens for exposed '
          'billing destinations.',
      details: missingDestinationIds.map((destinationId) => destinationId.name),
    ),
  ];
}

List<BillingDomainModuleReadinessIssue> _navigationPolicyIssues(
  BillingBusinessDomainModule module,
) {
  if (module.hasNavigationPolicy) return const [];

  return [
    BillingDomainModuleReadinessIssue(
      kind: BillingDomainModuleReadinessIssueKind.missingNavigationPolicy,
      severity: BillingDomainModuleReadinessIssueSeverity.warning,
      message:
          '${module.profile.label} uses profile-derived billing navigation.',
    ),
  ];
}

List<BillingDomainModuleReadinessIssue> _lineItemAdapterIssues(
  BillingBusinessDomainModule module,
) {
  if (module.hasLineItemAdapters) return const [];

  final severity =
      _requiresLineItemAdapters(module.profile)
          ? BillingDomainModuleReadinessIssueSeverity.blocker
          : BillingDomainModuleReadinessIssueSeverity.warning;

  return [
    BillingDomainModuleReadinessIssue(
      kind: BillingDomainModuleReadinessIssueKind.missingLineItemAdapter,
      severity: severity,
      message:
          '${module.profile.label} has no line item adapter for '
          '${module.profile.defaultSourceType}.',
    ),
  ];
}

List<BillingDomainModuleReadinessIssue> _issuePolicyIssues(
  BillingBusinessDomainModule module,
) {
  final issuePolicy = module.issuePolicy;
  if (issuePolicy == null) {
    return [
      BillingDomainModuleReadinessIssue(
        kind: BillingDomainModuleReadinessIssueKind.missingIssuePolicy,
        severity: BillingDomainModuleReadinessIssueSeverity.warning,
        message:
            '${module.profile.label} uses invoice issue defaults without a '
            'domain policy.',
      ),
    ];
  }

  if (!_requiresPaymentSchedulePolicy(module.profile) ||
      issuePolicy.hasPaymentSchedulePolicy) {
    return const [];
  }

  return [
    BillingDomainModuleReadinessIssue(
      kind: BillingDomainModuleReadinessIssueKind.missingPaymentSchedulePolicy,
      severity: BillingDomainModuleReadinessIssueSeverity.warning,
      message:
          '${module.profile.label} should define payment schedule policy for '
          'its billing capabilities.',
    ),
  ];
}

List<BillingDomainModuleReadinessIssue> _navigationCoverageIssues(
  BillingNavigationCoverageReport navigationCoverage,
) {
  if (navigationCoverage.isComplete) return const [];

  return [
    BillingDomainModuleReadinessIssue(
      kind: BillingDomainModuleReadinessIssueKind.navigationCoverage,
      severity: BillingDomainModuleReadinessIssueSeverity.blocker,
      message: navigationCoverage.summary.summaryLabel,
      details: navigationCoverage.unreachableDestinationIds.map(
        (destinationId) => destinationId.name,
      ),
    ),
  ];
}

List<BillingNavigationDestinationId> _expectedDestinationIds(
  BillingBusinessDomainModule module,
) {
  final policyDestinationIds = module.navigationPolicy?.destinationIds;
  if (policyDestinationIds != null) return policyDestinationIds;

  return billingNavigationDestinationIdsForProfile(module.profile);
}

List<BillingNavigationDestinationId> _missingRegisteredDestinationIds(
  BillingBusinessDomainModule module,
  BillingBusinessDomainScreenRegistry screenRegistry,
) {
  return List.unmodifiable(
    _expectedDestinationIds(
      module,
    ).where((destinationId) => !screenRegistry.contains(destinationId)),
  );
}

bool _requiresLineItemAdapters(BillingBusinessDomainProfile profile) {
  return profile.supports(BillingBusinessDomainCapability.productCatalog) ||
      profile.supports(BillingBusinessDomainCapability.cartCheckout) ||
      profile.supports(BillingBusinessDomainCapability.inventory);
}

bool _requiresPaymentSchedulePolicy(BillingBusinessDomainProfile profile) {
  return profile.supports(BillingBusinessDomainCapability.progressBilling) ||
      profile.supports(
        BillingBusinessDomainCapability.recurringSubscriptions,
      ) ||
      profile.supports(BillingBusinessDomainCapability.meteredUsage) ||
      profile.supports(BillingBusinessDomainCapability.retainers);
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

String _beVerb(int count) {
  return count == 1 ? 'is' : 'are';
}

String _needVerb(int count) {
  return count == 1 ? 'needs' : 'need';
}
