enum CompensationStatus { draft, inReview, approved, blocked }

enum BenefitEnrollmentStatus { open, pending, enrolled, issue }

enum AllowanceBudgetStatus { healthy, watch, overBudget }

enum IncentiveStatus { draft, pendingApproval, approved, paid }

class CompensationReview {
  final String id;
  final String employeeName;
  final String department;
  final String role;
  final String managerName;
  final int currentSalary;
  final int proposedSalary;
  final int marketPercentile;
  final DateTime effectiveDate;
  final CompensationStatus status;

  const CompensationReview({
    required this.id,
    required this.employeeName,
    required this.department,
    required this.role,
    required this.managerName,
    required this.currentSalary,
    required this.proposedSalary,
    required this.marketPercentile,
    required this.effectiveDate,
    required this.status,
  });

  int get increaseAmount => proposedSalary - currentSalary;

  double get increaseRate {
    if (currentSalary == 0) return 0;
    return increaseAmount / currentSalary;
  }
}

class BenefitEnrollment {
  final String id;
  final String employeeName;
  final String department;
  final String planName;
  final String coverage;
  final DateTime deadline;
  final BenefitEnrollmentStatus status;

  const BenefitEnrollment({
    required this.id,
    required this.employeeName,
    required this.department,
    required this.planName,
    required this.coverage,
    required this.deadline,
    required this.status,
  });
}

class AllowanceBudget {
  final String id;
  final String department;
  final String allowanceType;
  final int budget;
  final int spent;
  final int forecast;
  final AllowanceBudgetStatus status;

  const AllowanceBudget({
    required this.id,
    required this.department,
    required this.allowanceType,
    required this.budget,
    required this.spent,
    required this.forecast,
    required this.status,
  });

  double get usedRate => budget == 0 ? 0 : spent / budget;

  int get remaining {
    final value = budget - spent;
    return value < 0 ? 0 : value;
  }
}

class IncentivePayout {
  final String id;
  final String employeeName;
  final String department;
  final String programName;
  final int targetAmount;
  final int approvedAmount;
  final DateTime payoutDate;
  final IncentiveStatus status;

  const IncentivePayout({
    required this.id,
    required this.employeeName,
    required this.department,
    required this.programName,
    required this.targetAmount,
    required this.approvedAmount,
    required this.payoutDate,
    required this.status,
  });

  double get approvalRate =>
      targetAmount == 0 ? 0 : approvedAmount / targetAmount;
}

class CompensationSummary {
  final int reviewItems;
  final int pendingApprovals;
  final int benefitIssues;
  final int allowanceWatch;
  final int incentivePending;

  const CompensationSummary({
    required this.reviewItems,
    required this.pendingApprovals,
    required this.benefitIssues,
    required this.allowanceWatch,
    required this.incentivePending,
  });
}

class CompensationRiskSummary {
  final int blockedReviews;
  final int lowMarketPercentileReviews;
  final int benefitIssues;
  final int budgetExceptions;
  final int pendingIncentiveApprovals;
  final int dueWithinFourteenDays;

  const CompensationRiskSummary({
    required this.blockedReviews,
    required this.lowMarketPercentileReviews,
    required this.benefitIssues,
    required this.budgetExceptions,
    required this.pendingIncentiveApprovals,
    required this.dueWithinFourteenDays,
  });

  int get totalRisks =>
      blockedReviews +
      lowMarketPercentileReviews +
      benefitIssues +
      budgetExceptions +
      pendingIncentiveApprovals;

  factory CompensationRiskSummary.fromData({
    required List<CompensationReview> reviews,
    required List<BenefitEnrollment> benefits,
    required List<AllowanceBudget> allowances,
    required List<IncentivePayout> incentives,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));

    return CompensationRiskSummary(
      blockedReviews:
          reviews
              .where((item) => item.status == CompensationStatus.blocked)
              .length,
      lowMarketPercentileReviews:
          reviews
              .where(
                (item) =>
                    item.status != CompensationStatus.approved &&
                    item.marketPercentile < 60,
              )
              .length,
      benefitIssues:
          benefits
              .where((item) => item.status == BenefitEnrollmentStatus.issue)
              .length,
      budgetExceptions:
          allowances
              .where((item) => item.status != AllowanceBudgetStatus.healthy)
              .length,
      pendingIncentiveApprovals:
          incentives
              .where(
                (item) =>
                    item.status == IncentiveStatus.draft ||
                    item.status == IncentiveStatus.pendingApproval,
              )
              .length,
      dueWithinFourteenDays:
          reviews
              .where(
                (item) =>
                    item.status != CompensationStatus.approved &&
                    !item.effectiveDate.isAfter(dueThreshold),
              )
              .length +
          benefits
              .where(
                (item) =>
                    item.status != BenefitEnrollmentStatus.enrolled &&
                    !item.deadline.isAfter(dueThreshold),
              )
              .length +
          incentives
              .where(
                (item) =>
                    item.status != IncentiveStatus.paid &&
                    !item.payoutDate.isAfter(dueThreshold),
              )
              .length,
    );
  }
}
