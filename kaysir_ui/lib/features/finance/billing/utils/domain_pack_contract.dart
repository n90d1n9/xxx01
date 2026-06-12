import '../widgets/billing_navigation_coverage.dart';
import '../widgets/billing_navigation_destination.dart';
import 'billing_business_domain_module_readiness.dart';
import 'billing_business_domain_pack.dart';
import 'billing_business_domain_pack_readiness.dart';

const domainPackContractModuleReadinessId = 'module-readiness';
const domainPackContractDiagnosticsProfileId = 'diagnostics-profile';
const domainPackContractReleaseWorkspaceProfileId = 'release-workspace-profile';
const domainPackContractReleaseProfileSavedViewsId =
    'release-profile-saved-views';
const domainPackContractReleaseGateTargetsId = 'release-gate-targets';

/// Result state for a single billing domain-pack contract requirement.
enum DomainPackContractStatus { satisfied, warning, blocked }

/// Human-readable contract requirement used by diagnostics and pack tests.
class DomainPackContractRequirement {
  final String id;
  final String label;
  final DomainPackContractStatus status;
  final String message;
  final List<String> details;

  DomainPackContractRequirement({
    required this.id,
    required this.label,
    required this.status,
    required this.message,
    Iterable<String> details = const [],
  }) : details = List.unmodifiable(details);

  bool get isSatisfied {
    return status == DomainPackContractStatus.satisfied;
  }

  bool get isWarning {
    return status == DomainPackContractStatus.warning;
  }

  bool get isBlocked {
    return status == DomainPackContractStatus.blocked;
  }

  String get statusLabel {
    return switch (status) {
      DomainPackContractStatus.satisfied => 'Ready',
      DomainPackContractStatus.warning => 'Hardening',
      DomainPackContractStatus.blocked => 'Blocked',
    };
  }
}

/// Checklist-style contract report for one billing business-domain pack.
class DomainPackContractReport {
  final BillingBusinessDomainPackReadinessReport readinessReport;
  final List<DomainPackContractRequirement> requirements;

  DomainPackContractReport({
    required this.readinessReport,
    required Iterable<DomainPackContractRequirement> requirements,
  }) : requirements = List.unmodifiable(requirements);

  factory DomainPackContractReport.forPack(
    BillingBusinessDomainPack pack, {
    bool hasTenant = true,
    Iterable<BillingNavigationSurface> surfaces =
        billingNavigationCoverageSurfaces,
  }) {
    return DomainPackContractReport.fromReadiness(
      BillingBusinessDomainPackReadinessReport.forPack(
        pack,
        hasTenant: hasTenant,
        surfaces: surfaces,
      ),
    );
  }

  factory DomainPackContractReport.fromReadiness(
    BillingBusinessDomainPackReadinessReport readinessReport,
  ) {
    return DomainPackContractReport(
      readinessReport: readinessReport,
      requirements: _requirementsForReadiness(readinessReport),
    );
  }

  String get packId => readinessReport.packId;

  String get domainKey => readinessReport.domainKey;

  String get domainLabel => readinessReport.domainLabel;

  bool get isReleaseReady => blockedRequirements.isEmpty;

  bool get isFullySpecified => openRequirements.isEmpty;

  int get openRequirementCount => openRequirements.length;

  int get blockedRequirementCount => blockedRequirements.length;

  int get warningRequirementCount => warningRequirements.length;

  List<DomainPackContractRequirement> get openRequirements {
    return List.unmodifiable(
      requirements.where((requirement) {
        return !requirement.isSatisfied;
      }),
    );
  }

  List<DomainPackContractRequirement> get blockedRequirements {
    return List.unmodifiable(
      requirements.where((requirement) {
        return requirement.isBlocked;
      }),
    );
  }

  List<DomainPackContractRequirement> get warningRequirements {
    return List.unmodifiable(
      requirements.where((requirement) {
        return requirement.isWarning;
      }),
    );
  }

  DomainPackContractRequirement? requirementForId(String id) {
    for (final requirement in requirements) {
      if (requirement.id == id) return requirement;
    }

    return null;
  }

  DomainPackContractRequirement requireRequirement(String id) {
    final requirement = requirementForId(id);
    if (requirement == null) {
      throw StateError('No billing domain-pack contract requirement for $id.');
    }

    return requirement;
  }

  String get summaryLabel {
    if (isFullySpecified) {
      return '$domainLabel billing pack contract is fully specified.';
    }
    if (isReleaseReady) {
      return '$domainLabel billing pack contract is release-ready with '
          '$warningRequirementCount '
          '${_plural(warningRequirementCount, 'hardening requirement')}.';
    }

    return '$domainLabel billing pack contract has '
        '$blockedRequirementCount '
        '${_plural(blockedRequirementCount, 'blocked requirement')} and '
        '$warningRequirementCount '
        '${_plural(warningRequirementCount, 'hardening requirement')}.';
  }
}

