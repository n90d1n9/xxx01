import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_checkpoint_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_activation_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent activation follow-up draft initializes from checkpoint',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final checkpoint = _checkpoint(
        asOfDate,
        health: IncomingTalentActivationCheckpointHealth.watch,
        confidenceScore: 3,
      );

      container
          .read(incomingTalentActivationFollowUpDraftProvider.notifier)
          .initializeFromCheckpoint(checkpoint);

      final draft = container.read(
        incomingTalentActivationFollowUpDraftProvider,
      );

      expect(draft.checkpointId, checkpoint.id);
      expect(draft.candidateName, 'Fajar Nugroho');
      expect(draft.ownerName, 'Engineering Manager');
      expect(
        draft.actionType,
        IncomingTalentActivationFollowUpType.learningAdjustment,
      );
      expect(draft.dueDate, asOfDate.add(const Duration(days: 14)));
      expect(draft.action, startsWith('Learning adjustment:'));
      expect(
        draft.successCriteria,
        'Restore activation confidence to 4/5 or better before next review.',
      );
      expect(draft.isReadyToSubmit, isTrue);
    },
  );

  test('incoming talent activation follow-ups submit and summarize status', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    container
        .read(incomingTalentActivationFollowUpDraftProvider.notifier)
        .initializeFromCheckpoint(
          _checkpoint(
            asOfDate,
            health: IncomingTalentActivationCheckpointHealth.blocked,
            confidenceScore: 2,
          ),
        );
    container
        .read(incomingTalentActivationFollowUpDraftProvider.notifier)
        .setDueDate(asOfDate.add(const Duration(days: 3)));

    final action = container
        .read(incomingTalentActivationFollowUpActionsProvider.notifier)
        .submitDraft(
          container.read(incomingTalentActivationFollowUpDraftProvider),
        );

    expect(action.id, 'talent-follow-up-001');
    expect(action.status, IncomingTalentActivationFollowUpStatus.planned);
    expect(
      action.actionType,
      IncomingTalentActivationFollowUpType.managerAlignment,
    );
    expect(action.isDueSoon(asOfDate), isTrue);

    expect(
      () => container
          .read(incomingTalentActivationFollowUpActionsProvider.notifier)
          .submitDraft(
            container.read(incomingTalentActivationFollowUpDraftProvider),
          ),
      throwsStateError,
    );

    var summary = container.read(
      incomingTalentActivationFollowUpSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.plannedCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.nextAction, 'Complete 1 follow-up actions due soon.');

    container
        .read(incomingTalentActivationFollowUpActionsProvider.notifier)
        .start(action.id);
    summary = container.read(incomingTalentActivationFollowUpSummaryProvider);
    expect(summary.inProgressCount, 1);
    expect(summary.nextAction, 'Complete 1 follow-up actions due soon.');

    container
        .read(incomingTalentActivationFollowUpActionsProvider.notifier)
        .block(action.id);
    summary = container.read(incomingTalentActivationFollowUpSummaryProvider);
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Unblock 1 follow-up actions.');

    container
        .read(incomingTalentActivationFollowUpActionsProvider.notifier)
        .complete(action.id);
    summary = container.read(incomingTalentActivationFollowUpSummaryProvider);
    expect(summary.completedCount, 1);
    expect(summary.dueSoonCount, 0);
    expect(summary.nextAction, 'Activation follow-up actions are complete.');
  });

  test('incoming talent activation follow-up snapshots release evidence', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final checkpoint = _checkpoint(
      asOfDate,
      health: IncomingTalentActivationCheckpointHealth.onTrack,
      confidenceScore: 4,
      acceptedProgramMilestoneCount: 1,
      roleReadyProgramCompletionCount: 1,
    );

    container
        .read(incomingTalentActivationFollowUpDraftProvider.notifier)
        .initializeFromCheckpoint(checkpoint);

    final draft = container.read(incomingTalentActivationFollowUpDraftProvider);
    expect(draft.acceptedProgramMilestoneCount, 1);
    expect(draft.roleReadyProgramCompletionCount, 1);
    expect(draft.programCompletionExtensionCount, 0);

    final action = container
        .read(incomingTalentActivationFollowUpActionsProvider.notifier)
        .submitDraft(draft);
    expect(action.acceptedProgramMilestoneCount, 1);
    expect(action.roleReadyProgramCompletionCount, 1);
    expect(action.programCompletionExtensionCount, 0);
    expect(action.developmentEvidenceCount, 2);

    final summary = container.read(
      incomingTalentActivationFollowUpSummaryProvider,
    );
    expect(summary.evidenceBackedCount, 1);
    expect(summary.roleReadyCredentialCount, 1);
    expect(summary.programExtensionRiskCount, 0);
  });

  test(
    'incoming talent activation follow-up targets extension evidence risk',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final checkpoint = _checkpoint(
        asOfDate,
        health: IncomingTalentActivationCheckpointHealth.onTrack,
        confidenceScore: 4,
        programCompletionExtensionCount: 1,
      );

      container
          .read(incomingTalentActivationFollowUpDraftProvider.notifier)
          .initializeFromCheckpoint(checkpoint);

      final draft = container.read(
        incomingTalentActivationFollowUpDraftProvider,
      );
      expect(
        draft.actionType,
        IncomingTalentActivationFollowUpType.learningAdjustment,
      );
      expect(draft.action, contains('resolve 1 program extension decision'));
      expect(
        draft.successCriteria,
        'Close program extension decisions and restore activation confidence to 4/5.',
      );

      final action = container
          .read(incomingTalentActivationFollowUpActionsProvider.notifier)
          .submitDraft(draft);
      expect(action.programCompletionExtensionCount, 1);
      expect(action.needsAttention, isTrue);

      final summary = container.read(
        incomingTalentActivationFollowUpSummaryProvider,
      );
      expect(summary.programExtensionRiskCount, 1);
      expect(summary.nextAction, 'Close 1 follow-up release evidence risks.');
    },
  );

  test(
    'incoming talent activation follow-up draft validates required fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentActivationFollowUpDraft.empty(
        asOfDate,
      ).copyWith(
        dueDate: asOfDate.subtract(const Duration(days: 1)),
        action: 'short',
        successCriteria: 'tiny',
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter a checkpoint',
        'Please enter an owner',
        'Select a follow-up type',
        'Due date cannot be in the past',
        'Follow-up action must be at least 12 characters',
        'Success criteria must be at least 12 characters',
      ]);
    },
  );

  test('incoming talent activation follow-ups follow talent filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringAction = _submitFollowUp(
      container,
      _checkpoint(
        asOfDate,
        checkpointId: 'checkpoint-engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        health: IncomingTalentActivationCheckpointHealth.watch,
        confidenceScore: 3,
      ),
    );
    container
        .read(incomingTalentActivationFollowUpActionsProvider.notifier)
        .complete(engineeringAction.id);

    _submitFollowUp(
      container,
      _checkpoint(
        asOfDate,
        checkpointId: 'checkpoint-finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        health: IncomingTalentActivationCheckpointHealth.blocked,
        confidenceScore: 2,
      ),
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentActivationFollowUpActionsProvider,
    );
    final summary = container.read(
      incomingTalentActivationFollowUpSummaryProvider,
    );

    expect(filtered.map((action) => action.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.actionType,
      IncomingTalentActivationFollowUpType.managerAlignment,
    );
    expect(summary.totalCount, 1);
    expect(summary.plannedCount, 1);
    expect(summary.nextAction, 'Start 1 planned follow-up actions.');
  });
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [
      recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
      talentAsOfDateProvider.overrideWithValue(asOfDate),
    ],
  );
}

