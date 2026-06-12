import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_empty_guidance.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_query.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_sort.dart';

void main() {
  test('workspace empty guidance describes a search miss inside a filter', () {
    final guidance = DashboardWorkspaceEmptyGuidance.fromQuery(
      const DashboardWorkspaceQuery(
        filter: DashboardWorkspaceFilter.critical,
        searchText: 'payroll',
      ),
    );

    expect(guidance.title, 'No match in Critical');
    expect(
      guidance.message,
      'The search term does not match the selected workspace scope.',
    );
    expect(guidance.options.map((option) => option.action), [
      DashboardWorkspaceRecoveryAction.clearSearch,
      DashboardWorkspaceRecoveryAction.clearFilter,
      DashboardWorkspaceRecoveryAction.reset,
    ]);
  });

  test('workspace empty guidance recommends clearing risk-focused sort', () {
    final guidance = DashboardWorkspaceEmptyGuidance.fromQuery(
      const DashboardWorkspaceQuery(
        filter: DashboardWorkspaceFilter.timeSensitive,
        sort: DashboardWorkspaceSort.risk,
      ),
    );

    expect(guidance.title, 'No risk workspaces in scope');
    expect(
      guidance.message,
      'There are no workspaces currently matching this risk lens.',
    );
    expect(guidance.options.map((option) => option.label), [
      'Clear filter',
      'Clear sort',
      'Reset discovery',
    ]);
  });
}
