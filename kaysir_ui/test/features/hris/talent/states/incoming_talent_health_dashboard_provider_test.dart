import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_support_action_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_support_outcome_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_check_in_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_follow_up_resolution_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_follow_up_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_portfolio_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_program_completion_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_program_milestone_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_health_dashboard_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_follow_up_action_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_follow_up_resolution_summary.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_review_summary.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_outcome_follow_up_resolution_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_portfolio_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_completion_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_milestone_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_roadmap_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_health_dashboard_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_stabilization_follow_up_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_stabilization_follow_up_resolution_provider.dart';

void main() {
  test('talent health dashboard stays strong with healthy summaries', () {
    final dashboard = IncomingTalentHealthDashboard.fromSummaries(
      roadmapSummary: _roadmapSummary(total: 2, averageReadiness: 92),
      portfolioSummary: _portfolioSummary(total: 2, averageReadiness: 90),
      careerPathSummary: _careerPathSummary(total: 2),
      supportActionSummary: _supportActionSummary(),
      supportOutcomeSummary: _supportOutcomeSummary(),
      milestoneSummary: _milestoneSummary(),
      completionSummary: _completionSummary(),
      checkInSummary: _checkInSummary(total: 2, averageConfidence: 4.5),
      interventionSummary: _interventionSummary(total: 1, resolved: 1),
      interventionOutcomeSummary: _interventionOutcomeSummary(),
      interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(),
      interventionOutcomeFollowUpResolutionSummary:
          _interventionFollowUpResolutionSummary(),
    );

    expect(dashboard.status, IncomingTalentHealthStatus.strong);
    expect(dashboard.healthScore, 100);
    expect(dashboard.attentionSignalCount, 0);
    expect(dashboard.averageReadinessScore, 91);
    expect(dashboard.nextAction, 'Keep talent development health on cadence.');
  });

  test('talent health dashboard escalates critical summary signals', () {
    final dashboard = IncomingTalentHealthDashboard.fromSummaries(
      roadmapSummary: _roadmapSummary(
        total: 3,
        atRisk: 1,
        averageReadiness: 70,
      ),
      portfolioSummary: _portfolioSummary(
        total: 2,
        watch: 1,
        recovery: 1,
        dueSoon: 1,
        averageReadiness: 64,
      ),
      careerPathSummary: _careerPathSummary(
        total: 2,
        blocked: 1,
        critical: 1,
        dueSoon: 1,
        averageGap: 2,
      ),
      supportActionSummary: _supportActionSummary(),
      supportOutcomeSummary: _supportOutcomeSummary(),
      milestoneSummary: _milestoneSummary(),
      completionSummary: _completionSummary(),
      checkInSummary: _checkInSummary(
        total: 2,
        blocked: 1,
        lowConfidence: 2,
        averageConfidence: 2.5,
      ),
      interventionSummary: _interventionSummary(
        total: 2,
        open: 2,
        critical: 1,
        dueSoon: 1,
      ),
      interventionOutcomeSummary: _interventionOutcomeSummary(),
      interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(),
      interventionOutcomeFollowUpResolutionSummary:
          _interventionFollowUpResolutionSummary(),
    );

    expect(dashboard.status, IncomingTalentHealthStatus.critical);
    expect(dashboard.healthScore, 0);
    expect(dashboard.attentionSignalCount, 5);
    expect(dashboard.blockedCareerPaths, 1);
    expect(dashboard.criticalInterventions, 1);
    expect(dashboard.nextAction, 'Resolve 3 critical talent health signals.');
    expect(dashboard.signals.map((signal) => signal.severity), [
      IncomingTalentHealthSignalSeverity.watch,
      IncomingTalentHealthSignalSeverity.watch,
      IncomingTalentHealthSignalSeverity.critical,
      IncomingTalentHealthSignalSeverity.stable,
      IncomingTalentHealthSignalSeverity.stable,
      IncomingTalentHealthSignalSeverity.stable,
      IncomingTalentHealthSignalSeverity.critical,
      IncomingTalentHealthSignalSeverity.critical,
    ]);
  });

  test('talent health dashboard includes career support risk signals', () {
    final dashboard = IncomingTalentHealthDashboard.fromSummaries(
      roadmapSummary: _roadmapSummary(total: 2, averageReadiness: 92),
      portfolioSummary: _portfolioSummary(total: 2, averageReadiness: 90),
      careerPathSummary: _careerPathSummary(total: 1),
      supportActionSummary: _supportActionSummary(
        total: 2,
        open: 1,
        critical: 1,
        dueSoon: 1,
      ),
      supportOutcomeSummary: _supportOutcomeSummary(
        total: 1,
        monitor: 1,
        attention: 1,
        averageVerifiedLevel: 2,
      ),
      milestoneSummary: _milestoneSummary(),
      completionSummary: _completionSummary(),
      checkInSummary: _checkInSummary(total: 1, averageConfidence: 4),
      interventionSummary: _interventionSummary(total: 1, resolved: 1),
      interventionOutcomeSummary: _interventionOutcomeSummary(),
      interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(),
      interventionOutcomeFollowUpResolutionSummary:
          _interventionFollowUpResolutionSummary(),
    );

    final supportSignal = dashboard.signals.firstWhere(
      (signal) => signal.label == 'Career support',
    );

    expect(dashboard.status, IncomingTalentHealthStatus.critical);
    expect(dashboard.healthScore, 75);
    expect(dashboard.openCareerSupportActions, 1);
    expect(dashboard.criticalCareerSupportActions, 1);
    expect(dashboard.monitorCareerSupportOutcomes, 1);
    expect(dashboard.averageCareerSupportOutcomeLevel, 2);
    expect(dashboard.nextAction, 'Resolve 1 critical talent health signals.');
    expect(supportSignal.severity, IncomingTalentHealthSignalSeverity.critical);
    expect(supportSignal.value, '1');
  });

  test('talent health dashboard includes program milestone risk signals', () {
    final dashboard = IncomingTalentHealthDashboard.fromSummaries(
      roadmapSummary: _roadmapSummary(total: 2, averageReadiness: 92),
      portfolioSummary: _portfolioSummary(total: 2, averageReadiness: 90),
      careerPathSummary: _careerPathSummary(total: 1),
      supportActionSummary: _supportActionSummary(),
      supportOutcomeSummary: _supportOutcomeSummary(),
      milestoneSummary: _milestoneSummary(
        total: 4,
        submitted: 1,
        accepted: 1,
        revision: 2,
        dueSoon: 1,
        averageScore: 68,
      ),
      completionSummary: _completionSummary(),
      checkInSummary: _checkInSummary(total: 1, averageConfidence: 4),
      interventionSummary: _interventionSummary(total: 1, resolved: 1),
      interventionOutcomeSummary: _interventionOutcomeSummary(),
      interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(),
      interventionOutcomeFollowUpResolutionSummary:
          _interventionFollowUpResolutionSummary(),
    );

    final milestoneSignal = dashboard.signals.firstWhere(
      (signal) => signal.label == 'Program milestones',
    );

    expect(dashboard.status, IncomingTalentHealthStatus.critical);
    expect(dashboard.healthScore, 79);
    expect(dashboard.totalProgramMilestones, 4);
    expect(dashboard.programMilestoneRevisions, 2);
    expect(dashboard.dueProgramMilestones, 1);
    expect(dashboard.averageProgramMilestoneScore, 68);
    expect(dashboard.nextAction, 'Resolve 1 critical talent health signals.');
    expect(
      milestoneSignal.severity,
      IncomingTalentHealthSignalSeverity.critical,
    );
    expect(milestoneSignal.value, '2');
    expect(milestoneSignal.detail, '1 submitted, 1 due soon');
  });

  test('talent health dashboard includes program completion risk signals', () {
    final dashboard = IncomingTalentHealthDashboard.fromSummaries(
      roadmapSummary: _roadmapSummary(total: 2, averageReadiness: 92),
      portfolioSummary: _portfolioSummary(total: 2, averageReadiness: 90),
      careerPathSummary: _careerPathSummary(total: 1),
      supportActionSummary: _supportActionSummary(),
      supportOutcomeSummary: _supportOutcomeSummary(),
      milestoneSummary: _milestoneSummary(total: 2, accepted: 2),
      completionSummary: _completionSummary(
        total: 3,
        roleReady: 1,
        extension: 1,
        renewalDue: 1,
        averageScore: 72,
      ),
      checkInSummary: _checkInSummary(total: 1, averageConfidence: 4),
      interventionSummary: _interventionSummary(total: 1, resolved: 1),
      interventionOutcomeSummary: _interventionOutcomeSummary(),
      interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(),
      interventionOutcomeFollowUpResolutionSummary:
          _interventionFollowUpResolutionSummary(),
    );

    final completionSignal = dashboard.signals.firstWhere(
      (signal) => signal.label == 'Program completions',
    );

    expect(dashboard.status, IncomingTalentHealthStatus.critical);
    expect(dashboard.healthScore, 88);
    expect(dashboard.totalProgramCompletions, 3);
    expect(dashboard.roleReadyProgramCompletions, 1);
    expect(dashboard.programCompletionExtensions, 1);
    expect(dashboard.renewalDueProgramCompletions, 1);
    expect(dashboard.averageProgramCompletionScore, 72);
    expect(dashboard.nextAction, 'Resolve 1 critical talent health signals.');
    expect(
      completionSignal.severity,
      IncomingTalentHealthSignalSeverity.critical,
    );
    expect(completionSignal.value, '1');
    expect(completionSignal.detail, '1 role-ready, 1 renewals due');
  });

  test('talent health dashboard includes release evidence intervention risk', () {
    final dashboard = IncomingTalentHealthDashboard.fromSummaries(
      roadmapSummary: _roadmapSummary(total: 2, averageReadiness: 92),
      portfolioSummary: _portfolioSummary(total: 2, averageReadiness: 90),
      careerPathSummary: _careerPathSummary(total: 1),
      supportActionSummary: _supportActionSummary(),
      supportOutcomeSummary: _supportOutcomeSummary(),
      milestoneSummary: _milestoneSummary(),
      completionSummary: _completionSummary(),
      checkInSummary: _checkInSummary(total: 1, averageConfidence: 4),
      interventionSummary: _interventionSummary(
        total: 1,
        open: 1,
        releaseRisk: 1,
      ),
      interventionOutcomeSummary: _interventionOutcomeSummary(),
      interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(),
      interventionOutcomeFollowUpResolutionSummary:
          _interventionFollowUpResolutionSummary(),
    );

    final interventionSignal = dashboard.signals.firstWhere(
      (signal) => signal.label == 'Interventions',
    );

    expect(dashboard.status, IncomingTalentHealthStatus.critical);
    expect(dashboard.healthScore, 84);
    expect(dashboard.releaseEvidenceInterventions, 1);
    expect(dashboard.nextAction, 'Resolve 1 critical talent health signals.');
    expect(
      interventionSignal.severity,
      IncomingTalentHealthSignalSeverity.critical,
    );
    expect(
      interventionSignal.detail,
      '0 critical, 1 release risks, 0 outcomes on watch, 0 follow-ups due, 0 reviews on watch',
    );
  });

  test(
    'talent health dashboard includes development intervention outcome risk',
    () {
      final dashboard = IncomingTalentHealthDashboard.fromSummaries(
        roadmapSummary: _roadmapSummary(total: 2, averageReadiness: 92),
        portfolioSummary: _portfolioSummary(total: 2, averageReadiness: 90),
        careerPathSummary: _careerPathSummary(total: 1),
        supportActionSummary: _supportActionSummary(),
        supportOutcomeSummary: _supportOutcomeSummary(),
        milestoneSummary: _milestoneSummary(),
        completionSummary: _completionSummary(),
        checkInSummary: _checkInSummary(total: 1, averageConfidence: 4),
        interventionSummary: _interventionSummary(total: 1, resolved: 1),
        interventionOutcomeSummary: _interventionOutcomeSummary(
          total: 1,
          monitor: 1,
          attention: 1,
          releaseRisk: 1,
          averageConfidenceAfter: 3,
        ),
        interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(),
        interventionOutcomeFollowUpResolutionSummary:
            _interventionFollowUpResolutionSummary(),
      );

      final interventionSignal = dashboard.signals.firstWhere(
        (signal) => signal.label == 'Interventions',
      );

      expect(dashboard.status, IncomingTalentHealthStatus.critical);
      expect(dashboard.healthScore, 86);
      expect(dashboard.developmentOutcomeAttentionCount, 1);
      expect(dashboard.developmentOutcomeReleaseRiskCount, 1);
      expect(dashboard.averageDevelopmentOutcomeConfidence, 3);
      expect(dashboard.nextAction, 'Resolve 1 critical talent health signals.');
      expect(
        interventionSignal.severity,
        IncomingTalentHealthSignalSeverity.critical,
      );
      expect(
        interventionSignal.detail,
        '0 critical, 0 release risks, 1 outcomes on watch, 0 follow-ups due, 0 reviews on watch',
      );
    },
  );

  test(
    'talent health dashboard includes intervention outcome follow-up risk',
    () {
      final dashboard = IncomingTalentHealthDashboard.fromSummaries(
        roadmapSummary: _roadmapSummary(total: 2, averageReadiness: 92),
        portfolioSummary: _portfolioSummary(total: 2, averageReadiness: 90),
        careerPathSummary: _careerPathSummary(total: 1),
        supportActionSummary: _supportActionSummary(),
        supportOutcomeSummary: _supportOutcomeSummary(),
        milestoneSummary: _milestoneSummary(),
        completionSummary: _completionSummary(),
        checkInSummary: _checkInSummary(total: 1, averageConfidence: 4),
        interventionSummary: _interventionSummary(total: 1, resolved: 1),
        interventionOutcomeSummary: _interventionOutcomeSummary(),
        interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(
          total: 2,
          open: 1,
          escalated: 1,
          dueSoon: 1,
          overdue: 1,
          attention: 2,
        ),
        interventionOutcomeFollowUpResolutionSummary:
            _interventionFollowUpResolutionSummary(),
      );

      final interventionSignal = dashboard.signals.firstWhere(
        (signal) => signal.label == 'Interventions',
      );

      expect(dashboard.status, IncomingTalentHealthStatus.critical);
      expect(dashboard.healthScore, 67);
      expect(dashboard.developmentFollowUpOpenCount, 1);
      expect(dashboard.developmentFollowUpDueSoonCount, 1);
      expect(dashboard.developmentFollowUpOverdueCount, 1);
      expect(dashboard.developmentFollowUpEscalatedCount, 1);
      expect(dashboard.nextAction, 'Resolve 1 critical talent health signals.');
      expect(
        interventionSignal.severity,
        IncomingTalentHealthSignalSeverity.critical,
      );
      expect(
        interventionSignal.detail,
        '0 critical, 0 release risks, 0 outcomes on watch, 1 follow-ups due, 0 reviews on watch',
      );
    },
  );

  test('talent health dashboard includes follow-up resolution review risk', () {
    final dashboard = IncomingTalentHealthDashboard.fromSummaries(
      roadmapSummary: _roadmapSummary(total: 2, averageReadiness: 92),
      portfolioSummary: _portfolioSummary(total: 2, averageReadiness: 90),
      careerPathSummary: _careerPathSummary(total: 1),
      supportActionSummary: _supportActionSummary(),
      supportOutcomeSummary: _supportOutcomeSummary(),
      milestoneSummary: _milestoneSummary(),
      completionSummary: _completionSummary(),
      checkInSummary: _checkInSummary(total: 1, averageConfidence: 4),
      interventionSummary: _interventionSummary(total: 1, resolved: 1),
      interventionOutcomeSummary: _interventionOutcomeSummary(),
      interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(),
      interventionOutcomeFollowUpResolutionSummary:
          _interventionFollowUpResolutionSummary(
            total: 2,
            monitor: 1,
            escalate: 1,
            attention: 2,
            averageConfidenceAfter: 2.5,
            averageConfidenceDelta: -1,
          ),
    );

    final interventionSignal = dashboard.signals.firstWhere(
      (signal) => signal.label == 'Interventions',
    );

    expect(dashboard.status, IncomingTalentHealthStatus.critical);
    expect(dashboard.healthScore, 66);
    expect(dashboard.developmentFollowUpResolutionAttentionCount, 2);
    expect(dashboard.developmentFollowUpResolutionEscalatedCount, 1);
    expect(dashboard.averageDevelopmentFollowUpResolutionConfidence, 2.5);
    expect(dashboard.nextAction, 'Resolve 1 critical talent health signals.');
    expect(
      interventionSignal.severity,
      IncomingTalentHealthSignalSeverity.critical,
    );
    expect(
      interventionSignal.detail,
      '0 critical, 0 release risks, 0 outcomes on watch, 0 follow-ups due, 2 reviews on watch',
    );
  });

  test('talent health dashboard includes promotion stabilization risk', () {
    final dashboard = IncomingTalentHealthDashboard.fromSummaries(
      roadmapSummary: _roadmapSummary(total: 2, averageReadiness: 92),
      portfolioSummary: _portfolioSummary(total: 2, averageReadiness: 90),
      careerPathSummary: _careerPathSummary(total: 1),
      supportActionSummary: _supportActionSummary(),
      supportOutcomeSummary: _supportOutcomeSummary(),
      milestoneSummary: _milestoneSummary(),
      completionSummary: _completionSummary(),
      checkInSummary: _checkInSummary(total: 1, averageConfidence: 4),
      interventionSummary: _interventionSummary(total: 1, resolved: 1),
      interventionOutcomeSummary: _interventionOutcomeSummary(),
      interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(),
      interventionOutcomeFollowUpResolutionSummary:
          _interventionFollowUpResolutionSummary(),
      promotionStabilizationSummary: _promotionStabilizationSummary(
        total: 2,
        attention: 2,
        escalated: 1,
        dueFollowUp: 1,
        trialExtended: 1,
        averageConfidence: 2.5,
      ),
    );

    final promotionSignal = dashboard.signals.firstWhere(
      (signal) => signal.label == 'Promotion stability',
    );

    expect(dashboard.status, IncomingTalentHealthStatus.critical);
    expect(dashboard.healthScore, 67);
    expect(dashboard.totalPromotionStabilizationReviews, 2);
    expect(dashboard.promotionStabilizationAttentionCount, 2);
    expect(dashboard.promotionStabilizationEscalatedCount, 1);
    expect(dashboard.promotionStabilizationDueFollowUps, 1);
    expect(dashboard.averagePromotionStabilizationConfidence, 2.5);
    expect(dashboard.nextAction, 'Resolve 1 critical talent health signals.');
    expect(
      promotionSignal.severity,
      IncomingTalentHealthSignalSeverity.critical,
    );
    expect(
      promotionSignal.detail,
      '1 escalated, 1 follow-ups due, 2.5 avg confidence',
    );
  });

  test('talent health dashboard includes promotion follow-up action risk', () {
    final dashboard = IncomingTalentHealthDashboard.fromSummaries(
      roadmapSummary: _roadmapSummary(total: 2, averageReadiness: 92),
      portfolioSummary: _portfolioSummary(total: 2, averageReadiness: 90),
      careerPathSummary: _careerPathSummary(total: 1),
      supportActionSummary: _supportActionSummary(),
      supportOutcomeSummary: _supportOutcomeSummary(),
      milestoneSummary: _milestoneSummary(),
      completionSummary: _completionSummary(),
      checkInSummary: _checkInSummary(total: 1, averageConfidence: 4),
      interventionSummary: _interventionSummary(total: 1, resolved: 1),
      interventionOutcomeSummary: _interventionOutcomeSummary(),
      interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(),
      interventionOutcomeFollowUpResolutionSummary:
          _interventionFollowUpResolutionSummary(),
      promotionFollowUpSummary: _promotionFollowUpSummary(
        total: 2,
        open: 1,
        escalated: 1,
        critical: 1,
        dueSoon: 1,
        attention: 2,
        averageProgress: 0.4,
      ),
    );

    final followUpSignal = dashboard.signals.firstWhere(
      (signal) => signal.label == 'Promotion follow-ups',
    );

    expect(dashboard.status, IncomingTalentHealthStatus.critical);
    expect(dashboard.healthScore, 69);
    expect(dashboard.totalPromotionFollowUpActions, 2);
    expect(dashboard.openPromotionFollowUpActions, 1);
    expect(dashboard.promotionFollowUpAttentionCount, 2);
    expect(dashboard.criticalPromotionFollowUpActions, 1);
    expect(dashboard.promotionFollowUpDueSoonCount, 1);
    expect(dashboard.promotionFollowUpEscalatedCount, 1);
    expect(dashboard.averagePromotionFollowUpProgress, 0.4);
    expect(dashboard.nextAction, 'Resolve 1 critical talent health signals.');
    expect(
      followUpSignal.severity,
      IncomingTalentHealthSignalSeverity.critical,
    );
    expect(followUpSignal.value, '2');
    expect(followUpSignal.detail, '1 escalated, 1 due soon, 40% avg progress');
  });

  test('talent health dashboard includes promotion resolution review risk', () {
    final dashboard = IncomingTalentHealthDashboard.fromSummaries(
      roadmapSummary: _roadmapSummary(total: 2, averageReadiness: 92),
      portfolioSummary: _portfolioSummary(total: 2, averageReadiness: 90),
      careerPathSummary: _careerPathSummary(total: 1),
      supportActionSummary: _supportActionSummary(),
      supportOutcomeSummary: _supportOutcomeSummary(),
      milestoneSummary: _milestoneSummary(),
      completionSummary: _completionSummary(),
      checkInSummary: _checkInSummary(total: 1, averageConfidence: 4),
      interventionSummary: _interventionSummary(total: 1, resolved: 1),
      interventionOutcomeSummary: _interventionOutcomeSummary(),
      interventionOutcomeFollowUpSummary: _interventionFollowUpSummary(),
      interventionOutcomeFollowUpResolutionSummary:
          _interventionFollowUpResolutionSummary(),
      promotionResolutionSummary: _promotionResolutionSummary(
        total: 2,
        monitor: 1,
        reopened: 1,
        attention: 2,
        averageConfidenceAfter: 2.5,
        averageConfidenceDelta: -0.5,
      ),
    );

    final resolutionSignal = dashboard.signals.firstWhere(
      (signal) => signal.label == 'Promotion resolutions',
    );

    expect(dashboard.status, IncomingTalentHealthStatus.critical);
    expect(dashboard.healthScore, 74);
    expect(dashboard.totalPromotionFollowUpResolutions, 2);
    expect(dashboard.promotionResolutionAttentionCount, 2);
    expect(dashboard.promotionResolutionMonitorCount, 1);
    expect(dashboard.promotionResolutionReopenedCount, 1);
    expect(dashboard.promotionResolutionEscalatedCount, 0);
    expect(dashboard.averagePromotionResolutionConfidence, 2.5);
    expect(dashboard.averagePromotionResolutionConfidenceDelta, -0.5);
    expect(dashboard.nextAction, 'Resolve 1 critical talent health signals.');
    expect(
      resolutionSignal.severity,
      IncomingTalentHealthSignalSeverity.critical,
    );
    expect(resolutionSignal.value, '2');
    expect(
      resolutionSignal.detail,
      '0 escalated, 1 reopened, 2.5 avg confidence',
    );
  });

  test('talent health dashboard provider reads filtered module summaries', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentDevelopmentRoadmapSummaryProvider.overrideWithValue(
          _roadmapSummary(total: 1, averageReadiness: 88),
        ),
        incomingTalentDevelopmentPortfolioSummaryProvider.overrideWithValue(
          _portfolioSummary(total: 1, dueSoon: 1, averageReadiness: 82),
        ),
        incomingTalentCareerPathSummaryProvider.overrideWithValue(
          _careerPathSummary(total: 1),
        ),
        incomingTalentDevelopmentCheckInSummaryProvider.overrideWithValue(
          _checkInSummary(total: 1, lowConfidence: 1, averageConfidence: 3),
        ),
        incomingTalentDevelopmentInterventionSummaryProvider.overrideWithValue(
          _interventionSummary(total: 1, open: 1),
        ),
        incomingTalentDevelopmentProgramMilestoneSummaryProvider
            .overrideWithValue(_milestoneSummary(total: 1, dueSoon: 1)),
        incomingTalentDevelopmentProgramCompletionSummaryProvider
            .overrideWithValue(_completionSummary()),
        incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummaryProvider
            .overrideWithValue(_interventionFollowUpResolutionSummary()),
        incomingTalentPromotionStabilizationFollowUpActionSummaryProvider
            .overrideWithValue(
              _promotionFollowUpSummary(
                total: 1,
                open: 1,
                dueSoon: 1,
                attention: 1,
                averageProgress: 0.2,
              ),
            ),
        incomingTalentPromotionStabilizationFollowUpResolutionSummaryProvider
            .overrideWithValue(
              _promotionResolutionSummary(
                total: 1,
                monitor: 1,
                attention: 1,
                averageConfidenceAfter: 3,
              ),
            ),
      ],
    );
    addTearDown(container.dispose);

    final dashboard = container.read(incomingTalentHealthDashboardProvider);

    expect(dashboard.status, IncomingTalentHealthStatus.watch);
    expect(dashboard.healthScore, 65);
    expect(dashboard.totalPortfolios, 1);
    expect(dashboard.duePortfolioReviews, 1);
    expect(dashboard.openInterventions, 1);
    expect(dashboard.dueProgramMilestones, 1);
    expect(dashboard.openPromotionFollowUpActions, 1);
    expect(dashboard.promotionResolutionAttentionCount, 1);
    expect(dashboard.nextAction, 'Review 5 watch talent health signals.');
  });
}

