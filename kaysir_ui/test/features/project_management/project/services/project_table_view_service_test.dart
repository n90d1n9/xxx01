import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_portfolio_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_priority_service.dart';
import 'package:kaysir/features/project_management/project/services/project_saved_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_profile_recommendation_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_view_service.dart';

void main() {
  test('project table profiles expose reusable column sets', () {
    expect(
      ProjectTableColumnProfile.operations.columns,
      containsAll(ProjectTableColumn.values),
    );
    expect(
      ProjectTableColumnProfile.delivery.columns,
      containsAll([
        ProjectTableColumn.progress,
        ProjectTableColumn.openMilestones,
        ProjectTableColumn.timeline,
      ]),
    );
    expect(
      ProjectTableColumnProfile.delivery.columns,
      isNot(contains(ProjectTableColumn.budget)),
    );
    expect(
      ProjectTableColumnProfile.financial.columns,
      containsAll([ProjectTableColumn.progress, ProjectTableColumn.budget]),
    );
    expect(
      ProjectTableColumnProfile.domainContext.columns,
      contains(ProjectTableColumn.extensions),
    );
    expect(
      ProjectTableColumnProfile.domainContext.columns,
      isNot(contains(ProjectTableColumn.budget)),
    );
  });

  test('project table profile labels are presentation ready', () {
    expect(ProjectTableColumnProfile.operations.label, 'Operations');
    expect(ProjectTableColumnProfile.delivery.label, 'Delivery');
    expect(ProjectTableColumnProfile.financial.label, 'Financial');
    expect(ProjectTableColumnProfile.domainContext.label, 'Domain Context');
    expect(ProjectTableColumn.budget.label, 'Budget');
  });

  test('recommends profiles from portfolio view context', () {
    expect(
      recommendedProjectTableColumnProfile(
        viewPreset: ProjectPortfolioViewPreset.all,
        domainReadinessFilter: ProjectDomainReadinessFilter.all,
        sortOption: ProjectPortfolioSortOption.attention,
      ),
      ProjectTableColumnProfile.operations,
    );
    expect(
      recommendedProjectTableColumnProfile(
        viewPreset: ProjectPortfolioViewPreset.budgetPressure,
        domainReadinessFilter: ProjectDomainReadinessFilter.all,
        sortOption: ProjectPortfolioSortOption.budget,
      ),
      ProjectTableColumnProfile.financial,
    );
    expect(
      recommendedProjectTableColumnProfile(
        viewPreset: ProjectPortfolioViewPreset.domainGaps,
        domainReadinessFilter: ProjectDomainReadinessFilter.all,
        sortOption: ProjectPortfolioSortOption.domainContext,
      ),
      ProjectTableColumnProfile.domainContext,
    );
    expect(
      recommendedProjectTableColumnProfile(
        viewPreset: ProjectPortfolioViewPreset.all,
        domainReadinessFilter: ProjectDomainReadinessFilter.needsContext,
        sortOption: ProjectPortfolioSortOption.attention,
      ),
      ProjectTableColumnProfile.domainContext,
    );
    expect(
      recommendedProjectTableColumnProfile(
        viewPreset: ProjectPortfolioViewPreset.dueSoon,
        domainReadinessFilter: ProjectDomainReadinessFilter.all,
        sortOption: ProjectPortfolioSortOption.dueDate,
      ),
      ProjectTableColumnProfile.delivery,
    );
  });
}
