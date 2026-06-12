import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_talent_handoff_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_talent_handoff_checklist_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_talent_handoff_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_program_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_readiness.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_activation_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_completion_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_milestone_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_readiness_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('incoming talent activation draft initializes from ready handoff', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final readiness = _readyReadiness(
      container,
      candidateId: 'candidate-fajar',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
    );

    container
        .read(incomingTalentActivationDraftProvider.notifier)
        .initializeFromReadiness(readiness);

    final draft = container.read(incomingTalentActivationDraftProvider);

    expect(draft.handoffId, readiness.handoffId);
    expect(draft.candidateName, 'Fajar Nugroho');
    expect(draft.readinessStatus, IncomingTalentReadinessStatus.ready);
    expect(draft.mentorName, 'Engineering mentor');
    expect(
      draft.learningPlanTitle,
      'Senior Flutter Engineer first 30-day learning path',
    );
    expect(draft.activationOwner, 'Talent Partner');
    expect(draft.kickoffDate, asOfDate.add(const Duration(days: 7)));
    expect(draft.firstCheckpointDate, asOfDate.add(const Duration(days: 21)));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('incoming talent activation submits and tracks status summary', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final readiness = _readyReadiness(
      container,
      candidateId: 'candidate-fajar',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
    );

    container
        .read(incomingTalentActivationDraftProvider.notifier)
        .initializeFromReadiness(readiness);

    final plan = container
        .read(incomingTalentActivationPlansProvider.notifier)
        .submitDraft(container.read(incomingTalentActivationDraftProvider));

    expect(plan.id, 'talent-activation-001');
    expect(plan.status, IncomingTalentActivationStatus.planned);
    expect(plan.isDueSoon(asOfDate), isTrue);
    expect(plan.daysUntilKickoff(asOfDate), 7);

    expect(
      () => container
          .read(incomingTalentActivationPlansProvider.notifier)
          .submitDraft(container.read(incomingTalentActivationDraftProvider)),
      throwsStateError,
    );

    var summary = container.read(incomingTalentActivationSummaryProvider);
    expect(summary.totalCount, 1);
    expect(summary.plannedCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.nextAction, 'Launch 1 activation plans due soon.');

    container
        .read(incomingTalentActivationPlansProvider.notifier)
        .start(plan.id);
    summary = container.read(incomingTalentActivationSummaryProvider);
    expect(summary.activeCount, 1);
    expect(summary.nextAction, 'Launch 1 activation plans due soon.');

    container
        .read(incomingTalentActivationPlansProvider.notifier)
        .block(plan.id);
    summary = container.read(incomingTalentActivationSummaryProvider);
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Unblock 1 activation plans.');

    container
        .read(incomingTalentActivationPlansProvider.notifier)
        .complete(plan.id);
    summary = container.read(incomingTalentActivationSummaryProvider);
    expect(summary.completedCount, 1);
    expect(summary.dueSoonCount, 0);
    expect(summary.nextAction, 'Talent activations are complete.');
  });

  test('incoming talent activation snapshots development evidence gates', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final readiness = _developmentEvidenceReadiness(
      container,
      candidateId: 'candidate-fajar',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
      score: 92,
    );

    container
        .read(incomingTalentActivationDraftProvider.notifier)
        .initializeFromReadiness(readiness);

    final draft = container.read(incomingTalentActivationDraftProvider);
    expect(draft.acceptedProgramMilestoneCount, 1);
    expect(draft.roleReadyProgramCompletionCount, 1);
    expect(draft.programCompletionExtensionCount, 0);
    expect(draft.completionRatio, 1);
    expect(draft.isReadyToSubmit, isTrue);

    final plan = container
        .read(incomingTalentActivationPlansProvider.notifier)
        .submitDraft(draft);

    expect(plan.acceptedProgramMilestoneCount, 1);
    expect(plan.roleReadyProgramCompletionCount, 1);
    expect(plan.programCompletionExtensionCount, 0);
    expect(plan.developmentEvidenceCount, 2);
    expect(plan.hasProgramExtensionRisk, isFalse);

    final summary = container.read(incomingTalentActivationSummaryProvider);
    expect(summary.evidenceBackedCount, 1);
    expect(summary.roleReadyCredentialCount, 1);
    expect(summary.programExtensionRiskCount, 0);
    expect(summary.nextAction, 'Launch 1 activation plans due soon.');
  });

  test('incoming talent activation blocks program extension evidence', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final readiness = _developmentEvidenceReadiness(
      container,
      candidateId: 'candidate-mira',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
      score: 64,
      decision:
          IncomingTalentDevelopmentProgramCompletionDecision.extendProgram,
      credentialLevel:
          IncomingTalentDevelopmentProgramCredentialLevel.foundational,
    );

    expect(readiness.status, IncomingTalentReadinessStatus.attention);
    expect(readiness.programCompletionExtensionCount, 1);

    container
        .read(incomingTalentActivationDraftProvider.notifier)
        .initializeFromReadiness(readiness);

    final draft = container.read(incomingTalentActivationDraftProvider);
    expect(draft.programCompletionExtensionCount, 1);
    expect(draft.isReadyToSubmit, isFalse);
    expect(
      draft.validationErrors,
      contains('Resolve program extension decisions before activation'),
    );
  });

  test('incoming talent activation requires ready handoff gates', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    _submitHandoff(
      container,
      candidateId: 'candidate-mira',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
      status: CandidateTalentHandoffStatus.ready,
      readinessScore: 86,
    );

    final readiness =
        container
            .read(incomingTalentReadinessWithDevelopmentEvidenceProvider)
            .single;
    expect(readiness.status, IncomingTalentReadinessStatus.attention);

    container
        .read(incomingTalentActivationDraftProvider.notifier)
        .initializeFromReadiness(readiness);

    final draft = container.read(incomingTalentActivationDraftProvider);
    expect(draft.isReadyToSubmit, isFalse);
    expect(
      draft.validationErrors,
      contains('Incoming handoff must be ready before activation'),
    );
    expect(
      () => container
          .read(incomingTalentActivationPlansProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test(
    'incoming talent activation follows department and attention filters',
    () {
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
          .complete(engineeringPlan.id);

      _submitActivation(
        container,
        candidateId: 'candidate-mira',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
      );

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(
        filteredIncomingTalentActivationPlansProvider,
      );
      final summary = container.read(incomingTalentActivationSummaryProvider);

      expect(filtered.map((plan) => plan.candidateName), ['Mira Lestari']);
      expect(summary.totalCount, 1);
      expect(summary.plannedCount, 1);
      expect(summary.nextAction, 'Launch 1 activation plans due soon.');
    },
  );
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [
      recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
      talentAsOfDateProvider.overrideWithValue(asOfDate),
    ],
  );
}

IncomingTalentActivationPlan _submitActivation(
  ProviderContainer container, {
  required String candidateId,
  required String candidateName,
  required String department,
  required String role,
}) {
  final readiness = _readyReadiness(
    container,
    candidateId: candidateId,
    candidateName: candidateName,
    department: department,
    role: role,
  );
  container
      .read(incomingTalentActivationDraftProvider.notifier)
      .initializeFromReadiness(readiness);
  return container
      .read(incomingTalentActivationPlansProvider.notifier)
      .submitDraft(container.read(incomingTalentActivationDraftProvider));
}

IncomingTalentReadiness _readyReadiness(
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
    status: CandidateTalentHandoffStatus.ready,
    readinessScore: 86,
  );
  _completeGeneratedChecklist(container, handoff, asOfDate);

  return container
      .read(incomingTalentReadinessWithDevelopmentEvidenceProvider)
      .singleWhere((item) => item.handoffId == handoff.id);
}

