import '../models/financial_entry.dart';
import '../models/financial_report_mapping.dart';

class FinancialReportVatSettlementSummary {
  final double outputVat;
  final double inputVat;
  final double recordedVatPayable;
  final double recordedVatRefund;
  final int outputVatLineCount;
  final int inputVatLineCount;
  final int settlementLineCount;

  const FinancialReportVatSettlementSummary({
    required this.outputVat,
    required this.inputVat,
    required this.recordedVatPayable,
    required this.recordedVatRefund,
    required this.outputVatLineCount,
    required this.inputVatLineCount,
    required this.settlementLineCount,
  });

  double get expectedNetVatPayable {
    return outputVat - inputVat;
  }

  double get recordedNetVatPosition {
    return recordedVatPayable - recordedVatRefund;
  }

  double get settlementVariance {
    if (!hasNetSettlementEvidence) {
      return 0;
    }
    return recordedNetVatPosition - expectedNetVatPayable;
  }

  bool get hasVatEvidence {
    return outputVat.abs() >= 0.01 ||
        inputVat.abs() >= 0.01 ||
        hasNetSettlementEvidence ||
        outputVatLineCount > 0 ||
        inputVatLineCount > 0;
  }

  bool get hasNetSettlementEvidence {
    return recordedVatPayable.abs() >= 0.01 ||
        recordedVatRefund.abs() >= 0.01 ||
        settlementLineCount > 0;
  }
}

class FinancialReportVatSettlementService {
  const FinancialReportVatSettlementService();

  FinancialReportVatSettlementSummary summarize({
    required Iterable<FinancialEntry> positionEntries,
  }) {
    final outputEntries = positionEntries.where(_isOutputVat).toList();
    final inputEntries = positionEntries.where(_isInputVat).toList();
    final payableEntries = positionEntries.where(_isNetVatPayable).toList();
    final refundEntries = positionEntries.where(_isNetVatRefund).toList();

    return FinancialReportVatSettlementSummary(
      outputVat: _sum(outputEntries),
      inputVat: _sum(inputEntries),
      recordedVatPayable: _sum(payableEntries),
      recordedVatRefund: _sum(refundEntries),
      outputVatLineCount: outputEntries.length,
      inputVatLineCount: inputEntries.length,
      settlementLineCount: payableEntries.length + refundEntries.length,
    );
  }

  bool _isOutputVat(FinancialEntry entry) {
    if (entry.type != 'liability') {
      return false;
    }
    final label = FinancialReportLineMapper.searchLabelFor(entry);
    return _hasVatSignal(label) &&
        (label.contains('output') ||
            label.contains('keluaran') ||
            label.contains('collected'));
  }

  bool _isInputVat(FinancialEntry entry) {
    if (entry.type != 'asset') {
      return false;
    }
    final label = FinancialReportLineMapper.searchLabelFor(entry);
    return _hasVatSignal(label) &&
        (label.contains('input') ||
            label.contains('masukan') ||
            label.contains('credit') ||
            label.contains('kredit'));
  }

  bool _isNetVatPayable(FinancialEntry entry) {
    if (entry.type != 'liability') {
      return false;
    }
    final label = FinancialReportLineMapper.searchLabelFor(entry);
    return _hasVatSignal(label) &&
        (label.contains('net') ||
            label.contains('settlement') ||
            label.contains('payable') ||
            label.contains('kurang bayar') ||
            label.contains('utang') ||
            label.contains('hutang')) &&
        !_isOutputVat(entry);
  }

  bool _isNetVatRefund(FinancialEntry entry) {
    if (entry.type != 'asset') {
      return false;
    }
    final label = FinancialReportLineMapper.searchLabelFor(entry);
    return _hasVatSignal(label) &&
        (label.contains('refund') ||
            label.contains('receivable') ||
            label.contains('lebih bayar')) &&
        !_isInputVat(entry);
  }

  bool _hasVatSignal(String label) {
    return label.contains('vat') || label.contains('ppn');
  }

  double _sum(Iterable<FinancialEntry> entries) {
    return entries.fold(0.0, (sum, entry) => sum + entry.amount);
  }
}
