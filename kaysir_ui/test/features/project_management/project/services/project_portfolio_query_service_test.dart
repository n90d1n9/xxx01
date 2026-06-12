import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_focus_service.dart';
import 'package:kaysir/features/project_management/project/services/project_portfolio_query_service.dart';
import 'package:kaysir/features/project_management/project/services/project_portfolio_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_priority_service.dart';
import 'package:kaysir/features/project_management/project/services/project_saved_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_view_service.dart';

void main() {
  test('portfolio query searches text and custom attribute values', () {
    final results = queryProjectPortfolio(
      projects: demoProjectPortfolio,
      query: const ProjectPortfolioQuery(
        searchQuery: 'controller',
        sortOption: ProjectPortfolioSortOption.name,
      ),
    );

    expect(results.map((project) => project.id), ['finance-close-suite']);
    expect(
      projectMatchesPortfolioSearch(demoProjectPortfolio.last, 'controller'),
      isTrue,
    );
  });

  test('portfolio query combines saved view and domain gap focus filters', () {
    final results = queryProjectPortfolio(
      projects: demoProjectPortfolio,
      query: const ProjectPortfolioQuery(
        viewPreset: ProjectPortfolioViewPreset.domainGaps,
        domainGapFocus: ProjectDomainGapFocus.missingRequired,
        sortOption: ProjectPortfolioSortOption.name,
      ),
    );

    expect(results.map((project) => project.id), [
      'finance-close-suite',
      'mobile-field-app',
      'warehouse-automation',
    ]);
  });

  test('portfolio query can focus any domain field gap', () {
    final results = queryProjectPortfolio(
      projects: demoProjectPortfolio,
      query: const ProjectPortfolioQuery(
        domainGapFocus: ProjectDomainGapFocus.missingAny,
        sortOption: ProjectPortfolioSortOption.name,
      ),
    );

    expect(results.map((project) => project.id), [
      'finance-close-suite',
      'mobile-field-app',
      'retail-modernization',
      'warehouse-automation',
    ]);
  });

  test('portfolio query can be built from persisted preferences', () {
    const preferences = ProjectPortfolioViewPreferences(
      query: 'ops',
      healthFilter: ProjectHealth.atRisk,
      domainReadinessFilter: ProjectDomainReadinessFilter.needsContext,
      domainGapFocus: ProjectDomainGapFocus.missingRequired,
      sortOption: ProjectPortfolioSortOption.name,
      viewPreset: ProjectPortfolioViewPreset.all,
      tableColumnProfile: ProjectTableColumnProfile.domainContext,
    );
    final query = ProjectPortfolioQuery.fromPreferences(
      preferences,
      today: DateTime(2026, 6, 3),
    );

    final results = queryProjectPortfolio(
      projects: demoProjectPortfolio,
      query: query,
    );

    expect(query.today, DateTime(2026, 6, 3));
    expect(results.map((project) => project.id), ['warehouse-automation']);
  });

  test('portfolio query applies deterministic due-soon dates', () {
    final results = queryProjectPortfolio(
      projects: demoProjectPortfolio,
      query: ProjectPortfolioQuery(
        viewPreset: ProjectPortfolioViewPreset.dueSoon,
        sortOption: ProjectPortfolioSortOption.dueDate,
        today: DateTime(2026, 6, 23),
        dueSoonDays: 10,
      ),
    );

    expect(results.map((project) => project.id), ['warehouse-automation']);
  });
}
