import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_follow_up_resolution_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_outcome_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_outcome_follow_up_resolution_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'intervention follow-up resolution draft defaults from completed follow-up',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final followUp = _submitClosedFollowUp(
        container,
        asOfDate,
        status:
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                .completed,
      );

      final draft =
          IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.fromFollowUp(
            followUp: followUp,
            asOfDate: asOfDate,
          );

      expect(draft.followUpId, followUp.id);
      expect(draft.sourceStatus, followUp.status);
      expect(draft.confidenceBefore, 3);
      expect(draft.confidenceAfter, 4);
      expect(draft.remainingReleaseRiskCount, 0);
      expect(
        draft.decision,
        IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
            .sustained,
      );
      expect(draft.nextReviewDate, asOfDate.add(const Duration(days: 45)));
      expect(draft.isReadyToSubmit, isTrue);
    },
  );

  test('intervention follow-up resolutions submit, de-duplicate, and summarize', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final followUp = _submitClosedFollowUp(
      container,
      asOfDate,
      status:
          IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.completed,
    );

    expect(
      container.read(
        resolutionReadyDevelopmentInterventionOutcomeFollowUpsProvider,
      ),
      [followUp],
    );

    container
        .read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider
              .notifier,
        )
        .initializeFromFollowUp(followUp);
    final draft = container.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider,
    );
    final resolution = container
        .read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider
              .notifier,
        )
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummaryProvider,
    );

    expect(resolution.id, 'talent-intervention-follow-up-resolution-001');
    expect(resolution.followUpId, followUp.id);
    expect(
      container.read(
        resolutionReadyDevelopmentInterventionOutcomeFollowUpsProvider,
      ),
      isEmpty,
    );
    expect(summary.totalCount, 1);
    expect(summary.sustainedCount, 1);
    expect(summary.attentionCount, 0);
    expect(summary.averageConfidenceAfter, 4);
    expect(summary.averageConfidenceDelta, 1);
    expect(
      summary.nextAction,
      'Keep 1 sustained follow-up resolutions on watch.',
    );
    expect(
      () => container
          .read(
            incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider
                .notifier,
          )
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('intervention follow-up resolution draft validates fields', () {
    final asOfDate = DateTime(2026, 5, 30);
    final draft =
        IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.empty(
          asOfDate,
        ).copyWith(
          sourceStatus:
              IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.open,
          reviewDate: asOfDate.subtract(const Duration(days: 1)),
          confidenceAfter: 6,
          evidenceSummary: 'short',
          managerNote: 'tiny',
          nextAction: 'mini',
          nextReviewDate: asOfDate.subtract(const Duration(days: 2)),
        );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a closed follow-up',
      'Please enter a reviewer',
      'Follow-up must be completed or escalated before resolution review',
      'Resolution review date cannot be in the past',
      'Select resolution decision',
      'Confidence must be between 1 and 5',
      'Evidence summary must be at least 12 characters',
      'Manager note must be at least 12 characters',
      'Next action must be at least 12 characters',
      'Next review must be after resolution review date',
    ]);
  });

  test(
    'intervention follow-up resolutions follow department and attention filters',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final engineeringFollowUp = _submitClosedFollowUp(
        container,
        asOfDate,
        id: 'engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        decision: IncomingTalentDevelopmentInterventionOutcomeDecision.improved,
        confidenceAfter: 4,
        remainingReleaseRiskCount: 0,
        status:
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                .completed,
      );
      _submitResolution(container, engineeringFollowUp);

      final financeFollowUp = _submitClosedFollowUp(
        container,
        asOfDate,
        id: 'finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        decision: IncomingTalentDevelopmentInterventionOutcomeDecision.escalate,
        confidenceAfter: 2,
        remainingReleaseRiskCount: 2,
        status:
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                .escalated,
      );
      _submitResolution(container, financeFollowUp);

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(
        filteredIncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider,
      );
      final summary = container.read(
        incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummaryProvider,
      );

      expect(filtered.map((item) => item.candidateName), ['Mira Lestari']);
      expect(
        filtered.single.decision,
        IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
            .escalate,
      );
      expect(filtered.single.needsAttention, isTrue);
      expect(summary.totalCount, 1);
      expect(summary.escalateCount, 1);
      expect(summary.attentionCount, 1);
      expect(
        summary.nextAction,
        'Escalate 1 follow-up resolutions to HR council.',
      );
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

IncomingTalentDevelopmentInterventionOutcomeFollowUp _submitClosedFollowUp(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'outcome-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  IncomingTalentDevelopmentInterventionOutcomeDecision decision =
      IncomingTalentDevelopmentInterventionOutcomeDecision.monitor,
  int confidenceAfter = 3,
  int remainingReleaseRiskCount = 1,
  required IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus status,
}) {
  final outcome = _submitOutcome(
    container,
    _submitReadyOutcomeDraft(
      asOfDate,
      id: id,
      candidateName: candidateName,
      department: department,
      decision: decision,
      confidenceAfter: confidenceAfter,
      remainingReleaseRiskCount: remainingReleaseRiskCount,
    ),
  );
  final followUp = _submitFollowUp(container, outcome);
  final notifier = container.read(
    incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider.notifier,
  );
  switch (status) {
    case IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.open:
      break;
    case IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.inProgress:
      notifier.start(followUp.id);
      break;
    case IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.completed:
      notifier.start(followUp.id);
      notifier.complete(
        followUp.id,
        resolutionNote: 'Follow-up evidence reviewed and closed.',
      );
      break;
    case IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.escalated:
      notifier.escalate(
        followUp.id,
        resolutionNote:
            'Residual release risk escalated to HR manager council.',
      );
      break;
  }
  return container
      .read(incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider)
      .firstWhere((item) => item.id == followUp.id);
}

IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution
_submitResolution(
  ProviderContainer container,
  IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp,
) {
  container
      .read(
        incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider
            .notifier,
      )
      .initializeFromFollowUp(followUp);
  return container
      .read(
        incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider
            .notifier,
      )
      .submitDraft(
        container.read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider,
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
}) {
  final candidateKey = candidateName.toLowerCase().split(' ').first;
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
    reviewDate: asOfDate,
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
    nextReviewDate: asOfDate.add(const Duration(days: 7)),
    asOfDate: asOfDate,
  );
}
