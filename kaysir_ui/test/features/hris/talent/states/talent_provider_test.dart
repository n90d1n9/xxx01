import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_talent_handoff_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_talent_handoff_checklist_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_talent_handoff_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_readiness.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent summary aggregates development signals', () {
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(talentSummaryProvider);

    expect(summary.skillGaps, 2);
    expect(summary.learningDue, 23);
    expect(summary.certificationRisks, 3);
    expect(summary.mentoringWatch, 2);
    expect(summary.averageLearningCompletion, closeTo(0.6875, 0.0001));
  });

  test('attention filter focuses finance development risks', () {
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final summary = container.read(talentSummaryProvider);
    final skillGaps = container.read(filteredSkillGapsProvider);
    final learningPlans = container.read(filteredLearningPlansProvider);
    final certifications = container.read(filteredCertificationsProvider);
    final mentorshipPairs = container.read(filteredMentorshipPairsProvider);

    expect(skillGaps.map((item) => item.employeeName), ['Anisa Putri']);
    expect(learningPlans.map((item) => item.title), [
      'Payroll close checklist',
    ]);
    expect(certifications.map((item) => item.employeeName), ['Anisa Putri']);
    expect(mentorshipPairs.map((item) => item.menteeName), ['Anisa Putri']);
    expect(summary.skillGaps, 1);
    expect(summary.learningDue, 6);
    expect(summary.certificationRisks, 1);
    expect(summary.mentoringWatch, 1);
    expect(summary.averageLearningCompletion, closeTo(0.5, 0.0001));
  });

  test('talent risk summary aggregates urgent development signals', () {
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final risks = container.read(talentRiskSummaryProvider);

    expect(risks.skillGaps, 2);
    expect(risks.overdueLearningPlans, 1);
    expect(risks.expiredCertifications, 1);
    expect(risks.expiringCertifications, 2);
    expect(risks.blockedMentorships, 1);
    expect(risks.dueWithinFourteenDays, 6);
    expect(risks.totalRisks, 7);
  });

  test('talent date override drives generated learning dates', () {
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 7, 10)),
      ],
    );
    addTearDown(container.dispose);

    final learningPlans = container.read(learningPlansProvider);
    final certifications = container.read(certificationsProvider);
    final mentorshipPairs = container.read(mentorshipPairsProvider);

    expect(learningPlans.first.dueDate, DateTime(2026, 7, 18));
    expect(certifications.first.expiryDate, DateTime(2026, 7, 29));
    expect(mentorshipPairs.first.nextSession, DateTime(2026, 7, 14));
  });

  test('incoming talent readiness tracks handoff checklist gates', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final handoff = _submitHandoff(
      container,
      candidateId: 'candidate-fajar',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
      status: CandidateTalentHandoffStatus.ready,
      readinessScore: 86,
    );

    var readiness = container.read(incomingTalentReadinessProvider).single;
    expect(readiness.status, IncomingTalentReadinessStatus.attention);
    expect(readiness.requiredChecklistCount, 5);
    expect(readiness.missingRequiredChecklistCount, 5);
    expect(readiness.openRequiredChecklistCount, 0);
    expect(readiness.checklistCompletionRatio, 0);
    expect(
      readiness.nextAction,
      'Generate 5 missing required checklist tasks.',
    );

    var summary = container.read(incomingTalentReadinessSummaryProvider);
    expect(summary.totalCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.missingChecklistCount, 5);
    expect(summary.nextAction, 'Generate 5 missing required checklist tasks.');

    final generated = container
        .read(candidateTalentHandoffChecklistItemsProvider.notifier)
        .generateForHandoff(handoff: handoff, asOfDate: asOfDate);

    readiness = container.read(incomingTalentReadinessProvider).single;
    expect(readiness.status, IncomingTalentReadinessStatus.attention);
    expect(readiness.missingRequiredChecklistCount, 0);
    expect(readiness.openRequiredChecklistCount, 5);
    expect(
      readiness.nextAction,
      'Close 5 required checklist tasks before start.',
    );

    summary = container.read(incomingTalentReadinessSummaryProvider);
    expect(summary.openChecklistCount, 5);
    expect(summary.nextAction, 'Close checklist work for 1 incoming handoffs.');

    for (final item in generated) {
      container
          .read(candidateTalentHandoffChecklistItemsProvider.notifier)
          .complete(item.id);
    }

    readiness = container.read(incomingTalentReadinessProvider).single;
    expect(readiness.status, IncomingTalentReadinessStatus.ready);
    expect(readiness.completedRequiredChecklistCount, 5);
    expect(readiness.pendingRequiredChecklistCount, 0);
    expect(readiness.checklistCompletionRatio, 1);
    expect(readiness.nextAction, 'Release to learning and mentorship setup.');

    summary = container.read(incomingTalentReadinessSummaryProvider);
    expect(summary.readyCount, 1);
    expect(summary.checklistCompletionRate, 1);
    expect(summary.nextAction, 'Release 1 incoming hires into talent plans.');
  });

  test(
    'incoming talent readiness follows department and attention filters',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = ProviderContainer(
        overrides: [
          recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
          talentAsOfDateProvider.overrideWithValue(asOfDate),
        ],
      );
      addTearDown(container.dispose);

      final engineeringHandoff = _submitHandoff(
        container,
        candidateId: 'candidate-fajar',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
        status: CandidateTalentHandoffStatus.ready,
        readinessScore: 86,
      );
      final generated = container
          .read(candidateTalentHandoffChecklistItemsProvider.notifier)
          .generateForHandoff(handoff: engineeringHandoff, asOfDate: asOfDate);
      for (final item in generated) {
        container
            .read(candidateTalentHandoffChecklistItemsProvider.notifier)
            .complete(item.id);
      }

      _submitHandoff(
        container,
        candidateId: 'candidate-mira',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        status: CandidateTalentHandoffStatus.blocked,
        type: CandidateTalentHandoffType.deferred,
        readinessScore: 42,
        targetOffset: const Duration(days: 21),
      );

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(filteredIncomingTalentReadinessProvider);
      final summary = container.read(incomingTalentReadinessSummaryProvider);

      expect(filtered.map((item) => item.candidateName), ['Mira Lestari']);
      expect(filtered.single.status, IncomingTalentReadinessStatus.blocked);
      expect(filtered.single.missingRequiredChecklistCount, 2);
      expect(summary.totalCount, 1);
      expect(summary.blockedCount, 1);
      expect(summary.nextAction, 'Escalate 1 incoming handoff blockers.');
      expect(container.read(talentDepartmentsProvider), contains('Finance'));
    },
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
  CandidateTalentHandoffType type = CandidateTalentHandoffType.offerTransition,
  Duration targetOffset = const Duration(days: 7),
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final targetStartDate = asOfDate.add(targetOffset);
  final draft = CandidateTalentHandoffDraft(
    calibrationReviewId: 'calibration-$candidateId',
    objectiveId: 'objective-$candidateId',
    candidateId: candidateId,
    candidateName: candidateName,
    role: role,
    department: department,
    type: type,
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
