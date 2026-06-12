import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/performance_seed_data.dart';
import '../models/performance_models.dart';

const performanceAllDepartments = 'All';

final performanceDepartmentProvider = StateProvider<String>(
  (ref) => performanceAllDepartments,
);
final performanceAttentionOnlyProvider = StateProvider<bool>((ref) => false);
final performanceAsOfDateProvider = Provider<DateTime>((ref) => DateTime.now());

final goalProgressProvider = Provider<List<GoalProgress>>((ref) {
  return buildGoalProgress(ref.watch(performanceAsOfDateProvider));
});

final reviewCyclesProvider = Provider<List<ReviewCycle>>((ref) {
  return buildReviewCycles(ref.watch(performanceAsOfDateProvider));
});

final calibrationItemsProvider = Provider<List<CalibrationItem>>((ref) {
  return performanceCalibrationItems;
});

final successionCandidatesProvider = Provider<List<SuccessionCandidate>>((ref) {
  return performanceSuccessionCandidates;
});

final retentionRisksProvider = Provider<List<RetentionRisk>>((ref) {
  return buildRetentionRisks(ref.watch(performanceAsOfDateProvider));
});

final performanceDepartmentsProvider = Provider<List<String>>((ref) {
  final departments =
      <String>{
          ...ref.watch(goalProgressProvider).map((item) => item.department),
          ...ref.watch(reviewCyclesProvider).map((item) => item.department),
          ...ref.watch(calibrationItemsProvider).map((item) => item.department),
          ...ref
              .watch(successionCandidatesProvider)
              .map((item) => item.department),
          ...ref.watch(retentionRisksProvider).map((item) => item.department),
        }.toList()
        ..sort();

  return [performanceAllDepartments, ...departments];
});

final filteredGoalProgressProvider = Provider<List<GoalProgress>>((ref) {
  return ref
      .watch(goalProgressProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(ref, item.status == GoalStatus.atRisk),
      )
      .toList();
});

final filteredReviewCyclesProvider = Provider<List<ReviewCycle>>((ref) {
  return ref
      .watch(reviewCyclesProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(
              ref,
              item.status == ReviewStatus.overdue || item.pendingCount > 0,
            ),
      )
      .toList();
});

final filteredCalibrationItemsProvider = Provider<List<CalibrationItem>>((ref) {
  return ref
      .watch(calibrationItemsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(ref, item.status != CalibrationStatus.aligned),
      )
      .toList();
});

final filteredSuccessionCandidatesProvider =
    Provider<List<SuccessionCandidate>>((ref) {
      return ref
          .watch(successionCandidatesProvider)
          .where(
            (item) =>
                _matchesDepartment(ref, item.department) &&
                _matchesAttention(
                  ref,
                  item.readiness != SuccessionReadiness.readyNow,
                ),
          )
          .toList();
    });

final filteredRetentionRisksProvider = Provider<List<RetentionRisk>>((ref) {
  return ref
      .watch(retentionRisksProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(ref, item.level == RetentionRiskLevel.high),
      )
      .toList();
});

final performanceRiskSummaryProvider = Provider<PerformanceRiskSummary>((ref) {
  return PerformanceRiskSummary.fromData(
    goals: ref.watch(filteredGoalProgressProvider),
    reviews: ref.watch(filteredReviewCyclesProvider),
    calibration: ref.watch(filteredCalibrationItemsProvider),
    successors: ref.watch(filteredSuccessionCandidatesProvider),
    retention: ref.watch(filteredRetentionRisksProvider),
    asOfDate: ref.watch(performanceAsOfDateProvider),
  );
});

final performanceSummaryProvider = Provider<PerformanceSummary>((ref) {
  final goals = ref.watch(filteredGoalProgressProvider);
  final reviews = ref.watch(filteredReviewCyclesProvider);
  final calibration = ref.watch(filteredCalibrationItemsProvider);
  final successors = ref.watch(filteredSuccessionCandidatesProvider);
  final retention = ref.watch(filteredRetentionRisksProvider);

  return PerformanceSummary(
    activeGoals:
        goals.where((item) => item.status != GoalStatus.completed).length,
    reviewsDue: reviews.fold<int>(
      0,
      (total, review) => total + review.pendingCount,
    ),
    calibrationFlags:
        calibration
            .where((item) => item.status != CalibrationStatus.aligned)
            .length,
    successorsReady:
        successors
            .where((item) => item.readiness == SuccessionReadiness.readyNow)
            .length,
    highRetentionRisks:
        retention.where((item) => item.level == RetentionRiskLevel.high).length,
  );
});

bool _matchesDepartment(Ref ref, String department) {
  final selectedDepartment = ref.watch(performanceDepartmentProvider);
  return selectedDepartment == performanceAllDepartments ||
      department == selectedDepartment;
}

bool _matchesAttention(Ref ref, bool needsAttention) {
  return !ref.watch(performanceAttentionOnlyProvider) || needsAttention;
}
