import 'dashboard_workspace_filter.dart';
import 'dashboard_workspace_query.dart';
import 'dashboard_workspace_sort.dart';

class DashboardWorkspaceDiscoveryScope {
  final int visibleCount;
  final int totalCount;
  final String modeLabel;
  final String detailLabel;
  final bool isRiskFocused;

  const DashboardWorkspaceDiscoveryScope({
    required this.visibleCount,
    required this.totalCount,
    required this.modeLabel,
    required this.detailLabel,
    required this.isRiskFocused,
  });

  factory DashboardWorkspaceDiscoveryScope.fromQuery({
    required DashboardWorkspaceQuery query,
    required int visibleCount,
    required int totalCount,
  }) {
    final activeLabels = _activeLabels(query);

    return DashboardWorkspaceDiscoveryScope(
      visibleCount: visibleCount,
      totalCount: totalCount,
      modeLabel: _modeLabel(query),
      detailLabel: _detailLabel(
        visibleCount: visibleCount,
        totalCount: totalCount,
        activeLabels: activeLabels,
      ),
      isRiskFocused: query.isRiskFocused,
    );
  }

  double get coverage {
    if (totalCount == 0) return 0;
    return (visibleCount / totalCount).clamp(0, 1).toDouble();
  }
}

String _modeLabel(DashboardWorkspaceQuery query) {
  if (!query.hasActiveDiscovery) return 'All workspaces';
  if (query.isRiskFocused) return 'Risk focus';
  if (query.hasSearch) return 'Search results';
  if (query.hasActiveFilter) return '${query.filter.nameLabel} view';
  return '${query.sort.label} order';
}

String _detailLabel({
  required int visibleCount,
  required int totalCount,
  required List<String> activeLabels,
}) {
  final scopeLabel =
      totalCount == 0
          ? 'No workspaces available'
          : '$visibleCount of $totalCount in scope';
  if (activeLabels.isEmpty) return scopeLabel;
  return '$scopeLabel - ${activeLabels.join(', ')}';
}

List<String> _activeLabels(DashboardWorkspaceQuery query) {
  return [
    if (query.hasSearch) 'Search "${query.searchText.trim()}"',
    if (query.hasActiveFilter) query.filter.nameLabel,
    if (query.hasActiveSort) query.sort.label,
  ];
}
