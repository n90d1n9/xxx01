import 'billing_route_contract.dart';
import 'billing_route_contract_remediation.dart';
import 'billing_route_execution_contract.dart';
import 'billing_route_extension_manifest.dart';
import 'billing_route_extension_manifest_remediation.dart';

const billingReleaseGateRouteContractLaneId = 'route-contract';
const billingReleaseGateRouteExecutionLaneId = 'route-execution';
const billingReleaseGateRouteExtensionManifestLaneId =
    'route-extension-manifests';

/// Release gate status for a billing readiness lane or aggregate report.
enum BillingReleaseGateStatus { ready, hardening, blocked }

/// A single release-readiness lane within the billing release gate.
class BillingReleaseGateLane {
  final String id;
  final String title;
  final BillingReleaseGateStatus status;
  final String summaryLabel;
  final int blockerCount;
  final int warningCount;
  final int actionCount;
  final int priority;

  const BillingReleaseGateLane({
    required this.id,
    required this.title,
    required this.status,
    required this.summaryLabel,
    required this.blockerCount,
    required this.warningCount,
    required this.actionCount,
    required this.priority,
  }) : assert(blockerCount >= 0),
       assert(warningCount >= 0),
       assert(actionCount >= 0);

  bool get isReady => status == BillingReleaseGateStatus.ready;

  bool get isHardening => status == BillingReleaseGateStatus.hardening;

  bool get isBlocked => status == BillingReleaseGateStatus.blocked;
}

/// Aggregates billing launch readiness across route and extension surfaces.
class BillingReleaseGateReport {
  final List<BillingReleaseGateLane> lanes;

  BillingReleaseGateReport({required Iterable<BillingReleaseGateLane> lanes})
    : lanes = List.unmodifiable(_sortLanes(lanes));

  factory BillingReleaseGateReport.forRouting({
    required BillingRouteContractReport routeContractReport,
    required BillingRouteExecutionReport routeExecutionReport,
    required BillingRouteExtensionManifestReport routeExtensionManifestReport,
    BillingRouteContractRemediationPlan? routeContractRemediationPlan,
    BillingRouteExtensionManifestRemediationPlan?
    routeExtensionManifestRemediationPlan,
    Iterable<BillingReleaseGateLane> extensions = const [],
  }) {
    final contractPlan =
        routeContractRemediationPlan ??
        BillingRouteContractRemediationPlan.forReport(routeContractReport);
    final manifestPlan =
        routeExtensionManifestRemediationPlan ??
        BillingRouteExtensionManifestRemediationPlan.forReport(
          routeExtensionManifestReport,
        );

    return BillingReleaseGateReport(
      lanes: [
        BillingReleaseGateLane(
          id: billingReleaseGateRouteContractLaneId,
          title: 'Route contract',
          status: _statusForCounts(
            blockerCount: routeContractReport.blockerIssues.length,
            warningCount: routeContractReport.warningIssues.length,
          ),
          summaryLabel: routeContractReport.summaryLabel,
          blockerCount: routeContractReport.blockerIssues.length,
          warningCount: routeContractReport.warningIssues.length,
          actionCount: contractPlan.actionCount,
          priority: 100,
        ),
        BillingReleaseGateLane(
          id: billingReleaseGateRouteExecutionLaneId,
          title: 'Route execution',
          status:
              routeExecutionReport.isReady
                  ? BillingReleaseGateStatus.ready
                  : BillingReleaseGateStatus.blocked,
          summaryLabel: routeExecutionReport.summaryLabel,
          blockerCount: routeExecutionReport.issues.length,
          warningCount: 0,
          actionCount: routeExecutionReport.issues.length,
          priority: 200,
        ),
        BillingReleaseGateLane(
          id: billingReleaseGateRouteExtensionManifestLaneId,
          title: 'Route extension manifests',
          status: _statusForCounts(
            blockerCount: routeExtensionManifestReport.blockerIssues.length,
            warningCount: routeExtensionManifestReport.warningIssues.length,
          ),
          summaryLabel: routeExtensionManifestReport.summaryLabel,
          blockerCount: routeExtensionManifestReport.blockerIssues.length,
          warningCount: routeExtensionManifestReport.warningIssues.length,
          actionCount: manifestPlan.actionCount,
          priority: 300,
        ),
        ...extensions,
      ],
    );
  }

  BillingReleaseGateStatus get status {
    if (blockedLanes.isNotEmpty) return BillingReleaseGateStatus.blocked;
    if (hardeningLanes.isNotEmpty) return BillingReleaseGateStatus.hardening;

    return BillingReleaseGateStatus.ready;
  }

  bool get isReady => status == BillingReleaseGateStatus.ready;

  bool get hasBlockers => blockedLanes.isNotEmpty;

  bool get hasWarnings => hardeningLanes.isNotEmpty;

  int get laneCount => lanes.length;

  int get blockerCount {
    return lanes.fold<int>(0, (total, lane) => total + lane.blockerCount);
  }

  int get warningCount {
    return lanes.fold<int>(0, (total, lane) => total + lane.warningCount);
  }

  int get actionCount {
    return lanes.fold<int>(0, (total, lane) => total + lane.actionCount);
  }

  List<BillingReleaseGateLane> get readyLanes {
    return List.unmodifiable(lanes.where((lane) => lane.isReady));
  }

  List<BillingReleaseGateLane> get hardeningLanes {
    return List.unmodifiable(lanes.where((lane) => lane.isHardening));
  }

  List<BillingReleaseGateLane> get blockedLanes {
    return List.unmodifiable(lanes.where((lane) => lane.isBlocked));
  }

  BillingReleaseGateLane? laneForId(String id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;

    for (final lane in lanes) {
      if (lane.id == normalizedId) return lane;
    }

    return null;
  }

  String get summaryLabel {
    return switch (status) {
      BillingReleaseGateStatus.ready =>
        'Billing release gate is ready across '
            '$laneCount ${_plural(laneCount, 'lane')}.',
      BillingReleaseGateStatus.hardening =>
        'Billing release gate is launch-ready with '
            '$warningCount ${_plural(warningCount, 'warning')} across '
            '${hardeningLanes.length} ${_plural(hardeningLanes.length, 'lane')}.',
      BillingReleaseGateStatus.blocked =>
        'Billing release gate is blocked by '
            '$blockerCount ${_plural(blockerCount, 'blocker')} across '
            '${blockedLanes.length} ${_plural(blockedLanes.length, 'lane')}.',
    };
  }
}

BillingReleaseGateStatus _statusForCounts({
  required int blockerCount,
  required int warningCount,
}) {
  if (blockerCount > 0) return BillingReleaseGateStatus.blocked;
  if (warningCount > 0) return BillingReleaseGateStatus.hardening;

  return BillingReleaseGateStatus.ready;
}

List<BillingReleaseGateLane> _sortLanes(
  Iterable<BillingReleaseGateLane> lanes,
) {
  final sorted = lanes.toList();
  sorted.sort((left, right) {
    final priority = left.priority.compareTo(right.priority);
    if (priority != 0) return priority;

    return left.id.compareTo(right.id);
  });

  return sorted;
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
