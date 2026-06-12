import 'payroll_archive_models.dart';
import 'payroll_journal_models.dart';
import 'payroll_liability_models.dart';
import 'payroll_register_report_models.dart';

enum PayrollStatutoryFilingStatus {
  blocked('Blocked'),
  ready('Ready'),
  exported('Exported');

  final String label;

  const PayrollStatutoryFilingStatus(this.label);
}

enum PayrollStatutoryFilingType {
  taxWithholding('Tax withholding'),
  retirement('Retirement'),
  healthBenefit('Health benefit'),
  payrollRegister('Payroll register');

  final String label;

  const PayrollStatutoryFilingType(this.label);
}

class PayrollStatutoryFilingLine {
  final String id;
  final PayrollStatutoryFilingType type;
  final String title;
  final String recipient;
  final String referenceCode;
  final DateTime dueDate;
  final double amount;
  final bool isExported;
  final List<String> blockers;

  const PayrollStatutoryFilingLine({
    required this.id,
    required this.type,
    required this.title,
    required this.recipient,
    required this.referenceCode,
    required this.dueDate,
    required this.amount,
    required this.isExported,
    required this.blockers,
  });

  PayrollStatutoryFilingStatus get status {
    if (blockers.isNotEmpty) return PayrollStatutoryFilingStatus.blocked;
    if (isExported) return PayrollStatutoryFilingStatus.exported;
    return PayrollStatutoryFilingStatus.ready;
  }

  bool get canExport => status == PayrollStatutoryFilingStatus.ready;

  String get nextAction {
    if (blockers.isNotEmpty) return blockers.first;
    if (isExported) return '$title filing is exported.';
    return 'Export $title filing package.';
  }
}

class PayrollStatutoryReportSummary {
  final String packId;
  final String periodLabel;
  final DateTime payDate;
  final List<PayrollStatutoryFilingLine> lines;

  const PayrollStatutoryReportSummary({
    required this.packId,
    required this.periodLabel,
    required this.payDate,
    required this.lines,
  });

  factory PayrollStatutoryReportSummary.fromRun({
    required PayrollLiabilitySummary liabilities,
    required PayrollRegisterReportSummary registerReport,
    required PayrollJournalPostingSummary journalPosting,
    required PayrollArchivePackageSummary archivePackage,
    required Set<String> exportedFilingIds,
  }) {
    final sharedBlockers = [
      if (journalPosting.status != PayrollJournalPostingStatus.posted)
        'Payroll journal is not posted',
      if (registerReport.status != PayrollRegisterReportStatus.exported)
        'Payroll register report is not exported',
      if (!archivePackage.isArchived) 'Payroll archive package is not retained',
    ];

    final liabilityLines = liabilities.lines.map((line) {
      final filingId =
          'SF-${liabilities.payDate.year}'
          '${liabilities.payDate.month.toString().padLeft(2, '0')}-'
          '${line.id}';
      return PayrollStatutoryFilingLine(
        id: filingId,
        type: _filingTypeForLiability(line.type),
        title: line.label,
        recipient: line.recipientName,
        referenceCode: line.referenceCode,
        dueDate: line.dueDate,
        amount: line.amount,
        isExported: exportedFilingIds.contains(filingId),
        blockers: [
          if (!line.isRemitted) '${line.label} remittance is not complete',
          ...sharedBlockers,
        ],
      );
    });

    final registerFilingId =
        'SF-${registerReport.payDate.year}'
        '${registerReport.payDate.month.toString().padLeft(2, '0')}-register';
    final registerLine = PayrollStatutoryFilingLine(
      id: registerFilingId,
      type: PayrollStatutoryFilingType.payrollRegister,
      title: 'Employee payroll register',
      recipient: 'Payroll statutory archive',
      referenceCode: registerReport.reportId,
      dueDate: registerReport.payDate.add(const Duration(days: 7)),
      amount: registerReport.totalNet,
      isExported: exportedFilingIds.contains(registerFilingId),
      blockers: [
        ...registerReport.blockers,
        if (registerReport.status != PayrollRegisterReportStatus.exported)
          'Payroll register report is not exported',
        if (!archivePackage.isArchived)
          'Payroll archive package is not retained',
      ],
    );

    return PayrollStatutoryReportSummary(
      packId: registerReport.reportId.replaceFirst('REG-', 'STAT-'),
      periodLabel: registerReport.periodLabel,
      payDate: registerReport.payDate,
      lines: [...liabilityLines, registerLine],
    );
  }

  int get readyCount => lines.where((line) => line.canExport).length;

  int get exportedCount =>
      lines
          .where((line) => line.status == PayrollStatutoryFilingStatus.exported)
          .length;

  int get blockedCount =>
      lines
          .where((line) => line.status == PayrollStatutoryFilingStatus.blocked)
          .length;

  double get totalAmount => lines.fold(0, (total, line) => total + line.amount);

  bool get canExport => readyCount > 0 && blockedCount == 0;

  bool get isExported => exportedCount == lines.length;

  PayrollStatutoryFilingStatus get status {
    if (blockedCount > 0) return PayrollStatutoryFilingStatus.blocked;
    if (isExported) return PayrollStatutoryFilingStatus.exported;
    return PayrollStatutoryFilingStatus.ready;
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount statutory filing blockers.';
    }
    if (isExported) return 'Statutory reporting pack is exported.';
    return 'Export $readyCount statutory filing packages.';
  }
}

PayrollStatutoryFilingType _filingTypeForLiability(PayrollLiabilityType type) {
  return switch (type) {
    PayrollLiabilityType.federalIncomeTax ||
    PayrollLiabilityType.stateIncomeTax ||
    PayrollLiabilityType.socialSecurity ||
    PayrollLiabilityType.medicare => PayrollStatutoryFilingType.taxWithholding,
    PayrollLiabilityType.retirement401k =>
      PayrollStatutoryFilingType.retirement,
    PayrollLiabilityType.healthInsurance =>
      PayrollStatutoryFilingType.healthBenefit,
  };
}
