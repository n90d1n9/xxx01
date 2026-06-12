import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_checkpoint_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_activation_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent activation outcome draft stabilizes healthy evidence',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final plan = _plan(
        asOfDate,
        status: IncomingTalentActivationStatus.completed,
      );
      final checkpoint = _checkpoint(
        asOfDate,
        plan,
        health: IncomingTalentActivationCheckpointHealth.onTrack,
        confidenceScore: 5,
      );
      final followUp = _followUp(
        asOfDate,
        plan,
        checkpoint,
        status: IncomingTalentActivationFollowUpStatus.completed,
      );

      container
          .read(incomingTalentActivationOutcomeDraftProvider.notifier)
          .initializeFromPlan(
            plan: plan,
            checkpoints: [checkpoint],
            followUps: [followUp],
          );

      final draft = container.read(
        incomingTalentActivationOutcomeDraftProvider,
      );

      expect(
        draft.decision,
        IncomingTalentActivationOutcomeDecision.stabilized,
      );
      expect(draft.retentionRisk, IncomingTalentActivationRetentionRisk.low);
      expect(draft.readinessScore, 95);
      expect(draft.nextDevelopmentTrack, contains('excellence track'));
      expect(draft.evidenceNote, contains('1/1 follow-up actions completed'));
      expect(draft.isReadyToSubmit, isTrue);
    },
  );

  test('incoming talent activation outcomes submit and summarize risk', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final plan = _plan(
      asOfDate,
      status: IncomingTalentActivationStatus.blocked,
    );
    final checkpoint = _checkpoint(
      asOfDate,
      plan,
      health: IncomingTalentActivationCheckpointHealth.blocked,
      confidenceScore: 2,
    );
    final followUp = _followUp(
      asOfDate,
      plan,
      checkpoint,
      status: IncomingTalentActivationFollowUpStatus.blocked,
    );

    final review = _submitOutcome(container, plan, [checkpoint], [followUp]);

    expect(review.id, 'talent-outcome-001');
    expect(
      review.decision,
      IncomingTalentActivationOutcomeDecision.escalateRisk,
    );
    expect(review.retentionRisk, IncomingTalentActivationRetentionRisk.high);
    expect(review.needsAttention, isTrue);

    expect(
      () => container
          .read(incomingTalentActivationOutcomeReviewsProvider.notifier)
          .submitDraft(
            container.read(incomingTalentActivationOutcomeDraftProvider),
          ),
      throwsStateError,
    );

    final summary = container.read(
      incomingTalentActivationOutcomeSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.escalatedCount, 1);
    expect(summary.highRiskCount, 1);
    expect(summary.nextAction, 'Escalate 1 high-risk activation outcomes.');
  });

  test(
    'incoming talent activation outcome draft validates required fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentActivationOutcomeDraft.empty(
        asOfDate,
      ).copyWith(
        reviewDate: asOfDate.subtract(const Duration(days: 1)),
        readinessScore: 0,
        nextDevelopmentTrack: 'short',
        evidenceNote: 'tiny',
        decisionNote: 'mini',
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter an activation plan',
        'Please enter a reviewer',
        'Review date cannot be in the past',
        'Select an outcome decision',
        'Select retention risk',
        'Readiness score must be between 1 and 100',
        'Development track must be at least 8 characters',
        'Evidence notes must be at least 12 characters',
        'Decision notes must be at least 12 characters',
      ]);
    },
  );

  test('incoming talent activation outcomes follow talent filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringPlan = _plan(
      asOfDate,
      id: 'activation-engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
      status: IncomingTalentActivationStatus.completed,
    );
    final engineeringCheckpoint = _checkpoint(
      asOfDate,
      engineeringPlan,
      health: IncomingTalentActivationCheckpointHealth.onTrack,
      confidenceScore: 5,
    );
    _submitOutcome(
      container,
      engineeringPlan,
      [engineeringCheckpoint],
      [
        _followUp(
          asOfDate,
          engineeringPlan,
          engineeringCheckpoint,
          status: IncomingTalentActivationFollowUpStatus.completed,
        ),
      ],
    );

    final financePlan = _plan(
      asOfDate,
      id: 'activation-finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
      status: IncomingTalentActivationStatus.blocked,
    );
    final financeCheckpoint = _checkpoint(
      asOfDate,
      financePlan,
      health: IncomingTalentActivationCheckpointHealth.blocked,
      confidenceScore: 2,
    );
    _submitOutcome(
      container,
      financePlan,
      [financeCheckpoint],
      [
        _followUp(
          asOfDate,
          financePlan,
          financeCheckpoint,
          status: IncomingTalentActivationFollowUpStatus.blocked,
        ),
      ],
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentActivationOutcomeReviewsProvider,
    );
    final summary = container.read(
      incomingTalentActivationOutcomeSummaryProvider,
    );

    expect(filtered.map((review) => review.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.decision,
      IncomingTalentActivationOutcomeDecision.escalateRisk,
    );
    expect(summary.totalCount, 1);
    expect(summary.highRiskCount, 1);
    expect(summary.nextAction, 'Escalate 1 high-risk activation outcomes.');
  });
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentActivationOutcomeReview _submitOutcome(
  ProviderContainer container,
  IncomingTalentActivationPlan plan,
  List<IncomingTalentActivationCheckpoint> checkpoints,
  List<IncomingTalentActivationFollowUpAction> followUps,
) {
  container
      .read(incomingTalentActivationOutcomeDraftProvider.notifier)
      .initializeFromPlan(
        plan: plan,
        checkpoints: checkpoints,
        followUps: followUps,
      );
  return container
      .read(incomingTalentActivationOutcomeReviewsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentActivationOutcomeDraftProvider),
      );
}