IncomingTalentCareerPathSummary _careerPathSummary({
  required int total,
  int blocked = 0,
  int critical = 0,
  int dueSoon = 0,
  double averageGap = 0,
}) {
  return IncomingTalentCareerPathSummary(
    totalCount: total,
    draftCount: total - blocked,
    activeCount: 0,
    blockedCount: blocked,
    achievedCount: 0,
    criticalCount: critical,
    dueSoonCount: dueSoon,
    averageGap: averageGap,
    nextAction: '',
  );
}

IncomingTalentCareerPathSupportActionSummary _supportActionSummary({
  int total = 0,
  int open = 0,
  int inProgress = 0,
  int resolved = 0,
  int critical = 0,
  int dueSoon = 0,
  int attention = 0,
}) {
  return IncomingTalentCareerPathSupportActionSummary(
    totalCount: total,
    openCount: open,
    inProgressCount: inProgress,
    resolvedCount: resolved,
    criticalCount: critical,
    dueSoonCount: dueSoon,
    attentionCount: attention,
    nextAction: '',
  );
}

IncomingTalentCareerPathSupportOutcomeSummary _supportOutcomeSummary({
  int total = 0,
  int resolved = 0,
  int improved = 0,
  int monitor = 0,
  int escalate = 0,
  int attention = 0,
  double averageVerifiedLevel = 0,
}) {
  return IncomingTalentCareerPathSupportOutcomeSummary(
    totalCount: total,
    resolvedCount: resolved,
    improvedCount: improved,
    monitorCount: monitor,
    escalateCount: escalate,
    attentionCount: attention,
    averageVerifiedLevel: averageVerifiedLevel,
    nextAction: '',
  );
}

