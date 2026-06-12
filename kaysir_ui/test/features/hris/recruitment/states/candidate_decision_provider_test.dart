import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_decision_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_decision_review_draft.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_decision_review_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_ramp_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_skill_fit_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_decision_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_decision_review_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_skill_fit_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('candidate decision packets combine skill fit, ramp, and offers', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final packets = container.read(candidateDecisionPacketsProvider);
    final summary = container.read(recruitmentCandidateDecisionSummaryProvider);

    expect(packets.map((item) => item.candidateName), [
      'Fajar Nugroho',
      'Mira Lestari',
      'Galih Santoso',
      'Dina Kartika',
    ]);

    final fajar = packets.singleWhere(
      (item) => item.candidateName == 'Fajar Nugroho',
    );
    expect(fajar.recommendation, CandidateDecisionRecommendation.conditional);
    expect(fajar.fitStatus, CandidateSkillFitStatus.coaching);
    expect(fajar.rampReadiness, CandidateRampReadiness.coaching);
    expect(fajar.blockers, isEmpty);
    expect(fajar.daysUntilDue(asOfDate), 14);
    expect(
      fajar.nextAction,
      'Attach scorecard evidence for Flutter architecture',
    );

    final mira = packets.singleWhere(
      (item) => item.candidateName == 'Mira Lestari',
    );
    expect(mira.recommendation, CandidateDecisionRecommendation.hold);
    expect(mira.fitStatus, CandidateSkillFitStatus.gapRisk);
    expect(mira.rampReadiness, CandidateRampReadiness.atRisk);
    expect(mira.daysUntilDue(asOfDate), 4);
    expect(mira.blockers, [
      'Resolve skill gap: Payroll reconciliation',
      'Ramp at risk: Unblock mentor capacity before offer handoff.',
      'Offer expires in 4 days',
    ]);

    expect(summary.totalPackets, 4);
    expect(summary.approveCount, 0);
    expect(summary.conditionalCount, 2);
    expect(summary.holdCount, 2);
    expect(summary.dueSoonCount, 1);
    expect(summary.nextAction, 'Review 2 blocked hiring decisions.');
  });

  test(
    'recruitment decision packets follow department and priority filters',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = ProviderContainer(
        overrides: [
          recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
          talentAsOfDateProvider.overrideWithValue(asOfDate),
        ],
      );
      addTearDown(container.dispose);

      container.read(recruitmentDepartmentProvider.notifier).state =
          'Operations';
      container.read(recruitmentPriorityOnlyProvider.notifier).state = true;

      final packets = container.read(
        filteredRecruitmentCandidateDecisionPacketsProvider,
      );
      final summary = container.read(
        recruitmentCandidateDecisionSummaryProvider,
      );

      expect(packets.map((item) => item.candidateName), ['Galih Santoso']);
      expect(
        packets.single.recommendation,
        CandidateDecisionRecommendation.hold,
      );
      expect(
        packets.single.blockers.first,
        'Resolve skill gap: Labor scheduling',
      );
      expect(summary.totalPackets, 1);
      expect(summary.holdCount, 1);
    },
  );

  test('talent decision packets can focus incoming handoff risks', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final packets = container.read(
      filteredTalentCandidateDecisionPacketsProvider,
    );
    final summary = container.read(talentCandidateDecisionSummaryProvider);

    expect(packets.map((item) => item.candidateName), ['Mira Lestari']);
    expect(packets.single.recommendation, CandidateDecisionRecommendation.hold);
    expect(packets.single.suggestedMentor, 'Emma Rodriguez');
    expect(summary.totalPackets, 1);
    expect(summary.dueSoonCount, 1);
  });

  test('candidate evidence updates decision packet fit blockers', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final profile = container
        .read(candidateSkillFitProfilesProvider)
        .singleWhere((item) => item.candidateId == 'cand-003');
    final signal = profile.signals.singleWhere(
      (item) => item.skill == 'Labor scheduling',
    );
    final draftNotifier = container.read(
      candidateSkillEvidenceDraftProvider.notifier,
    );

    draftNotifier.initializeFromSignal(profile: profile, signal: signal);
    draftNotifier.setCurrentLevel('4');
    draftNotifier.setEvidence(
      'Scheduling simulation now covers peak-hour labor constraints.',
    );

    container
        .read(candidateSkillEvidenceProvider.notifier)
        .upsertDraft(container.read(candidateSkillEvidenceDraftProvider));

    final updated = container
        .read(candidateDecisionPacketsProvider)
        .singleWhere((item) => item.candidateName == 'Galih Santoso');

    expect(updated.fitScore, 83);
    expect(updated.fitStatus, CandidateSkillFitStatus.coaching);
    expect(
      updated.blockers,
      isNot(contains('Resolve skill gap: Labor scheduling')),
    );
    expect(
      updated.blockers,
      contains(
        'Ramp at risk: Create a manager-owned ramp plan before moving Galih Santoso.',
      ),
    );
  });

  test('candidate decision review draft initializes from packet', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final packet = container
        .read(candidateDecisionPacketsProvider)
        .singleWhere((item) => item.candidateName == 'Fajar Nugroho');

    container
        .read(candidateDecisionReviewDraftProvider.notifier)
        .initializeFromPacket(packet);

    final draft = container.read(candidateDecisionReviewDraftProvider);
    expect(draft.candidateName, 'Fajar Nugroho');
    expect(draft.outcome, CandidateDecisionOutcome.advanceWithConditions);
    expect(draft.ownerName, 'Hiring Committee');
    expect(draft.dueDate, DateTime(2026, 6, 13));
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);
  });

  test('candidate decision reviews submit and summarize outcomes', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final packet = container
        .read(candidateDecisionPacketsProvider)
        .singleWhere((item) => item.candidateName == 'Galih Santoso');
    final draftNotifier = container.read(
      candidateDecisionReviewDraftProvider.notifier,
    );
    draftNotifier.initializeFromPacket(packet);
    draftNotifier.setOwnerName('Operations Hiring Lead');
    draftNotifier.setNotes('Hold until labor scheduling evidence is updated.');

    final review = container
        .read(candidateDecisionReviewsProvider.notifier)
        .submitDraft(container.read(candidateDecisionReviewDraftProvider));

    expect(review.id, 'decision-review-001');
    expect(review.outcome, CandidateDecisionOutcome.hold);
    expect(review.ownerName, 'Operations Hiring Lead');
    expect(review.blockerCount, 2);

    final summary = container.read(candidateDecisionReviewSummaryProvider);
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.offerReadyCount, 0);
    expect(
      summary.nextAction,
      'Resolve 1 blocked decision reviews before handoff.',
    );
  });

  test('candidate decision review draft validates required fields', () {
    final draft = CandidateDecisionReviewDraft.empty(DateTime(2026, 5, 30));

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.completionRatio, 0);
    expect(draft.validationErrors, [
      'Please enter a candidate decision packet',
      'Select a decision outcome',
      'Please enter a decision owner',
      'Select a decision due date',
      'Please enter a next step',
      'Please enter decision notes',
    ]);
  });
}