IncomingTalentReadiness _developmentEvidenceReadiness(
  ProviderContainer container, {
  required String candidateId,
  required String candidateName,
  required String department,
  required String role,
  required int score,
  IncomingTalentDevelopmentProgramCompletionDecision? decision,
  IncomingTalentDevelopmentProgramCredentialLevel? credentialLevel,
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final handoff = _submitHandoff(
    container,
    candidateId: candidateId,
    candidateName: candidateName,
    department: department,
    role: role,
    status: CandidateTalentHandoffStatus.ready,
    readinessScore: 88,
  );
  _completeGeneratedChecklist(container, handoff, asOfDate);

  final milestone = _submitProgramMilestone(
    container,
    handoff: handoff,
    score: score,
  );
  _submitProgramCompletion(
    container,
    milestone,
    decision: decision,
    credentialLevel: credentialLevel,
    score: score,
  );

  return container
      .read(incomingTalentReadinessWithDevelopmentEvidenceProvider)
      .singleWhere((item) => item.handoffId == handoff.id);
}

void _completeGeneratedChecklist(
  ProviderContainer container,
  CandidateTalentHandoff handoff,
  DateTime asOfDate,
) {
  final generated = container
      .read(candidateTalentHandoffChecklistItemsProvider.notifier)
      .generateForHandoff(handoff: handoff, asOfDate: asOfDate);
  for (final item in generated) {
    container
        .read(candidateTalentHandoffChecklistItemsProvider.notifier)
        .complete(item.id);
  }
}

IncomingTalentDevelopmentProgramMilestone _submitProgramMilestone(
  ProviderContainer container, {
  required CandidateTalentHandoff handoff,
  required int score,
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentDevelopmentProgramMilestoneDraft(
    enrollmentId: 'enrollment-${handoff.candidateId}',
    programId: 'program-${handoff.department}',
    programTitle: '${handoff.department} readiness cohort',
    candidateId: handoff.candidateId,
    candidateName: handoff.candidateName,
    role: handoff.role,
    department: handoff.department,
    reviewerName: '${handoff.department} Reviewer',
    title: 'Complete ${handoff.role} readiness milestone.',
    evidenceSummary: 'Submitted accepted evidence for ${handoff.role}.',
    reviewNotes: 'Accepted evidence and closed readiness review.',
    type: IncomingTalentDevelopmentProgramMilestoneType.skillEvidence,
    status: IncomingTalentDevelopmentProgramMilestoneStatus.accepted,
    score: score,
    dueDate: asOfDate.add(const Duration(days: 7)),
    submittedAt: asOfDate.subtract(const Duration(days: 2)),
    reviewedAt: asOfDate,
    sourceEnrollmentStatus:
        IncomingTalentDevelopmentProgramEnrollmentStatus.active,
    asOfDate: asOfDate,
  );

  return container
      .read(incomingTalentDevelopmentProgramMilestonesProvider.notifier)
      .submitDraft(draft);
}

IncomingTalentDevelopmentProgramCompletion _submitProgramCompletion(
  ProviderContainer container,
  IncomingTalentDevelopmentProgramMilestone milestone, {
  IncomingTalentDevelopmentProgramCompletionDecision? decision,
  IncomingTalentDevelopmentProgramCredentialLevel? credentialLevel,
  int? score,
}) {
  final notifier = container.read(
    incomingTalentDevelopmentProgramCompletionDraftProvider.notifier,
  );
  notifier.initializeFromMilestone(milestone);
  if (decision != null) notifier.setDecision(decision);
  if (credentialLevel != null) notifier.setCredentialLevel(credentialLevel);
  if (score != null) notifier.setScore(score);

  return container
      .read(incomingTalentDevelopmentProgramCompletionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentDevelopmentProgramCompletionDraftProvider),
      );
}

CandidateTalentHandoff _submitHandoff(
  ProviderContainer container, {
  required String candidateId,
  required String candidateName,
  required String department,
  required String role,
  required CandidateTalentHandoffStatus status,
  required int readinessScore,
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
    status: status,
    readinessScore: readinessScore,
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
