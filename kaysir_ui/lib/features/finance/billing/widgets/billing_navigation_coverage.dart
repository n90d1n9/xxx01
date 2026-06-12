import '../models/billing_business_domain_module.dart';
import '../models/billing_business_domain_profile.dart';
import 'billing_domain_navigation_policy.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_dispatch_plan.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_coverage_issue.dart';
import 'billing_navigation_coverage_summary.dart';
import 'billing_navigation_launch_planner.dart';

export 'billing_navigation_coverage_issue.dart';
export 'billing_navigation_coverage_summary.dart';

const billingNavigationCoverageSurfaces = [
  BillingNavigationSurface.dashboard,
  BillingNavigationSurface.productWorkspace,
];

class BillingNavigationRegistryCoverageReport {
  final bool hasTenant;
  final List<BillingNavigationCoverageReport> moduleReports;

  BillingNavigationRegistryCoverageReport({
    required this.hasTenant,
    required Iterable<BillingNavigationCoverageReport> moduleReports,
  }) : moduleReports = List.unmodifiable(moduleReports);

  factory BillingNavigationRegistryCoverageReport.forRegistry(
    BillingBusinessDomainModuleRegistry registry, {
    bool hasTenant = true,
    Iterable<BillingNavigationSurface> surfaces =
        billingNavigationCoverageSurfaces,
  }) {
    return BillingNavigationRegistryCoverageReport(
      hasTenant: hasTenant,
      moduleReports: registry.modules.map(
        (module) => BillingNavigationCoverageReport.forModule(
          module,
          hasTenant: hasTenant,
          surfaces: surfaces,
        ),
      ),
    );
  }

  bool get isEmpty => moduleReports.isEmpty;

  bool get isComplete => incompleteModuleReports.isEmpty;

  bool get hasIssues => issues.isNotEmpty;

  List<BillingNavigationCoverageIssue> get issues {
    return List.unmodifiable(moduleReports.expand((report) => report.issues));
  }

  BillingNavigationCoverageSummary get summary {
    return BillingNavigationCoverageSummary(issues: issues);
  }

  List<String> get domainKeys {
    return List.unmodifiable(
      moduleReports.map((report) => report.navigationSet.profile.key),
    );
  }

  List<BillingNavigationCoverageReport> get completeModuleReports {
    return List.unmodifiable(
      moduleReports.where((report) => report.isComplete),
    );
  }

  List<BillingNavigationCoverageReport> get incompleteModuleReports {
    return List.unmodifiable(
      moduleReports.where((report) => !report.isComplete),
    );
  }

  List<String> get completeDomainKeys {
    return List.unmodifiable(
      completeModuleReports.map((report) => report.navigationSet.profile.key),
    );
  }

  List<String> get incompleteDomainKeys {
    return List.unmodifiable(
      incompleteModuleReports.map((report) => report.navigationSet.profile.key),
    );
  }

  BillingNavigationCoverageReport? reportForDomain(String domain) {
    final key = billingBusinessDomainKey(domain);

    for (final report in moduleReports) {
      if (report.navigationSet.profile.key == key) return report;
    }

    return null;
  }

  List<BillingNavigationCoverageIssue> issuesForDomain(String domain) {
    return reportForDomain(domain)?.issues ?? const [];
  }

  BillingNavigationCoverageReport requireReportForDomain(String domain) {
    final report = reportForDomain(domain);
    if (report == null) {
      throw StateError(
        'No billing navigation coverage report is available for $domain.',
      );
    }

    return report;
  }
}

class BillingNavigationCoverageReport {
  final BillingDomainNavigationSet navigationSet;
  final bool hasTenant;
  final List<BillingNavigationSurfaceCoverage> surfaceCoverages;

  BillingNavigationCoverageReport({
    required this.navigationSet,
    required this.hasTenant,
    required Iterable<BillingNavigationSurfaceCoverage> surfaceCoverages,
  }) : surfaceCoverages = List.unmodifiable(surfaceCoverages);

  factory BillingNavigationCoverageReport.forModule(
    BillingBusinessDomainModule module, {
    bool hasTenant = true,
    Iterable<BillingNavigationSurface> surfaces =
        billingNavigationCoverageSurfaces,
  }) {
    return BillingNavigationCoverageReport.forNavigationSet(
      navigationSet: billingDomainNavigationSetForModule(module),
      hasTenant: hasTenant,
      surfaces: surfaces,
    );
  }

  factory BillingNavigationCoverageReport.forNavigationSet({
    required BillingDomainNavigationSet navigationSet,
    bool hasTenant = true,
    Iterable<BillingNavigationSurface> surfaces =
        billingNavigationCoverageSurfaces,
  }) {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: hasTenant,
      navigationSet: navigationSet,
    );

