import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_activation_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_bench_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_bench_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_bench_replenishment_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_dashboard_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_transition_intervention_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_transition_outcome_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_transition_pulse_provider.dart';

void main() {
  test('succession coverage dashboard marks empty slate critical', () {
    final container = _container();
    addTearDown(container.dispose);

    final dashboard = container.read(
      incomingTalentSuccessionCoverageDashboardProvider,
    );

    expect(dashboard.totalCandidates, 0);
    expect(dashboard.coverageScore, 0);
    expect(dashboard.health, IncomingTalentSuccessionCoverageHealth.critical);
    expect(
      dashboard.nextAction,
      'Build a succession slate before coverage review.',
    );
  });

  test(
    'succession coverage dashboard recognizes healthy ready-now coverage',
    () {
      final container = _container(
        candidates: [
          _candidate(
            id: 'engineering',
            readiness: IncomingTalentSuccessionReadiness.readyNow,
            risk: IncomingTalentSuccessionRisk.low,
          ),
          _candidate(
            id: 'finance',
            department: 'Finance',
            readiness: IncomingTalentSuccessionReadiness.readySoon,
            risk: IncomingTalentSuccessionRisk.low,
          ),
        ],
      );
      addTearDown(container.dispose);

      final dashboard = container.read(
        incomingTalentSuccessionCoverageDashboardProvider,
      );

      expect(dashboard.coverageScore, 81);
      expect(dashboard.readyCoverageRatio, 1);
      expect(dashboard.attentionSignalCount, 0);
      expect(dashboard.health, IncomingTalentSuccessionCoverageHealth.strong);
      expect(dashboard.nextAction, 'Succession coverage is healthy.');
    },
  );

  test('succession coverage dashboard prioritizes open bench actions', () {
    final container = _container(
      candidates: [
        _candidate(
          id: 'engineering',
          readiness: IncomingTalentSuccessionReadiness.blocked,
          risk: IncomingTalentSuccessionRisk.high,
        ),
      ],
      benchPlans: [_benchPlan()],
      benchCheckIns: [_benchCheckIn()],
      benchActions: [_benchAction()],
    );
    addTearDown(container.dispose);

    final dashboard = container.read(
      incomingTalentSuccessionCoverageDashboardProvider,
    );

    expect(dashboard.coverageScore, 1);
    expect(dashboard.blockedCandidateCount, 1);
    expect(dashboard.criticalBenchPlanCount, 1);
    expect(dashboard.benchCheckInAttentionCount, 1);
    expect(dashboard.openBenchActionCount, 1);
    expect(dashboard.health, IncomingTalentSuccessionCoverageHealth.critical);
    expect(
      dashboard.nextAction,
      'Resolve 1 open bench action before coverage review.',
    );
  });
}

ProviderContainer _container({
  List<IncomingTalentSuccessionCandidate> candidates = const [],
  List<IncomingTalentSuccessionActivationPlan> activationPlans = const [],
  List<IncomingTalentSuccessionTransitionPulse> transitionPulses = const [],
  List<IncomingTalentSuccessionTransitionIntervention> transitionInterventions =
      const [],
  List<IncomingTalentSuccessionTransitionOutcomeReview>
      transitionOutcomeReviews =
      const [],
  List<IncomingTalentSuccessionBenchReplenishment> benchPlans = const [],
  List<IncomingTalentSuccessionBenchCheckIn> benchCheckIns = const [],
  List<IncomingTalentSuccessionBenchAction> benchActions = const [],
}) {
  return ProviderContainer(
    overrides: [
      filteredIncomingTalentSuccessionCandidatesProvider.overrideWithValue(
        candidates,
      ),
      filteredIncomingTalentSuccessionActivationPlansProvider.overrideWithValue(
        activationPlans,
      ),
      filteredIncomingTalentSuccessionTransitionPulsesProvider
          .overrideWithValue(transitionPulses),
      filteredIncomingTalentSuccessionTransitionInterventionsProvider
          .overrideWithValue(transitionInterventions),
      filteredIncomingTalentSuccessionTransitionOutcomeReviewsProvider
          .overrideWithValue(transitionOutcomeReviews),
      filteredIncomingTalentSuccessionBenchReplenishmentsProvider
          .overrideWithValue(benchPlans),
      filteredIncomingTalentSuccessionBenchCheckInsProvider.overrideWithValue(
        benchCheckIns,
      ),
      filteredIncomingTalentSuccessionBenchActionsProvider.overrideWithValue(
        benchActions,
      ),
    ],
  );
}

