import 'dart:math' as math;

import 'incoming_talent_career_path_summary.dart';
import 'incoming_talent_governance_command_center.dart';
import 'incoming_talent_health_dashboard.dart';
import 'incoming_talent_health_signal.dart';
import 'incoming_talent_operating_assurance_execution_summary.dart';
import 'incoming_talent_operating_assurance_remediation_summary.dart';
import 'incoming_talent_operating_assurance_summary.dart';
import 'incoming_talent_operating_escalation_summary.dart';
import 'incoming_talent_operating_sla_summary.dart';
import 'incoming_talent_succession_coverage_dashboard.dart';
import 'incoming_talent_training_session_summary.dart';

/// Builds the executive talent governance command center from module summaries.
IncomingTalentGovernanceCommandCenter
buildIncomingTalentGovernanceCommandCenter({
  required IncomingTalentHealthDashboard healthDashboard,
  required IncomingTalentOperatingSlaSummary slaSummary,
  required IncomingTalentOperatingEscalationSummary escalationSummary,
  required IncomingTalentOperatingAssuranceSummary assuranceSummary,
  required IncomingTalentOperatingAssuranceRemediationSummary
  remediationSummary,
  required IncomingTalentOperatingAssuranceExecutionSummary executionSummary,
  required IncomingTalentSuccessionCoverageDashboard successionDashboard,
  required IncomingTalentTrainingSessionSummary trainingSummary,
  required IncomingTalentCareerPathSummary careerPathSummary,
}) {
  final lanes = [
    _healthLane(healthDashboard),
    _slaLane(slaSummary),
    _escalationLane(escalationSummary),
    _assuranceLane(
      assuranceSummary: assuranceSummary,
      remediationSummary: remediationSummary,
      executionSummary: executionSummary,
    ),
    _successionLane(successionDashboard),
    _trainingLane(trainingSummary),
    _careerPathLane(careerPathSummary),
  ]..sort(_compareLanes);

  final criticalLaneCount = _countByStatus(
    lanes,
    IncomingTalentGovernanceCommandStatus.critical,
  );
  final watchLaneCount = _countByStatus(
    lanes,
    IncomingTalentGovernanceCommandStatus.watch,
  );
  final stableLaneCount = _countByStatus(
    lanes,
    IncomingTalentGovernanceCommandStatus.stable,
  );
  final totalSignalCount = lanes.fold<int>(
    0,
    (total, lane) => total + lane.signalCount,
  );
  final decisionCount = lanes.fold<int>(
    0,
    (total, lane) => total + lane.decisionCount,
  );
  final governanceScore = _governanceScore(
    lanes: lanes,
    criticalLaneCount: criticalLaneCount,
    watchLaneCount: watchLaneCount,
    totalSignalCount: totalSignalCount,
  );
  final status = _centerStatus(
    governanceScore: governanceScore,
    criticalLaneCount: criticalLaneCount,
    watchLaneCount: watchLaneCount,
  );

  return IncomingTalentGovernanceCommandCenter(
    status: status,
    governanceScore: governanceScore,
    laneCount: lanes.length,
    criticalLaneCount: criticalLaneCount,
    watchLaneCount: watchLaneCount,
    stableLaneCount: stableLaneCount,
    totalSignalCount: totalSignalCount,
    decisionCount: decisionCount,
    nextAction: _nextAction(
      lanes: lanes,
      status: status,
      criticalLaneCount: criticalLaneCount,
      watchLaneCount: watchLaneCount,
    ),
    lanes: lanes,
  );
}

IncomingTalentGovernanceCommandLane _healthLane(
  IncomingTalentHealthDashboard dashboard,
) {
  final status = switch (dashboard.status) {
    IncomingTalentHealthStatus.critical =>
      IncomingTalentGovernanceCommandStatus.critical,
    IncomingTalentHealthStatus.watch =>
      IncomingTalentGovernanceCommandStatus.watch,
    IncomingTalentHealthStatus.strong =>
      IncomingTalentGovernanceCommandStatus.stable,
  };

  return IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-health',
    type: IncomingTalentGovernanceCommandLaneType.health,
    status: status,
    title: 'Talent health',
    detail:
        '${dashboard.attentionSignalCount} attention ${_plural(dashboard.attentionSignalCount, 'signal')} across development and promotion.',
    metricLabel: 'Health',
    metricValue: '${dashboard.healthScore}%',
    nextAction: dashboard.nextAction,
    pressureRatio: 1 - dashboard.healthRatio,
    signalCount: dashboard.attentionSignalCount,
    decisionCount: dashboard.attentionSignalCount,
  );
}

