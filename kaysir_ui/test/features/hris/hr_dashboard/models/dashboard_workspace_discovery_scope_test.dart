import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_discovery_scope.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_query.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_sort.dart';

void main() {
  test('workspace discovery scope describes the default workspace set', () {
    final scope = DashboardWorkspaceDiscoveryScope.fromQuery(
      query: const DashboardWorkspaceQuery(),
      visibleCount: 12,
      totalCount: 12,
    );

    expect(scope.modeLabel, 'All workspaces');
    expect(scope.detailLabel, '12 of 12 in scope');
    expect(scope.coverage, 1);
    expect(scope.isRiskFocused, isFalse);
  });

  test('workspace discovery scope describes risk-focused discovery', () {
    final scope = DashboardWorkspaceDiscoveryScope.fromQuery(
      query: const DashboardWorkspaceQuery(
        filter: DashboardWorkspaceFilter.timeSensitive,
        sort: DashboardWorkspaceSort.risk,
      ),
      visibleCount: 2,
      totalCount: 7,
    );

    expect(scope.modeLabel, 'Risk focus');
    expect(
      scope.detailLabel,
      '2 of 7 in scope - Time-sensitive, Risk pressure',
    );
    expect(scope.coverage, closeTo(2 / 7, 0.001));
    expect(scope.isRiskFocused, isTrue);
  });
}
