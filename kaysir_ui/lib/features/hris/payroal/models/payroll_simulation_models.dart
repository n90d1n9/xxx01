import 'payroll_attendance_bridge_models.dart';
import 'payroll_deduction_authorization_models.dart';
import 'payroll_detail.dart';
import 'payroll_input_change_models.dart';
import 'payroll_loan_repayment_models.dart';

enum PayrollSimulationStatus {
  blocked('Blocked'),
  draft('Draft'),
  reviewed('Reviewed'),
  applied('Applied');

  final String label;

  const PayrollSimulationStatus(this.label);
}

class PayrollSimulationImpactLine {
  final String label;
  final String detail;
  final double amount;
  final bool isBlocking;

  const PayrollSimulationImpactLine({
    required this.label,
    required this.detail,
    required this.amount,
    required this.isBlocking,
  });
}

class PayrollSimulationSummary {
  final PayrollSummary baseSummary;
  final PayrollInputChangeSummary inputChanges;
  final PayrollAttendanceBridgeSummary attendanceBridge;
  final PayrollLoanRepaymentSummary loanRepayments;
  final PayrollDeductionAuthorizationSummary deductionAuthorizations;
  final bool isReviewed;
  final bool isApplied;

  const PayrollSimulationSummary({
    required this.baseSummary,
    required this.inputChanges,
    required this.attendanceBridge,
    required this.loanRepayments,
    required this.deductionAuthorizations,
    required this.isReviewed,
    required this.isApplied,
  });

  double get inputGrossImpact => inputChanges.lines
      .where((line) => !line.hasBlockers)
      .fold(0, (total, line) => total + line.payrollImpact);

  double get attendanceGrossImpact => attendanceBridge.lines
      .where((line) => !line.hasBlockers)
      .fold(0, (total, line) => total + line.amount);

  double get grossDelta => inputGrossImpact + attendanceGrossImpact;

  double get averageDeductionRate {
    if (baseSummary.totalGross == 0) return 0;
    return baseSummary.totalDeductions / baseSummary.totalGross;
  }

  double get estimatedTaxDelta => grossDelta * averageDeductionRate;

  double get loanRepaymentImpact => loanRepayments.lines
      .where((line) => !line.hasBlockers && !line.account.isPaused)
      .fold(0, (total, line) => total + line.repaymentAmount);

  double get netDelta => grossDelta - estimatedTaxDelta - loanRepaymentImpact;

  double get projectedGross => baseSummary.totalGross + grossDelta;

  double get projectedNet => baseSummary.totalNet + netDelta;

  int get blockerCount {
    return inputChanges.blockedCount +
        attendanceBridge.blockedCount +
        loanRepayments.blockedCount +
        deductionAuthorizations.blockedCount;
  }

  List<PayrollSimulationImpactLine> get impactLines {
    return [
      PayrollSimulationImpactLine(
        label: 'Input changes',
        detail:
            '${inputChanges.pendingCount + inputChanges.approvedCount + inputChanges.appliedCount} usable inputs',
        amount: inputGrossImpact,
        isBlocking: inputChanges.blockedCount > 0,
      ),
      PayrollSimulationImpactLine(
        label: 'Attendance bridge',
        detail:
            '${attendanceBridge.pendingCount + attendanceBridge.approvedCount + attendanceBridge.appliedCount} usable signals',
        amount: attendanceGrossImpact,
        isBlocking: attendanceBridge.blockedCount > 0,
      ),
      PayrollSimulationImpactLine(
        label: 'Loan repayments',
        detail:
            '${loanRepayments.readyCount + loanRepayments.appliedCount} deductible loans',
        amount: -loanRepaymentImpact,
        isBlocking: loanRepayments.blockedCount > 0,
      ),
      PayrollSimulationImpactLine(
        label: 'Deduction controls',
        detail:
            '${deductionAuthorizations.approvedCount}/${deductionAuthorizations.lines.length} authorizations approved',
        amount: 0,
        isBlocking: deductionAuthorizations.blockedCount > 0,
      ),
    ];
  }

  PayrollSimulationStatus get status {
    if (blockerCount > 0) return PayrollSimulationStatus.blocked;
    if (isApplied) return PayrollSimulationStatus.applied;
    if (isReviewed) return PayrollSimulationStatus.reviewed;
    return PayrollSimulationStatus.draft;
  }

  bool get canReview => status == PayrollSimulationStatus.draft;

  bool get canApply => status == PayrollSimulationStatus.reviewed;

  String get nextAction {
    if (blockerCount > 0) {
      return 'Resolve $blockerCount upstream simulation blockers.';
    }
    if (isApplied) return 'Payroll simulation is applied to the run preview.';
    if (isReviewed) return 'Apply reviewed simulation to the run preview.';
    return 'Review payroll simulation before applying the scenario.';
  }
}
