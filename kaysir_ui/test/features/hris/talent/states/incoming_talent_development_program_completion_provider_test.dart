import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_program_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_completion_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_milestone_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('program completion draft validates required credential fields', () {
    final asOfDate = DateTime(2026, 6, 7);
    final draft = IncomingTalentDevelopmentProgramCompletionDraft.empty(
      asOfDate,
    ).copyWith(
      score: -1,
      completedAt: asOfDate.add(const Duration(days: 1)),
      credentialNote: 'tiny',
      managerRecommendation: 'mini',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter an accepted milestone',
      'Please enter a reviewer',
      'Select completion decision',
      'Select credential level',
      'Score cannot be below 0',
      'Completion date cannot be in the future',
      'credential note must be at least 12 characters',
      'manager recommendation must be at least 12 characters',
    ]);
  });

  test('program completions default from accepted milestone and summarize', () {
    final asOfDate = DateTime(2026, 6, 7);
    final milestone = _milestone(asOfDate, score: 91);
    final container = _container(asOfDate, milestones: [milestone]);
    addTearDown(container.dispose);

    final draft = IncomingTalentDevelopmentProgramCompletionDraft.fromMilestone(
      milestone: milestone,
      asOfDate: asOfDate,
    );

    expect(
      draft.decision,
      IncomingTalentDevelopmentProgramCompletionDecision.roleReady,
    );
    expect(
      draft.credentialLevel,
      IncomingTalentDevelopmentProgramCredentialLevel.advanced,
    );
    expect(draft.score, 91);
    expect(draft.renewalDate, asOfDate.add(const Duration(days: 365)));
    expect(draft.isReadyToSubmit, isTrue);

    final completion = _submitCompletion(container, milestone);

    expect(completion.id, 'talent-program-completion-001');
    expect(completion.isRoleReady, isTrue);
    expect(container.read(completionReadyProgramMilestonesProvider), isEmpty);

    final summary = container.read(
      incomingTalentDevelopmentProgramCompletionSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.roleReadyCount, 1);
    expect(summary.extensionCount, 0);
    expect(summary.averageScore, 91);
    expect(
      summary.nextAction,
      'Apply 1 role-ready credentials to growth decisions.',
    );

    expect(
      () => container
          .read(incomingTalentDevelopmentProgramCompletionsProvider.notifier)
          .submitDraft(
            container.read(
              incomingTalentDevelopmentProgramCompletionDraftProvider,
            ),
          ),
      throwsStateError,
    );
  });

  test('program completions follow talent filters', () {
    final asOfDate = DateTime(2026, 6, 7);
    final engineeringMilestone = _milestone(
      asOfDate,
      id: 'milestone-engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
      score: 91,
    );
    final financeMilestone = _milestone(
      asOfDate,
      id: 'milestone-finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
      score: 68,
    );
    final container = _container(
      asOfDate,
      milestones: [engineeringMilestone, financeMilestone],
    );
    addTearDown(container.dispose);

    _submitCompletion(container, engineeringMilestone);
    _submitCompletion(
      container,
      financeMilestone,
      decision:
          IncomingTalentDevelopmentProgramCompletionDecision.extendProgram,
      credentialLevel:
          IncomingTalentDevelopmentProgramCredentialLevel.foundational,
      score: 66,
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentDevelopmentProgramCompletionsProvider,
    );
    final summary = container.read(
      incomingTalentDevelopmentProgramCompletionSummaryProvider,
    );

    expect(filtered.map((completion) => completion.candidateName), [
      'Mira Lestari',
    ]);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.extensionCount, 1);
    expect(summary.nextAction, 'Resolve 1 program extension decisions.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentDevelopmentProgramMilestone> milestones,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentDevelopmentProgramMilestonesProvider
          .overrideWithValue(milestones),
    ],
  );
}

IncomingTalentDevelopmentProgramCompletion _submitCompletion(
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

IncomingTalentDevelopmentProgramMilestone _milestone(
  DateTime asOfDate, {
  String id = 'milestone-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  int score = 88,
}) {
  return IncomingTalentDevelopmentProgramMilestone(
    id: id,
    enrollmentId: 'enrollment-$id',
    programId: 'program-$department',
    programTitle: '$department readiness cohort',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    role: role,
    department: department,
    reviewerName: '$department Reviewer',
    title: 'Complete $role readiness milestone with accepted evidence.',
    evidenceSummary: 'Submitted manager-reviewed evidence for $role.',
    reviewNotes: 'Accepted milestone evidence and closed readiness review.',
    type: IncomingTalentDevelopmentProgramMilestoneType.skillEvidence,
    status: IncomingTalentDevelopmentProgramMilestoneStatus.accepted,
    score: score,
    dueDate: asOfDate.subtract(const Duration(days: 7)),
    submittedAt: asOfDate.subtract(const Duration(days: 4)),
    reviewedAt: asOfDate.subtract(const Duration(days: 2)),
    sourceEnrollmentStatus:
        IncomingTalentDevelopmentProgramEnrollmentStatus.active,
    createdAt: asOfDate.subtract(const Duration(days: 7)),
  );
}
