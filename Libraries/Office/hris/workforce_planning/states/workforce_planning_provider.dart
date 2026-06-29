import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/workforce_planning_seed_data.dart';
import '../models/workforce_planning_models.dart';

const workforcePlanningAllDepartments = 'All';

final workforcePlanningDepartmentProvider = StateProvider<String>(
  (ref) => workforcePlanningAllDepartments,
);
final workforcePlanningAttentionOnlyProvider = StateProvider<bool>(
  (ref) => false,
);
final workforcePlanningAsOfDateProvider = Provider<DateTime>(
  (ref) => DateTime.now(),
);

final headcountPlansProvider = Provider<List<HeadcountPlan>>((ref) {
  return workforceHeadcountPlans;
});

final positionRequestsProvider = Provider<List<PositionRequest>>((ref) {
  return buildPositionRequests(ref.watch(workforcePlanningAsOfDateProvider));
});

final capacityRisksProvider = Provider<List<CapacityRisk>>((ref) {
  return workforceCapacityRisks;
});

final workforceScenariosProvider = Provider<List<WorkforceScenario>>((ref) {
  return workforceScenarios;
});

final workforcePlanningDepartmentsProvider = Provider<List<String>>((ref) {
  final departments =
      <String>{
            ...ref.watch(headcountPlansProvider).map((item) => item.department),
            ...ref
                .watch(positionRequestsProvider)
                .map((item) => item.department),
            ...ref.watch(capacityRisksProvider).map((item) => item.department),
            ...ref
                .watch(workforceScenariosProvider)
                .map((item) => item.department),
          }
          .where((department) => department != workforcePlanningAllDepartments)
          .toList()
        ..sort();

  return [workforcePlanningAllDepartments, ...departments];
});

final filteredHeadcountPlansProvider = Provider<List<HeadcountPlan>>((ref) {
  return ref
      .watch(headcountPlansProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(ref, item.status != WorkforcePlanStatus.onTrack),
      )
      .toList();
});

final filteredPositionRequestsProvider = Provider<List<PositionRequest>>((ref) {
  return ref
      .watch(positionRequestsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(
              ref,
              item.status == PositionRequestStatus.awaitingApproval ||
                  item.status == PositionRequestStatus.blocked ||
                  item.status == PositionRequestStatus.draft,
            ),
      )
      .toList();
});

final filteredCapacityRisksProvider = Provider<List<CapacityRisk>>((ref) {
  return ref
      .watch(capacityRisksProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(ref, item.riskLevel != CapacityRiskLevel.low),
      )
      .toList();
});

final filteredWorkforceScenariosProvider = Provider<List<WorkforceScenario>>((
  ref,
) {
  return ref
      .watch(workforceScenariosProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(
              ref,
              item.confidence == ScenarioConfidence.low ||
                  item.impactScore >= 80,
            ),
      )
      .toList();
});

final workforcePlanningRiskSummaryProvider =
    Provider<WorkforcePlanningRiskSummary>((ref) {
      return WorkforcePlanningRiskSummary.fromData(
        plans: ref.watch(filteredHeadcountPlansProvider),
        positions: ref.watch(filteredPositionRequestsProvider),
        risks: ref.watch(filteredCapacityRisksProvider),
        scenarios: ref.watch(filteredWorkforceScenariosProvider),
        asOfDate: ref.watch(workforcePlanningAsOfDateProvider),
      );
    });

final workforcePlanningSummaryProvider = Provider<WorkforcePlanningSummary>((
  ref,
) {
  final plans = ref.watch(filteredHeadcountPlansProvider);
  final positions = ref.watch(filteredPositionRequestsProvider);
  final risks = ref.watch(filteredCapacityRisksProvider);

  return WorkforcePlanningSummary(
    totalPlanned: plans.fold(0, (sum, item) => sum + item.planned),
    totalActual: plans.fold(0, (sum, item) => sum + item.actual),
    forecastGap: plans.fold(0, (sum, item) => sum + item.forecastGap),
    openPositions: positions.fold(
      0,
      (sum, item) => sum + item.remainingHeadcount,
    ),
    pendingApprovals:
        positions
            .where(
              (item) => item.status == PositionRequestStatus.awaitingApproval,
            )
            .length,
    highRisks:
        risks.where((item) => item.riskLevel == CapacityRiskLevel.high).length,
    budgetAtRisk: plans
        .where(
          (item) =>
              item.status == WorkforcePlanStatus.gap ||
              item.status == WorkforcePlanStatus.overPlan,
        )
        .fold(0, (sum, item) => sum + item.budget),
  );
});

bool _matchesDepartment(Ref ref, String department) {
  final selectedDepartment = ref.watch(workforcePlanningDepartmentProvider);
  return selectedDepartment == workforcePlanningAllDepartments ||
      department == selectedDepartment;
}

bool _matchesAttention(Ref ref, bool needsAttention) {
  return !ref.watch(workforcePlanningAttentionOnlyProvider) || needsAttention;
}
