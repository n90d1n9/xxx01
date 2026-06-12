import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_check_in_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_activation_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent intervention outcome defaults from resolved intervention',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final action = _resolvedCheckInIntervention(asOfDate);

      final draft =
          IncomingTalentDevelopmentInterventionOutcomeDraft.fromIntervention(
            action: action,
            asOfDate: asOfDate,
          );

      expect(draft.interventionId, action.id);
      expect(
        draft.decision,
        IncomingTalentDevelopmentInterventionOutcomeDecision.stabilized,
      );
      expect(draft.confidenceBefore, 2);
      expect(draft.confidenceAfter, 4);
      expect(draft.evidenceSummary, action.resolutionNote);
      expect(draft.nextReviewDate, asOfDate.add(const Duration(days: 30)));
      expect(draft.isReadyToSubmit, isTrue);
    },
  );

  test(
    'incoming talent intervention outcomes submit and summarize release recovery',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final action = _submitResolvedFollowUpIntervention(
        container,
        asOfDate,
        resolutionNote:
            'Extension evidence closed and manager confirms readiness recovery.',
      );

      expect(
        container.read(outcomeReadyDevelopmentInterventionsProvider),
        hasLength(1),
      );

      container
          .read(
            incomingTalentDevelopmentInterventionOutcomeDraftProvider.notifier,
          )
          .initializeFromIntervention(action);
      final outcome = container
          .read(incomingTalentDevelopmentInterventionOutcomesProvider.notifier)
          .submitDraft(
            container.read(
              incomingTalentDevelopmentInterventionOutcomeDraftProvider,
            ),
          );

      expect(outcome.id, 'talent-intervention-outcome-001');
      expect(
        outcome.decision,
        IncomingTalentDevelopmentInterventionOutcomeDecision.improved,
      );
      expect(outcome.remainingReleaseRiskCount, 0);
      expect(outcome.needsAttention, isFalse);
      expect(
        container.read(outcomeReadyDevelopmentInterventionsProvider),
        isEmpty,
      );

      expect(
        () => container
            .read(
              incomingTalentDevelopmentInterventionOutcomesProvider.notifier,
            )
            .submitDraft(
              container.read(
                incomingTalentDevelopmentInterventionOutcomeDraftProvider,
              ),
            ),
        throwsStateError,
      );

      final summary = container.read(
        incomingTalentDevelopmentInterventionOutcomeSummaryProvider,
      );
      expect(summary.totalCount, 1);
      expect(summary.improvedCount, 1);
      expect(summary.releaseRiskCount, 0);
      expect(summary.averageConfidenceAfter, 5);
      expect(summary.nextAction, 'Archive 1 development wins.');
    },
  );

  test('incoming talent intervention outcomes flag residual release risk', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final action = _submitResolvedFollowUpIntervention(
      container,
      asOfDate,
      resolutionNote:
          'Manager review still needs extension ownership follow-through.',
    );
    container
        .read(
          incomingTalentDevelopmentInterventionOutcomeDraftProvider.notifier,
        )
        .initializeFromIntervention(action);
    final outcome = container
        .read(incomingTalentDevelopmentInterventionOutcomesProvider.notifier)
        .submitDraft(
          container.read(
            incomingTalentDevelopmentInterventionOutcomeDraftProvider,
          ),
        );

    expect(
      outcome.decision,
      IncomingTalentDevelopmentInterventionOutcomeDecision.monitor,
    );
    expect(outcome.remainingReleaseRiskCount, 1);
    expect(outcome.needsAttention, isTrue);

    final summary = container.read(
      incomingTalentDevelopmentInterventionOutcomeSummaryProvider,
    );
    expect(summary.monitorCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.releaseRiskCount, 1);
    expect(summary.nextAction, 'Close 1 outcome release evidence risks.');

    container.read(talentNeedsAttentionProvider.notifier).state = true;
    expect(
      container.read(
        filteredIncomingTalentDevelopmentInterventionOutcomesProvider,
      ),
      [outcome],
    );
  });

  test('incoming talent intervention outcomes follow department filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    _submitOutcomeForCheckIn(
      container,
      _checkIn(
        asOfDate,
        id: 'engineering-check-in',
        roadmapId: 'engineering-roadmap',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
      ),
    );
    final financeOutcome = _submitOutcomeForCheckIn(
      container,
      _checkIn(
        asOfDate,
        id: 'finance-check-in',
        roadmapId: 'finance-roadmap',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
      ),
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';

    final filtered = container.read(
      filteredIncomingTalentDevelopmentInterventionOutcomesProvider,
    );
    final summary = container.read(
      incomingTalentDevelopmentInterventionOutcomeSummaryProvider,
    );

    expect(filtered, [financeOutcome]);
    expect(summary.totalCount, 1);
    expect(summary.improvedCount, 0);
    expect(summary.stabilizedCount, 1);
  });
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentDevelopmentInterventionAction _resolvedCheckInIntervention(
  DateTime asOfDate,
) {
  final draft = IncomingTalentDevelopmentInterventionDraft.fromCheckIn(
    checkIn: _checkIn(asOfDate),
    asOfDate: asOfDate,
  );
  return draft
      .toAction(id: 'talent-intervention-001', createdAt: asOfDate)
      .copyWith(
        status: IncomingTalentDevelopmentInterventionStatus.resolved,
        resolutionNote:
            'Blockers resolved and manager confirms development support.',
      );
}

