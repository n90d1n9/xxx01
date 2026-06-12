import '../models/financial_entry.dart';
import '../models/financial_report_mapping.dart';

enum FinancialEquityMovementType {
  ownerContribution,
  ownerDistribution,
  otherComprehensiveIncome,
  retainedEarningsTransfer,
  otherReserveMovement,
}

class FinancialEquityMovementSummary {
  final double ownerContributions;
  final double ownerDistributions;
  final double otherComprehensiveIncome;
  final double retainedEarningsTransfers;
  final double otherReserveMovements;

  const FinancialEquityMovementSummary({
    required this.ownerContributions,
    required this.ownerDistributions,
    required this.otherComprehensiveIncome,
    required this.retainedEarningsTransfers,
    required this.otherReserveMovements,
  });

  double get netMovement {
    return ownerContributions -
        ownerDistributions +
        otherComprehensiveIncome +
        retainedEarningsTransfers +
        otherReserveMovements;
  }
}

class FinancialEquityMovementClassifier {
  const FinancialEquityMovementClassifier();

  FinancialEquityMovementSummary summarize(Iterable<FinancialEntry> entries) {
    var ownerContributions = 0.0;
    var ownerDistributions = 0.0;
    var otherComprehensiveIncome = 0.0;
    var retainedEarningsTransfers = 0.0;
    var otherReserveMovements = 0.0;

    for (final entry in entries.where((entry) => entry.type == 'equity')) {
      switch (classify(entry)) {
        case FinancialEquityMovementType.ownerContribution:
          ownerContributions += entry.amount;
        case FinancialEquityMovementType.ownerDistribution:
          ownerDistributions += entry.amount.abs();
        case FinancialEquityMovementType.otherComprehensiveIncome:
          otherComprehensiveIncome += entry.amount;
        case FinancialEquityMovementType.retainedEarningsTransfer:
          retainedEarningsTransfers += entry.amount;
        case FinancialEquityMovementType.otherReserveMovement:
          otherReserveMovements += entry.amount;
      }
    }

    return FinancialEquityMovementSummary(
      ownerContributions: ownerContributions,
      ownerDistributions: ownerDistributions,
      otherComprehensiveIncome: otherComprehensiveIncome,
      retainedEarningsTransfers: retainedEarningsTransfers,
      otherReserveMovements: otherReserveMovements,
    );
  }

  FinancialEquityMovementType classify(FinancialEntry entry) {
    final label = FinancialReportLineMapper.searchLabelFor(entry);
    final accountCode = FinancialReportLineMapper.accountCodeFor(entry);

    if (_containsAny(label, _ociKeywords)) {
      return FinancialEquityMovementType.otherComprehensiveIncome;
    }
    if (_containsAny(label, _distributionKeywords)) {
      return FinancialEquityMovementType.ownerDistribution;
    }
    if (_containsAny(label, _retainedEarningsKeywords)) {
      return FinancialEquityMovementType.retainedEarningsTransfer;
    }
    if (_containsAny(label, _capitalKeywords) || _isCapitalCode(accountCode)) {
      return entry.amount < 0
          ? FinancialEquityMovementType.ownerDistribution
          : FinancialEquityMovementType.ownerContribution;
    }
    return FinancialEquityMovementType.otherReserveMovement;
  }

  bool _isCapitalCode(String? accountCode) {
    if (accountCode == null) {
      return false;
    }
    return accountCode.startsWith('300') ||
        accountCode.startsWith('310') ||
        accountCode.startsWith('320');
  }

  bool _containsAny(String value, List<String> keywords) {
    return keywords.any(value.contains);
  }
}

const _capitalKeywords = [
  'owner capital',
  'share capital',
  'paid in capital',
  'paid-in capital',
  'contributed capital',
  'capital contribution',
  'modal disetor',
  'modal saham',
];

const _distributionKeywords = [
  'dividend',
  'distribution',
  'drawing',
  'drawings',
  'prive',
  'pribadi',
];

const _ociKeywords = [
  'oci',
  'other comprehensive income',
  'revaluation reserve',
  'fair value reserve',
  'cadangan revaluasi',
];

const _retainedEarningsKeywords = [
  'retained earnings',
  'saldo laba',
  'closing entry',
  'period close',
  'income summary',
  'ikhtisar laba rugi',
];
