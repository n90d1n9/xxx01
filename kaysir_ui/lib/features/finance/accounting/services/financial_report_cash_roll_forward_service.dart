import '../models/financial_entry.dart';
import '../models/financial_report_mapping.dart';

class FinancialReportCashRollForwardSummary {
  final double openingCash;
  final double cashInflows;
  final double cashOutflows;
  final double reportedClosingCash;
  final int openingLineCount;
  final int periodLineCount;
  final int closingLineCount;
  final int cashAccountCount;

  const FinancialReportCashRollForwardSummary({
    required this.openingCash,
    required this.cashInflows,
    required this.cashOutflows,
    required this.reportedClosingCash,
    required this.openingLineCount,
    required this.periodLineCount,
    required this.closingLineCount,
    required this.cashAccountCount,
  });

  double get netCashMovement {
    return cashInflows - cashOutflows;
  }

  double get calculatedClosingCash {
    return openingCash + netCashMovement;
  }

  double get rollForwardVariance {
    return reportedClosingCash - calculatedClosingCash;
  }

  bool get hasCashEvidence {
    return openingCash.abs() >= 0.01 ||
        reportedClosingCash.abs() >= 0.01 ||
        periodLineCount > 0 ||
        openingLineCount > 0 ||
        closingLineCount > 0;
  }
}

class FinancialReportCashRollForwardService {
  const FinancialReportCashRollForwardService();

  FinancialReportCashRollForwardSummary summarize({
    required Iterable<FinancialEntry> allEntries,
    required Iterable<FinancialEntry> periodEntries,
    required Iterable<FinancialEntry> positionEntries,
    required FinancialReportLineMapper lineMapper,
    required DateTime? periodStart,
  }) {
    final openingEntries =
        periodStart == null
            ? const <FinancialEntry>[]
            : allEntries
                .where((entry) => entry.date.isBefore(periodStart))
                .where((entry) => _isCashEquivalent(entry, lineMapper))
                .toList();
    final periodCashEntries =
        periodEntries
            .where((entry) => _isCashEquivalent(entry, lineMapper))
            .toList();
    final closingEntries =
        positionEntries
            .where((entry) => _isCashEquivalent(entry, lineMapper))
            .toList();

    return FinancialReportCashRollForwardSummary(
      openingCash: _sum(openingEntries),
      cashInflows: _sum(periodCashEntries.where((entry) => entry.amount > 0)),
      cashOutflows: -_sum(periodCashEntries.where((entry) => entry.amount < 0)),
      reportedClosingCash: _sum(closingEntries),
      openingLineCount: openingEntries.length,
      periodLineCount: periodCashEntries.length,
      closingLineCount: closingEntries.length,
      cashAccountCount: _cashAccountCount(closingEntries),
    );
  }

  bool isCashEquivalent(
    FinancialEntry entry,
    FinancialReportLineMapper lineMapper,
  ) {
    return _isCashEquivalent(entry, lineMapper);
  }

  bool _isCashEquivalent(
    FinancialEntry entry,
    FinancialReportLineMapper lineMapper,
  ) {
    return entry.type == 'asset' &&
        lineMapper.lineLabelFor(entry) == 'Cash and cash equivalents';
  }

  int _cashAccountCount(Iterable<FinancialEntry> entries) {
    return entries
        .map(_accountKey)
        .where((key) => key.isNotEmpty)
        .toSet()
        .length;
  }

  String _accountKey(FinancialEntry entry) {
    final category = entry.category.trim();
    if (category.isNotEmpty) {
      return category;
    }
    return entry.name.trim();
  }

  double _sum(Iterable<FinancialEntry> entries) {
    return entries.fold(0.0, (sum, entry) => sum + entry.amount);
  }
}
