import '../models/billing_business_domain_profile.dart';
import 'billing_business_domain_module_readiness.dart';
import 'billing_business_domain_pack_readiness.dart';

enum BillingBusinessDomainPackRemediationActionKind {
  validateProfile,
  registerScreenRegistry,
  registerMissingScreens,
  defineNavigationPolicy,
  addLineItemAdapter,
  addIssuePolicy,
  addPaymentSchedulePolicy,
  restoreNavigationCoverage,
  registerDiagnosticsProfile,
  registerReleaseWorkspaceProfile,
  registerReleaseProfileSavedViewProfile,
  registerReleaseGateLaneTarget,
}

enum BillingBusinessDomainPackRemediationActionSource { module, pack }

class BillingBusinessDomainPackRemediationAction {
  final String id;
  final String domainKey;
  final String domainLabel;
  final BillingBusinessDomainPackRemediationActionKind kind;
  final BillingBusinessDomainPackRemediationActionSource source;
  final BillingDomainModuleReadinessIssueSeverity severity;
  final String label;
  final String detail;
  final List<String> facts;
  final int priority;

  BillingBusinessDomainPackRemediationAction({
    required this.id,
    required this.domainKey,
    required this.domainLabel,
    required this.kind,
    required this.source,
    required this.severity,
    required this.label,
    required this.detail,
    Iterable<String> facts = const [],
    required this.priority,
  }) : facts = List.unmodifiable(facts);

  bool get isBlocker {
    return severity == BillingDomainModuleReadinessIssueSeverity.blocker;
  }

  bool get isWarning {
    return severity == BillingDomainModuleReadinessIssueSeverity.warning;
  }

  String get sourceLabel {
    return switch (source) {
      BillingBusinessDomainPackRemediationActionSource.module => 'Module',
      BillingBusinessDomainPackRemediationActionSource.pack => 'Pack',
    };
  }

  String get severityLabel => isBlocker ? 'Blocker' : 'Warning';

  String get kindLabel {
    return switch (kind) {
      BillingBusinessDomainPackRemediationActionKind.validateProfile =>
        'Profile',
      BillingBusinessDomainPackRemediationActionKind.registerScreenRegistry =>
        'Screen registry',
      BillingBusinessDomainPackRemediationActionKind.registerMissingScreens =>
        'Screen coverage',
      BillingBusinessDomainPackRemediationActionKind.defineNavigationPolicy =>
        'Navigation policy',
      BillingBusinessDomainPackRemediationActionKind.addLineItemAdapter =>
        'Line item adapter',
      BillingBusinessDomainPackRemediationActionKind.addIssuePolicy =>
        'Issue policy',
      BillingBusinessDomainPackRemediationActionKind.addPaymentSchedulePolicy =>
        'Schedule policy',
      BillingBusinessDomainPackRemediationActionKind
          .restoreNavigationCoverage =>
        'Navigation coverage',
      BillingBusinessDomainPackRemediationActionKind
          .registerDiagnosticsProfile =>
        'Diagnostics profile',
      BillingBusinessDomainPackRemediationActionKind
          .registerReleaseWorkspaceProfile =>
        'Release workspace',
      BillingBusinessDomainPackRemediationActionKind
          .registerReleaseProfileSavedViewProfile =>
        'Release profile views',
      BillingBusinessDomainPackRemediationActionKind
          .registerReleaseGateLaneTarget =>
        'Release gate navigation',
    };
  }
}

class BillingBusinessDomainPackRemediationPlan {
  final BillingBusinessDomainPackReadinessReport readinessReport;
  final List<BillingBusinessDomainPackRemediationAction> actions;

  BillingBusinessDomainPackRemediationPlan({
    required this.readinessReport,
    required Iterable<BillingBusinessDomainPackRemediationAction> actions,
  }) : actions = List.unmodifiable(_sortRemediationActions(actions));

  factory BillingBusinessDomainPackRemediationPlan.forReport(
    BillingBusinessDomainPackReadinessReport report,
  ) {
    return BillingBusinessDomainPackRemediationPlan(
      readinessReport: report,
      actions: [..._moduleActions(report), ..._packActions(report)],
    );
  }

  String get domainKey => readinessReport.domainKey;

  String get domainLabel => readinessReport.domainLabel;

