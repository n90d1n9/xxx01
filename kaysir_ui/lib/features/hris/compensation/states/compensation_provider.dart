import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/compensation_seed_data.dart';
import '../models/compensation_models.dart';

const compensationAllDepartments = 'All';

final compensationDepartmentProvider = StateProvider<String>(
  (ref) => compensationAllDepartments,
);
final compensationAttentionOnlyProvider = StateProvider<bool>((ref) => false);
final compensationAsOfDateProvider = Provider<DateTime>(
  (ref) => DateTime.now(),
);

final compensationReviewsProvider = Provider<List<CompensationReview>>((ref) {
  return buildCompensationReviews(ref.watch(compensationAsOfDateProvider));
});

final benefitEnrollmentsProvider = Provider<List<BenefitEnrollment>>((ref) {
  return buildBenefitEnrollments(ref.watch(compensationAsOfDateProvider));
});

final allowanceBudgetsProvider = Provider<List<AllowanceBudget>>((ref) {
  return compensationAllowanceBudgets;
});

final incentivePayoutsProvider = Provider<List<IncentivePayout>>((ref) {
  return buildIncentivePayouts(ref.watch(compensationAsOfDateProvider));
});

final compensationDepartmentsProvider = Provider<List<String>>((ref) {
  final departments =
      <String>{
            ...ref
                .watch(compensationReviewsProvider)
                .map((item) => item.department),
            ...ref
                .watch(benefitEnrollmentsProvider)
                .map((item) => item.department),
            ...ref
                .watch(allowanceBudgetsProvider)
                .map((item) => item.department),
            ...ref
                .watch(incentivePayoutsProvider)
                .map((item) => item.department),
          }
          .where((department) => department != compensationAllDepartments)
          .toList()
        ..sort();

  return [compensationAllDepartments, ...departments];
});

final filteredCompensationReviewsProvider = Provider<List<CompensationReview>>((
  ref,
) {
  return ref
      .watch(compensationReviewsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(
              ref,
              item.status == CompensationStatus.blocked ||
                  item.status == CompensationStatus.inReview,
            ),
      )
      .toList();
});

final filteredBenefitEnrollmentsProvider = Provider<List<BenefitEnrollment>>((
  ref,
) {
  return ref
      .watch(benefitEnrollmentsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(
              ref,
              item.status == BenefitEnrollmentStatus.issue ||
                  item.status == BenefitEnrollmentStatus.open,
            ),
      )
      .toList();
});

final filteredAllowanceBudgetsProvider = Provider<List<AllowanceBudget>>((ref) {
  return ref
      .watch(allowanceBudgetsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(
              ref,
              item.status != AllowanceBudgetStatus.healthy,
            ),
      )
      .toList();
});

final filteredIncentivePayoutsProvider = Provider<List<IncentivePayout>>((ref) {
  return ref
      .watch(incentivePayoutsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(
              ref,
              item.status == IncentiveStatus.draft ||
                  item.status == IncentiveStatus.pendingApproval,
            ),
      )
      .toList();
});

final compensationRiskSummaryProvider = Provider<CompensationRiskSummary>((
  ref,
) {
  return CompensationRiskSummary.fromData(
    reviews: ref.watch(filteredCompensationReviewsProvider),
    benefits: ref.watch(filteredBenefitEnrollmentsProvider),
    allowances: ref.watch(filteredAllowanceBudgetsProvider),
    incentives: ref.watch(filteredIncentivePayoutsProvider),
    asOfDate: ref.watch(compensationAsOfDateProvider),
  );
});

final compensationSummaryProvider = Provider<CompensationSummary>((ref) {
  final reviews = ref.watch(filteredCompensationReviewsProvider);
  final benefits = ref.watch(filteredBenefitEnrollmentsProvider);
  final allowances = ref.watch(filteredAllowanceBudgetsProvider);
  final incentives = ref.watch(filteredIncentivePayoutsProvider);

  return CompensationSummary(
    reviewItems:
        reviews
            .where((item) => item.status != CompensationStatus.approved)
            .length,
    pendingApprovals:
        reviews
            .where((item) => item.status == CompensationStatus.inReview)
            .length,
    benefitIssues:
        benefits
            .where((item) => item.status == BenefitEnrollmentStatus.issue)
            .length,
    allowanceWatch:
        allowances
            .where((item) => item.status != AllowanceBudgetStatus.healthy)
            .length,
    incentivePending:
        incentives.where((item) => item.status != IncentiveStatus.paid).length,
  );
});

bool _matchesDepartment(Ref ref, String department) {
  final selectedDepartment = ref.watch(compensationDepartmentProvider);
  return selectedDepartment == compensationAllDepartments ||
      department == selectedDepartment;
}

bool _matchesAttention(Ref ref, bool needsAttention) {
  return !ref.watch(compensationAttentionOnlyProvider) || needsAttention;
}
