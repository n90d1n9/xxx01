enum WorkforcePlanStatus { onTrack, watch, gap, overPlan }

enum PositionRequestStatus { draft, awaitingApproval, approved, blocked }

enum CapacityRiskLevel { low, medium, high }

enum ScenarioConfidence { low, medium, high }

class HeadcountPlan {
  final String id;
  final String department;
  final String ownerName;
  final int planned;
  final int actual;
  final int forecast;
  final int budget;
  final WorkforcePlanStatus status;

  const HeadcountPlan({
    required this.id,
    required this.department,
    required this.ownerName,
    required this.planned,
    required this.actual,
    required this.forecast,
    required this.budget,
    required this.status,
  });

  int get variance => actual - planned;

  int get forecastGap {
    final value = planned - forecast;
    return value < 0 ? 0 : value;
  }

  double get utilizationRate => planned == 0 ? 0 : actual / planned;

  double get forecastRate => planned == 0 ? 0 : forecast / planned;
}

class PositionRequest {
  final String id;
  final String title;
  final String department;
  final String hiringManager;
  final int requestedHeadcount;
  final int approvedHeadcount;
  final DateTime targetStartDate;
  final PositionRequestStatus status;

  const PositionRequest({
    required this.id,
    required this.title,
    required this.department,
    required this.hiringManager,
    required this.requestedHeadcount,
    required this.approvedHeadcount,
    required this.targetStartDate,
    required this.status,
  });

  int get remainingHeadcount {
    final value = requestedHeadcount - approvedHeadcount;
    return value < 0 ? 0 : value;
  }
}

class CapacityRisk {
  final String id;
  final String department;
  final String signal;
  final String ownerName;
  final int currentLoad;
  final int targetLoad;
  final String mitigation;
  final CapacityRiskLevel riskLevel;

  const CapacityRisk({
    required this.id,
    required this.department,
    required this.signal,
    required this.ownerName,
    required this.currentLoad,
    required this.targetLoad,
    required this.mitigation,
    required this.riskLevel,
  });

  int get loadDelta => currentLoad - targetLoad;

  double get loadRate => targetLoad == 0 ? 0 : currentLoad / targetLoad;
}

class WorkforceScenario {
  final String id;
  final String name;
  final String department;
  final String assumption;
  final int projectedHeadcount;
  final int projectedCost;
  final int impactScore;
  final ScenarioConfidence confidence;

  const WorkforceScenario({
    required this.id,
    required this.name,
    required this.department,
    required this.assumption,
    required this.projectedHeadcount,
    required this.projectedCost,
    required this.impactScore,
    required this.confidence,
  });
}

class WorkforcePlanningSummary {
  final int totalPlanned;
  final int totalActual;
  final int forecastGap;
  final int openPositions;
  final int pendingApprovals;
  final int highRisks;
  final int budgetAtRisk;

  const WorkforcePlanningSummary({
    required this.totalPlanned,
    required this.totalActual,
    required this.forecastGap,
    required this.openPositions,
    required this.pendingApprovals,
    required this.highRisks,
    required this.budgetAtRisk,
  });
}

class WorkforcePlanningRiskSummary {
  final int planExceptions;
  final int blockedRequests;
  final int pendingApprovals;
  final int highCapacityRisks;
  final int lowConfidenceScenarios;
  final int startsWithinThirtyDays;

  const WorkforcePlanningRiskSummary({
    required this.planExceptions,
    required this.blockedRequests,
    required this.pendingApprovals,
    required this.highCapacityRisks,
    required this.lowConfidenceScenarios,
    required this.startsWithinThirtyDays,
  });

  int get totalRisks =>
      planExceptions +
      blockedRequests +
      pendingApprovals +
      highCapacityRisks +
      lowConfidenceScenarios;

  factory WorkforcePlanningRiskSummary.fromData({
    required List<HeadcountPlan> plans,
    required List<PositionRequest> positions,
    required List<CapacityRisk> risks,
    required List<WorkforceScenario> scenarios,
    required DateTime asOfDate,
  }) {
    final startThreshold = asOfDate.add(const Duration(days: 30));

    return WorkforcePlanningRiskSummary(
      planExceptions:
          plans
              .where((item) => item.status != WorkforcePlanStatus.onTrack)
              .length,
      blockedRequests:
          positions
              .where((item) => item.status == PositionRequestStatus.blocked)
              .length,
      pendingApprovals:
          positions
              .where(
                (item) => item.status == PositionRequestStatus.awaitingApproval,
              )
              .length,
      highCapacityRisks:
          risks
              .where((item) => item.riskLevel == CapacityRiskLevel.high)
              .length,
      lowConfidenceScenarios:
          scenarios
              .where((item) => item.confidence == ScenarioConfidence.low)
              .length,
      startsWithinThirtyDays:
          positions
              .where(
                (item) =>
                    item.status != PositionRequestStatus.approved &&
                    !item.targetStartDate.isAfter(startThreshold),
              )
              .length,
    );
  }
}
