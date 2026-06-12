/// Primary account class used for normal balance and report grouping.
enum AccountingAccountType { asset, liability, equity, revenue, expense }

/// Debit or credit orientation expected for an accounting account class.
enum NormalBalance { debit, credit }

/// Primary statement bucket used when mapping CoA lines into reports.
enum AccountingReportSection {
  assets,
  liabilities,
  equity,
  revenue,
  costOfSales,
  operatingExpenses,
  otherIncomeExpense,
  incomeTax,
}

/// Cash-flow classification used by statement-of-cash-flow mapping.
enum AccountingCashFlowCategory { none, operating, investing, financing }

/// Structured chart-of-accounts record used by posting and reporting flows.
class AccountingAccount {
  const AccountingAccount({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.parentId,
    this.isActive = true,
    this.allowPosting = true,
    this.reportSection,
    this.cashFlowCategory = AccountingCashFlowCategory.none,
    this.taxTag,
    this.currencyCode = 'IDR',
    this.entityId,
    this.branchId,
  });

  final String id;
  final String code;
  final String name;
  final AccountingAccountType type;
  final String? parentId;
  final bool isActive;
  final bool allowPosting;
  final AccountingReportSection? reportSection;
  final AccountingCashFlowCategory cashFlowCategory;
  final String? taxTag;
  final String currencyCode;
  final String? entityId;
  final String? branchId;

  AccountingReportSection get effectiveReportSection =>
      reportSection ?? type.defaultReportSection;

  NormalBalance get normalBalance {
    switch (type) {
      case AccountingAccountType.asset:
      case AccountingAccountType.expense:
        return NormalBalance.debit;
      case AccountingAccountType.liability:
      case AccountingAccountType.equity:
      case AccountingAccountType.revenue:
        return NormalBalance.credit;
    }
  }

  /// Returns a copy with updated CoA metadata.
  AccountingAccount copyWith({
    String? id,
    String? code,
    String? name,
    AccountingAccountType? type,
    String? parentId,
    bool? clearParentId,
    bool? isActive,
    bool? allowPosting,
    AccountingReportSection? reportSection,
    bool? clearReportSection,
    AccountingCashFlowCategory? cashFlowCategory,
    String? taxTag,
    bool? clearTaxTag,
    String? currencyCode,
    String? entityId,
    bool? clearEntityId,
    String? branchId,
    bool? clearBranchId,
  }) {
    return AccountingAccount(
      id: id ?? this.id,
      code: code?.trim() ?? this.code,
      name: name?.trim() ?? this.name,
      type: type ?? this.type,
      parentId: clearParentId == true ? null : parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
      allowPosting: allowPosting ?? this.allowPosting,
      reportSection:
          clearReportSection == true
              ? null
              : reportSection ?? this.reportSection,
      cashFlowCategory: cashFlowCategory ?? this.cashFlowCategory,
      taxTag: clearTaxTag == true ? null : _trimmed(taxTag) ?? this.taxTag,
      currencyCode: _trimmed(currencyCode)?.toUpperCase() ?? this.currencyCode,
      entityId:
          clearEntityId == true ? null : _trimmed(entityId) ?? this.entityId,
      branchId:
          clearBranchId == true ? null : _trimmed(branchId) ?? this.branchId,
    );
  }
}

/// Labels and defaults for [AccountingAccountType].
extension AccountingAccountTypeLabel on AccountingAccountType {
  String get label {
    switch (this) {
      case AccountingAccountType.asset:
        return 'Asset';
      case AccountingAccountType.liability:
        return 'Liability';
      case AccountingAccountType.equity:
        return 'Equity';
      case AccountingAccountType.revenue:
        return 'Revenue';
      case AccountingAccountType.expense:
        return 'Expense';
    }
  }

  AccountingReportSection get defaultReportSection {
    switch (this) {
      case AccountingAccountType.asset:
        return AccountingReportSection.assets;
      case AccountingAccountType.liability:
        return AccountingReportSection.liabilities;
      case AccountingAccountType.equity:
        return AccountingReportSection.equity;
      case AccountingAccountType.revenue:
        return AccountingReportSection.revenue;
      case AccountingAccountType.expense:
        return AccountingReportSection.operatingExpenses;
    }
  }
}

/// Display labels for normal balance values.
extension NormalBalanceLabel on NormalBalance {
  String get label {
    switch (this) {
      case NormalBalance.debit:
        return 'Debit';
      case NormalBalance.credit:
        return 'Credit';
    }
  }
}

/// Display labels for report mapping buckets.
extension AccountingReportSectionLabel on AccountingReportSection {
  String get label {
    switch (this) {
      case AccountingReportSection.assets:
        return 'Assets';
      case AccountingReportSection.liabilities:
        return 'Liabilities';
      case AccountingReportSection.equity:
        return 'Equity';
      case AccountingReportSection.revenue:
        return 'Revenue';
      case AccountingReportSection.costOfSales:
        return 'Cost of sales';
      case AccountingReportSection.operatingExpenses:
        return 'Operating expenses';
      case AccountingReportSection.otherIncomeExpense:
        return 'Other income/expense';
      case AccountingReportSection.incomeTax:
        return 'Income tax';
    }
  }
}

/// Display labels for cash-flow mapping buckets.
extension AccountingCashFlowCategoryLabel on AccountingCashFlowCategory {
  String get label {
    switch (this) {
      case AccountingCashFlowCategory.none:
        return 'Not mapped';
      case AccountingCashFlowCategory.operating:
        return 'Operating';
      case AccountingCashFlowCategory.investing:
        return 'Investing';
      case AccountingCashFlowCategory.financing:
        return 'Financing';
    }
  }
}

String? _trimmed(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  return trimmed;
}
