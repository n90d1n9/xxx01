import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_focus_service.dart';
import 'package:kaysir/features/project_management/project/services/project_portfolio_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_priority_service.dart';
import 'package:kaysir/features/project_management/project/services/project_saved_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_view_service.dart';

void main() {
  test('project portfolio view preferences serialize board filters', () {
    const preferences = ProjectPortfolioViewPreferences(
      query: 'mobile',
      healthFilter: ProjectHealth.blocked,
      domainReadinessFilter: ProjectDomainReadinessFilter.needsContext,
      domainGapFocus: ProjectDomainGapFocus.missingRequired,
      sortOption: ProjectPortfolioSortOption.budget,
      viewPreset: ProjectPortfolioViewPreset.budgetPressure,
      tableColumnProfile: ProjectTableColumnProfile.financial,
    );

    expect(
      ProjectPortfolioViewPreferences.fromJson(preferences.toJson()),
      preferences,
    );
  });

  test('project portfolio view preferences tolerate stale snapshots', () {
    final preferences = ProjectPortfolioViewPreferences.fromJson({
      'query': 42,
      'healthFilter': 'gone',
      'domainReadinessFilter': 'retired',
      'sortOption': 'removed',
      'viewPreset': 'legacy',
    });

    expect(preferences, ProjectPortfolioViewPreferences.initial);
  });

  test('project portfolio readiness filter matches adaptive domain status', () {
    final project = ProjectPortfolioItem(
      id: 'field-app',
      name: 'Field App',
      owner: 'Nadia Putri',
      client: 'Service Team',
      businessDomain: 'Software Development',
      startDate: DateTime(2026, 6),
      endDate: DateTime(2026, 8),
      progress: 0.4,
      budgetUsed: 0.3,
      health: ProjectHealth.atRisk,
      milestones: const [],
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'api-contract',
          label: 'API Contract',
          type: ProjectCustomAttributeType.boolean,
          value: 'No',
        ),
      ],
    );

    expect(
      projectMatchesDomainReadinessFilter(
        project,
        ProjectDomainReadinessFilter.needsContext,
      ),
      isTrue,
    );
    expect(
      projectMatchesDomainReadinessFilter(
        project,
        ProjectDomainReadinessFilter.ready,
      ),
      isFalse,
    );
  });
}