  bool get isEmpty => actions.isEmpty;

  bool get hasBlockers => blockerActions.isNotEmpty;

  bool get hasWarnings => warningActions.isNotEmpty;

  int get actionCount => actions.length;

  List<BillingBusinessDomainPackRemediationAction> get blockerActions {
    return List.unmodifiable(actions.where((action) => action.isBlocker));
  }

  List<BillingBusinessDomainPackRemediationAction> get warningActions {
    return List.unmodifiable(actions.where((action) => action.isWarning));
  }

  String get summaryLabel {
    if (isEmpty) {
      return '$domainLabel billing pack has no remediation actions.';
    }
    if (hasBlockers) {
      return '$domainLabel billing pack needs ${blockerActions.length} '
          '${_plural(blockerActions.length, 'blocker')} cleared before '
          'release.';
    }

    return '$domainLabel billing pack has ${warningActions.length} '
        '${_plural(warningActions.length, 'hardening action')}.';
  }
}

class BillingBusinessDomainPackRegistryRemediationPlan {
  final List<BillingBusinessDomainPackRemediationPlan> packPlans;

  BillingBusinessDomainPackRegistryRemediationPlan({
    required Iterable<BillingBusinessDomainPackRemediationPlan> packPlans,
  }) : packPlans = List.unmodifiable(packPlans);

  factory BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
    BillingBusinessDomainPackRegistryReadinessReport report,
  ) {
    return BillingBusinessDomainPackRegistryRemediationPlan(
      packPlans: report.packReports.map(
        BillingBusinessDomainPackRemediationPlan.forReport,
      ),
    );
  }

  bool get isEmpty => actions.isEmpty;

  List<BillingBusinessDomainPackRemediationAction> get actions {
    return List.unmodifiable(
      _sortRemediationActions(packPlans.expand((plan) => plan.actions)),
    );
  }

  List<BillingBusinessDomainPackRemediationAction> get blockerActions {
    return List.unmodifiable(actions.where((action) => action.isBlocker));
  }

  List<BillingBusinessDomainPackRemediationAction> get warningActions {
    return List.unmodifiable(actions.where((action) => action.isWarning));
  }

  int get actionCount => actions.length;

  int get blockerActionCount => blockerActions.length;

  int get warningActionCount => warningActions.length;

  List<String> get affectedDomainKeys {
    return List.unmodifiable(
      actions.map((action) => action.domainKey).toSet().toList()..sort(),
    );
  }

  BillingBusinessDomainPackRemediationPlan? planForDomain(String domain) {
    final domainKey = billingBusinessDomainKey(domain);
    for (final plan in packPlans) {
      if (plan.domainKey == domainKey) return plan;
    }

    return null;
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'All billing packs have no remediation actions.';
    }
    if (blockerActionCount > 0) {
      return '$blockerActionCount '
          '${_plural(blockerActionCount, 'blocker action')} should be '
          'cleared before pack release.';
    }

    return '$warningActionCount '
        '${_plural(warningActionCount, 'hardening action')} can improve '
        'billing pack release quality.';
  }
}

List<BillingBusinessDomainPackRemediationAction> _moduleActions(
  BillingBusinessDomainPackReadinessReport report,
) {
  return List.unmodifiable(
    report.moduleReadiness.issues.indexed.map((entry) {
      final index = entry.$1;
      final issue = entry.$2;
      final kind = _moduleActionKind(issue.kind);

      return BillingBusinessDomainPackRemediationAction(
        id: '${report.domainKey}:module:${issue.kind.name}:$index',
        domainKey: report.domainKey,
        domainLabel: report.domainLabel,
        kind: kind,
        source: BillingBusinessDomainPackRemediationActionSource.module,
        severity: issue.severity,
        label: _moduleActionLabel(report, issue.kind),
        detail: _moduleActionDetail(issue),
        facts: issue.details,
        priority: _moduleActionPriority(issue.kind),
      );
    }),
  );
}

