import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/people_ops_seed_data.dart';
import '../models/people_ops_models.dart';

const peopleOpsAllDepartments = 'All';

final peopleOpsDepartmentProvider = StateProvider<String>(
  (ref) => peopleOpsAllDepartments,
);
final peopleOpsRiskOnlyProvider = StateProvider<bool>((ref) => false);
final peopleOpsAsOfDateProvider = Provider<DateTime>((ref) => DateTime.now());

final workforcePlansProvider = Provider<List<WorkforcePlan>>((ref) {
  return buildPeopleOpsWorkforcePlans(ref.watch(peopleOpsAsOfDateProvider));
});

final onboardingMilestonesProvider = Provider<List<OnboardingMilestone>>((ref) {
  return buildOnboardingMilestones(ref.watch(peopleOpsAsOfDateProvider));
});

final complianceItemsProvider = Provider<List<ComplianceItem>>((ref) {
  return buildPeopleOpsComplianceItems(ref.watch(peopleOpsAsOfDateProvider));
});

final engagementPulsesProvider = Provider<List<EngagementPulse>>((ref) {
  return peopleOpsEngagementPulses;
});

final peopleOpsDepartmentsProvider = Provider<List<String>>((ref) {
  final departments =
      <String>{
          ...ref.watch(workforcePlansProvider).map((item) => item.department),
          ...ref
              .watch(onboardingMilestonesProvider)
              .map((item) => item.department),
          ...ref.watch(complianceItemsProvider).map((item) => item.department),
          ...ref.watch(engagementPulsesProvider).map((item) => item.department),
        }.where((department) => department != peopleOpsAllDepartments).toList()
        ..sort();

  return [peopleOpsAllDepartments, ...departments];
});

final filteredWorkforcePlansProvider = Provider<List<WorkforcePlan>>((ref) {
  return ref
      .watch(workforcePlansProvider)
      .where(
        (plan) =>
            _matchesDepartment(ref, plan.department) &&
            _matchesRisk(
              ref,
              plan.priority == PeopleOpsPriority.high || plan.remaining > 0,
            ),
      )
      .toList();
});

final filteredOnboardingMilestonesProvider =
    Provider<List<OnboardingMilestone>>((ref) {
      return ref
          .watch(onboardingMilestonesProvider)
          .where(
            (milestone) =>
                _matchesDepartment(ref, milestone.department) &&
                _matchesRisk(ref, milestone.status == OnboardingStatus.blocked),
          )
          .toList();
    });

final filteredComplianceItemsProvider = Provider<List<ComplianceItem>>((ref) {
  return ref
      .watch(complianceItemsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesRisk(ref, item.status != ComplianceStatus.valid),
      )
      .toList();
});

final filteredEngagementPulsesProvider = Provider<List<EngagementPulse>>((ref) {
  return ref
      .watch(engagementPulsesProvider)
      .where(
        (pulse) =>
            _matchesDepartment(ref, pulse.department) &&
            _matchesRisk(
              ref,
              pulse.priority == PeopleOpsPriority.high || pulse.score < 70,
            ),
      )
      .toList();
});

final peopleOpsRiskSummaryProvider = Provider<PeopleOpsRiskSummary>((ref) {
  return PeopleOpsRiskSummary.fromData(
    workforcePlans: ref.watch(filteredWorkforcePlansProvider),
    onboarding: ref.watch(filteredOnboardingMilestonesProvider),
    compliance: ref.watch(filteredComplianceItemsProvider),
    pulses: ref.watch(filteredEngagementPulsesProvider),
    asOfDate: ref.watch(peopleOpsAsOfDateProvider),
  );
});

final peopleOpsSummaryProvider = Provider<PeopleOpsSummary>((ref) {
  final workforce = ref.watch(filteredWorkforcePlansProvider);
  final onboarding = ref.watch(filteredOnboardingMilestonesProvider);
  final compliance = ref.watch(filteredComplianceItemsProvider);
  final pulses = ref.watch(filteredEngagementPulsesProvider);

  final totalPulseScore = pulses.fold<int>(
    0,
    (total, pulse) => total + pulse.score,
  );

  return PeopleOpsSummary(
    openRoles: workforce.where((plan) => plan.remaining > 0).length,
    hiresNeeded: workforce.fold<int>(
      0,
      (total, plan) => total + plan.remaining,
    ),
    onboardingTasksDue: onboarding.fold<int>(
      0,
      (total, milestone) => total + milestone.remainingTasks,
    ),
    complianceRisks:
        compliance
            .where((item) => item.status != ComplianceStatus.valid)
            .length,
    averagePulseScore: pulses.isEmpty ? 0 : totalPulseScore / pulses.length,
  );
});

bool _matchesDepartment(Ref ref, String department) {
  final selectedDepartment = ref.watch(peopleOpsDepartmentProvider);
  return selectedDepartment == peopleOpsAllDepartments ||
      department == selectedDepartment;
}

bool _matchesRisk(Ref ref, bool hasRisk) {
  return !ref.watch(peopleOpsRiskOnlyProvider) || hasRisk;
}
