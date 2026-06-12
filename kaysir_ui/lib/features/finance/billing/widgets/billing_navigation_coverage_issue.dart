import '../models/billing_business_domain_profile.dart';
import 'billing_navigation_destination.dart';

enum BillingNavigationCoverageIssueKind {
  unavailable,
  missingPlan,
  unreachable,
}

class BillingNavigationCoverageIssue {
  final BillingBusinessDomainProfile profile;
  final BillingNavigationDestination destination;
  final List<BillingNavigationIssueSurfaceDecision> surfaceDecisions;

  BillingNavigationCoverageIssue({
    required this.profile,
    required this.destination,
    required Iterable<BillingNavigationIssueSurfaceDecision> surfaceDecisions,
  }) : surfaceDecisions = List.unmodifiable(surfaceDecisions);

  String get domainKey => profile.key;

  String get domainLabel => profile.label;

  BillingNavigationDestinationId get destinationId => destination.id;

  BillingNavigationCoverageIssueKind get kind {
    if (unavailableSurfaces.isNotEmpty) {
      return BillingNavigationCoverageIssueKind.unavailable;
    }
    if (missingPlanSurfaces.isNotEmpty) {
      return BillingNavigationCoverageIssueKind.missingPlan;
    }

    return BillingNavigationCoverageIssueKind.unreachable;
  }

  List<BillingNavigationSurface> get checkedSurfaces {
    return List.unmodifiable(
      surfaceDecisions.map((decision) => decision.surface),
    );
  }

  List<BillingNavigationSurface> get unavailableSurfaces {
    return List.unmodifiable(
      surfaceDecisions
          .where((decision) => decision.isUnavailable)
          .map((decision) => decision.surface),
    );
  }

  List<BillingNavigationSurface> get missingPlanSurfaces {
    return List.unmodifiable(
      surfaceDecisions
          .where((decision) => decision.isMissingPlan)
          .map((decision) => decision.surface),
    );
  }

  String? get disabledReason {
    for (final decision in surfaceDecisions) {
      final reason = decision.disabledReason;
      if (reason != null) return reason;
    }

    return null;
  }

  String get summary {
    final reason = disabledReason;
    if (reason == null) {
      return '${destination.label} is not reachable for $domainLabel.';
    }

    return '${destination.label} is not reachable for $domainLabel: $reason.';
  }
}

class BillingNavigationIssueSurfaceDecision {
  final BillingNavigationSurface surface;
  final bool isActionable;
  final bool isUnavailable;
  final bool isMissingPlan;
  final String? disabledReason;

  const BillingNavigationIssueSurfaceDecision({
    required this.surface,
    required this.isActionable,
    required this.isUnavailable,
    required this.isMissingPlan,
    this.disabledReason,
  });
}
