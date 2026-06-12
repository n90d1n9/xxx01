import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_talent_handoff_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_talent_handoff_checklist_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_talent_handoff_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_checkpoint_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_activation_checkpoint_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_activation_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('incoming talent activation checkpoint draft initializes from plan', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final plan = _submitActivation(
      container,
      candidateId: 'candidate-fajar',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
    );
    container
        .read(incomingTalentActivationPlansProvider.notifier)
        .start(plan.id);
    final activePlan = container
        .read(incomingTalentActivationPlansProvider)
        .singleWhere((item) => item.id == plan.id);

    container
        .read(incomingTalentActivationCheckpointDraftProvider.notifier)
        .initializeFromPlan(activePlan);

    final draft = container.read(
      incomingTalentActivationCheckpointDraftProvider,
    );

    expect(draft.activationPlanId, plan.id);
    expect(draft.candidateName, 'Fajar Nugroho');
    expect(draft.reviewerName, 'Engineering Manager');
    expect(draft.reviewDate, asOfDate.add(const Duration(days: 21)));
    expect(draft.health, IncomingTalentActivationCheckpointHealth.onTrack);
    expect(draft.confidenceScore, 4);
    expect(draft.requiresBlockerNote, isFalse);
    expect(draft.nextStep, contains('first 30-day learning path'));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test(
    'incoming talent activation checkpoints submit and summarize health',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final plan = _submitActivation(
        container,
        candidateId: 'candidate-fajar',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
      );

      container
          .read(incomingTalentActivationCheckpointDraftProvider.notifier)
          .initializeFromPlan(plan);

      final checkpoint = container
          .read(incomingTalentActivationCheckpointsProvider.notifier)
          .submitDraft(
            container.read(incomingTalentActivationCheckpointDraftProvider),
          );

      expect(checkpoint.id, 'talent-checkpoint-001');
      expect(checkpoint.health, IncomingTalentActivationCheckpointHealth.watch);
      expect(checkpoint.confidenceScore, 3);
      expect(checkpoint.needsAttention, isTrue);

      var summary = container.read(
        incomingTalentActivationCheckpointSummaryProvider,
      );
      expect(summary.totalCount, 1);
      expect(summary.watchCount, 1);
      expect(summary.lowConfidenceCount, 1);
      expect(
        summary.nextAction,
        'Review 1 activation checkpoints needing follow-up.',
      );

      container
          .read(incomingTalentActivationCheckpointDraftProvider.notifier)
          .setHealth(IncomingTalentActivationCheckpointHealth.blocked);
      container
          .read(incomingTalentActivationCheckpointDraftProvider.notifier)
          .setConfidenceScore(2);
      container
          .read(incomingTalentActivationCheckpointDraftProvider.notifier)
          .setBlockerNote('Manager has no mentor capacity this week.');

      final blockedCheckpoint = container
          .read(incomingTalentActivationCheckpointsProvider.notifier)
          .submitDraft(
            container.read(incomingTalentActivationCheckpointDraftProvider),
          );

      expect(blockedCheckpoint.id, 'talent-checkpoint-002');
      expect(blockedCheckpoint.isBlocked, isTrue);

      summary = container.read(
        incomingTalentActivationCheckpointSummaryProvider,
      );
      expect(summary.blockedCount, 1);
      expect(summary.lowConfidenceCount, 2);
      expect(summary.averageConfidence, closeTo(2.5, 0.0001));
      expect(summary.nextAction, 'Escalate 1 blocked checkpoints.');
    },
  );

  test('incoming talent activation checkpoint snapshots release evidence', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final plan = _submitActivation(
      container,
      candidateId: 'candidate-fajar',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
    ).copyWith(
      acceptedProgramMilestoneCount: 1,
      roleReadyProgramCompletionCount: 1,
    );

    container
        .read(incomingTalentActivationCheckpointDraftProvider.notifier)
        .initializeFromPlan(plan);

    final draft = container.read(
      incomingTalentActivationCheckpointDraftProvider,
    );
    expect(draft.acceptedProgramMilestoneCount, 1);
    expect(draft.roleReadyProgramCompletionCount, 1);
    expect(draft.programCompletionExtensionCount, 0);

    final checkpoint = container
        .read(incomingTalentActivationCheckpointsProvider.notifier)
        .submitDraft(draft);
    expect(checkpoint.acceptedProgramMilestoneCount, 1);
    expect(checkpoint.roleReadyProgramCompletionCount, 1);
    expect(checkpoint.programCompletionExtensionCount, 0);
    expect(checkpoint.developmentEvidenceCount, 2);

    final summary = container.read(
      incomingTalentActivationCheckpointSummaryProvider,
    );
    expect(summary.evidenceBackedCount, 1);
    expect(summary.roleReadyCredentialCount, 1);
    expect(summary.programExtensionRiskCount, 0);
  });

  test(
    'incoming talent activation checkpoint flags extension evidence risk',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final plan = _submitActivation(
        container,
        candidateId: 'candidate-mira',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
      ).copyWith(programCompletionExtensionCount: 1);

      container
          .read(incomingTalentActivationCheckpointDraftProvider.notifier)
          .initializeFromPlan(plan);

      final draft = container.read(
        incomingTalentActivationCheckpointDraftProvider,
      );
      expect(draft.health, IncomingTalentActivationCheckpointHealth.blocked);
      expect(draft.confidenceScore, 2);
      expect(draft.programCompletionExtensionCount, 1);
      expect(draft.requiresBlockerNote, isTrue);
      expect(draft.isReadyToSubmit, isTrue);

      final checkpoint = container
          .read(incomingTalentActivationCheckpointsProvider.notifier)
          .submitDraft(draft);
      expect(checkpoint.needsAttention, isTrue);
      expect(checkpoint.programCompletionExtensionCount, 1);

      final summary = container.read(
        incomingTalentActivationCheckpointSummaryProvider,
      );
      expect(summary.blockedCount, 1);
      expect(summary.programExtensionRiskCount, 1);
      expect(summary.nextAction, 'Escalate 1 blocked checkpoints.');
    },
  );

  test(
    'incoming talent activation checkpoint draft validates required fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentActivationCheckpointDraft.empty(
        asOfDate,
      ).copyWith(
        reviewDate: asOfDate.subtract(const Duration(days: 1)),
        health: IncomingTalentActivationCheckpointHealth.blocked,
        confidenceScore: 0,
        managerFeedback: 'short',
        nextStep: 'tiny',
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter an activation plan',
        'Please enter a reviewer',
        'Review date cannot be in the past',
        'Confidence must be between 1 and 5',
        'Manager feedback must be at least 12 characters',
        'Please enter a blocker note',
        'Next step must be at least 8 characters',
      ]);
    },
  );

  test('incoming talent activation checkpoints follow talent filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringPlan = _submitActivation(
      container,
      candidateId: 'candidate-fajar',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
    );
    container
        .read(incomingTalentActivationPlansProvider.notifier)
        .start(engineeringPlan.id);
    _submitCheckpoint(container, engineeringPlan);

    final financePlan = _submitActivation(
      container,
      candidateId: 'candidate-mira',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
    );
    container
        .read(incomingTalentActivationPlansProvider.notifier)
        .block(financePlan.id);
    final blockedFinancePlan = container
        .read(incomingTalentActivationPlansProvider)
        .singleWhere((item) => item.id == financePlan.id);
    _submitCheckpoint(container, blockedFinancePlan);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentActivationCheckpointsProvider,
    );
    final summary = container.read(
      incomingTalentActivationCheckpointSummaryProvider,
    );

    expect(filtered.map((item) => item.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.health,
      IncomingTalentActivationCheckpointHealth.blocked,
    );
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Escalate 1 blocked checkpoints.');
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

IncomingTalentActivationCheckpoint _submitCheckpoint(
  ProviderContainer container,
  IncomingTalentActivationPlan plan,
) {
  container
      .read(incomingTalentActivationCheckpointDraftProvider.notifier)
      .initializeFromPlan(plan);
  final draft = container.read(incomingTalentActivationCheckpointDraftProvider);
  if (draft.requiresBlockerNote) {
    container
        .read(incomingTalentActivationCheckpointDraftProvider.notifier)
        .setBlockerNote('Manager has no mentor capacity this week.');
  }
  return container
      .read(incomingTalentActivationCheckpointsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentActivationCheckpointDraftProvider),
      );
}