IncomingTalentDevelopmentProgramMilestoneSummary _milestoneSummary({
  int total = 0,
  int planned = 0,
  int submitted = 0,
  int accepted = 0,
  int revision = 0,
  int dueSoon = 0,
  double averageScore = 0,
}) {
  return IncomingTalentDevelopmentProgramMilestoneSummary(
    totalCount: total,
    plannedCount: planned,
    submittedCount: submitted,
    acceptedCount: accepted,
    revisionCount: revision,
    dueSoonCount: dueSoon,
    averageScore: averageScore,
    nextAction: '',
  );
}

IncomingTalentDevelopmentProgramCompletionSummary _completionSummary({
  int total = 0,
  int credentialed = 0,
  int roleReady = 0,
  int extension = 0,
  int renewalDue = 0,
  double averageScore = 0,
}) {
  return IncomingTalentDevelopmentProgramCompletionSummary(
    totalCount: total,
    credentialedCount: credentialed,
    roleReadyCount: roleReady,
    extensionCount: extension,
    renewalDueCount: renewalDue,
    averageScore: averageScore,
    nextAction: '',
  );
}

IncomingTalentDevelopmentRoadmapSummary _roadmapSummary({
  required int total,
  int atRisk = 0,
  double averageReadiness = 0,
}) {
  return IncomingTalentDevelopmentRoadmapSummary(
    totalCount: total,
    plannedCount: total - atRisk,
    activeCount: 0,
    atRiskCount: atRisk,
    completedCount: 0,
    highRiskCount: atRisk,
    dueSoonCount: 0,
    averageReadinessScore: averageReadiness,
    nextAction: '',
  );
}

