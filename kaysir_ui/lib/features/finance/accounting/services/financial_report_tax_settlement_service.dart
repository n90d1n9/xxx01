import '../models/financial_entry.dart';
import '../models/financial_report_mapping.dart';

class FinancialReportTaxSettlementSummary {
  final double currentTaxExpense;
  final double taxCreditsAndPrepayments;
  final double recordedTaxPayable;
  final int taxCreditLineCount;
  final int taxPayableLineCount;

  const FinancialReportTaxSettlementSummary({
    required this.currentTaxExpense,
    required this.taxCreditsAndPrepayments,
    required this.recordedTaxPayable,
    required this.taxCreditLineCount,
    required this.taxPayableLineCount,
  });

  double get expectedTaxPayable {
    return currentTaxExpense - taxCreditsAndPrepayments;
  }

  double get settlementVariance {
    return recordedTaxPayable - expectedTaxPayable;
  }

  bool get hasSettlementEvidence {
    return taxCreditsAndPrepayments.abs() >= 0.01 ||
        recordedTaxPayable.abs() >= 0.01 ||
        taxCreditLineCount > 0 ||
        taxPayableLineCount > 0;
  }
}

class FinancialReportTaxSettlementService {
  const FinancialReportTaxSettlementService();

  FinancialReportTaxSettlementSummary summarize({
    required Iterable<FinancialEntry> periodEntries,
    required Iterable<FinancialEntry> positionEntries,
    required FinancialReportLineMapper lineMapper,
  }) {
    final currentTaxEntries =
        periodEntries
            .where((entry) => _isCurrentIncomeTaxEntry(entry, lineMapper))
            .toList();
    final creditEntries =
        positionEntries.where(_isIncomeTaxCreditOrPrepayment).toList();
    final payableEntries = positionEntries.where(_isIncomeTaxPayable).toList();

    return FinancialReportTaxSettlementSummary(
      currentTaxExpense: _sum(currentTaxEntries),
      taxCreditsAndPrepayments: _sum(creditEntries),
      recordedTaxPayable: _sum(payableEntries),
      taxCreditLineCount: creditEntries.length,
      taxPayableLineCount: payableEntries.length,
    );
  }

  bool _isCurrentIncomeTaxEntry(
    FinancialEntry entry,
    FinancialReportLineMapper lineMapper,
  ) {
    if (entry.type != 'expense' ||
        lineMapper.expenseGroupFor(entry) != FinancialReportExpenseGroup.tax) {
      return false;
    }
    final label = FinancialReportLineMapper.searchLabelFor(entry);
    return !label.contains('deferred') && !label.contains('tangguhan');
  }

  bool _isIncomeTaxCreditOrPrepayment(FinancialEntry entry) {
    if (entry.type != 'asset') {
      return false;
    }
    final label = FinancialReportLineMapper.searchLabelFor(entry);
    if (_isVatOnly(label)) {
      return false;
    }
    if (!_hasIncomeTaxCreditSignal(label)) {
      return false;
    }
    return label.contains('prepaid') ||
        label.contains('prepayment') ||
        label.contains('paid in advance') ||
        label.contains('tax credit') ||
        label.contains('withholding') ||
        label.contains('withheld') ||
        label.contains('dipotong') ||
        label.contains('potongan') ||
        label.contains('kredit pajak') ||
        label.contains('angsuran') ||
        label.contains('installment') ||
        label.contains('pph 22') ||
        label.contains('pph 23') ||
        label.contains('pph 25');
  }

  bool _isIncomeTaxPayable(FinancialEntry entry) {
    if (entry.type != 'liability') {
      return false;
    }
    final label = FinancialReportLineMapper.searchLabelFor(entry);
    if (_isVatOnly(label)) {
      return false;
    }
    return label.contains('income tax payable') ||
        label.contains('corporate tax payable') ||
        label.contains('tax payable') ||
        label.contains('pph 29') ||
        label.contains('pph badan') ||
        label.contains('pajak penghasilan badan') ||
        label.contains('utang pajak penghasilan') ||
        label.contains('hutang pajak penghasilan');
  }

  bool _hasIncomeTaxCreditSignal(String label) {
    return label.contains('income tax') ||
        label.contains('corporate tax') ||
        label.contains('pajak penghasilan') ||
        label.contains('pph') ||
        label.contains('tax credit') ||
        label.contains('kredit pajak');
  }

  bool _isVatOnly(String label) {
    final hasVatSignal = label.contains('vat') || label.contains('ppn');
    final hasIncomeTaxSignal =
        label.contains('income tax') ||
        label.contains('corporate tax') ||
        label.contains('pajak penghasilan') ||
        label.contains('pph');
    return hasVatSignal && !hasIncomeTaxSignal;
  }

  double _sum(Iterable<FinancialEntry> entries) {
    return entries.fold(0.0, (sum, entry) => sum + entry.amount);
  }
}