/// Aggregated contract report for a billing domain-pack registry.
class DomainPackContractRegistryReport {
  final List<DomainPackContractReport> packReports;

  DomainPackContractRegistryReport({
    required Iterable<DomainPackContractReport> packReports,
  }) : packReports = List.unmodifiable(packReports);

  factory DomainPackContractRegistryReport.forRegistry(
    BillingBusinessDomainPackRegistry registry, {
    bool hasTenant = true,
    Iterable<BillingNavigationSurface> surfaces =
        billingNavigationCoverageSurfaces,
  }) {
    return DomainPackContractRegistryReport(
      packReports: registry.packs.map(
        (pack) => DomainPackContractReport.forPack(
          pack,
          hasTenant: hasTenant,
          surfaces: surfaces,
        ),
      ),
    );
  }

  factory DomainPackContractRegistryReport.fromReadiness(
    BillingBusinessDomainPackRegistryReadinessReport readinessReport,
  ) {
    return DomainPackContractRegistryReport(
      packReports: readinessReport.packReports.map(
        DomainPackContractReport.fromReadiness,
      ),
    );
  }

  bool get isEmpty => packReports.isEmpty;

  bool get isReleaseReady => blockedPackReports.isEmpty;

  bool get isFullySpecified => openRequirements.isEmpty;

  int get openRequirementCount => openRequirements.length;

  int get blockedRequirementCount => blockedRequirements.length;

  int get warningRequirementCount => warningRequirements.length;

  List<String> get domainKeys {
    return List.unmodifiable(packReports.map((report) => report.domainKey));
  }

  List<String> get blockedDomainKeys {
    return List.unmodifiable(
      blockedPackReports.map((report) => report.domainKey),
    );
  }

  List<String> get warningDomainKeys {
    return List.unmodifiable(
      packReports
          .where((report) => report.warningRequirements.isNotEmpty)
          .map((report) => report.domainKey),
    );
  }

  List<DomainPackContractRequirement> get openRequirements {
    return List.unmodifiable(
      packReports.expand((report) => report.openRequirements),
    );
  }

  List<DomainPackContractRequirement> get blockedRequirements {
    return List.unmodifiable(
      packReports.expand((report) => report.blockedRequirements),
    );
  }

  List<DomainPackContractRequirement> get warningRequirements {
    return List.unmodifiable(
      packReports.expand((report) => report.warningRequirements),
    );
  }

  List<DomainPackContractReport> get blockedPackReports {
    return List.unmodifiable(
      packReports.where((report) => !report.isReleaseReady),
    );
  }

  DomainPackContractReport? reportForDomain(String domain) {
    final key = domain.trim().toLowerCase();

    for (final report in packReports) {
      if (report.domainKey == key) return report;
    }

    return null;
  }

  DomainPackContractReport requireReportForDomain(String domain) {
    final report = reportForDomain(domain);
    if (report == null) {
      throw StateError(
        'No billing domain-pack contract report is available for $domain.',
      );
    }

    return report;
  }

  String get summaryLabel {
    if (isEmpty) return 'No billing domain-pack contracts are registered.';
    if (isFullySpecified) {
      return '${packReports.length} billing domain-pack '
          '${_plural(packReports.length, 'contract')} '
          '${_beVerb(packReports.length)} fully specified.';
    }
    if (isReleaseReady) {
      return '${packReports.length} billing domain-pack '
          '${_plural(packReports.length, 'contract')} '
          '${_beVerb(packReports.length)} release-ready with '
          '$warningRequirementCount '
          '${_plural(warningRequirementCount, 'hardening requirement')}.';
    }

    return '${blockedPackReports.length} of ${packReports.length} billing '
        'domain-pack ${_plural(packReports.length, 'contract')} '
        '${_needVerb(blockedPackReports.length)} contract attention.';
  }
}