IncomingTalentDevelopmentPortfolioSummary _portfolioSummary({
  required int total,
  int watch = 0,
  int recovery = 0,
  int dueSoon = 0,
  double averageReadiness = 0,
}) {
  return IncomingTalentDevelopmentPortfolioSummary(
    totalCount: total,
    designingCount: total - watch,
    activeCount: 0,
    watchCount: watch,
    graduatedCount: 0,
    recoveryPriorityCount: recovery,
    dueSoonCount: dueSoon,
    averageReadinessScore: averageReadiness,
    nextAction: '',
  );
}

IncomingTalentDevelopmentCheckInSummary _checkInSummary({
  required int total,
  int blocked = 0,
  int lowConfidence = 0,
  double averageConfidence = 0,
}) {
  return IncomingTalentDevelopmentCheckInSummary(
    totalCount: total,
    improvingCount: total - blocked,
    steadyCount: 0,
    watchCount: 0,
    blockedCount: blocked,
    lowConfidenceCount: lowConfidence,
    dueSoonCount: 0,
    averageConfidenceScore: averageConfidence,
    nextAction: '',
  );
}

IncomingTalentDevelopmentInterventionSummary _interventionSummary({
  required int total,
  int open = 0,
  int resolved = 0,
  int critical = 0,
  int dueSoon = 0,
  int activationFollowUp = 0,
  int releaseBacked = 0,
  int releaseRisk = 0,
}) {
  return IncomingTalentDevelopmentInterventionSummary(
    totalCount: total,
    openCount: open,
    inProgressCount: total - open - resolved,
    resolvedCount: resolved,
    criticalCount: critical,
    dueSoonCount: dueSoon,
    activationFollowUpCount: activationFollowUp,
    releaseEvidenceBackedCount: releaseBacked,
    releaseEvidenceRiskCount: releaseRisk,
    nextAction: '',
  );
}

