import '../models/billing_business_domain_profile.dart';
import '../widgets/billing_navigation_coverage.dart';
import '../widgets/billing_navigation_destination.dart';
import 'billing_business_domain_module_readiness.dart';
import 'billing_business_domain_pack.dart';

enum BillingBusinessDomainPackReadinessIssueKind {
  missingDiagnosticsProfile,
  missingReleaseWorkspaceProfile,
  missingReleaseProfileSavedViewProfile,
  missingReleaseGateLaneTarget,
}

/// Readiness issue raised by a billing domain pack contract audit.
class BillingBusinessDomainPackReadinessIssue {
  final BillingBusinessDomainPackReadinessIssueKind kind;
  final BillingDomainModuleReadinessIssueSeverity severity;
  final String message;
  final List<String> details;

  BillingBusinessDomainPackReadinessIssue({
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

/// Readiness report for one modular billing business-domain pack.
class BillingBusinessDomainPackReadinessReport {
  final BillingBusinessDomainPack pack;
  final BillingDomainModuleReadinessReport moduleReadiness;
  final List<BillingBusinessDomainPackReadinessIssue> packIssues;

  BillingBusinessDomainPackReadinessReport({
    required this.pack,
    required this.moduleReadiness,
    required Iterable<BillingBusinessDomainPackReadinessIssue> packIssues,
  }) : packIssues = List.unmodifiable(packIssues);

  factory BillingBusinessDomainPackReadinessReport.forPack(
    BillingBusinessDomainPack pack, {
    bool hasTenant = true,
    Iterable<BillingNavigationSurface> surfaces =
        billingNavigationCoverageSurfaces,
  }) {
    return BillingBusinessDomainPackReadinessReport(
      pack: pack,
      moduleReadiness: BillingDomainModuleReadinessReport.forModule(
        pack.module,
        hasTenant: hasTenant,
        surfaces: surfaces,
      ),
      packIssues: _packContractIssues(pack),
    );
  }

  String get packId => pack.id;

  String get domainKey => pack.domainKey;

  String get domainLabel => pack.profile.label;

  bool get isReady => blockerIssueCount == 0;

  bool get hasWarnings => warningIssueCount > 0;

  int get blockerIssueCount {
    return moduleReadiness.blockerIssueCount + packBlockerIssues.length;
  }

  int get warningIssueCount {
    return moduleReadiness.warningIssueCount + packWarningIssues.length;
  }

  List<BillingBusinessDomainPackReadinessIssue> get packBlockerIssues {
    return List.unmodifiable(packIssues.where((issue) => issue.isBlocker));
  }

  List<BillingBusinessDomainPackReadinessIssue> get packWarningIssues {
    return List.unmodifiable(packIssues.where((issue) => issue.isWarning));
  }

  BillingBusinessDomainPackReadinessIssue? issueForKind(
    BillingBusinessDomainPackReadinessIssueKind kind,
  ) {
    for (final issue in packIssues) {
      if (issue.kind == kind) return issue;
    }

    return null;
  }

  bool hasIssueKind(BillingBusinessDomainPackReadinessIssueKind kind) {
    return issueForKind(kind) != null;
  }

  String get summaryLabel {
    if (isReady && !hasWarnings) {
      return '$domainLabel billing pack is release-ready.';
    }
    if (isReady) {
      return '$domainLabel billing pack is release-ready with '
          '$warningIssueCount ${_plural(warningIssueCount, 'warning')}.';
    }

    return '$domainLabel billing pack has $blockerIssueCount '
        '${_plural(blockerIssueCount, 'blocker')} and $warningIssueCount '
        '${_plural(warningIssueCount, 'warning')}.';
  }
}

/// Aggregated readiness report for all registered billing domain packs.
class BillingBusinessDomainPackRegistryReadinessReport {
  final List<BillingBusinessDomainPackReadinessReport> packReports;

  BillingBusinessDomainPackRegistryReadinessReport({
    required Iterable<BillingBusinessDomainPackReadinessReport> packReports,
  }) : packReports = List.unmodifiable(packReports);

  factory BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
    BillingBusinessDomainPackRegistry registry, {
    bool hasTenant = true,
    Iterable<BillingNavigationSurface> surfaces =
        billingNavigationCoverageSurfaces,
  }) {
    return BillingBusinessDomainPackRegistryReadinessReport(
      packReports: registry.packs.map(
        (pack) => BillingBusinessDomainPackReadinessReport.forPack(
          pack,
          hasTenant: hasTenant,
          surfaces: surfaces,
        ),
      ),
    );
  }

  bool get isEmpty => packReports.isEmpty;

  bool get isReady => blockedPackReports.isEmpty;

  bool get hasWarnings => warningIssueCount > 0;

  int get blockerIssueCount {
    return packReports.fold(
      0,
      (total, report) => total + report.blockerIssueCount,
    );
  }

  int get warningIssueCount {
    return packReports.fold(
      0,
      (total, report) => total + report.warningIssueCount,
    );
  }

  List<String> get domainKeys {
    return List.unmodifiable(packReports.map((report) => report.domainKey));
  }

  List<String> get readyDomainKeys {
    return List.unmodifiable(
      packReports
          .where((report) => report.isReady)
          .map((report) => report.domainKey),
    );
  }

  List<String> get blockedDomainKeys {
    return List.unmodifiable(
      blockedPackReports.map((report) => report.domainKey),
    );
  }

  List<BillingBusinessDomainPackReadinessReport> get blockedPackReports {
    return List.unmodifiable(packReports.where((report) => !report.isReady));
  }

  BillingBusinessDomainPackReadinessReport? reportForDomain(String domain) {
    final key = billingBusinessDomainKey(domain);

    for (final report in packReports) {
      if (report.domainKey == key) return report;
    }

    return null;
  }

  BillingBusinessDomainPackReadinessReport requireReportForDomain(
    String domain,
  ) {
    final report = reportForDomain(domain);
    if (report == null) {
      throw StateError(
        'No billing pack readiness report is available for $domain.',
      );
    }

    return report;
  }

  String get summaryLabel {
    if (isEmpty) return 'No billing business domain packs are registered.';
    if (isReady && !hasWarnings) {
      return '${packReports.length} billing '
          '${_plural(packReports.length, 'pack')} '
          '${_beVerb(packReports.length)} release-ready.';
    }
    if (isReady) {
      return '${packReports.length} billing '
          '${_plural(packReports.length, 'pack')} '
          '${_beVerb(packReports.length)} release-ready with '
          '$warningIssueCount ${_plural(warningIssueCount, 'warning')}.';
    }

    return '${blockedPackReports.length} of ${packReports.length} billing '
        '${_plural(packReports.length, 'pack')} '
        '${_needVerb(blockedPackReports.length)} attention.';
  }
}

List<BillingBusinessDomainPackReadinessIssue> _packContractIssues(
  BillingBusinessDomainPack pack,
) {
  return [
    if (pack.diagnosticsProfile == null)
      BillingBusinessDomainPackReadinessIssue(
        kind:
            BillingBusinessDomainPackReadinessIssueKind
                .missingDiagnosticsProfile,
        severity: BillingDomainModuleReadinessIssueSeverity.warning,
        message:
            '${pack.profile.label} uses standard diagnostics without a '
            'domain-specific pack profile.',
      ),
    if (pack.releaseWorkspaceProfile == null)
      BillingBusinessDomainPackReadinessIssue(
        kind:
            BillingBusinessDomainPackReadinessIssueKind
                .missingReleaseWorkspaceProfile,
        severity: BillingDomainModuleReadinessIssueSeverity.warning,
        message:
            '${pack.profile.label} uses standard release workspace behavior '
            'without a domain-specific pack profile.',
      ),
    if (pack.releaseProfileSavedViewProfile == null)
      BillingBusinessDomainPackReadinessIssue(
        kind:
            BillingBusinessDomainPackReadinessIssueKind
                .missingReleaseProfileSavedViewProfile,
        severity: BillingDomainModuleReadinessIssueSeverity.warning,
        message:
            '${pack.profile.label} uses standard release profile saved views '
            'without a domain-specific preset profile.',
      ),
    ..._releaseGateLaneTargetIssues(pack),
  ];
}

List<BillingBusinessDomainPackReadinessIssue> _releaseGateLaneTargetIssues(
  BillingBusinessDomainPack pack,
) {
  if (pack.releaseGateLanes.isEmpty) return const [];

  final targetedLaneIds =
      pack.releaseGateLaneTargets.map((target) => target.laneId).toSet();
  final untargetedLaneIds =
      pack.releaseGateLanes
          .map((lane) => lane.id)
          .where((laneId) => !targetedLaneIds.contains(laneId))
          .toList();

  if (untargetedLaneIds.isEmpty) return const [];

  return [
    BillingBusinessDomainPackReadinessIssue(
      kind:
          BillingBusinessDomainPackReadinessIssueKind
              .missingReleaseGateLaneTarget,
      severity: BillingDomainModuleReadinessIssueSeverity.warning,
      message:
          '${pack.profile.label} has release gate lanes without diagnostics '
          'navigation targets.',
      details: untargetedLaneIds,
    ),
  ];
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