List<DomainPackContractRequirement> _requirementsForReadiness(
  BillingBusinessDomainPackReadinessReport readinessReport,
) {
  return [
    _moduleRequirement(readinessReport),
    _packRequirement(
      readinessReport,
      id: domainPackContractDiagnosticsProfileId,
      label: 'Diagnostics contract',
      readyMessage:
          '${readinessReport.domainLabel} has a diagnostics profile contract.',
      issueKind:
          BillingBusinessDomainPackReadinessIssueKind.missingDiagnosticsProfile,
      readyDetails: _diagnosticsProfileDetails(readinessReport.pack),
    ),
    _packRequirement(
      readinessReport,
      id: domainPackContractReleaseWorkspaceProfileId,
      label: 'Release workspace',
      readyMessage:
          '${readinessReport.domainLabel} has a release workspace profile.',
      issueKind:
          BillingBusinessDomainPackReadinessIssueKind
              .missingReleaseWorkspaceProfile,
      readyDetails: _releaseWorkspaceProfileDetails(readinessReport.pack),
    ),
    _packRequirement(
      readinessReport,
      id: domainPackContractReleaseProfileSavedViewsId,
      label: 'Release profile views',
      readyMessage:
          '${readinessReport.domainLabel} has release profile saved views.',
      issueKind:
          BillingBusinessDomainPackReadinessIssueKind
              .missingReleaseProfileSavedViewProfile,
      readyDetails: _releaseProfileSavedViewDetails(readinessReport.pack),
    ),
    _packRequirement(
      readinessReport,
      id: domainPackContractReleaseGateTargetsId,
      label: 'Release gate targets',
      readyMessage: _releaseGateTargetReadyMessage(readinessReport.pack),
      issueKind:
          BillingBusinessDomainPackReadinessIssueKind
              .missingReleaseGateLaneTarget,
      readyDetails: _releaseGateTargetReadyDetails(readinessReport.pack),
    ),
  ];
}

DomainPackContractRequirement _moduleRequirement(
  BillingBusinessDomainPackReadinessReport readinessReport,
) {
  final moduleReadiness = readinessReport.moduleReadiness;
  if (moduleReadiness.issues.isEmpty) {
    return DomainPackContractRequirement(
      id: domainPackContractModuleReadinessId,
      label: 'Module contract',
      status: DomainPackContractStatus.satisfied,
      message: moduleReadiness.summaryLabel,
    );
  }

  return DomainPackContractRequirement(
    id: domainPackContractModuleReadinessId,
    label: 'Module contract',
    status:
        moduleReadiness.blockerIssues.isNotEmpty
            ? DomainPackContractStatus.blocked
            : DomainPackContractStatus.warning,
    message: moduleReadiness.summaryLabel,
    details: moduleReadiness.issues.map((issue) => issue.message),
  );
}

DomainPackContractRequirement _packRequirement(
  BillingBusinessDomainPackReadinessReport readinessReport, {
  required String id,
  required String label,
  required String readyMessage,
  required BillingBusinessDomainPackReadinessIssueKind issueKind,
  Iterable<String> readyDetails = const [],
}) {
  final issue = readinessReport.issueForKind(issueKind);
  if (issue == null) {
    return DomainPackContractRequirement(
      id: id,
      label: label,
      status: DomainPackContractStatus.satisfied,
      message: readyMessage,
      details: readyDetails,
    );
  }

  return DomainPackContractRequirement(
    id: id,
    label: label,
    status: _statusForSeverity(issue.severity),
    message: issue.message,
    details: issue.details,
  );
}

DomainPackContractStatus _statusForSeverity(
  BillingDomainModuleReadinessIssueSeverity severity,
) {
  return switch (severity) {
    BillingDomainModuleReadinessIssueSeverity.blocker =>
      DomainPackContractStatus.blocked,
    BillingDomainModuleReadinessIssueSeverity.warning =>
      DomainPackContractStatus.warning,
  };
}

List<String> _diagnosticsProfileDetails(BillingBusinessDomainPack pack) {
  final profile = pack.diagnosticsProfile;
  if (profile == null) return const [];

  return ['${profile.id} · ${profile.businessDomains.join(', ')}'];
}

List<String> _releaseWorkspaceProfileDetails(BillingBusinessDomainPack pack) {
  final profile = pack.releaseWorkspaceProfile;
  if (profile == null) return const [];

  return [profile.buildContract().summaryLabel];
}

List<String> _releaseProfileSavedViewDetails(BillingBusinessDomainPack pack) {
  final profile = pack.releaseProfileSavedViewProfile;
  if (profile == null) return const [];

  final viewCount = profile.buildRegistry().views.length;
  return ['${profile.id} · ${_countLabel(viewCount, 'view')}'];
}

String _releaseGateTargetReadyMessage(BillingBusinessDomainPack pack) {
  if (pack.releaseGateLanes.isEmpty) {
    return '${pack.profile.label} has no pack release gate lanes to target.';
  }

  return '${pack.profile.label} release gate lanes can navigate to '
      'diagnostics.';
}

List<String> _releaseGateTargetReadyDetails(BillingBusinessDomainPack pack) {
  if (pack.releaseGateLanes.isEmpty) return const [];

  return List.unmodifiable(pack.releaseGateLanes.map((lane) => lane.id));
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

String _countLabel(int count, String noun) {
  return '$count ${_plural(count, noun)}';
}

String _beVerb(int count) {
  return count == 1 ? 'is' : 'are';
}

String _needVerb(int count) {
  return count == 1 ? 'needs' : 'need';
}
