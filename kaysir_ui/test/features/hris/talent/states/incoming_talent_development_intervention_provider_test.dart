import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_check_in_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_activation_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent development intervention defaults from blocked check-in',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final checkIn = _checkIn(
        asOfDate,
        trend: IncomingTalentDevelopmentCheckInTrend.blocked,
        risk: IncomingTalentActivationRetentionRisk.high,
        confidenceScore: 2,
      );

      final draft = IncomingTalentDevelopmentInterventionDraft.fromCheckIn(
        checkIn: checkIn,
        asOfDate: asOfDate,
      );

      expect(draft.checkInId, checkIn.id);
      expect(
        draft.actionType,
        IncomingTalentDevelopmentInterventionType.escalation,
      );
      expect(
        draft.priority,
        IncomingTalentDevelopmentInterventionPriority.critical,
      );
      expect(draft.status, IncomingTalentDevelopmentInterventionStatus.open);
      expect(draft.dueDate, asOfDate.add(const Duration(days: 7)));
      expect(draft.action, contains('Escalate blockers'));
      expect(draft.isReadyToSubmit, isTrue);
    },
  );

  test(
    'incoming talent development intervention defaults from activation follow-up',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final followUp = _followUp(asOfDate, programCompletionExtensionCount: 1);

      final draft = IncomingTalentDevelopmentInterventionDraft.fromFollowUp(
        action: followUp,
        asOfDate: asOfDate,
      );

      expect(draft.checkInId, isEmpty);
      expect(draft.activationFollowUpId, followUp.id);
      expect(
        draft.actionType,
        IncomingTalentDevelopmentInterventionType.learningAdjustment,
      );
      expect(
        draft.priority,
        IncomingTalentDevelopmentInterventionPriority.critical,
      );
      expect(draft.sourceTrend, IncomingTalentDevelopmentCheckInTrend.watch);
      expect(draft.retentionRisk, IncomingTalentActivationRetentionRisk.medium);
      expect(draft.programCompletionExtensionCount, 1);
      expect(draft.dueDate, asOfDate.add(const Duration(days: 7)));
      expect(draft.action, contains('close 1 program extension decision'));
      expect(draft.isReadyToSubmit, isTrue);
    },
  );

  test(
    'incoming talent development interventions submit and summarize risk',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final checkIn = _submitCheckIn(
        container,
        _checkIn(
          asOfDate,
          trend: IncomingTalentDevelopmentCheckInTrend.blocked,
          risk: IncomingTalentActivationRetentionRisk.high,
          confidenceScore: 2,
        ),
      );

      final action = _submitAction(container, checkIn);

      expect(action.id, 'talent-intervention-001');
      expect(
        action.priority,
        IncomingTalentDevelopmentInterventionPriority.critical,
      );
      expect(action.needsAttention, isTrue);
      expect(
        container.read(interventionReadyDevelopmentCheckInsProvider),
        isEmpty,
      );

      expect(
        () => container
            .read(incomingTalentDevelopmentInterventionsProvider.notifier)
            .submitDraft(
              container.read(
                incomingTalentDevelopmentInterventionDraftProvider,
              ),
            ),
        throwsStateError,
      );

      final summary = container.read(
        incomingTalentDevelopmentInterventionSummaryProvider,
      );
      expect(summary.totalCount, 1);
      expect(summary.criticalCount, 1);
      expect(summary.dueSoonCount, 1);
      expect(summary.releaseEvidenceRiskCount, 0);
      expect(
        summary.nextAction,
        'Resolve 1 critical development interventions.',
      );
    },
  );

  test(
    'incoming talent development intervention draft validates required fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentDevelopmentInterventionDraft.empty(
        asOfDate,
      ).copyWith(
        status: IncomingTalentDevelopmentInterventionStatus.resolved,
        dueDate: asOfDate.subtract(const Duration(days: 1)),
        action: 'tiny',
        successCriteria: 'mini',
        resolutionNote: 'short',
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Select a risk source',
        'Please enter an owner',
        'Select an action type',
        'Select action priority',
        'Due date cannot be in the past',
        'Action must be at least 12 characters',
        'Success criteria must be at least 12 characters',
        'Resolution note must be at least 12 characters',
      ]);
    },
  );

  test('incoming talent development interventions follow talent filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringCheckIn = _submitCheckIn(
      container,
      _checkIn(
        asOfDate,
        id: 'check-in-engineering',
        roadmapId: 'roadmap-engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
        trend: IncomingTalentDevelopmentCheckInTrend.steady,
        risk: IncomingTalentActivationRetentionRisk.low,
        confidenceScore: 4,
      ),
    );
    _submitAction(container, engineeringCheckIn);

    final financeCheckIn = _submitCheckIn(
      container,
      _checkIn(
        asOfDate,
        id: 'check-in-finance',
        roadmapId: 'roadmap-finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        trend: IncomingTalentDevelopmentCheckInTrend.blocked,
        risk: IncomingTalentActivationRetentionRisk.high,
        confidenceScore: 2,
      ),
    );
    _submitAction(container, financeCheckIn);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentDevelopmentInterventionsProvider,
    );
    final summary = container.read(
      incomingTalentDevelopmentInterventionSummaryProvider,
    );

    expect(filtered.map((action) => action.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.priority,
      IncomingTalentDevelopmentInterventionPriority.critical,
    );
    expect(summary.totalCount, 1);
    expect(summary.criticalCount, 1);
    expect(summary.nextAction, 'Resolve 1 critical development interventions.');
  });

  test(
    'incoming talent development interventions convert follow-up release risk',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final followUp = _submitFollowUp(
        container,
        _followUpDraft(asOfDate, programCompletionExtensionCount: 1),
      );

      final readyFollowUps = container.read(
        interventionReadyActivationFollowUpsProvider,
      );
      final sources = container.read(
        interventionReadyDevelopmentSourcesProvider,
      );

      expect(readyFollowUps.map((action) => action.id), [followUp.id]);
      expect(sources.single.source.label, 'Activation follow-up');

      container
          .read(incomingTalentDevelopmentInterventionDraftProvider.notifier)
          .initializeFromFollowUp(followUp);
      final action = container
          .read(incomingTalentDevelopmentInterventionsProvider.notifier)
          .submitDraft(
            container.read(incomingTalentDevelopmentInterventionDraftProvider),
          );

      expect(action.activationFollowUpId, followUp.id);
      expect(action.source.label, 'Activation follow-up');
      expect(action.programCompletionExtensionCount, 1);
      expect(action.hasReleaseEvidenceRisk, isTrue);
      expect(action.needsAttention, isTrue);
      expect(
        container.read(interventionReadyActivationFollowUpsProvider),
        isEmpty,
      );

      expect(
        () => container
            .read(incomingTalentDevelopmentInterventionsProvider.notifier)
            .submitDraft(
              container.read(
                incomingTalentDevelopmentInterventionDraftProvider,
              ),
            ),
        throwsStateError,
      );

      final summary = container.read(
        incomingTalentDevelopmentInterventionSummaryProvider,
      );
      expect(summary.totalCount, 1);
      expect(summary.activationFollowUpCount, 1);
      expect(summary.releaseEvidenceBackedCount, 1);
      expect(summary.releaseEvidenceRiskCount, 1);
      expect(summary.nextAction, 'Close 1 release evidence interventions.');
    },
  );

  test(
    'incoming talent development interventions follow lifecycle controls',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final followUp = _submitFollowUp(
        container,
        _followUpDraft(asOfDate, programCompletionExtensionCount: 1),
      );
      container
          .read(incomingTalentDevelopmentInterventionDraftProvider.notifier)
          .initializeFromFollowUp(followUp);
      final action = container
          .read(incomingTalentDevelopmentInterventionsProvider.notifier)
          .submitDraft(
            container.read(incomingTalentDevelopmentInterventionDraftProvider),
          );
      final notifier = container.read(
        incomingTalentDevelopmentInterventionsProvider.notifier,
      );

      notifier.start(action.id);

      var updated = container.read(
        incomingTalentDevelopmentInterventionsProvider,
      );
      expect(
        updated.single.status,
        IncomingTalentDevelopmentInterventionStatus.inProgress,
      );
      expect(
        container
            .read(incomingTalentDevelopmentInterventionSummaryProvider)
            .inProgressCount,
        1,
      );

      expect(
        () => notifier.resolve(action.id, resolutionNote: 'short'),
        throwsStateError,
      );

      notifier.resolve(
        action.id,
        resolutionNote:
            'Extension evidence closed and manager confirms readiness recovery.',
      );

      updated = container.read(incomingTalentDevelopmentInterventionsProvider);
      final summary = container.read(
        incomingTalentDevelopmentInterventionSummaryProvider,
      );

      expect(
        updated.single.status,
        IncomingTalentDevelopmentInterventionStatus.resolved,
      );
      expect(updated.single.resolutionNote, contains('readiness recovery'));
      expect(updated.single.needsAttention, isFalse);
      expect(summary.resolvedCount, 1);
      expect(summary.criticalCount, 0);
      expect(summary.releaseEvidenceRiskCount, 0);
      expect(
        summary.nextAction,
        'Keep development interventions moving to resolution.',
      );
      expect(() => notifier.start(action.id), throwsStateError);
      expect(
        () => notifier.cancel(
          action.id,
          resolutionNote: 'No longer relevant after manager review.',
        ),
        throwsStateError,
      );
    },
  );

  test(
    'incoming talent development interventions can cancel active actions',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final checkIn = _submitCheckIn(
        container,
        _checkIn(
          asOfDate,
          trend: IncomingTalentDevelopmentCheckInTrend.watch,
          risk: IncomingTalentActivationRetentionRisk.medium,
          confidenceScore: 3,
        ),
      );
      final action = _submitAction(container, checkIn);
      final notifier = container.read(
        incomingTalentDevelopmentInterventionsProvider.notifier,
      );

      notifier.cancel(
        action.id,
        resolutionNote: 'Action cancelled because ownership moved to roadmap.',
      );

      final updated = container.read(
        incomingTalentDevelopmentInterventionsProvider,
      );
      final summary = container.read(
        incomingTalentDevelopmentInterventionSummaryProvider,
      );

      expect(
        updated.single.status,
        IncomingTalentDevelopmentInterventionStatus.cancelled,
      );
      expect(updated.single.needsAttention, isFalse);
      expect(summary.cancelledCount, 1);
      expect(summary.criticalCount, 0);
    },
  );
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentDevelopmentCheckIn _submitCheckIn(
  ProviderContainer container,
  IncomingTalentDevelopmentCheckIn checkIn,
) {
  return container
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
}