IncomingTalentDevelopmentInterventionOutcomeSummary
_interventionOutcomeSummary({
  int total = 0,
  int improved = 0,
  int stabilized = 0,
  int monitor = 0,
  int escalate = 0,
  int attention = 0,
  int releaseRisk = 0,
  double averageConfidenceAfter = 0,
}) {
  return IncomingTalentDevelopmentInterventionOutcomeSummary(
    totalCount: total,
    improvedCount: improved,
    stabilizedCount: stabilized,
    monitorCount: monitor,
    escalateCount: escalate,
    attentionCount: attention,
    releaseRiskCount: releaseRisk,
    averageConfidenceAfter: averageConfidenceAfter,
    nextAction: '',
  );
}

IncomingTalentDevelopmentInterventionOutcomeFollowUpSummary
_interventionFollowUpSummary({
  int total = 0,
  int open = 0,
  int inProgress = 0,
  int completed = 0,
  int escalated = 0,
  int dueSoon = 0,
  int overdue = 0,
  int attention = 0,
}) {
  return IncomingTalentDevelopmentInterventionOutcomeFollowUpSummary(
    totalCount: total,
    openCount: open,
    inProgressCount: inProgress,
    completedCount: completed,
    escalatedCount: escalated,
    dueSoonCount: dueSoon,
    overdueCount: overdue,
    attentionCount: attention,
    nextAction: '',
  );
}

IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummary
_interventionFollowUpResolutionSummary({
  int total = 0,
  int closed = 0,
  int sustained = 0,
  int monitor = 0,
  int escalate = 0,
  int attention = 0,
  double averageConfidenceAfter = 0,
  double averageConfidenceDelta = 0,
}) {
  return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummary(
    totalCount: total,
    closedCount: closed,
    sustainedCount: sustained,
    monitorCount: monitor,
    escalateCount: escalate,
    attentionCount: attention,
    averageConfidenceAfter: averageConfidenceAfter,
    averageConfidenceDelta: averageConfidenceDelta,
    nextAction: '',
  );
}

IncomingTalentPromotionStabilizationReviewSummary
_promotionStabilizationSummary({
  int total = 0,
  int stable = 0,
  int followUpRequired = 0,
  int escalated = 0,
  int attention = 0,
  int dueFollowUp = 0,
  int compensationFollowUp = 0,
  int trialExtended = 0,
  double averageConfidence = 0,
}) {
  return IncomingTalentPromotionStabilizationReviewSummary(
    totalCount: total,
    stableCount: stable,
    followUpRequiredCount: followUpRequired,
    escalatedCount: escalated,
    attentionCount: attention,
    dueFollowUpCount: dueFollowUp,
    compensationFollowUpCount: compensationFollowUp,
    trialExtendedCount: trialExtended,
    averageConfidence: averageConfidence,
    averageProgress: 0,
    nextAction: '',
  );
}