List<BillingBusinessDomainPackRemediationAction> _packActions(
  BillingBusinessDomainPackReadinessReport report,
) {
  return List.unmodifiable(
    report.packIssues.indexed.map((entry) {
      final index = entry.$1;
      final issue = entry.$2;

      return BillingBusinessDomainPackRemediationAction(
        id: '${report.domainKey}:pack:${issue.kind.name}:$index',
        domainKey: report.domainKey,
        domainLabel: report.domainLabel,
        kind: _packActionKind(issue.kind),
        source: BillingBusinessDomainPackRemediationActionSource.pack,
        severity: issue.severity,
        label: _packActionLabel(report, issue.kind),
        detail: issue.message,
        facts: issue.details,
        priority: _packActionPriority(issue.kind),
      );
    }),
  );
}

BillingBusinessDomainPackRemediationActionKind _moduleActionKind(
  BillingDomainModuleReadinessIssueKind kind,
) {
  return switch (kind) {
    BillingDomainModuleReadinessIssueKind.profileValidation =>
      BillingBusinessDomainPackRemediationActionKind.validateProfile,
    BillingDomainModuleReadinessIssueKind.missingScreenRegistry ||
    BillingDomainModuleReadinessIssueKind.emptyScreenRegistry =>
      BillingBusinessDomainPackRemediationActionKind.registerScreenRegistry,
    BillingDomainModuleReadinessIssueKind.missingRegisteredScreens =>
      BillingBusinessDomainPackRemediationActionKind.registerMissingScreens,
    BillingDomainModuleReadinessIssueKind.missingNavigationPolicy =>
      BillingBusinessDomainPackRemediationActionKind.defineNavigationPolicy,
    BillingDomainModuleReadinessIssueKind.missingLineItemAdapter =>
      BillingBusinessDomainPackRemediationActionKind.addLineItemAdapter,
    BillingDomainModuleReadinessIssueKind.missingIssuePolicy =>
      BillingBusinessDomainPackRemediationActionKind.addIssuePolicy,
    BillingDomainModuleReadinessIssueKind.missingPaymentSchedulePolicy =>
      BillingBusinessDomainPackRemediationActionKind.addPaymentSchedulePolicy,
    BillingDomainModuleReadinessIssueKind.navigationCoverage =>
      BillingBusinessDomainPackRemediationActionKind.restoreNavigationCoverage,
  };
}

BillingBusinessDomainPackRemediationActionKind _packActionKind(
  BillingBusinessDomainPackReadinessIssueKind kind,
) {
  return switch (kind) {
    BillingBusinessDomainPackReadinessIssueKind.missingDiagnosticsProfile =>
      BillingBusinessDomainPackRemediationActionKind.registerDiagnosticsProfile,
    BillingBusinessDomainPackReadinessIssueKind
        .missingReleaseWorkspaceProfile =>
      BillingBusinessDomainPackRemediationActionKind
          .registerReleaseWorkspaceProfile,
    BillingBusinessDomainPackReadinessIssueKind
        .missingReleaseProfileSavedViewProfile =>
      BillingBusinessDomainPackRemediationActionKind
          .registerReleaseProfileSavedViewProfile,
    BillingBusinessDomainPackReadinessIssueKind.missingReleaseGateLaneTarget =>
      BillingBusinessDomainPackRemediationActionKind
          .registerReleaseGateLaneTarget,
  };
}

String _moduleActionLabel(
  BillingBusinessDomainPackReadinessReport report,
  BillingDomainModuleReadinessIssueKind kind,
) {
  return switch (kind) {
    BillingDomainModuleReadinessIssueKind.profileValidation =>
      'Fix ${report.domainLabel} profile',
    BillingDomainModuleReadinessIssueKind.missingScreenRegistry =>
      'Register ${report.domainLabel} screen registry',
    BillingDomainModuleReadinessIssueKind.emptyScreenRegistry =>
      'Add ${report.domainLabel} screen entries',
    BillingDomainModuleReadinessIssueKind.missingRegisteredScreens =>
      'Register missing ${report.domainLabel} screens',
    BillingDomainModuleReadinessIssueKind.missingNavigationPolicy =>
      'Define ${report.domainLabel} navigation policy',
    BillingDomainModuleReadinessIssueKind.missingLineItemAdapter =>
      'Add ${report.domainLabel} line item adapter',
    BillingDomainModuleReadinessIssueKind.missingIssuePolicy =>
      'Add ${report.domainLabel} issue policy',
    BillingDomainModuleReadinessIssueKind.missingPaymentSchedulePolicy =>
      'Add ${report.domainLabel} schedule policy',
    BillingDomainModuleReadinessIssueKind.navigationCoverage =>
      'Restore ${report.domainLabel} navigation coverage',
  };
}

