class LedgerFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? account;
  final String? category;
  final String? searchTerm;

  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        (account != null && account!.isNotEmpty) ||
        (category != null && category!.isNotEmpty) ||
        (searchTerm != null && searchTerm!.isNotEmpty);
  }

  const LedgerFilter({
    this.startDate,
    this.endDate,
    this.account,
    this.category,
    this.searchTerm,
  });

  LedgerFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? account,
    String? category,
    String? searchTerm,
  }) {
    return LedgerFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      account: account ?? this.account,
      category: category ?? this.category,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}
