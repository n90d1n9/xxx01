import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_ramp_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_ramp_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('candidate ramp plans connect hiring pipeline to talent readiness', () {
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final plans = container.read(candidateRampPlansProvider);
    final summary = container.read(recruitmentCandidateRampSummaryProvider);

    expect(plans.map((item) => item.candidateName), [
      'Fajar Nugroho',
      'Mira Lestari',
      'Galih Santoso',
      'Dina Kartika',
    ]);
    expect(plans.map((item) => item.readiness), [
      CandidateRampReadiness.coaching,
      CandidateRampReadiness.atRisk,
      CandidateRampReadiness.atRisk,
      CandidateRampReadiness.coaching,
    ]);
    expect(plans.first.skillFocus, 'Flutter architecture');
    expect(plans.first.learningPlanTitle, 'Mobile POS release readiness');
    expect(plans.first.daysUntilReady(DateTime(2026, 5, 30)), 45);
    expect(summary.totalPlans, 4);
    expect(summary.readyCount, 0);
    expect(summary.coachingCount, 2);
    expect(summary.atRiskCount, 2);
    expect(summary.offerStageCount, 1);
    expect(summary.averageCandidateScore, closeTo(84.25, 0.0001));
    expect(
      summary.nextAction,
      'Pair at-risk candidates with mentors before offer handoff.',
    );
  });

  test('recruitment ramp filter follows priority hiring controls', () {
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    container.read(recruitmentDepartmentProvider.notifier).state = 'Operations';
    container.read(recruitmentPriorityOnlyProvider.notifier).state = true;

    final plans = container.read(filteredRecruitmentCandidateRampPlansProvider);
    final summary = container.read(recruitmentCandidateRampSummaryProvider);

    expect(plans.map((item) => item.candidateName), ['Galih Santoso']);
    expect(plans.single.readiness, CandidateRampReadiness.atRisk);
    expect(plans.single.skillFocus, 'Labor scheduling');
    expect(plans.single.mentorName, 'David Kim');
    expect(summary.totalPlans, 1);
    expect(summary.atRiskCount, 1);
    expect(summary.averageCandidateScore, 78);
  });

  test('talent ramp filter focuses incoming finance readiness risks', () {
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final plans = container.read(filteredTalentCandidateRampPlansProvider);
    final summary = container.read(talentCandidateRampSummaryProvider);

    expect(plans.map((item) => item.candidateName), ['Mira Lestari']);
    expect(plans.single.readiness, CandidateRampReadiness.atRisk);
    expect(plans.single.skillFocus, 'Payroll reconciliation');
    expect(plans.single.learningPlanTitle, 'Payroll close checklist');
    expect(
      plans.single.action,
      'Unblock mentor capacity before offer handoff.',
    );
    expect(summary.totalPlans, 1);
    expect(summary.offerStageCount, 1);
    expect(summary.atRiskCount, 1);
  });
}
