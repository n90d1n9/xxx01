import 'dashboard_workspace_entry.dart';
import 'dashboard_workspace_filter.dart';
import 'dashboard_workspace_sort.dart';

class DashboardWorkspaceQuery {
  final DashboardWorkspaceFilter filter;
  final DashboardWorkspaceSort sort;
  final String searchText;

  const DashboardWorkspaceQuery({
    this.filter = DashboardWorkspaceFilter.all,
    this.sort = DashboardWorkspaceSort.recommended,
    this.searchText = '',
  });

  String get normalizedSearchText => searchText.trim().toLowerCase();

  bool get hasSearch => normalizedSearchText.isNotEmpty;

  bool get hasActiveFilter => filter != DashboardWorkspaceFilter.all;

  bool get hasActiveSort => sort != DashboardWorkspaceSort.recommended;

  bool get hasActiveDiscovery => hasSearch || hasActiveFilter || hasActiveSort;

  bool get isRiskFocused {
    return filter == DashboardWorkspaceFilter.attention ||
        filter == DashboardWorkspaceFilter.timeSensitive ||
        filter == DashboardWorkspaceFilter.critical ||
        filter == DashboardWorkspaceFilter.elevated ||
        sort == DashboardWorkspaceSort.risk;
  }

  List<DashboardWorkspaceEntry> applyTo(
    Iterable<DashboardWorkspaceEntry> entries,
  ) {
    return sort.applyTo(
      entries.where(
        (entry) =>
            filter.includesEntry(entry) && entry.matchesSearch(searchText),
      ),
    );
  }

  DashboardWorkspaceQuery copyWith({
    DashboardWorkspaceFilter? filter,
    DashboardWorkspaceSort? sort,
    String? searchText,
  }) {
    return DashboardWorkspaceQuery(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      searchText: searchText ?? this.searchText,
    );
  }

  DashboardWorkspaceQuery resetDiscovery() {
    return const DashboardWorkspaceQuery();
  }

  DashboardWorkspaceQuery clearSearch() {
    return copyWith(searchText: '');
  }

  DashboardWorkspaceQuery clearFilter() {
    return copyWith(filter: DashboardWorkspaceFilter.all);
  }

  DashboardWorkspaceQuery clearSort() {
    return copyWith(sort: DashboardWorkspaceSort.recommended);
  }

  DashboardWorkspaceQuery focusAttention() {
    return copyWith(
      filter: DashboardWorkspaceFilter.attention,
      sort: DashboardWorkspaceSort.risk,
      searchText: '',
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DashboardWorkspaceQuery &&
            other.filter == filter &&
            other.sort == sort &&
            other.searchText == searchText;
  }

  @override
  int get hashCode => Object.hash(filter, sort, searchText);
}
