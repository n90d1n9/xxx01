import 'payroll_cost_center_models.dart';

enum PayrollCostCenterBudgetStatus {
  onTrack('On track'),
  watch('Watch'),
  overBudget('Over budget');

  final String label;

  const PayrollCostCenterBudgetStatus(this.label);
}

class PayrollCostCenterBudgetPlan {
  final String costCenterId;
  final String owner;
  final double budget;
  final double reserve;

  const PayrollCostCenterBudgetPlan({
    required this.costCenterId,
    required this.owner,
    required this.budget,
    required this.reserve,
  });
}

class PayrollCostCenterBudgetEvidenceItem {
  final String id;
  final String title;
  final String owner;
  final bool isReady;

  const PayrollCostCenterBudgetEvidenceItem({
    required this.id,
    required this.title,
    required this.owner,
    required this.isReady,
  });
}

class PayrollCostCenterBudgetLine {
  final String id;
  final String label;
  final String owner;
  final int employeeCount;
  final double budget;
  final double reserve;
  final double grossPayroll;
  final int riskCount;
  final bool isApprovedForRelease;

  const PayrollCostCenterBudgetLine({
    required this.id,
    required this.label,
    required this.owner,
    required this.employeeCount,
    required this.budget,
    required this.reserve,
    required this.grossPayroll,
    required this.riskCount,
    required this.isApprovedForRelease,
  });

  double get utilization {
    if (budget == 0) return 0;
    return grossPayroll / budget;
  }

  double get remainingBudget => budget - grossPayroll;

  bool get isOverBudget => remainingBudget < 0;

  bool get needsBudgetEvidence =>
      isOverBudget || isInsideReserve || riskCount > 0;

  bool get needsReleaseApproval {
    return needsBudgetEvidence && !isApprovedForRelease;
  }

  bool get isInsideReserve {
    return remainingBudget >= 0 && remainingBudget <= reserve;
  }

  PayrollCostCenterBudgetStatus get status {
    if (isOverBudget) return PayrollCostCenterBudgetStatus.overBudget;
    if (isInsideReserve || riskCount > 0) {
      return PayrollCostCenterBudgetStatus.watch;
    }
    return PayrollCostCenterBudgetStatus.onTrack;
  }

  List<PayrollCostCenterBudgetEvidenceItem> get evidenceItems {
    final items = <PayrollCostCenterBudgetEvidenceItem>[
      PayrollCostCenterBudgetEvidenceItem(
        id: '$id-register',
        title: 'Payroll register snapshot',
        owner: 'Payroll Ops',
        isReady: true,
      ),
    ];

    if (isOverBudget) {
      items.add(
        PayrollCostCenterBudgetEvidenceItem(
          id: '$id-variance',
          title: 'Budget variance rationale',
          owner: owner,
          isReady: isApprovedForRelease,
        ),
      );
    }
    if (isInsideReserve) {
      items.add(
        PayrollCostCenterBudgetEvidenceItem(
          id: '$id-reserve',
          title: 'Reserve usage confirmation',
          owner: owner,
          isReady: isApprovedForRelease,
        ),
      );
    }
    if (riskCount > 0) {
      items.add(
        PayrollCostCenterBudgetEvidenceItem(
          id: '$id-risk',
          title: 'Open payroll risk acknowledgement',
          owner: owner,
          isReady: isApprovedForRelease,
        ),
      );
    }
    return items;
  }

  int get readyEvidenceCount {
    return evidenceItems.where((item) => item.isReady).length;
  }

  int get requiredEvidenceCount => evidenceItems.length;

  double get evidenceCompletionRate {
    if (requiredEvidenceCount == 0) return 1;
    return readyEvidenceCount / requiredEvidenceCount;
  }
}

class PayrollCostCenterBudgetSummary {
  final String periodLabel;
  final List<PayrollCostCenterBudgetLine> lines;
  final String nextAction;

  const PayrollCostCenterBudgetSummary({
    required this.periodLabel,
    required this.lines,
    required this.nextAction,
  });

  factory PayrollCostCenterBudgetSummary.fromCostCenters({
    required PayrollCostCenterSummary costCenters,
    required List<PayrollCostCenterBudgetPlan> plans,
    required Set<String> approvedCostCenterIds,
  }) {
    final plansByCostCenterId = {
      for (final plan in plans) plan.costCenterId: plan,
    };

    final lines =
        costCenters.lines.map((line) {
            final plan = plansByCostCenterId[line.id];
            return PayrollCostCenterBudgetLine(
              id: line.id,
              label: line.label,
              owner: plan?.owner ?? 'Finance Partner',
              employeeCount: line.employeeCount,
              budget: plan?.budget ?? line.grossPayroll,
              reserve: plan?.reserve ?? 0,
              grossPayroll: line.grossPayroll,
              riskCount: line.riskCount,
              isApprovedForRelease: approvedCostCenterIds.contains(line.id),
            );
          }).toList()
          ..sort((left, right) {
            final status = right.status.index.compareTo(left.status.index);
            if (status != 0) return status;
            return right.utilization.compareTo(left.utilization);
          });

    final overBudget =
        lines
            .where((line) => line.isOverBudget && line.needsReleaseApproval)
            .toList();
    final watch =
        lines
            .where(
              (line) =>
                  line.status == PayrollCostCenterBudgetStatus.watch &&
                  line.needsReleaseApproval,
            )
            .toList();
    final nextAction =
        overBudget.isNotEmpty
            ? '${overBudget.first.label} needs budget approval before payroll release.'
            : watch.isNotEmpty
            ? '${watch.first.label} needs owner confirmation before release.'
            : 'All cost center budgets are ready for payroll release.';

    return PayrollCostCenterBudgetSummary(
      periodLabel: costCenters.periodLabel,
      lines: lines,
      nextAction: nextAction,
    );
  }

  int get overBudgetCount {
    return lines.where((line) => line.isOverBudget).length;
  }

  int get pendingApprovalCount {
    return lines.where((line) => line.needsReleaseApproval).length;
  }

  int get approvedReleaseCount {
    return lines.where((line) => line.isApprovedForRelease).length;
  }

  int get readyEvidenceCount {
    return lines.fold(0, (total, line) => total + line.readyEvidenceCount);
  }

  int get requiredEvidenceCount {
    return lines.fold(0, (total, line) => total + line.requiredEvidenceCount);
  }

  int get incompleteEvidenceCount => requiredEvidenceCount - readyEvidenceCount;

  double get evidenceCompletionRate {
    if (requiredEvidenceCount == 0) return 1;
    return readyEvidenceCount / requiredEvidenceCount;
  }

  int get watchCount {
    return lines
        .where((line) => line.status == PayrollCostCenterBudgetStatus.watch)
        .length;
  }

  double get totalBudget {
    return lines.fold(0, (total, line) => total + line.budget);
  }

  double get totalGrossPayroll {
    return lines.fold(0, (total, line) => total + line.grossPayroll);
  }

  double get totalRemainingBudget => totalBudget - totalGrossPayroll;
}
