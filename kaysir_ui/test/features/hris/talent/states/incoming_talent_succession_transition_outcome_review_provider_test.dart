import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_transition_intervention_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_transition_outcome_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_transition_pulse_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent succession transition outcomes submit from completed intervention',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final intervention = _submitCompletedIntervention(
        container,
        asOfDate,
        health: IncomingTalentSuccessionTransitionPulseHealth.intervention,
        adoptionScore: 2,
        managerConfidenceScore: 2,
        retentionRisk: IncomingTalentSuccessionTransitionRetentionRisk.high,
      );

      expect(
        container.read(outcomeReadySuccessionTransitionInterventionsProvider),
        [intervention],
      );

      container
          .read(
            incomingTalentSuccessionTransitionOutcomeReviewDraftProvider
                .notifier,
          )
          .initializeFromIntervention(intervention);
      final draft = container.read(
        incomingTalentSuccessionTransitionOutcomeReviewDraftProvider,
      );
      final review = container
          .read(
            incomingTalentSuccessionTransitionOutcomeReviewsProvider.notifier,
          )
          .submitDraft(draft);
      final summary = container.read(
        incomingTalentSuccessionTransitionOutcomeReviewSummaryProvider,
      );

      expect(review.id, 'talent-succession-transition-outcome-001');
      expect(review.interventionId, intervention.id);
      expect(
        review.decision,
        IncomingTalentSuccessionTransitionOutcomeDecision.extendSupport,
      );
      expect(
        review.residualRisk,
        IncomingTalentSuccessionTransitionOutcomeResidualRisk.high,
      );
      expect(review.stabilizationScore, 3);
      expect(review.nextReviewDate, asOfDate.add(const Duration(days: 30)));
      expect(summary.totalReviews, 1);
      expect(summary.extendedCount, 1);
      expect(summary.attentionCount, 1);
      expect(summary.nextAction, 'Keep 1 transition outcomes on watch.');
      expect(
        container.read(outcomeReadySuccessionTransitionInterventionsProvider),
        isEmpty,
      );

      expect(
        () => container
            .read(
              incomingTalentSuccessionTransitionOutcomeReviewsProvider.notifier,
            )
            .submitDraft(draft),
        throwsStateError,
      );
    },
  );

  test(
    'incoming talent succession transition outcome draft validates fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final pastDate = asOfDate.subtract(const Duration(days: 1));
      final draft = IncomingTalentSuccessionTransitionOutcomeReviewDraft.empty(
        asOfDate,
      ).copyWith(
        reviewDate: pastDate,
        nextReviewDate: pastDate,
        evidenceSummary: 'short',
        lessonsLearned: 'tiny',
        nextTalentAction: 'mini',
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter a completed intervention',
        'Please enter an outcome reviewer',
        'Select a completed intervention',
        'Review date cannot be in the past',
        'Select outcome decision',
        'Select residual risk',
        'Stabilization score must be between 1 and 5',
        'Evidence summary must be at least 12 characters',
        'Lessons learned must be at least 12 characters',
        'Next talent action must be at least 12 characters',
        'Next review must be after review date',
      ]);
    },
  );

  test('incoming talent succession transition outcomes follow filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringIntervention = _submitCompletedIntervention(
      container,
      asOfDate,
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
      health: IncomingTalentSuccessionTransitionPulseHealth.stable,
      adoptionScore: 4,
      managerConfidenceScore: 4,
      retentionRisk: IncomingTalentSuccessionTransitionRetentionRisk.low,
    );
    _submitOutcome(container, engineeringIntervention);

    final financeIntervention = _submitCompletedIntervention(
      container,
      asOfDate,
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
      health: IncomingTalentSuccessionTransitionPulseHealth.intervention,
      adoptionScore: 2,
      managerConfidenceScore: 2,
      retentionRisk: IncomingTalentSuccessionTransitionRetentionRisk.high,
    );
    container
        .read(
          incomingTalentSuccessionTransitionOutcomeReviewDraftProvider.notifier,
        )
        .initializeFromIntervention(financeIntervention);
    container
        .read(
          incomingTalentSuccessionTransitionOutcomeReviewDraftProvider.notifier,
        )
        .setDecision(
          IncomingTalentSuccessionTransitionOutcomeDecision.successionRework,
        );
    container
        .read(
          incomingTalentSuccessionTransitionOutcomeReviewDraftProvider.notifier,
        )
        .setResidualRisk(
          IncomingTalentSuccessionTransitionOutcomeResidualRisk.high,
        );
    container
        .read(
          incomingTalentSuccessionTransitionOutcomeReviewDraftProvider.notifier,
        )
        .setStabilizationScore(2);
    container
        .read(
          incomingTalentSuccessionTransitionOutcomeReviewDraftProvider.notifier,
        )
        .setNextTalentAction(
          'Reopen succession coverage with interim role ownership.',
        );
    final financeReview = container
        .read(incomingTalentSuccessionTransitionOutcomeReviewsProvider.notifier)
        .submitDraft(
          container.read(
            incomingTalentSuccessionTransitionOutcomeReviewDraftProvider,
          ),
        );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    var filtered = container.read(
      filteredIncomingTalentSuccessionTransitionOutcomeReviewsProvider,
    );
    var summary = container.read(
      incomingTalentSuccessionTransitionOutcomeReviewSummaryProvider,
    );

    expect(filtered.map((review) => review.candidateName), ['Mira Lestari']);
    expect(filtered.single, financeReview);
    expect(summary.successionReworkCount, 1);
    expect(summary.nextAction, 'Rework 1 transition outcomes.');

    container.read(talentDepartmentProvider.notifier).state = 'Engineering';
    filtered = container.read(
      filteredIncomingTalentSuccessionTransitionOutcomeReviewsProvider,
    );
    expect(filtered, isEmpty);

    container.read(talentNeedsAttentionProvider.notifier).state = false;
    filtered = container.read(
      filteredIncomingTalentSuccessionTransitionOutcomeReviewsProvider,
    );
    summary = container.read(
      incomingTalentSuccessionTransitionOutcomeReviewSummaryProvider,
    );

    expect(filtered.single.candidateName, 'Fajar Nugroho');
    expect(summary.stabilizedCount, 1);
    expect(summary.nextAction, '1 transition outcomes stabilized.');
  });
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentSuccessionTransitionIntervention _submitCompletedIntervention(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentSuccessionTransitionPulseHealth health,
  required int adoptionScore,
  required int managerConfidenceScore,
  required IncomingTalentSuccessionTransitionRetentionRisk retentionRisk,
}) {
  final pulse = container
      .read(incomingTalentSuccessionTransitionPulsesProvider.notifier)
      .submitDraft(
        IncomingTalentSuccessionTransitionPulseDraft(
          closureId: 'closure-$id',
          resolutionReviewId: 'resolution-$id',
          activationPlanId: 'activation-$id',
          decisionId: 'decision-$id',
          candidateId: 'candidate-$id',
          candidateName: candidateName,
          role: role,
          department: department,
          targetRole: '$department Succession Lead',
          ownerName: '$department Talent Partner',
          closureType: IncomingTalentSuccessionActivationClosureType.promotion,
          closureStatus:
              IncomingTalentSuccessionActivationClosureStatus.completed,
          effectiveDate: asOfDate,
          pulseWindow: IncomingTalentSuccessionTransitionPulseWindow.thirtyDay,
          pulseDate: asOfDate,
          health: health,
          adoptionScore: adoptionScore,
          managerConfidenceScore: managerConfidenceScore,
          retentionRisk: retentionRisk,
          outcomeEvidence:
              'Transition pulse evidence confirms current adoption state.',
          employeeSignal:
              'Employee signal captures role clarity and transition support.',
          managerSignal:
              'Manager signal captures delivery ownership and support gaps.',
          stakeholderSentiment:
              'Stakeholders report transition adoption and accountability.',
          nextAction:
              'Create focused transition support before the next pulse.',
          nextPulseDate: asOfDate.add(const Duration(days: 30)),
          asOfDate: asOfDate,
        ),
      );

  container
      .read(
        incomingTalentSuccessionTransitionInterventionDraftProvider.notifier,
      )
      .initializeFromPulse(pulse);
  final intervention = container
      .read(incomingTalentSuccessionTransitionInterventionsProvider.notifier)
      .submitDraft(
        container.read(
          incomingTalentSuccessionTransitionInterventionDraftProvider,
        ),
      );
  container
      .read(incomingTalentSuccessionTransitionInterventionsProvider.notifier)
      .complete(intervention.id);

  return container
      .read(incomingTalentSuccessionTransitionInterventionsProvider)
      .firstWhere((item) => item.id == intervention.id);
}

IncomingTalentSuccessionTransitionOutcomeReview _submitOutcome(
  ProviderContainer container,
  IncomingTalentSuccessionTransitionIntervention intervention,
) {
  container
      .read(
        incomingTalentSuccessionTransitionOutcomeReviewDraftProvider.notifier,
      )
      .initializeFromIntervention(intervention);
  return container
      .read(incomingTalentSuccessionTransitionOutcomeReviewsProvider.notifier)
      .submitDraft(
        container.read(
          incomingTalentSuccessionTransitionOutcomeReviewDraftProvider,
        ),
      );
}