IncomingTalentSuccessionCandidate _candidate({
  required String id,
  String department = 'Engineering',
  required IncomingTalentSuccessionReadiness readiness,
  required IncomingTalentSuccessionRisk risk,
}) {
  return IncomingTalentSuccessionCandidate(
    candidateId: 'candidate-$id',
    candidateName: 'Candidate $id',
    role: '$department Specialist',
    department: department,
    targetRole: '$department Lead',
    promotionTrack: 'Succession track',
    readiness: readiness,
    risk: risk,
    readinessScore:
        readiness == IncomingTalentSuccessionReadiness.readyNow ? 92 : 78,
    confidenceScore: risk == IncomingTalentSuccessionRisk.low ? 5 : 2,
    openInterventionCount:
        readiness == IncomingTalentSuccessionReadiness.blocked ? 1 : 0,
    latestCalibrationDecisionLabel: 'Approved',
    evidenceSummary: 'Evidence summary for succession coverage.',
    nextAction: 'Keep succession plan current.',
    latestEvidenceDate: DateTime(2026, 6, 5),
  );
}

IncomingTalentSuccessionBenchReplenishment _benchPlan() {
  return IncomingTalentSuccessionBenchReplenishment(
    id: 'bench-001',
    outcomeReviewId: 'outcome-001',
    interventionId: 'intervention-001',
    pulseId: 'pulse-001',
    closureId: 'closure-001',
    activationPlanId: 'activation-001',
    decisionId: 'decision-001',
    candidateId: 'candidate-engineering',
    candidateName: 'Candidate engineering',
    role: 'Engineering Specialist',
    department: 'Engineering',
    targetRole: 'Engineering Lead',
    ownerName: 'Engineering Talent Partner',
    outcomeDecision:
        IncomingTalentSuccessionTransitionOutcomeDecision.successionRework,
    residualRisk: IncomingTalentSuccessionTransitionOutcomeResidualRisk.high,
    priority: IncomingTalentSuccessionBenchReplenishmentPriority.critical,
    status: IncomingTalentSuccessionBenchReplenishmentStatus.active,
    targetReadyDate: DateTime(2026, 6, 19),
    benchGap: 'Ready-now bench depth is below role coverage threshold.',
    sourcingStrategy: 'Open internal and external successor sourcing paths.',
    developmentTrack: 'Accelerated readiness track for emerging successors.',
    reviewCadence: 'Weekly talent council review.',
    createdAt: DateTime(2026, 6, 5),
  );
}

IncomingTalentSuccessionBenchCheckIn _benchCheckIn() {
  return IncomingTalentSuccessionBenchCheckIn(
    id: 'check-in-001',
    benchReplenishmentId: 'bench-001',
    outcomeReviewId: 'outcome-001',
    interventionId: 'intervention-001',
    activationPlanId: 'activation-001',
    decisionId: 'decision-001',
    candidateId: 'candidate-engineering',
    candidateName: 'Candidate engineering',
    role: 'Engineering Specialist',
    department: 'Engineering',
    targetRole: 'Engineering Lead',
    ownerName: 'Engineering Talent Partner',
    priority: IncomingTalentSuccessionBenchReplenishmentPriority.critical,
    planStatus: IncomingTalentSuccessionBenchReplenishmentStatus.active,
    checkInDate: DateTime(2026, 6, 5),
    health: IncomingTalentSuccessionBenchCheckInHealth.atRisk,
    successorSlateCount: 2,
    readyNowCount: 0,
    readinessScore: 2,
    blockerSummary: 'Bench check-in confirms ready-now successor gaps.',
    leadershipSupport: 'Leadership support needed for successor mobility.',
    nextAction: 'Activate bench action for critical successor coverage.',
    nextCheckInDate: DateTime(2026, 6, 12),
    createdAt: DateTime(2026, 6, 5),
  );
}

IncomingTalentSuccessionBenchAction _benchAction() {
  return IncomingTalentSuccessionBenchAction(
    id: 'action-001',
    checkInId: 'check-in-001',
    benchReplenishmentId: 'bench-001',
    outcomeReviewId: 'outcome-001',
    activationPlanId: 'activation-001',
    decisionId: 'decision-001',
    candidateId: 'candidate-engineering',
    candidateName: 'Candidate engineering',
    role: 'Engineering Specialist',
    department: 'Engineering',
    targetRole: 'Engineering Lead',
    ownerName: 'Engineering Talent Partner',
    priority: IncomingTalentSuccessionBenchReplenishmentPriority.critical,
    checkInHealth: IncomingTalentSuccessionBenchCheckInHealth.atRisk,
    actionType: IncomingTalentSuccessionBenchActionType.sourcing,
    status: IncomingTalentSuccessionBenchActionStatus.planned,
    dueDate: DateTime(2026, 6, 12),
    actionPlan: 'Launch successor sourcing and readiness remediation.',
    escalationPath: 'Escalate blocked coverage to talent council.',
    resolutionEvidence: 'Coverage action remains open for verification.',
    createdAt: DateTime(2026, 6, 5),
  );
}
