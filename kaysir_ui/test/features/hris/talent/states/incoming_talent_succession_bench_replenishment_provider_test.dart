import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_bench_replenishment_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_transition_outcome_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent succession bench replenishment submits from transition outcome',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final review = _submitOutcomeReview(
        container,
        asOfDate,
        decision:
            IncomingTalentSuccessionTransitionOutcomeDecision.successionRework,
        residualRisk:
            IncomingTalentSuccessionTransitionOutcomeResidualRisk.high,
        stabilizationScore: 2,
      );

      expect(
        container.read(benchReadySuccessionTransitionOutcomeReviewsProvider),
        [review],
      );

      container
          .read(
            incomingTalentSuccessionBenchReplenishmentDraftProvider.notifier,
          )
          .initializeFromOutcomeReview(review);
      final draft = container.read(
        incomingTalentSuccessionBenchReplenishmentDraftProvider,
      );
      final plan = container
          .read(incomingTalentSuccessionBenchReplenishmentsProvider.notifier)
          .submitDraft(draft);
      final summary = container.read(
        incomingTalentSuccessionBenchReplenishmentSummaryProvider,
      );

      expect(plan.id, 'talent-succession-bench-replenishment-001');
      expect(plan.outcomeReviewId, review.id);
      expect(
        plan.priority,
        IncomingTalentSuccessionBenchReplenishmentPriority.critical,
      );
      expect(
        plan.status,
        IncomingTalentSuccessionBenchReplenishmentStatus.planned,
      );
      expect(plan.targetReadyDate, asOfDate.add(const Duration(days: 30)));
      expect(summary.totalPlans, 1);
      expect(summary.criticalCount, 1);
      expect(summary.nextAction, 'Start 1 critical bench replenishments.');
      expect(
        container.read(benchReadySuccessionTransitionOutcomeReviewsProvider),
        isEmpty,
      );

      expect(
        () => container
            .read(incomingTalentSuccessionBenchReplenishmentsProvider.notifier)
            .submitDraft(draft),
        throwsStateError,
      );
    },
  );

  test(
    'incoming talent succession bench replenishment draft validates fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentSuccessionBenchReplenishmentDraft.empty(
        asOfDate,
      ).copyWith(
        targetReadyDate: asOfDate.subtract(const Duration(days: 1)),
        benchGap: 'short',
        sourcingStrategy: 'tiny',
        developmentTrack: 'mini',
        reviewCadence: 'brief',
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter a transition outcome',
        'Please enter a replenishment owner',
        'Select outcome decision',
        'Select residual risk',
        'Select replenishment priority',
        'Select replenishment status',
        'Target ready date cannot be in the past',
        'Bench gap must be at least 12 characters',
        'Sourcing strategy must be at least 12 characters',
        'Development track must be at least 12 characters',
        'Review cadence must be at least 12 characters',
      ]);
    },
  );

  test(
    'incoming talent succession bench replenishments follow filters and statuses',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final engineeringReview = _submitOutcomeReview(
        container,
        asOfDate,
        id: 'engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
        decision: IncomingTalentSuccessionTransitionOutcomeDecision.stabilized,
        residualRisk: IncomingTalentSuccessionTransitionOutcomeResidualRisk.low,
        stabilizationScore: 5,
      );
      _submitBenchPlan(container, engineeringReview);

      final financeReview = _submitOutcomeReview(
        container,
        asOfDate,
        id: 'finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        decision:
            IncomingTalentSuccessionTransitionOutcomeDecision.leadershipReview,
        residualRisk:
            IncomingTalentSuccessionTransitionOutcomeResidualRisk.high,
        stabilizationScore: 2,
      );
      final financePlan = _submitBenchPlan(container, financeReview);

      container
          .read(incomingTalentSuccessionBenchReplenishmentsProvider.notifier)
          .block(financePlan.id);
      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      var filtered = container.read(
        filteredIncomingTalentSuccessionBenchReplenishmentsProvider,
      );
      var summary = container.read(
        incomingTalentSuccessionBenchReplenishmentSummaryProvider,
      );

      expect(filtered.map((plan) => plan.candidateName), ['Mira Lestari']);
      expect(
        filtered.single.status,
        IncomingTalentSuccessionBenchReplenishmentStatus.blocked,
      );
      expect(summary.blockedCount, 1);
      expect(summary.nextAction, 'Unblock 1 bench replenishments.');

      container
          .read(incomingTalentSuccessionBenchReplenishmentsProvider.notifier)
          .complete(filtered.single.id);
      filtered = container.read(
        filteredIncomingTalentSuccessionBenchReplenishmentsProvider,
      );
      expect(filtered, isEmpty);

      container.read(talentNeedsAttentionProvider.notifier).state = false;
      filtered = container.read(
        filteredIncomingTalentSuccessionBenchReplenishmentsProvider,
      );
      summary = container.read(
        incomingTalentSuccessionBenchReplenishmentSummaryProvider,
      );

      expect(
        filtered.single.status,
        IncomingTalentSuccessionBenchReplenishmentStatus.completed,
      );
      expect(summary.completedCount, 1);
      expect(summary.nextAction, '1 bench replenishments complete.');
    },
  );
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentSuccessionTransitionOutcomeReview _submitOutcomeReview(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentSuccessionTransitionOutcomeDecision decision,
  required IncomingTalentSuccessionTransitionOutcomeResidualRisk residualRisk,
  required int stabilizationScore,
}) {
  return container
      .read(incomingTalentSuccessionTransitionOutcomeReviewsProvider.notifier)
      .submitDraft(
        IncomingTalentSuccessionTransitionOutcomeReviewDraft(
          interventionId: 'intervention-$id',
          pulseId: 'pulse-$id',
          closureId: 'closure-$id',
          resolutionReviewId: 'resolution-$id',
          activationPlanId: 'activation-$id',
          decisionId: 'decision-$id',
          candidateId: 'candidate-$id',
          candidateName: candidateName,
          role: role,
          department: department,
          targetRole: '$department Succession Lead',
          reviewerName: '$department Talent Partner',
          interventionType:
              IncomingTalentSuccessionTransitionInterventionType
                  .managerAlignment,
          interventionStatus:
              IncomingTalentSuccessionTransitionInterventionStatus.completed,
          pulseHealth:
              decision ==
                      IncomingTalentSuccessionTransitionOutcomeDecision
                          .stabilized
                  ? IncomingTalentSuccessionTransitionPulseHealth.stable
                  : IncomingTalentSuccessionTransitionPulseHealth.intervention,
          retentionRisk:
              residualRisk ==
                      IncomingTalentSuccessionTransitionOutcomeResidualRisk.high
                  ? IncomingTalentSuccessionTransitionRetentionRisk.high
                  : IncomingTalentSuccessionTransitionRetentionRisk.low,
          reviewDate: asOfDate,
          decision: decision,
          residualRisk: residualRisk,
          stabilizationScore: stabilizationScore,
          evidenceSummary:
              'Outcome review evidence confirms transition stabilization.',
          lessonsLearned:
              'Lessons learned capture manager support and adoption signals.',
          nextTalentAction:
              'Update successor bench and calibrate coverage actions.',
          nextReviewDate: asOfDate.add(const Duration(days: 30)),
          asOfDate: asOfDate,
        ),
      );
}

IncomingTalentSuccessionBenchReplenishment _submitBenchPlan(
  ProviderContainer container,
  IncomingTalentSuccessionTransitionOutcomeReview review,
) {
  container
      .read(incomingTalentSuccessionBenchReplenishmentDraftProvider.notifier)
      .initializeFromOutcomeReview(review);
  return container
      .read(incomingTalentSuccessionBenchReplenishmentsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionBenchReplenishmentDraftProvider),
      );
}