IncomingTalentDevelopmentInterventionAction _submitAction(
  ProviderContainer container,
  IncomingTalentDevelopmentCheckIn checkIn,
) {
  container
      .read(incomingTalentDevelopmentInterventionDraftProvider.notifier)
      .initializeFromCheckIn(checkIn);
  return container
      .read(incomingTalentDevelopmentInterventionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentDevelopmentInterventionDraftProvider),
      );
}

IncomingTalentActivationFollowUpAction _submitFollowUp(
  ProviderContainer container,
  IncomingTalentActivationFollowUpDraft draft,
) {
  return container
      .read(incomingTalentActivationFollowUpActionsProvider.notifier)
      .submitDraft(draft);
}

IncomingTalentDevelopmentCheckIn _checkIn(
  DateTime asOfDate, {
  String id = 'check-in-001',
  String roadmapId = 'roadmap-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentDevelopmentCheckInTrend trend,
  required IncomingTalentActivationRetentionRisk risk,
  required int confidenceScore,
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
    trend: trend,
    confidenceScore: confidenceScore,
    blockerNote:
        trend == IncomingTalentDevelopmentCheckInTrend.blocked
            ? 'Roadmap blockers require immediate manager escalation.'
            : '',
    nextAction: 'Restore progress through manager-owned support.',
    managerCommitment: '$department Manager will confirm support progress.',
    nextReviewDate: asOfDate.add(const Duration(days: 7)),
    roadmapStatus:
        trend == IncomingTalentDevelopmentCheckInTrend.blocked
            ? IncomingTalentDevelopmentRoadmapStatus.atRisk
            : IncomingTalentDevelopmentRoadmapStatus.active,
    retentionRisk: risk,
    createdAt: asOfDate,
  );
}

