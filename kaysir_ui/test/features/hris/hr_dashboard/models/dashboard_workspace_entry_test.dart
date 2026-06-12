import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';

void main() {
  test('workspace entry search matches workspace metadata and metrics', () {
    const entry = DashboardWorkspaceEntry(
      workspace: HrisWorkspace(
        id: HrisWorkspaceId.peopleOps,
        title: 'People Operations',
        path: '/hris-people-ops',
        category: DashboardWorkspaceCategory.strategic,
        icon: Icons.hub_outlined,
        color: Colors.indigo,
      ),
      description: 'Workforce, onboarding, compliance, and pulse signals',
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.person_search_outlined,
          label: 'Hires',
          value: '3',
        ),
      ],
    );

    expect(entry.matchesSearch('people'), isTrue);
    expect(entry.matchesSearch('/hris-people-ops'), isTrue);
    expect(entry.matchesSearch('strategic'), isTrue);
    expect(entry.matchesSearch('hires'), isTrue);
    expect(entry.matchesSearch('3'), isTrue);
    expect(entry.matchesSearch('payroll'), isFalse);
  });
}