    return BillingNavigationCoverageReport(
      navigationSet: navigationSet,
      hasTenant: hasTenant,
      surfaceCoverages: _uniqueSurfaces(surfaces).map(
        (surface) => BillingNavigationSurfaceCoverage(
          snapshot: planner.destinationDispatchSnapshot(
            currentSurface: surface,
          ),
        ),
      ),
    );
  }

  List<BillingNavigationDestinationId> get destinationIds {
    return List.unmodifiable(
      navigationSet.destinations.map((destination) => destination.id),
    );
  }

  List<BillingNavigationDestinationCoverage> get destinationCoverages {
    return List.unmodifiable(destinationIds.map(coverageFor));
  }

  List<BillingNavigationDestinationCoverage> get reachableDestinationCoverages {
    return List.unmodifiable(
      destinationCoverages.where((coverage) => coverage.isReachable),
    );
  }

  List<BillingNavigationDestinationCoverage>
  get unreachableDestinationCoverages {
    return List.unmodifiable(
      destinationCoverages.where((coverage) => !coverage.isReachable),
    );
  }

  List<BillingNavigationDestinationId> get reachableDestinationIds {
    return List.unmodifiable(
      reachableDestinationCoverages.map((coverage) => coverage.destinationId),
    );
  }

  List<BillingNavigationDestinationId> get unreachableDestinationIds {
    return List.unmodifiable(
      unreachableDestinationCoverages.map((coverage) => coverage.destinationId),
    );
  }

  bool get isComplete => unreachableDestinationCoverages.isEmpty;

  bool get hasIssues => issues.isNotEmpty;

  List<BillingNavigationCoverageIssue> get issues {
    return List.unmodifiable(
      unreachableDestinationCoverages.map(
        (coverage) => BillingNavigationCoverageIssue(
          profile: navigationSet.profile,
          destination: coverage.destination,
          surfaceDecisions: coverage.issueSurfaceDecisions,
        ),
      ),
    );
  }

  BillingNavigationCoverageSummary get summary {
    return BillingNavigationCoverageSummary(issues: issues);
  }

  BillingNavigationDestinationCoverage coverageFor(
    BillingNavigationDestinationId destinationId,
  ) {
    return BillingNavigationDestinationCoverage(
      destination: billingNavigationDestinationFor(destinationId),
      surfacePlans: surfaceCoverages.map(
        (coverage) => BillingNavigationSurfacePlan(
          surface: coverage.surface,
          plan: coverage.planFor(destinationId),
        ),
      ),
    );
  }
}

class BillingNavigationSurfaceCoverage {
  final BillingNavigationDispatchSnapshot snapshot;

  const BillingNavigationSurfaceCoverage({required this.snapshot});

  BillingNavigationSurface get surface => snapshot.currentSurface;

  List<BillingNavigationDestinationId> get destinationIds {
    return snapshot.destinationIds;
  }

  List<BillingNavigationDestinationId> get actionableDestinationIds {
    return List.unmodifiable(
      snapshot.actionablePlans.map((plan) => plan.destinationId),
    );
  }

  BillingNavigationDispatchPlan? planFor(
    BillingNavigationDestinationId destinationId,
  ) {
    return snapshot.planFor(destinationId);
  }

  bool reaches(BillingNavigationDestinationId destinationId) {
    return planFor(destinationId)?.isActionable ?? false;
  }
}

class BillingNavigationDestinationCoverage {
  final BillingNavigationDestination destination;
  final List<BillingNavigationSurfacePlan> surfacePlans;

  BillingNavigationDestinationCoverage({
    required this.destination,
    required Iterable<BillingNavigationSurfacePlan> surfacePlans,
  }) : surfacePlans = List.unmodifiable(surfacePlans);

  BillingNavigationDestinationId get destinationId => destination.id;

  List<BillingNavigationSurfacePlan> get actionableSurfacePlans {
    return List.unmodifiable(
      surfacePlans.where((surfacePlan) => surfacePlan.isActionable),
    );
  }

  List<BillingNavigationSurfacePlan> get unavailableSurfacePlans {
    return List.unmodifiable(
      surfacePlans.where((surfacePlan) => surfacePlan.isUnavailable),
    );
  }

  List<BillingNavigationSurface> get actionableSurfaces {
    return List.unmodifiable(
      actionableSurfacePlans.map((surfacePlan) => surfacePlan.surface),
    );
  }

  List<BillingNavigationSurface> get localSurfaces {
    return List.unmodifiable(
      surfacePlans
          .where((surfacePlan) => surfacePlan.plan?.isLocal ?? false)
          .map((surfacePlan) => surfacePlan.surface),
    );
  }

  List<BillingNavigationSurface> get routeSurfaces {
    return List.unmodifiable(
      surfacePlans
          .where((surfacePlan) => surfacePlan.plan?.opensRoute ?? false)
          .map((surfacePlan) => surfacePlan.surface),
    );
  }

  bool get isReachable => actionableSurfacePlans.isNotEmpty;

  List<BillingNavigationIssueSurfaceDecision> get issueSurfaceDecisions {
    return List.unmodifiable(
      surfacePlans.map((surfacePlan) {
        final plan = surfacePlan.plan;
        return BillingNavigationIssueSurfaceDecision(
          surface: surfacePlan.surface,
          isActionable: surfacePlan.isActionable,
          isUnavailable: surfacePlan.isUnavailable,
          isMissingPlan: plan == null,
          disabledReason: plan?.disabledReason,
        );
      }),
    );
  }

  String? get disabledReason {
    for (final surfacePlan in unavailableSurfacePlans) {
      final reason = surfacePlan.plan?.disabledReason;
      if (reason != null) return reason;
    }

    return null;
  }
}

class BillingNavigationSurfacePlan {
  final BillingNavigationSurface surface;
  final BillingNavigationDispatchPlan? plan;

  const BillingNavigationSurfacePlan({required this.surface, this.plan});

  bool get isActionable => plan?.isActionable ?? false;

  bool get isUnavailable => plan?.isUnavailable ?? false;
}

List<BillingNavigationSurface> _uniqueSurfaces(
  Iterable<BillingNavigationSurface> surfaces,
) {
  final seen = <BillingNavigationSurface>{};
  final uniqueSurfaces = <BillingNavigationSurface>[];

  for (final surface in surfaces) {
    if (seen.add(surface)) uniqueSurfaces.add(surface);
  }

  return List.unmodifiable(uniqueSurfaces);
}