IncomingTalentActivationFollowUpDraft _followUpDraft(
  DateTime asOfDate, {
  int acceptedProgramMilestoneCount = 1,
  int roleReadyProgramCompletionCount = 0,
  int programCompletionExtensionCount = 0,
}) {
  return IncomingTalentActivationFollowUpDraft(
    checkpointId: 'checkpoint-001',
    activationPlanId: 'activation-001',
    handoffId: 'handoff-001',
    candidateId: 'candidate-fajar',
    candidateName: 'Fajar Nugroho',
    role: 'Senior Flutter Engineer',
    department: 'Engineering',
    ownerName: 'Engineering Manager',
    acceptedProgramMilestoneCount: acceptedProgramMilestoneCount,
    roleReadyProgramCompletionCount: roleReadyProgramCompletionCount,
    programCompletionExtensionCount: programCompletionExtensionCount,
    actionType: IncomingTalentActivationFollowUpType.learningAdjustment,
    dueDate: asOfDate.add(const Duration(days: 7)),
    action:
        'Learning adjustment: resolve program extension before readiness review.',
    successCriteria:
        'Close extension decisions and restore activation confidence.',
    asOfDate: asOfDate,
  );
}

IncomingTalentActivationFollowUpAction _followUp(
  DateTime asOfDate, {
  int acceptedProgramMilestoneCount = 1,
  int roleReadyProgramCompletionCount = 0,
  int programCompletionExtensionCount = 0,
}) {
  return _followUpDraft(
    asOfDate,
    acceptedProgramMilestoneCount: acceptedProgramMilestoneCount,
    roleReadyProgramCompletionCount: roleReadyProgramCompletionCount,
    programCompletionExtensionCount: programCompletionExtensionCount,
  ).toAction(id: 'talent-follow-up-001', createdAt: asOfDate);
}
