import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_outcome_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('intervention outcome follow-up draft defaults from outcome', () {
    final asOfDate = DateTime(2026, 5, 30);
    final outcome = _submitReadyOutcomeDraft(
      asOfDate,
    ).toOutcome(id: 'talent-intervention-outcome-001', createdAt: asOfDate);

    final draft =
        IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft.fromOutcome(
          outcome: outcome,
          asOfDate: asOfDate,
        );

    expect(draft.outcomeId, outcome.id);
    expect(draft.ownerName, outcome.ownerName);
    expect(draft.dueDate, outcome.nextReviewDate);
    expect(
      draft.status,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.open,
    );
    expect(
      draft.successCriteria,
      contains('Remaining development risk is reviewed'),
    );
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('intervention outcome follow-ups submit, de-duplicate, and summarize', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final outcome = _submitOutcome(
      container,
      _submitReadyOutcomeDraft(
        asOfDate,
        nextReviewDate: asOfDate.add(const Duration(days: 3)),
      ),
    );

    expect(
      container.read(followUpReadyDevelopmentInterventionOutcomesProvider),
      [outcome],
    );

    container
        .read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider
              .notifier,
        )
        .initializeFromOutcome(outcome);
    final followUp = container
        .read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider
              .notifier,
        )
        .submitDraft(
          container.read(
            incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider,
          ),
        );

    expect(followUp.id, 'talent-intervention-outcome-follow-up-001');
    expect(followUp.action, outcome.nextAction);
    expect(
      container.read(followUpReadyDevelopmentInterventionOutcomesProvider),
      isEmpty,
    );
    expect(
      () => container
          .read(
            incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider
                .notifier,
          )
          .submitDraft(
            container.read(
              incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider,
            ),
          ),
      throwsStateError,
    );

    final summary = container.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.openCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.attentionCount, 1);
    expect(
      summary.nextAction,
      'Complete 1 intervention outcome follow-ups due soon.',
    );
  });

  test('intervention outcome follow-ups follow lifecycle controls', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final first = _submitFollowUp(
      container,
      _submitOutcome(
        container,
        _submitReadyOutcomeDraft(asOfDate, id: 'outcome-001'),
      ),
    );
    final second = _submitFollowUp(
      container,
      _submitOutcome(
        container,
        _submitReadyOutcomeDraft(
          asOfDate,
          id: 'outcome-002',
          candidateName: 'Mira Lestari',
          department: 'Finance',
        ),
      ),
    );

    final notifier = container.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider.notifier,
    );
    notifier.start(first.id);
    notifier.complete(
      first.id,
      resolutionNote: 'Follow-up evidence reviewed and closed.',
    );
    notifier.escalate(
      second.id,
      resolutionNote: 'Residual release risk escalated to HR council.',
    );

    final followUps = container.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider,
    );
    expect(
      followUps.firstWhere((item) => item.id == first.id).status,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.completed,
    );
    expect(
      followUps.firstWhere((item) => item.id == second.id).status,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.escalated,
    );
    expect(
      () => notifier.complete(
        second.id,
        resolutionNote: 'Try closing escalated follow-up.',
      ),
      throwsStateError,
    );

    final summary = container.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpSummaryProvider,
    );
    expect(summary.completedCount, 1);
    expect(summary.escalatedCount, 1);
    expect(summary.attentionCount, 1);
    expect(
      summary.nextAction,
      'Review 1 escalated intervention outcome follow-ups.',
    );
  });

  test(
    'intervention outcome follow-ups follow department and attention filters',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      _submitFollowUp(
        container,
        _submitOutcome(
          container,
          _submitReadyOutcomeDraft(
            asOfDate,
            id: 'engineering-outcome',
            candidateName: 'Fajar Nugroho',
            department: 'Engineering',
            decision:
                IncomingTalentDevelopmentInterventionOutcomeDecision.stabilized,
            confidenceAfter: 4,
            remainingReleaseRiskCount: 0,
            nextReviewDate: asOfDate.add(const Duration(days: 30)),
          ),
        ),
      );
      final financeFollowUp = _submitFollowUp(
        container,
        _submitOutcome(
          container,
          _submitReadyOutcomeDraft(
            asOfDate,
            id: 'finance-outcome',
            candidateName: 'Mira Lestari',
            department: 'Finance',
            nextReviewDate: asOfDate.add(const Duration(days: 2)),
          ),
        ),
      );

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(
        filteredIncomingTalentDevelopmentInterventionOutcomeFollowUpsProvider,
      );
      final summary = container.read(
        incomingTalentDevelopmentInterventionOutcomeFollowUpSummaryProvider,
      );

      expect(filtered, [financeFollowUp]);
      expect(summary.totalCount, 1);
      expect(summary.attentionCount, 1);
    },
  );
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentDevelopmentInterventionOutcome _submitOutcome(
  ProviderContainer container,
  IncomingTalentDevelopmentInterventionOutcomeDraft draft,
) {
  return container
      .read(incomingTalentDevelopmentInterventionOutcomesProvider.notifier)
      .submitDraft(draft);
}

IncomingTalentDevelopmentInterventionOutcomeFollowUp _submitFollowUp(
  ProviderContainer container,
  IncomingTalentDevelopmentInterventionOutcome outcome,
) {
  container
      .read(
        incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider
            .notifier,
      )
      .initializeFromOutcome(outcome);
  return container
      .read(
        incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider.notifier,
      )
      .submitDraft(
        container.read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider,
        ),
      );
}

IncomingTalentDevelopmentInterventionOutcomeDraft _submitReadyOutcomeDraft(
  DateTime asOfDate, {
  String id = 'outcome-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  IncomingTalentDevelopmentInterventionOutcomeDecision decision =
      IncomingTalentDevelopmentInterventionOutcomeDecision.monitor,
  int confidenceAfter = 3,
  int remainingReleaseRiskCount = 1,
  DateTime? nextReviewDate,
}) {
  final candidateKey = candidateName.toLowerCase().split(' ').first;
  final reviewDate = asOfDate;
  return IncomingTalentDevelopmentInterventionOutcomeDraft(
    interventionId: 'intervention-$id',
    checkInId: 'check-in-$id',
    activationFollowUpId: '',
    candidateId: 'candidate-$candidateKey',
    candidateName: candidateName,
    role: '$department Specialist',
    department: department,
    ownerName: '$department Manager',
    reviewerName: '$department Partner',
    reviewDate: reviewDate,
    source: IncomingTalentDevelopmentInterventionSource.checkIn,
    interventionType: IncomingTalentDevelopmentInterventionType.coaching,
    priority: IncomingTalentDevelopmentInterventionPriority.high,
    confidenceBefore: 2,
    confidenceAfter: confidenceAfter,
    releaseEvidenceCount: 1,
    remainingReleaseRiskCount: remainingReleaseRiskCount,
    decision: decision,
    evidenceSummary: 'Manager reviewed the intervention outcome evidence.',
    learningSummary:
        'The team captured reusable development follow-up insight.',
    nextAction: 'Run a follow-up review for remaining development risk.',
    nextReviewDate: nextReviewDate ?? asOfDate.add(const Duration(days: 7)),
    asOfDate: asOfDate,
  );
}