String _moduleActionDetail(BillingDomainModuleReadinessIssue issue) {
  return switch (issue.kind) {
    BillingDomainModuleReadinessIssueKind.missingNavigationPolicy =>
      '${issue.message} Add an explicit policy when this domain needs custom '
          'destinations or launch rules.',
    BillingDomainModuleReadinessIssueKind.missingLineItemAdapter =>
      '${issue.message} Register an adapter that maps domain source data into '
          'invoice line items.',
    BillingDomainModuleReadinessIssueKind.missingIssuePolicy =>
      '${issue.message} Attach an issue policy so invoice creation follows '
          'domain-specific rules.',
    BillingDomainModuleReadinessIssueKind.missingPaymentSchedulePolicy =>
      '${issue.message} Add schedule rules before packaging staged billing.',
    _ => issue.message,
  };
}

String _packActionLabel(
  BillingBusinessDomainPackReadinessReport report,
  BillingBusinessDomainPackReadinessIssueKind kind,
) {
  return switch (kind) {
    BillingBusinessDomainPackReadinessIssueKind.missingDiagnosticsProfile =>
      'Register ${report.domainLabel} diagnostics profile',
    BillingBusinessDomainPackReadinessIssueKind
        .missingReleaseWorkspaceProfile =>
      'Register ${report.domainLabel} release workspace profile',
    BillingBusinessDomainPackReadinessIssueKind
        .missingReleaseProfileSavedViewProfile =>
      'Register ${report.domainLabel} release profile saved views',
    BillingBusinessDomainPackReadinessIssueKind.missingReleaseGateLaneTarget =>
      'Map ${report.domainLabel} release gate lanes to diagnostics',
  };
}

int _moduleActionPriority(BillingDomainModuleReadinessIssueKind kind) {
  return switch (kind) {
    BillingDomainModuleReadinessIssueKind.profileValidation => 10,
    BillingDomainModuleReadinessIssueKind.missingScreenRegistry => 20,
    BillingDomainModuleReadinessIssueKind.emptyScreenRegistry => 25,
    BillingDomainModuleReadinessIssueKind.missingRegisteredScreens => 30,
    BillingDomainModuleReadinessIssueKind.navigationCoverage => 40,
    BillingDomainModuleReadinessIssueKind.missingLineItemAdapter => 60,
    BillingDomainModuleReadinessIssueKind.missingNavigationPolicy => 70,
    BillingDomainModuleReadinessIssueKind.missingIssuePolicy => 80,
    BillingDomainModuleReadinessIssueKind.missingPaymentSchedulePolicy => 90,
  };
}

int _packActionPriority(BillingBusinessDomainPackReadinessIssueKind kind) {
  return switch (kind) {
    BillingBusinessDomainPackReadinessIssueKind.missingDiagnosticsProfile => 95,
    BillingBusinessDomainPackReadinessIssueKind
        .missingReleaseWorkspaceProfile =>
      96,
    BillingBusinessDomainPackReadinessIssueKind
        .missingReleaseProfileSavedViewProfile =>
      97,
    BillingBusinessDomainPackReadinessIssueKind.missingReleaseGateLaneTarget =>
      98,
  };
}

List<BillingBusinessDomainPackRemediationAction> _sortRemediationActions(
  Iterable<BillingBusinessDomainPackRemediationAction> actions,
) {
  final sorted = actions.toList();
  sorted.sort((left, right) {
    final severity = _severityRank(
      left.severity,
    ).compareTo(_severityRank(right.severity));
    if (severity != 0) return severity;

    final priority = left.priority.compareTo(right.priority);
    if (priority != 0) return priority;

    final domain = left.domainKey.compareTo(right.domainKey);
    if (domain != 0) return domain;

    return left.id.compareTo(right.id);
  });

  return sorted;
}

int _severityRank(BillingDomainModuleReadinessIssueSeverity severity) {
  return switch (severity) {
    BillingDomainModuleReadinessIssueSeverity.blocker => 0,
    BillingDomainModuleReadinessIssueSeverity.warning => 1,
  };
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
