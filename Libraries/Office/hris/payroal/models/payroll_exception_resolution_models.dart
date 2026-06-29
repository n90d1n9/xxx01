import 'payroll_approval_workflow_models.dart';
import 'payroll_attendance_bridge_models.dart';
import 'payroll_exception_models.dart';
import 'payroll_gl_mapping_models.dart';
import 'payroll_input_change_models.dart';
import 'payroll_journal_models.dart';
import 'payroll_liability_models.dart';
import 'payroll_loan_repayment_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';

enum PayrollExceptionResolutionSource {
  inputChanges('Input changes'),
  attendance('Attendance'),
  loans('Loans'),
  glMapping('GL mapping'),
  approvals('Approvals'),
  payments('Payments'),
  payslips('Payslips'),
  liabilities('Liabilities'),
  journal('Journal');

  final String label;

  const PayrollExceptionResolutionSource(this.label);
}

enum PayrollExceptionResolutionStatus {
  blocked('Blocked'),
  clear('Clear');

  final String label;

  const PayrollExceptionResolutionStatus(this.label);
}

class PayrollExceptionResolutionLine {
  final String id;
  final PayrollExceptionResolutionSource source;
  final PayrollExceptionSeverity severity;
  final String title;
  final String owner;
  final String action;
  final double amount;

  const PayrollExceptionResolutionLine({
    required this.id,
    required this.source,
    required this.severity,
    required this.title,
    required this.owner,
    required this.action,
    required this.amount,
  });

  int get priority {
    return switch (severity) {
      PayrollExceptionSeverity.critical => 3,
      PayrollExceptionSeverity.warning => 2,
      PayrollExceptionSeverity.info => 1,
    };
  }
}

class PayrollExceptionResolutionSummary {
  final List<PayrollExceptionResolutionLine> lines;

  const PayrollExceptionResolutionSummary({required this.lines});

  factory PayrollExceptionResolutionSummary.fromRun({
    required PayrollInputChangeSummary inputChanges,
    required PayrollAttendanceBridgeSummary attendanceBridge,
    required PayrollLoanRepaymentSummary loanRepayments,
    required PayrollGlMappingSummary glMapping,
    required PayrollApprovalWorkflowSummary approvalWorkflow,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollPayslipPackageSummary payslipPackage,
    required PayrollLiabilitySummary liabilities,
    required PayrollJournalPostingSummary journalPosting,
  }) {
    final lines = <PayrollExceptionResolutionLine>[
      for (final line in inputChanges.lines.where((line) => line.hasBlockers))
        PayrollExceptionResolutionLine(
          id: 'input-${line.id}',
          source: PayrollExceptionResolutionSource.inputChanges,
          severity: PayrollExceptionSeverity.warning,
          title: '${line.employeeName} ${line.request.type.label}',
          owner: 'Payroll Operations',
          action: line.nextAction,
          amount: line.payrollImpact.abs(),
        ),
      for (final line in attendanceBridge.lines.where(
        (line) => line.hasBlockers,
      ))
        PayrollExceptionResolutionLine(
          id: 'attendance-${line.id}',
          source: PayrollExceptionResolutionSource.attendance,
          severity: PayrollExceptionSeverity.critical,
          title: '${line.employeeName} ${line.signal.type.label}',
          owner: 'Timekeeping',
          action: line.nextAction,
          amount: line.amount.abs(),
        ),
      for (final line in loanRepayments.lines.where((line) => line.hasBlockers))
        PayrollExceptionResolutionLine(
          id: 'loan-${line.id}',
          source: PayrollExceptionResolutionSource.loans,
          severity: PayrollExceptionSeverity.warning,
          title: '${line.employeeName} ${line.account.type.label}',
          owner: 'Finance Partner',
          action: line.nextAction,
          amount: line.repaymentAmount,
        ),
      for (final line in glMapping.lines.where((line) => !line.isMapped))
        PayrollExceptionResolutionLine(
          id: 'gl-${line.category.name}-${line.sourceLabel}',
          source: PayrollExceptionResolutionSource.glMapping,
          severity: PayrollExceptionSeverity.critical,
          title: line.sourceLabel,
          owner: 'Finance Systems',
          action: line.blocker,
          amount: line.amount,
        ),
      for (final stage in approvalWorkflow.stages.where(
        (stage) => stage.status == PayrollApprovalStageStatus.blocked,
      ))
        PayrollExceptionResolutionLine(
          id: 'approval-${stage.id}',
          source: PayrollExceptionResolutionSource.approvals,
          severity: PayrollExceptionSeverity.warning,
          title: stage.title,
          owner: stage.owner,
          action: stage.nextAction,
          amount: 0,
        ),
      for (final line in paymentBatch.lines.where((line) => line.hasBlockers))
        PayrollExceptionResolutionLine(
          id: 'payment-${line.employeeId}',
          source: PayrollExceptionResolutionSource.payments,
          severity: PayrollExceptionSeverity.critical,
          title: '${line.employeeName} payment',
          owner: 'Payroll Operations',
          action: line.blockers.first,
          amount: line.netAmount,
        ),
      for (final line in payslipPackage.lines.where((line) => line.hasBlockers))
        PayrollExceptionResolutionLine(
          id: 'payslip-${line.employeeId}',
          source: PayrollExceptionResolutionSource.payslips,
          severity: PayrollExceptionSeverity.warning,
          title: '${line.employeeName} payslip',
          owner: 'Payroll Operations',
          action: line.blockers.first,
          amount: line.netAmount,
        ),
      for (final line in liabilities.lines.where((line) => line.hasBlockers))
        PayrollExceptionResolutionLine(
          id: 'liability-${line.id}',
          source: PayrollExceptionResolutionSource.liabilities,
          severity: PayrollExceptionSeverity.warning,
          title: line.type.label,
          owner: 'Finance Partner',
          action: line.blockers.first,
          amount: line.amount,
        ),
      for (var index = 0; index < journalPosting.blockers.length; index++)
        PayrollExceptionResolutionLine(
          id: 'journal-$index',
          source: PayrollExceptionResolutionSource.journal,
          severity: PayrollExceptionSeverity.info,
          title: journalPosting.journalId,
          owner: 'Finance Systems',
          action: journalPosting.blockers[index],
          amount: journalPosting.balanceVariance,
        ),
    ];

    lines.sort((left, right) {
      final priority = right.priority.compareTo(left.priority);
      if (priority != 0) return priority;
      return right.amount.compareTo(left.amount);
    });

    return PayrollExceptionResolutionSummary(lines: lines);
  }

  int get criticalCount =>
      lines
          .where((line) => line.severity == PayrollExceptionSeverity.critical)
          .length;

  int get warningCount =>
      lines
          .where((line) => line.severity == PayrollExceptionSeverity.warning)
          .length;

  int get infoCount =>
      lines
          .where((line) => line.severity == PayrollExceptionSeverity.info)
          .length;

  double get financialExposure =>
      lines.fold(0, (total, line) => total + line.amount);

  PayrollExceptionResolutionStatus get status {
    if (lines.isNotEmpty) return PayrollExceptionResolutionStatus.blocked;
    return PayrollExceptionResolutionStatus.clear;
  }

  String get nextAction {
    if (lines.isEmpty) return 'No payroll exception blockers remain.';
    final topSource = lines.first.source.label;
    return 'Resolve ${lines.length} payroll blockers starting with $topSource.';
  }
}
