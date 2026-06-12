import 'ledger_trx.dart';

/// User-selected criteria for narrowing General Ledger transactions.
class LedgerFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? account;
  final String? category;
  final String? searchTerm;
  final TransactionType? type;

  static const Object _unset = Object();

  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        (account != null && account!.isNotEmpty) ||
        (category != null && category!.isNotEmpty) ||
        (searchTerm != null && searchTerm!.isNotEmpty) ||
        type != null;
  }

  const LedgerFilter({
    this.startDate,
    this.endDate,
    this.account,
    this.category,
    this.searchTerm,
    this.type,
  });

  LedgerFilter copyWith({
    Object? startDate = _unset,
    Object? endDate = _unset,
    Object? account = _unset,
    Object? category = _unset,
    Object? searchTerm = _unset,
    Object? type = _unset,
  }) {
    return LedgerFilter(
      startDate:
          identical(startDate, _unset)
              ? this.startDate
              : startDate as DateTime?,
      endDate: identical(endDate, _unset) ? this.endDate : endDate as DateTime?,
      account: identical(account, _unset) ? this.account : account as String?,
      category:
          identical(category, _unset) ? this.category : category as String?,
      searchTerm:
          identical(searchTerm, _unset)
              ? this.searchTerm
              : searchTerm as String?,
      type: identical(type, _unset) ? this.type : type as TransactionType?,
    );
  }
}