IncomingTalentActivationPlan _plan(
  DateTime asOfDate, {
  String id = 'talent-activation-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentActivationStatus status,
}) {
  return IncomingTalentActivationPlan(
    id: id,
    handoffId: 'handoff-$id',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    role: role,
    department: department,
    managerName: '$department Manager',
    mentorName: '$department mentor',
    learningPlanTitle: '$role first 30-day learning path',
    activationOwner: 'Talent Partner',
    kickoffDate: asOfDate.add(const Duration(days: 7)),
    firstCheckpointDate: asOfDate.add(const Duration(days: 21)),
    successMeasure: 'Confirm $role ramp readiness with manager.',
    notes: 'Prepare $candidateName for role readiness.',
    status: status,
    createdAt: asOfDate,
  );
}

IncomingTalentActivationCheckpoint _checkpoint(
  DateTime asOfDate,
  IncomingTalentActivationPlan plan, {
  required IncomingTalentActivationCheckpointHealth health,
  required int confidenceScore,
}) {
  return IncomingTalentActivationCheckpoint(
    id: 'checkpoint-${plan.id}',
    activationPlanId: plan.id,
    handoffId: plan.handoffId,
    candidateId: plan.candidateId,
    candidateName: plan.candidateName,
    role: plan.role,
    department: plan.department,
    managerName: plan.managerName,
    mentorName: plan.mentorName,
    reviewerName: plan.managerName,
    reviewDate: asOfDate.add(const Duration(days: 21)),
    health: health,
    confidenceScore: confidenceScore,
    managerFeedback: 'Manager feedback confirms activation evidence.',
    blockerNote:
        health == IncomingTalentActivationCheckpointHealth.blocked
            ? 'Manager has no mentor capacity this week.'
            : '',
    nextStep: 'Continue first 30-day learning path with mentor.',
    createdAt: asOfDate,
  );
}

IncomingTalentActivationFollowUpAction _followUp(
  DateTime asOfDate,
  IncomingTalentActivationPlan plan,
  IncomingTalentActivationCheckpoint checkpoint, {
  required IncomingTalentActivationFollowUpStatus status,
}) {
  return IncomingTalentActivationFollowUpAction(
    id: 'follow-up-${checkpoint.id}',
    checkpointId: checkpoint.id,
    activationPlanId: plan.id,
    handoffId: plan.handoffId,
    candidateId: plan.candidateId,
    candidateName: plan.candidateName,
    role: plan.role,
    department: plan.department,
    ownerName: plan.managerName,
    actionType: IncomingTalentActivationFollowUpType.managerAlignment,
    status: status,
    dueDate: asOfDate.add(const Duration(days: 3)),
    action: 'Resolve manager alignment and mentor capacity.',
    successCriteria: 'Restore activation confidence to 4/5 or better.',
    createdAt: asOfDate,
  );
}
