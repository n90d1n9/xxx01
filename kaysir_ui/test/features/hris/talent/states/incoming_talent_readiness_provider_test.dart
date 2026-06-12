import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_talent_handoff_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_talent_handoff_checklist_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_talent_handoff_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_program_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_readiness.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_completion_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_milestone_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_readiness_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('incoming talent readiness applies role-ready development evidence', () {
    final asOfDate = DateTime(2026, 6, 7);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final handoff = _submitHandoff(container);
    _completeGeneratedChecklist(container, handoff, asOfDate);
    final milestone = _submitMilestone(container, asOfDate, score: 92);
    _submitCompletion(container, milestone);

    final readiness =
        container
            .read(
              filteredIncomingTalentReadinessWithDevelopmentEvidenceProvider,
            )
            .single;
    final summary = container.read(
      incomingTalentReadinessWithDevelopmentEvidenceSummaryProvider,
    );

    expect(readiness.status, IncomingTalentReadinessStatus.ready);
    expect(readiness.acceptedProgramMilestoneCount, 1);
    expect(readiness.roleReadyProgramCompletionCount, 1);
    expect(readiness.programCompletionExtensionCount, 0);
    expect(readiness.developmentEvidenceCount, 2);
    expect(
      readiness.nextAction,
      'Apply 1 role-ready credential to talent setup.',
    );

    expect(summary.readyCount, 1);
    expect(summary.evidenceBackedCount, 1);
    expect(summary.roleReadyCredentialCount, 1);
    expect(summary.programCompletionExtensionCount, 0);
    expect(summary.developmentEvidenceCoverageRate, 1);
    expect(
      summary.nextAction,
      'Apply 1 role-ready credential to incoming plans.',
    );
  });

  test('incoming talent readiness flags program extension decisions', () {
    final asOfDate = DateTime(2026, 6, 7);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final handoff = _submitHandoff(container);
    _completeGeneratedChecklist(container, handoff, asOfDate);
    final milestone = _submitMilestone(container, asOfDate, score: 64);
    _submitCompletion(
      container,
      milestone,
      decision:
          IncomingTalentDevelopmentProgramCompletionDecision.extendProgram,
      credentialLevel:
          IncomingTalentDevelopmentProgramCredentialLevel.foundational,
      score: 64,
    );

    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final readiness =
        container
            .read(
              filteredIncomingTalentReadinessWithDevelopmentEvidenceProvider,
            )
            .single;
    final summary = container.read(
      incomingTalentReadinessWithDevelopmentEvidenceSummaryProvider,
    );

    expect(readiness.status, IncomingTalentReadinessStatus.attention);
    expect(readiness.needsAttention, isTrue);
    expect(readiness.acceptedProgramMilestoneCount, 1);
    expect(readiness.roleReadyProgramCompletionCount, 0);
    expect(readiness.programCompletionExtensionCount, 1);
    expect(
      readiness.nextAction,
      'Resolve 1 program extension decision before release.',
    );

    expect(summary.totalCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.programCompletionExtensionCount, 1);
    expect(summary.nextAction, 'Resolve 1 program extension decision.');
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

CandidateTalentHandoff _submitHandoff(ProviderContainer container) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final targetStartDate = asOfDate.add(const Duration(days: 7));
  final draft = CandidateTalentHandoffDraft(
    calibrationReviewId: 'calibration-candidate-fajar',
    objectiveId: 'objective-candidate-fajar',
    candidateId: 'candidate-fajar',
    candidateName: 'Fajar Nugroho',
    role: 'Senior Flutter Engineer',
    department: 'Engineering',
    type: CandidateTalentHandoffType.offerTransition,
    status: CandidateTalentHandoffStatus.ready,
    readinessScore: 88,
    ownerName: 'Talent Partner',
    receivingManagerName: 'Engineering Manager',
    targetStartDate: targetStartDate,
    firstCheckpointDate: targetStartDate.add(const Duration(days: 14)),
    talentFocus: 'Prepare Fajar Nugroho for role readiness.',
    handoffNote: 'Prepare Fajar Nugroho for role readiness.',
    asOfDate: asOfDate,
  );

  return container
      .read(candidateTalentHandoffsProvider.notifier)
      .submitDraft(draft);
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

IncomingTalentDevelopmentProgramMilestone _submitMilestone(
  ProviderContainer container,
  DateTime asOfDate, {
  required int score,
}) {
  final draft = IncomingTalentDevelopmentProgramMilestoneDraft(
    enrollmentId: 'enrollment-candidate-fajar',
    programId: 'program-engineering-readiness',
    programTitle: 'Engineering readiness cohort',
    candidateId: 'candidate-fajar',
    candidateName: 'Fajar Nugroho',
    role: 'Senior Flutter Engineer',
    department: 'Engineering',
    reviewerName: 'Engineering Reviewer',
    title: 'Complete Flutter architecture readiness milestone.',
    evidenceSummary: 'Submitted accepted evidence for architecture readiness.',
    reviewNotes: 'Accepted evidence and closed role readiness review.',
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
