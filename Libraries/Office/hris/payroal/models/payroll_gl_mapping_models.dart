import 'payroll_attendance_bridge_models.dart';
import 'payroll_cost_center_models.dart';
import 'payroll_liability_models.dart';
import 'payroll_loan_repayment_models.dart';
import 'payroll_payment_batch_models.dart';

enum PayrollGlMappingCategory {
  grossPayroll('Gross payroll'),
  cashClearing('Cash clearing'),
  withholdingLiability('Withholding liability'),
  benefitLiability('Benefit liability'),
  loanRepayment('Loan repayment'),
  attendanceImpact('Attendance impact'),
  costCenter('Cost center');

  final String label;

  const PayrollGlMappingCategory(this.label);
}

enum PayrollGlMappingStatus {
  blocked('Blocked'),
  ready('Ready');

  final String label;

  const PayrollGlMappingStatus(this.label);
}

class PayrollGlAccountMapping {
  final PayrollGlMappingCategory category;
  final String sourceLabel;
  final String accountCode;
  final String accountName;
  final bool isRequired;

  const PayrollGlAccountMapping({
    required this.category,
    required this.sourceLabel,
    required this.accountCode,
    required this.accountName,
    required this.isRequired,
  });

  bool get hasAccount =>
      accountCode.trim().isNotEmpty && accountName.trim().isNotEmpty;
}

class PayrollGlMappingLine {
  final PayrollGlMappingCategory category;
  final String sourceLabel;
  final double amount;
  final PayrollGlAccountMapping? mapping;

  const PayrollGlMappingLine({
    required this.category,
    required this.sourceLabel,
    required this.amount,
    required this.mapping,
  });

  bool get isMapped => mapping?.hasAccount ?? false;

  String get accountLabel {
    final account = mapping;
    if (account == null || !account.hasAccount) return 'Unmapped';
    return '${account.accountCode} ${account.accountName}';
  }

  String get blocker {
    if (isMapped) return '';
    return 'Missing GL mapping for ${category.label.toLowerCase()}';
  }
}

class PayrollGlMappingSummary {
  final List<PayrollGlMappingLine> lines;

  const PayrollGlMappingSummary({required this.lines});

  factory PayrollGlMappingSummary.fromPayrollRun({
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollLiabilitySummary liabilities,
    required PayrollLoanRepaymentSummary loanRepayments,
    required PayrollAttendanceBridgeSummary attendanceBridge,
    required PayrollCostCenterSummary costCenters,
    required List<PayrollGlAccountMapping> mappings,
  }) {
    final mappingByKey = {
      for (final mapping in mappings)
        _mappingKey(mapping.category, mapping.sourceLabel): mapping,
    };

    PayrollGlAccountMapping? findMapping(
      PayrollGlMappingCategory category,
      String sourceLabel,
    ) {
      return mappingByKey[_mappingKey(category, sourceLabel)] ??
          mappingByKey[_mappingKey(category, '*')];
    }

    return PayrollGlMappingSummary(
      lines: [
        PayrollGlMappingLine(
          category: PayrollGlMappingCategory.grossPayroll,
          sourceLabel: 'Gross payroll',
          amount: paymentBatch.totalGross,
          mapping: findMapping(PayrollGlMappingCategory.grossPayroll, '*'),
        ),
        PayrollGlMappingLine(
          category: PayrollGlMappingCategory.cashClearing,
          sourceLabel: 'Payroll cash clearing',
          amount: paymentBatch.totalNet,
          mapping: findMapping(PayrollGlMappingCategory.cashClearing, '*'),
        ),
        PayrollGlMappingLine(
          category: PayrollGlMappingCategory.withholdingLiability,
          sourceLabel: 'Payroll withholdings',
          amount: paymentBatch.totalGross - paymentBatch.totalNet,
          mapping: findMapping(
            PayrollGlMappingCategory.withholdingLiability,
            '*',
          ),
        ),
        for (final liability in liabilities.lines)
          PayrollGlMappingLine(
            category: _liabilityCategory(liability),
            sourceLabel: liability.type.label,
            amount: liability.amount,
            mapping: findMapping(
              _liabilityCategory(liability),
              liability.type.label,
            ),
          ),
        if (loanRepayments.scheduledRepayment > 0)
          PayrollGlMappingLine(
            category: PayrollGlMappingCategory.loanRepayment,
            sourceLabel: 'Employee loan repayment',
            amount: loanRepayments.scheduledRepayment,
            mapping: findMapping(PayrollGlMappingCategory.loanRepayment, '*'),
          ),
        if (attendanceBridge.totalImpact != 0)
          PayrollGlMappingLine(
            category: PayrollGlMappingCategory.attendanceImpact,
            sourceLabel: 'Attendance payroll impact',
            amount: attendanceBridge.totalImpact.abs(),
            mapping: findMapping(
              PayrollGlMappingCategory.attendanceImpact,
              '*',
            ),
          ),
        for (final costCenter in costCenters.lines)
          PayrollGlMappingLine(
            category: PayrollGlMappingCategory.costCenter,
            sourceLabel: costCenter.label,
            amount: costCenter.grossPayroll,
            mapping: findMapping(
              PayrollGlMappingCategory.costCenter,
              costCenter.label,
            ),
          ),
      ],
    );
  }

  int get mappedCount => lines.where((line) => line.isMapped).length;

  int get unmappedCount => lines.length - mappedCount;

  double get mappedAmount => lines
      .where((line) => line.isMapped)
      .fold(0, (total, line) => total + line.amount);

  double get unmappedAmount => lines
      .where((line) => !line.isMapped)
      .fold(0, (total, line) => total + line.amount);

  double get readinessRate {
    if (lines.isEmpty) return 0;
    return mappedCount / lines.length;
  }

  PayrollGlMappingStatus get status {
    if (unmappedCount > 0) return PayrollGlMappingStatus.blocked;
    return PayrollGlMappingStatus.ready;
  }

  String get nextAction {
    if (unmappedCount > 0) {
      return 'Map $unmappedCount payroll GL categories before journal posting.';
    }
    return 'Payroll GL mappings are ready for finance posting.';
  }

  static String _mappingKey(
    PayrollGlMappingCategory category,
    String sourceLabel,
  ) {
    return '${category.name}:${sourceLabel.trim().toLowerCase()}';
  }

  static PayrollGlMappingCategory _liabilityCategory(
    PayrollLiabilityLine line,
  ) {
    return switch (line.type) {
      PayrollLiabilityType.healthInsurance ||
      PayrollLiabilityType
          .retirement401k => PayrollGlMappingCategory.benefitLiability,
      _ => PayrollGlMappingCategory.withholdingLiability,
    };
  }
}
