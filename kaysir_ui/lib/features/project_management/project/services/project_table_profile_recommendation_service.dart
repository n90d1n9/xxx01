import 'project_portfolio_view_service.dart';
import 'project_priority_service.dart';
import 'project_saved_view_service.dart';
import 'project_table_view_service.dart';

ProjectTableColumnProfile recommendedProjectTableColumnProfile({
  required ProjectPortfolioViewPreset viewPreset,
  required ProjectDomainReadinessFilter domainReadinessFilter,
  required ProjectPortfolioSortOption sortOption,
}) {
  if (domainReadinessFilter != ProjectDomainReadinessFilter.all ||
      viewPreset == ProjectPortfolioViewPreset.domainGaps ||
      sortOption == ProjectPortfolioSortOption.domainContext) {
    return ProjectTableColumnProfile.domainContext;
  }

  if (viewPreset == ProjectPortfolioViewPreset.budgetPressure ||
      sortOption == ProjectPortfolioSortOption.budget) {
    return ProjectTableColumnProfile.financial;
  }

  if (viewPreset == ProjectPortfolioViewPreset.dueSoon ||
      viewPreset == ProjectPortfolioViewPreset.needsAttention ||
      viewPreset == ProjectPortfolioViewPreset.blocked ||
      sortOption == ProjectPortfolioSortOption.dueDate) {
    return ProjectTableColumnProfile.delivery;
  }

  return ProjectTableColumnProfile.operations;
}
