import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_skill_evidence_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_skill_fit_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_skill_fit_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('candidate skill fit profiles score role readiness signals', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final profiles = container.read(candidateSkillFitProfilesProvider);

    expect(profiles, hasLength(4));

    final fajar = profiles.singleWhere(
      (profile) => profile.candidateId == 'cand-001',
    );
    expect(fajar.status, CandidateSkillFitStatus.coaching);
    expect(fajar.fitScore, 89);
    expect(fajar.topSkillGap, 'Flutter architecture');
    expect(fajar.suggestedLearningPlan, 'Mobile POS release readiness');
    expect(fajar.suggestedMentor, 'Alya Saputra');

    final galih = profiles.singleWhere(
      (profile) => profile.candidateId == 'cand-003',
    );
    expect(galih.status, CandidateSkillFitStatus.gapRisk);
    expect(galih.fitScore, 66);
    expect(galih.criticalGapCount, 1);
    expect(galih.topSkillGap, 'Labor scheduling');

    final summary = container.read(recruitmentCandidateSkillFitSummaryProvider);
    expect(summary.totalProfiles, 4);
    expect(summary.strongFitCount, 0);
    expect(summary.coachingCount, 2);
    expect(summary.gapRiskCount, 2);
    expect(summary.averageFitScore, 79.5);
    expect(summary.topGapSkill, 'Labor scheduling');
    expect(
      summary.nextAction,
      'Resolve 2 critical fit gaps before offer approval.',
    );
  });

  test(
    'recruitment candidate skill fit follows department and priority filters',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(recruitmentDepartmentProvider.notifier).state =
          'Operations';
      container.read(recruitmentPriorityOnlyProvider.notifier).state = true;

      final profiles = container.read(
        filteredRecruitmentCandidateSkillFitProfilesProvider,
      );

      expect(profiles.map((profile) => profile.candidateName), [
        'Galih Santoso',
      ]);
      expect(
        container
            .read(recruitmentCandidateSkillFitSummaryProvider)
            .gapRiskCount,
        1,
      );
    },
  );

  test(
    'talent candidate skill fit can focus incoming attention by department',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(talentDepartmentProvider.notifier).state = 'Engineering';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final profiles = container.read(
        filteredTalentCandidateSkillFitProfilesProvider,
      );

      expect(profiles.map((profile) => profile.candidateName), [
        'Fajar Nugroho',
      ]);
      expect(
        container.read(talentCandidateSkillFitSummaryProvider).coachingCount,
        1,
      );
    },
  );

  test('candidate skill evidence draft validates scorecard input', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final profile = container
        .read(candidateSkillFitProfilesProvider)
        .singleWhere((item) => item.candidateId == 'cand-003');
    final signal = profile.signals.singleWhere(
      (item) => item.skill == 'Labor scheduling',
    );

    container
        .read(candidateSkillEvidenceDraftProvider.notifier)
        .initializeFromSignal(profile: profile, signal: signal);

    final draft = container.read(candidateSkillEvidenceDraftProvider);
    expect(draft.candidateName, 'Galih Santoso');
    expect(draft.skill, 'Labor scheduling');
    expect(draft.currentLevelText, '2');
    expect(draft.isReady, isTrue);

    final invalid = draft.copyWith(currentLevelText: '6', evidence: 'short');

    expect(invalid.isReady, isFalse);
    expect(invalid.validationErrors, [
      'Select a level from 0 to 5',
      'Add evidence with at least 12 characters',
    ]);
    expect(
      CandidateSkillEvidenceDraft.validateCandidate(''),
      'Select a candidate',
    );
  });

  test('candidate skill evidence upsert recalculates fit profile', () {
    final container = ProviderContainer();
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

    final evidence = container
        .read(candidateSkillEvidenceProvider.notifier)
        .upsertDraft(container.read(candidateSkillEvidenceDraftProvider));

    expect(evidence.currentLevel, 4);
    expect(container.read(candidateSkillEvidenceProvider), hasLength(12));

    final updated = container
        .read(candidateSkillFitProfilesProvider)
        .singleWhere((item) => item.candidateId == 'cand-003');

    expect(updated.status, CandidateSkillFitStatus.coaching);
    expect(updated.fitScore, 83);
    expect(updated.criticalGapCount, 0);
    expect(updated.topSkillGap, 'Store escalation');
    expect(
      container.read(recruitmentCandidateSkillFitSummaryProvider).gapRiskCount,
      1,
    );
  });
}