IncomingTalentActivationFollowUpAction _submitFollowUp(
  ProviderContainer container,
  IncomingTalentActivationCheckpoint checkpoint,
) {
  container
      .read(incomingTalentActivationFollowUpDraftProvider.notifier)
      .initializeFromCheckpoint(checkpoint);
  return container
      .read(incomingTalentActivationFollowUpActionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentActivationFollowUpDraftProvider),
      );
}

IncomingTalentActivationCheckpoint _checkpoint(
  DateTime asOfDate, {
  String checkpointId = 'talent-checkpoint-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  int acceptedProgramMilestoneCount = 0,
  int roleReadyProgramCompletionCount = 0,
  int programCompletionExtensionCount = 0,
  required IncomingTalentActivationCheckpointHealth health,
  required int confidenceScore,
}) {
  return IncomingTalentActivationCheckpoint(
    id: checkpointId,
    activationPlanId: 'talent-activation-001',
    handoffId: 'talent-handoff-001',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    role: role,
    department: department,
    managerName: '$department Manager',
    mentorName: '$department mentor',
    acceptedProgramMilestoneCount: acceptedProgramMilestoneCount,
    roleReadyProgramCompletionCount: roleReadyProgramCompletionCount,
    programCompletionExtensionCount: programCompletionExtensionCount,
    reviewerName: '$department Manager',
    reviewDate: asOfDate.add(const Duration(days: 7)),
    health: health,
    confidenceScore: confidenceScore,
    managerFeedback: 'Manager feedback shows activation needs follow-up.',
    blockerNote:
        health == IncomingTalentActivationCheckpointHealth.blocked
            ? 'Manager has no mentor capacity this week.'
            : '',
    nextStep: 'Continue first 30-day learning path with mentor.',
    createdAt: asOfDate,
  );
}
