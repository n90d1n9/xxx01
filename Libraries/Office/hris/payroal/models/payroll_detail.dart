import '../../employee/models/employee.dart';

class PayrollDetails {
  final double grossSalary;
  final double federalTax;
  final double stateTax;
  final double socialSecurity;
  final double medicare;
  final double retirement401k;
  final double healthInsurance;
  final double netSalary;

  PayrollDetails({
    required this.grossSalary,
    required this.federalTax,
    required this.stateTax,
    required this.socialSecurity,
    required this.medicare,
    required this.retirement401k,
    required this.healthInsurance,
    required this.netSalary,
  });

  factory PayrollDetails.fromSalary(double salary) {
    final federalTax = salary * 0.15;
    final stateTax = salary * 0.05;
    final socialSecurity = salary * 0.062;
    final medicare = salary * 0.0145;
    final retirement401k = salary * 0.05;
    final healthInsurance = 250.0;

    final netSalary =
        salary -
        federalTax -
        stateTax -
        socialSecurity -
        medicare -
        retirement401k -
        healthInsurance;

    return PayrollDetails(
      grossSalary: salary,
      federalTax: federalTax,
      stateTax: stateTax,
      socialSecurity: socialSecurity,
      medicare: medicare,
      retirement401k: retirement401k,
      healthInsurance: healthInsurance,
      netSalary: netSalary,
    );
  }

  double get totalDeductions => grossSalary - netSalary;
}

class PayrollSummary {
  final int employeeCount;
  final int paidCount;
  final int pendingCount;
  final double totalGross;
  final double totalDeductions;
  final double totalNet;

  const PayrollSummary({
    required this.employeeCount,
    required this.paidCount,
    required this.pendingCount,
    required this.totalGross,
    required this.totalDeductions,
    required this.totalNet,
  });

  factory PayrollSummary.fromEmployees({
    required List<Employee> employees,
    required Map<int, bool> paymentStatus,
  }) {
    double totalGross = 0;
    double totalDeductions = 0;
    double totalNet = 0;

    for (final employee in employees) {
      final details = PayrollDetails.fromSalary(employee.salary ?? 0);
      totalGross += details.grossSalary;
      totalDeductions += details.totalDeductions;
      totalNet += details.netSalary;
    }

    final paidCount =
        employees
            .where((employee) => paymentStatus[employee.id] ?? false)
            .length;

    return PayrollSummary(
      employeeCount: employees.length,
      paidCount: paidCount,
      pendingCount: employees.length - paidCount,
      totalGross: totalGross,
      totalDeductions: totalDeductions,
      totalNet: totalNet,
    );
  }

  double get completionRate {
    if (employeeCount == 0) return 0;
    return paidCount / employeeCount;
  }
}

class PayrollRiskSummary {
  final int pendingPayments;
  final int highDeductionEmployees;
  final double unpaidGross;
  final double unpaidNet;
  final double averageDeductionRate;

  const PayrollRiskSummary({
    required this.pendingPayments,
    required this.highDeductionEmployees,
    required this.unpaidGross,
    required this.unpaidNet,
    required this.averageDeductionRate,
  });

  int get totalRisks => pendingPayments + highDeductionEmployees;

  factory PayrollRiskSummary.fromEmployees({
    required List<Employee> employees,
    required Map<int, bool> paymentStatus,
  }) {
    double unpaidGross = 0;
    double unpaidNet = 0;
    double deductionRateTotal = 0;
    var pendingPayments = 0;
    var highDeductionEmployees = 0;

    for (final employee in employees) {
      final details = PayrollDetails.fromSalary(employee.salary ?? 0);
      final isPaid = paymentStatus[employee.id] ?? false;
      final deductionRate =
          details.grossSalary == 0
              ? 0
              : details.totalDeductions / details.grossSalary;

      deductionRateTotal += deductionRate;
      if (deductionRate >= 0.35) {
        highDeductionEmployees++;
      }
      if (!isPaid) {
        pendingPayments++;
        unpaidGross += details.grossSalary;
        unpaidNet += details.netSalary;
      }
    }

    return PayrollRiskSummary(
      pendingPayments: pendingPayments,
      highDeductionEmployees: highDeductionEmployees,
      unpaidGross: unpaidGross,
      unpaidNet: unpaidNet,
      averageDeductionRate:
          employees.isEmpty ? 0 : deductionRateTotal / employees.length,
    );
  }
}
