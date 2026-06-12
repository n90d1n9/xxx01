import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_command_center_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_health_dashboard_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_training_session_summary.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_command_center_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_health_dashboard_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_dashboard_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_training_session_provider.dart';

void main() {
  test('talent governance command center rolls up executive lanes', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentHealthDashboardProvider.overrideWithValue(
          _healthDashboard(
            status: IncomingTalentHealthStatus.watch,
            healthScore: 76,
            attentionSignalCount: 2,
          ),
        ),
        incomingTalentOperatingSlaSummaryProvider.overrideWithValue(
          const IncomingTalentOperatingSlaSummary(
            itemCount: 5,
            overdueCount: 1,
            dueTodayCount: 1,
            atRiskCount: 2,
            onTrackCount: 1,
            ownerCount: 5,
            sourceCount: 5,
            evidenceCount: 3,
            nextAction: 'Recover 1 overdue talent operating SLA item.',
          ),
        ),
        incomingTalentOperatingEscalationSummaryProvider.overrideWithValue(
          const IncomingTalentOperatingEscalationSummary(
            totalCount: 3,
            criticalCount: 0,
            highCount: 1,
            watchCount: 2,
            overdueCount: 0,
            dueTodayCount: 1,
            cadenceCount: 1,
            ownerReliefCount: 0,
            workstreamPressureCount: 1,
            inboxItemCount: 1,
            nextAction: 'Close 1 talent escalation due today.',
          ),
        ),
        incomingTalentOperatingAssuranceSummaryProvider.overrideWithValue(
          const IncomingTalentOperatingAssuranceSummary(
            workstreamCount: 2,
            exposedWorkstreamCount: 1,
            guardedWorkstreamCount: 1,
            readyWorkstreamCount: 0,
            totalGapCount: 4,
            criticalGapCount: 1,
            overdueGapCount: 1,
            linkedEscalationCount: 2,
            nextAction: 'Stabilize 1 audit-exposed talent workstream.',
          ),
        ),
        incomingTalentOperatingAssuranceRemediationSummaryProvider
            .overrideWithValue(
              const IncomingTalentOperatingAssuranceRemediationSummary(
                actionCount: 2,
                criticalActionCount: 1,
                highActionCount: 1,
                standardActionCount: 0,
                overdueActionCount: 1,
                dueTodayActionCount: 0,
                ownerCount: 2,
                workstreamCount: 2,
                totalGapCount: 4,
                linkedEscalationCount: 2,
                nextAction: 'Complete 1 critical assurance remediation action.',
              ),
            ),
        incomingTalentOperatingAssuranceExecutionSummaryProvider
            .overrideWithValue(
              const IncomingTalentOperatingAssuranceExecutionSummary(
                trackCount: 2,
                blockedCount: 1,
                recoveryCount: 0,
                dueTodayCount: 1,
                inProgressCount: 0,
                overdueCount: 0,
                ownerCount: 2,
                completionEvidenceCount: 6,
                linkedEscalationCount: 2,
                nextAction: 'Unblock 1 assurance remediation execution track.',
              ),
            ),
        incomingTalentSuccessionCoverageDashboardProvider.overrideWithValue(
          IncomingTalentSuccessionCoverageDashboard(
            counts: _coverageCounts,
            coverageScore: 68,
            health: IncomingTalentSuccessionCoverageHealth.watch,
            nextAction: 'Tighten succession readiness before executive review.',
          ),
        ),
        incomingTalentTrainingSessionSummaryProvider.overrideWithValue(
          const IncomingTalentTrainingSessionSummary(
            totalCount: 2,
            draftCount: 0,
            scheduledCount: 2,
            liveCount: 0,
            completedCount: 0,
            cancelledCount: 0,
            attentionCount: 0,
            dueSoonCount: 0,
            totalCapacity: 24,
            reservedSeatCount: 18,
            utilizationRatio: 0.75,
            nextAction: 'Track 2 scheduled training sessions.',
          ),
        ),
        incomingTalentCareerPathSummaryProvider.overrideWithValue(
          const IncomingTalentCareerPathSummary(
            totalCount: 2,
            draftCount: 0,
            activeCount: 1,
            blockedCount: 1,
            achievedCount: 0,
            criticalCount: 1,
            dueSoonCount: 1,
            averageGap: 1.5,
            nextAction: 'Unblock 1 critical career paths.',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final commandCenter = container.read(
      incomingTalentGovernanceCommandCenterProvider,
    );

    expect(commandCenter.laneCount, 7);
    expect(commandCenter.criticalLaneCount, 3);
    expect(commandCenter.watchLaneCount, 3);
    expect(commandCenter.stableLaneCount, 1);
    expect(commandCenter.totalSignalCount, greaterThan(0));
    expect(commandCenter.decisionCount, greaterThan(0));
    expect(
      commandCenter.status,
      IncomingTalentGovernanceCommandStatus.critical,
    );
    expect(commandCenter.governanceScore, lessThan(80));
    expect(
      commandCenter.lanes.first.type,
      IncomingTalentGovernanceCommandLaneType.careerPath,
    );
    expect(
      commandCenter.lanes.first.status,
      IncomingTalentGovernanceCommandStatus.critical,
    );
    expect(
      commandCenter.nextAction,
      'Run governance review for 3 critical talent lanes: Unblock 1 critical career paths.',
    );
    expect(
      commandCenter.lanes
          .map((lane) => lane.type)
          .contains(IncomingTalentGovernanceCommandLaneType.assurance),
      isTrue,
    );
  });
}

IncomingTalentHealthDashboard _healthDashboard({
  required IncomingTalentHealthStatus status,
  required int healthScore,
  required int attentionSignalCount,
}) {
  return IncomingTalentHealthDashboard(
    status: status,
    healthScore: healthScore,
    totalRoadmaps: 2,
    atRiskRoadmaps: 1,
    totalPortfolios: 2,
    watchPortfolios: 1,
    duePortfolioReviews: 0,
    totalCheckIns: 2,
    blockedCheckIns: 0,
    lowConfidenceCheckIns: 1,
    openInterventions: 0,
    criticalInterventions: 0,
    dueInterventions: 0,
    releaseEvidenceInterventions: 0,
    developmentOutcomeAttentionCount: 0,
    developmentOutcomeReleaseRiskCount: 0,
    averageDevelopmentOutcomeConfidence: 4,
    developmentFollowUpOpenCount: 0,
    developmentFollowUpDueSoonCount: 0,
    developmentFollowUpOverdueCount: 0,
    developmentFollowUpEscalatedCount: 0,
    developmentFollowUpResolutionAttentionCount: 0,
    developmentFollowUpResolutionEscalatedCount: 0,
    averageDevelopmentFollowUpResolutionConfidence: 4,
    totalCareerPaths: 2,
    blockedCareerPaths: 0,
    criticalCareerPaths: 0,
    averageCareerPathGap: 1,
    totalCareerSupportActions: 0,
    openCareerSupportActions: 0,
    criticalCareerSupportActions: 0,
    dueCareerSupportActions: 0,
    totalCareerSupportOutcomes: 0,
    monitorCareerSupportOutcomes: 0,
    escalatedCareerSupportOutcomes: 0,
    averageCareerSupportOutcomeLevel: 0,
    totalProgramMilestones: 0,
    programMilestoneRevisions: 0,
    dueProgramMilestones: 0,
    averageProgramMilestoneScore: 0,
    totalProgramCompletions: 0,
    roleReadyProgramCompletions: 0,
    programCompletionExtensions: 0,
    renewalDueProgramCompletions: 0,
    averageProgramCompletionScore: 0,
    totalPromotionStabilizationReviews: 0,
    promotionStabilizationAttentionCount: 0,
    promotionStabilizationEscalatedCount: 0,
    promotionStabilizationDueFollowUps: 0,
    averagePromotionStabilizationConfidence: 0,
    totalPromotionFollowUpActions: 0,
    openPromotionFollowUpActions: 0,
    promotionFollowUpAttentionCount: 0,
    criticalPromotionFollowUpActions: 0,
    promotionFollowUpDueSoonCount: 0,
    promotionFollowUpEscalatedCount: 0,
    averagePromotionFollowUpProgress: 0,
    totalPromotionFollowUpResolutions: 0,
    promotionResolutionAttentionCount: 0,
    promotionResolutionMonitorCount: 0,
    promotionResolutionReopenedCount: 0,
    promotionResolutionEscalatedCount: 0,
    averagePromotionResolutionConfidence: 0,
    averagePromotionResolutionConfidenceDelta: 0,
    averageReadinessScore: 78,
    averageConfidenceScore: 3.6,
    signals: [
      for (var index = 0; index < attentionSignalCount; index += 1)
        IncomingTalentHealthSignal(
          label: 'Signal $index',
          value: '1',
          detail: 'Governance attention signal.',
          severity: IncomingTalentHealthSignalSeverity.watch,
        ),
    ],
    nextAction: 'Stabilize talent health signals.',
  );
}

const _coverageCounts = IncomingTalentSuccessionCoverageCounts(
  totalCandidates: 4,
  readyNowCount: 1,
  readySoonCount: 1,
  blockedCandidateCount: 0,
  highRiskCandidateCount: 1,
  activationPlanCount: 1,
  activationAtRiskCount: 0,
  transitionPulseCount: 1,
  transitionPulseAtRiskCount: 1,
  openTransitionInterventionCount: 0,
  transitionOutcomeRiskCount: 0,
  benchPlanCount: 1,
  criticalBenchPlanCount: 0,
  benchCheckInAttentionCount: 0,
  openBenchActionCount: 0,
);