IncomingTalentPromotionStabilizationFollowUpActionSummary
_promotionFollowUpSummary({
  int total = 0,
  int open = 0,
  int inProgress = 0,
  int resolved = 0,
  int escalated = 0,
  int cancelled = 0,
  int critical = 0,
  int dueSoon = 0,
  int attention = 0,
  double averageProgress = 0,
}) {
  return IncomingTalentPromotionStabilizationFollowUpActionSummary(
    totalCount: total,
    openCount: open,
    inProgressCount: inProgress,
    resolvedCount: resolved,
    escalatedCount: escalated,
    cancelledCount: cancelled,
    criticalCount: critical,
    dueSoonCount: dueSoon,
    attentionCount: attention,
    averageProgress: averageProgress,
    nextAction: '',
  );
}

IncomingTalentPromotionStabilizationFollowUpResolutionSummary
_promotionResolutionSummary({
  int total = 0,
  int stabilized = 0,
  int monitor = 0,
  int reopened = 0,
  int escalated = 0,
  int attention = 0,
  double averageConfidenceAfter = 0,
  double averageConfidenceDelta = 0,
}) {
  return IncomingTalentPromotionStabilizationFollowUpResolutionSummary(
    totalCount: total,
    stabilizedCount: stabilized,
    monitorCount: monitor,
    reopenedCount: reopened,
    escalatedCount: escalated,
    attentionCount: attention,
    averageConfidenceAfter: averageConfidenceAfter,
    averageConfidenceDelta: averageConfidenceDelta,
    nextAction: '',
  );
}