IncomingTalentGovernanceCommandLane _slaLane(
  IncomingTalentOperatingSlaSummary summary,
) {
  final status = _statusForCounts(
    criticalCount: summary.overdueCount,
    watchCount: summary.dueTodayCount + summary.atRiskCount,
  );
  final signalCount =
      summary.overdueCount + summary.dueTodayCount + summary.atRiskCount;

  return IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-action-sla',
    type: IncomingTalentGovernanceCommandLaneType.actionSla,
    status: status,
    title: 'Action SLA',
    detail:
        '${summary.overdueCount} overdue, ${summary.dueTodayCount} today, ${summary.atRiskCount} at risk across ${summary.sourceCount} sources.',
    metricLabel: 'SLAs',
    metricValue: '${summary.itemCount}',
    nextAction: summary.nextAction,
    pressureRatio: _ratio(
      numerator:
          (summary.overdueCount * 3) +
          (summary.dueTodayCount * 2) +
          summary.atRiskCount,
      denominator: math.max(1, summary.itemCount * 3),
    ),
    signalCount: signalCount,
    decisionCount: signalCount,
  );
}

IncomingTalentGovernanceCommandLane _escalationLane(
  IncomingTalentOperatingEscalationSummary summary,
) {
  final status = _statusForCounts(
    criticalCount: summary.criticalCount + summary.overdueCount,
    watchCount: summary.highCount + summary.dueTodayCount,
  );
  final signalCount =
      summary.criticalCount +
      summary.highCount +
      summary.overdueCount +
      summary.dueTodayCount;

  return IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-escalation',
    type: IncomingTalentGovernanceCommandLaneType.escalation,
    status: status,
    title: 'Escalations',
    detail:
        '${summary.criticalCount} critical, ${summary.highCount} high, ${summary.ownerReliefCount} owner relief signals.',
    metricLabel: 'Open',
    metricValue: '${summary.totalCount}',
    nextAction: summary.nextAction,
    pressureRatio: _ratio(
      numerator:
          (summary.criticalCount * 3) +
          (summary.highCount * 2) +
          summary.watchCount,
      denominator: math.max(1, summary.totalCount * 3),
    ),
    signalCount: signalCount,
    decisionCount: summary.criticalCount + summary.highCount,
  );
}

IncomingTalentGovernanceCommandLane _assuranceLane({
  required IncomingTalentOperatingAssuranceSummary assuranceSummary,
  required IncomingTalentOperatingAssuranceRemediationSummary
  remediationSummary,
  required IncomingTalentOperatingAssuranceExecutionSummary executionSummary,
}) {
  final criticalCount =
      assuranceSummary.exposedWorkstreamCount +
      remediationSummary.criticalActionCount +
      executionSummary.blockedCount;
  final watchCount =
      assuranceSummary.guardedWorkstreamCount +
      remediationSummary.highActionCount +
      executionSummary.recoveryCount +
      executionSummary.dueTodayCount;
  final status = _statusForCounts(
    criticalCount: criticalCount,
    watchCount: watchCount,
  );
  final signalCount =
      criticalCount +
      watchCount +
      assuranceSummary.overdueGapCount +
      executionSummary.overdueCount;

  return IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-assurance',
    type: IncomingTalentGovernanceCommandLaneType.assurance,
    status: status,
    title: 'Assurance',
    detail:
        '${assuranceSummary.totalGapCount} evidence gaps, ${remediationSummary.actionCount} remediation actions, ${executionSummary.trackCount} execution tracks.',
    metricLabel: 'Gaps',
    metricValue: '${assuranceSummary.totalGapCount}',
    nextAction: _assuranceNextAction(
      assuranceSummary: assuranceSummary,
      remediationSummary: remediationSummary,
      executionSummary: executionSummary,
    ),
    pressureRatio: _ratio(
      numerator:
          (criticalCount * 3) +
          (watchCount * 2) +
          assuranceSummary.totalGapCount,
      denominator: math.max(
        1,
        (assuranceSummary.workstreamCount +
                    remediationSummary.actionCount +
                    executionSummary.trackCount +
                    assuranceSummary.totalGapCount)
                .clamp(1, 999) *
            3,
      ),
    ),
    signalCount: signalCount,
    decisionCount: remediationSummary.actionCount + executionSummary.trackCount,
  );
}

