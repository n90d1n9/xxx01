enum FinancialCloseItemStatus { ready, review, blocked }

extension FinancialCloseItemStatusLabel on FinancialCloseItemStatus {
  String get label {
    switch (this) {
      case FinancialCloseItemStatus.ready:
        return 'Ready';
      case FinancialCloseItemStatus.review:
        return 'Review';
      case FinancialCloseItemStatus.blocked:
        return 'Blocked';
    }
  }
}

class FinancialCloseChecklistItem {
  final String id;
  final String title;
  final String description;
  final FinancialCloseItemStatus status;
  final String reference;
  final String? amountLabel;

  const FinancialCloseChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.reference,
    this.amountLabel,
  });

  bool get isReady => status == FinancialCloseItemStatus.ready;
}

class FinancialCloseChecklist {
  final String periodLabel;
  final DateTime generatedAt;
  final double totalDebit;
  final double totalCredit;
  final double trialBalanceVariance;
  final List<FinancialCloseChecklistItem> items;

  const FinancialCloseChecklist({
    required this.periodLabel,
    required this.generatedAt,
    required this.totalDebit,
    required this.totalCredit,
    required this.trialBalanceVariance,
    required this.items,
  });

  bool get hasBlockers {
    return items.any((item) => item.status == FinancialCloseItemStatus.blocked);
  }

  int get readyCount {
    return items
        .where((item) => item.status == FinancialCloseItemStatus.ready)
        .length;
  }

  int get reviewCount {
    return items
        .where((item) => item.status == FinancialCloseItemStatus.review)
        .length;
  }

  int get blockedCount {
    return items
        .where((item) => item.status == FinancialCloseItemStatus.blocked)
        .length;
  }

  double get readinessRatio {
    if (items.isEmpty) {
      return 0;
    }
    return readyCount / items.length;
  }
}
