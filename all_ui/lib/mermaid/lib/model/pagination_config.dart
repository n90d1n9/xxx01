import 'dart:math' as math;

/// Pagination configuration
class PaginationConfig {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final int totalItems;
  final bool showPageInfo;
  final bool showQuickJump;
  final bool showPageSizeSelector;
  final List<int> pageSizeOptions;

  const PaginationConfig({
    this.currentPage = 1,
    this.totalPages = 1,
    this.itemsPerPage = 50,
    this.totalItems = 0,
    this.showPageInfo = true,
    this.showQuickJump = true,
    this.showPageSizeSelector = true,
    this.pageSizeOptions = const [10, 25, 50, 100, 200],
  });

  int get startItem => (currentPage - 1) * itemsPerPage + 1;
  int get endItem => math.min(currentPage * itemsPerPage, totalItems);
  bool get hasNext => currentPage < totalPages;
  bool get hasPrevious => currentPage > 1;

  PaginationConfig copyWith({
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    int? totalItems,
  }) {
    return PaginationConfig(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      showPageInfo: showPageInfo,
      showQuickJump: showQuickJump,
      showPageSizeSelector: showPageSizeSelector,
      pageSizeOptions: pageSizeOptions,
    );
  }
}