IncomingTalentGovernanceCommandLane _successionLane(
  IncomingTalentSuccessionCoverageDashboard dashboard,
) {
  final status = switch (dashboard.health) {
    IncomingTalentSuccessionCoverageHealth.critical =>
      IncomingTalentGovernanceCommandStatus.critical,
    IncomingTalentSuccessionCoverageHealth.watch =>
      IncomingTalentGovernanceCommandStatus.watch,
    IncomingTalentSuccessionCoverageHealth.strong =>
      IncomingTalentGovernanceCommandStatus.stable,
  };

  return IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-succession',
    type: IncomingTalentGovernanceCommandLaneType.succession,
    status: status,
    title: 'Succession',
    detail:
        '${dashboard.readyNowCount} ready now, ${dashboard.openBenchActionCount} open bench actions, ${dashboard.attentionSignalCount} signals.',
    metricLabel: 'Coverage',
    metricValue: '${dashboard.coverageScore}%',
    nextAction: dashboard.nextAction,
    pressureRatio: 1 - dashboard.coverageRatio,
    signalCount: dashboard.attentionSignalCount,
    decisionCount:
        dashboard.openBenchActionCount + dashboard.criticalBenchPlanCount,
  );
}

IncomingTalentGovernanceCommandLane _trainingLane(
  IncomingTalentTrainingSessionSummary summary,
) {
  final status = _statusForCounts(
    criticalCount: summary.attentionCount,
    watchCount: summary.dueSoonCount + summary.liveCount,
  );
  final signalCount = summary.attentionCount + summary.dueSoonCount;

  return IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-training',
    type: IncomingTalentGovernanceCommandLaneType.training,
    status: status,
    title: 'Training',
    detail:
        '${summary.scheduledCount} scheduled, ${summary.liveCount} live, ${(summary.utilizationRatio * 100).round()}% seat utilization.',
    metricLabel: 'Sessions',
    metricValue: '${summary.totalCount}',
    nextAction: summary.nextAction,
    pressureRatio: _ratio(
      numerator:
          (summary.attentionCount * 3) +
          (summary.dueSoonCount * 2) +
          summary.liveCount,
      denominator: math.max(1, summary.totalCount * 3),
    ),
    signalCount: signalCount,
    decisionCount: summary.attentionCount + summary.liveCount,
  );
}

IncomingTalentGovernanceCommandLane _careerPathLane(
  IncomingTalentCareerPathSummary summary,
) {
  final status = _statusForCounts(
    criticalCount: summary.blockedCount + summary.criticalCount,
    watchCount: summary.dueSoonCount + summary.draftCount,
  );
  final signalCount =
      summary.blockedCount +
      summary.criticalCount +
      summary.dueSoonCount +
      summary.draftCount;

  return IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-career-path',
    type: IncomingTalentGovernanceCommandLaneType.careerPath,
    status: status,
    title: 'Career path',
    detail:
        '${summary.blockedCount} blocked, ${summary.dueSoonCount} due soon, ${summary.averageGap.toStringAsFixed(1)} average level gap.',
    metricLabel: 'Paths',
    metricValue: '${summary.totalCount}',
    nextAction: summary.nextAction,
    pressureRatio: _ratio(
      numerator:
          (summary.blockedCount * 3) +
          (summary.criticalCount * 3) +
          (summary.dueSoonCount * 2) +
          summary.draftCount,
      denominator: math.max(1, summary.totalCount * 3),
    ),
    signalCount: signalCount,
    decisionCount: summary.blockedCount + summary.criticalCount,
  );
}