IncomingTalentDevelopmentInterventionOutcome _submitOutcomeForCheckIn(
  ProviderContainer container,
  IncomingTalentDevelopmentCheckIn checkIn,
) {
  final submittedCheckIn = container
      .read(incomingTalentDevelopmentCheckInsProvider.notifier)
      .submitDraft(
        IncomingTalentDevelopmentCheckInDraft(
          roadmapId: checkIn.roadmapId,
          outcomeReviewId: checkIn.outcomeReviewId,
          candidateId: checkIn.candidateId,
          candidateName: checkIn.candidateName,
          role: checkIn.role,
          department: checkIn.department,
          reviewerName: checkIn.reviewerName,
          checkInDate: checkIn.checkInDate,
          trend: checkIn.trend,
          confidenceScore: checkIn.confidenceScore,
          blockerNote: checkIn.blockerNote,
          nextAction: checkIn.nextAction,
          managerCommitment: checkIn.managerCommitment,
          nextReviewDate: checkIn.nextReviewDate,
          roadmapStatus: checkIn.roadmapStatus,
          retentionRisk: checkIn.retentionRisk,
          asOfDate: checkIn.createdAt,
        ),
      );
  container
      .read(incomingTalentDevelopmentInterventionDraftProvider.notifier)
      .initializeFromCheckIn(submittedCheckIn);
  final intervention = container
      .read(incomingTalentDevelopmentInterventionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentDevelopmentInterventionDraftProvider),
      );
  container
      .read(incomingTalentDevelopmentInterventionsProvider.notifier)
      .resolve(
        intervention.id,
        resolutionNote:
            'Development blocker resolved and manager confirms support.',
      );
  final resolved = container
      .read(incomingTalentDevelopmentInterventionsProvider)
      .firstWhere((item) => item.id == intervention.id);

  container
      .read(incomingTalentDevelopmentInterventionOutcomeDraftProvider.notifier)
      .initializeFromIntervention(resolved);
  return container
      .read(incomingTalentDevelopmentInterventionOutcomesProvider.notifier)
      .submitDraft(
        container.read(
          incomingTalentDevelopmentInterventionOutcomeDraftProvider,
        ),
      );
}

IncomingTalentDevelopmentInterventionAction _submitResolvedFollowUpIntervention(
  ProviderContainer container,
  DateTime asOfDate, {
  required String resolutionNote,
}) {
  final followUp = container
      .read(incomingTalentActivationFollowUpActionsProvider.notifier)
      .submitDraft(_followUpDraft(asOfDate));
  container
      .read(incomingTalentDevelopmentInterventionDraftProvider.notifier)
      .initializeFromFollowUp(followUp);
  final intervention = container
      .read(incomingTalentDevelopmentInterventionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentDevelopmentInterventionDraftProvider),
      );
  container
      .read(incomingTalentDevelopmentInterventionsProvider.notifier)
      .resolve(intervention.id, resolutionNote: resolutionNote);
  return container
      .read(incomingTalentDevelopmentInterventionsProvider)
      .firstWhere((item) => item.id == intervention.id);
}

IncomingTalentDevelopmentCheckIn _checkIn(
  DateTime asOfDate, {
  String id = 'check-in-001',
  String roadmapId = 'roadmap-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
}) {
  return IncomingTalentDevelopmentCheckIn(
    id: id,
    roadmapId: roadmapId,
    outcomeReviewId: 'outcome-$roadmapId',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    role: role,
    department: department,
    reviewerName: '$department Manager',
    checkInDate: asOfDate,
    trend: IncomingTalentDevelopmentCheckInTrend.blocked,
    confidenceScore: 2,
    blockerNote: 'Roadmap blockers require immediate manager escalation.',
    nextAction: 'Restore progress through manager-owned support.',
    managerCommitment: '$department Manager will confirm support progress.',
    nextReviewDate: asOfDate.add(const Duration(days: 7)),
    roadmapStatus: IncomingTalentDevelopmentRoadmapStatus.atRisk,
    retentionRisk: IncomingTalentActivationRetentionRisk.high,
    createdAt: asOfDate,
  );
}

IncomingTalentActivationFollowUpDraft _followUpDraft(DateTime asOfDate) {
  return IncomingTalentActivationFollowUpDraft(
    checkpointId: 'checkpoint-001',
    activationPlanId: 'activation-001',
    handoffId: 'handoff-001',
    candidateId: 'candidate-fajar',
    candidateName: 'Fajar Nugroho',
    role: 'Senior Flutter Engineer',
    department: 'Engineering',
    ownerName: 'Engineering Manager',
    acceptedProgramMilestoneCount: 1,
    roleReadyProgramCompletionCount: 0,
    programCompletionExtensionCount: 1,
    actionType: IncomingTalentActivationFollowUpType.learningAdjustment,
    dueDate: asOfDate.add(const Duration(days: 7)),
    action:
        'Learning adjustment: resolve program extension before readiness review.',
    successCriteria:
        'Close extension decisions and restore activation confidence.',
    asOfDate: asOfDate,
  );
}
