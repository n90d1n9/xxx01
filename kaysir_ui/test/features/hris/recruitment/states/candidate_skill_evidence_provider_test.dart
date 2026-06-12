import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_skill_evidence_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_skill_fit_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_skill_fit_provider.dart';

void main() {
  test(
    'candidate skill evidence draft validates required scorecard fields',
    () {
      final draft = CandidateSkillEvidenceDraft.empty();

      expect(draft.isReady, isFalse);
      expect(draft.validationErrors, [
        'Select a candidate',
        'Select a skill',
        'Select a level from 0 to 5',
        'Add evidence with at least 12 characters',
      ]);

      final readyDraft = draft.copyWith(
        candidateId: 'cand-003',
        candidateName: 'Galih Santoso',
        skill: 'Labor scheduling',
        currentLevelText: '4',
        evidence: 'Scheduling simulation now covers peak-hour constraints.',
      );

      expect(readyDraft.isReady, isTrue);
      expect(readyDraft.toEvidence().currentLevel, 4);
    },
  );

  test('candidate skill evidence draft initializes from a fit signal', () {
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
    expect(draft.evidence, contains('Scheduling simulation'));
  });

  test('candidate skill evidence upsert recomputes fit profile', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final before = container
        .read(candidateSkillFitProfilesProvider)
        .singleWhere((item) => item.candidateId == 'cand-003');
    expect(before.status, CandidateSkillFitStatus.gapRisk);
    expect(before.fitScore, 66);
    expect(before.criticalGapCount, 1);

    final evidenceCount = container.read(candidateSkillEvidenceProvider).length;
    final draft = CandidateSkillEvidenceDraft(
      candidateId: 'cand-003',
      candidateName: 'Galih Santoso',
      skill: 'Labor scheduling',
      currentLevelText: '4',
      evidence: 'Scheduling simulation now covers peak-hour constraints.',
    );

    final evidence = container
        .read(candidateSkillEvidenceProvider.notifier)
        .upsertDraft(draft);

    expect(evidence.currentLevel, 4);
    expect(
      container.read(candidateSkillEvidenceProvider),
      hasLength(evidenceCount),
    );

    final after = container
        .read(candidateSkillFitProfilesProvider)
        .singleWhere((item) => item.candidateId == 'cand-003');
    expect(after.status, CandidateSkillFitStatus.coaching);
    expect(after.fitScore, 83);
    expect(after.criticalGapCount, 0);

    final summary = container.read(recruitmentCandidateSkillFitSummaryProvider);
    expect(summary.gapRiskCount, 1);
    expect(summary.coachingCount, 3);
    expect(summary.topGapSkill, 'Payroll reconciliation');
  });
}