IncomingTalentGovernanceCommandStatus _statusForCounts({
  required int criticalCount,
  required int watchCount,
}) {
  if (criticalCount > 0) {
    return IncomingTalentGovernanceCommandStatus.critical;
  }
  if (watchCount > 0) {
    return IncomingTalentGovernanceCommandStatus.watch;
  }
  return IncomingTalentGovernanceCommandStatus.stable;
}

String _assuranceNextAction({
  required IncomingTalentOperatingAssuranceSummary assuranceSummary,
  required IncomingTalentOperatingAssuranceRemediationSummary
  remediationSummary,
  required IncomingTalentOperatingAssuranceExecutionSummary executionSummary,
}) {
  if (executionSummary.blockedCount > 0 ||
      executionSummary.recoveryCount > 0 ||
      executionSummary.dueTodayCount > 0) {
    return executionSummary.nextAction;
  }
  if (remediationSummary.actionCount > 0) return remediationSummary.nextAction;
  return assuranceSummary.nextAction;
}

int _countByStatus(
  List<IncomingTalentGovernanceCommandLane> lanes,
  IncomingTalentGovernanceCommandStatus status,
) {
  return lanes.where((lane) => lane.status == status).length;
}

int _governanceScore({
  required List<IncomingTalentGovernanceCommandLane> lanes,
  required int criticalLaneCount,
  required int watchLaneCount,
  required int totalSignalCount,
}) {
  final pressurePenalty = lanes.fold<int>(
    0,
    (total, lane) => total + (lane.normalizedPressureRatio * 10).round(),
  );
  final statusPenalty = (criticalLaneCount * 12) + (watchLaneCount * 6);
  final signalPenalty = math.min(totalSignalCount, 12) * 2;

  return (100 - pressurePenalty - statusPenalty - signalPenalty).clamp(0, 100);
}

IncomingTalentGovernanceCommandStatus _centerStatus({
  required int governanceScore,
  required int criticalLaneCount,
  required int watchLaneCount,
}) {
  if (criticalLaneCount > 0 || governanceScore < 55) {
    return IncomingTalentGovernanceCommandStatus.critical;
  }
  if (watchLaneCount > 0 || governanceScore < 80) {
    return IncomingTalentGovernanceCommandStatus.watch;
  }
  return IncomingTalentGovernanceCommandStatus.stable;
}

String _nextAction({
  required List<IncomingTalentGovernanceCommandLane> lanes,
  required IncomingTalentGovernanceCommandStatus status,
  required int criticalLaneCount,
  required int watchLaneCount,
}) {
  if (lanes.isEmpty) return 'No talent governance lanes are active.';
  final firstAttentionLane = lanes.firstWhere(
    (lane) => lane.needsAttention,
    orElse: () => lanes.first,
  );
  if (status == IncomingTalentGovernanceCommandStatus.critical) {
    return 'Run governance review for $criticalLaneCount critical talent ${_plural(criticalLaneCount, 'lane')}: ${firstAttentionLane.nextAction}';
  }
  if (status == IncomingTalentGovernanceCommandStatus.watch) {
    return 'Monitor $watchLaneCount talent governance ${_plural(watchLaneCount, 'lane')}: ${firstAttentionLane.nextAction}';
  }
  return 'Talent governance is stable across ${lanes.length} lanes.';
}

int _compareLanes(
  IncomingTalentGovernanceCommandLane left,
  IncomingTalentGovernanceCommandLane right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final pressure = right.normalizedPressureRatio.compareTo(
    left.normalizedPressureRatio,
  );
  if (pressure != 0) return pressure;

  final signals = right.signalCount.compareTo(left.signalCount);
  if (signals != 0) return signals;

  return left.title.compareTo(right.title);
}

double _ratio({required int numerator, required int denominator}) {
  final ratio = numerator / denominator;
  if (ratio < 0) return 0;
  if (ratio > 1) return 1;
  return ratio;
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