IncomingTalentActivationPlan _submitActivation(
  ProviderContainer container, {
  required String candidateId,
  required String candidateName,
  required String department,
  required String role,
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final handoff = _submitHandoff(
    container,
    candidateId: candidateId,
    candidateName: candidateName,
    department: department,
    role: role,
  );
  final generated = container
      .read(candidateTalentHandoffChecklistItemsProvider.notifier)
      .generateForHandoff(handoff: handoff, asOfDate: asOfDate);
  for (final item in generated) {
    container
        .read(candidateTalentHandoffChecklistItemsProvider.notifier)
        .complete(item.id);
  }

  final readiness = container
      .read(incomingTalentReadinessProvider)
      .singleWhere((item) => item.handoffId == handoff.id);
  container
      .read(incomingTalentActivationDraftProvider.notifier)
      .initializeFromReadiness(readiness);

  return container
      .read(incomingTalentActivationPlansProvider.notifier)
      .submitDraft(container.read(incomingTalentActivationDraftProvider));
}

CandidateTalentHandoff _submitHandoff(
  ProviderContainer container, {
  required String candidateId,
  required String candidateName,
  required String department,
  required String role,
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final targetStartDate = asOfDate.add(const Duration(days: 7));
  final draft = CandidateTalentHandoffDraft(
    calibrationReviewId: 'calibration-$candidateId',
    objectiveId: 'objective-$candidateId',
    candidateId: candidateId,
    candidateName: candidateName,
    role: role,
    department: department,
    type: CandidateTalentHandoffType.offerTransition,
    status: CandidateTalentHandoffStatus.ready,
    readinessScore: 86,
    ownerName: 'Talent Partner',
    receivingManagerName: '$department Manager',
    targetStartDate: targetStartDate,
    firstCheckpointDate: targetStartDate.add(const Duration(days: 14)),
    talentFocus: 'Prepare $candidateName for role readiness.',
    handoffNote: 'Prepare $candidateName for role readiness.',
    asOfDate: asOfDate,
  );

  return container
      .read(candidateTalentHandoffsProvider.notifier)
      .submitDraft(draft);
}
