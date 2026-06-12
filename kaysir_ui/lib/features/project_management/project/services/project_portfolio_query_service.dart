import '../models/project_portfolio_item.dart';
import 'project_domain_gap_focus_service.dart';
import 'project_portfolio_view_service.dart';
import 'project_priority_service.dart';
import 'project_saved_view_service.dart';

class ProjectPortfolioQuery {
  const ProjectPortfolioQuery({
    this.searchQuery = '',
    this.healthFilter,
    this.domainReadinessFilter = ProjectDomainReadinessFilter.all,
    this.domainGapFocus = ProjectDomainGapFocus.all,
    this.sortOption = ProjectPortfolioSortOption.attention,
    this.viewPreset = ProjectPortfolioViewPreset.all,
    this.today,
    this.dueSoonDays = 30,
  });

  factory ProjectPortfolioQuery.fromPreferences(
    ProjectPortfolioViewPreferences preferences, {
    DateTime? today,
    int dueSoonDays = 30,
  }) {
    return ProjectPortfolioQuery(
      searchQuery: preferences.query,
      healthFilter: preferences.healthFilter,
      domainReadinessFilter: preferences.domainReadinessFilter,
      domainGapFocus: preferences.domainGapFocus,
      sortOption: preferences.sortOption,
      viewPreset: preferences.viewPreset,
      today: today,
      dueSoonDays: dueSoonDays,
    );
  }

  final String searchQuery;
  final ProjectHealth? healthFilter;
  final ProjectDomainReadinessFilter domainReadinessFilter;
  final ProjectDomainGapFocus domainGapFocus;
  final ProjectPortfolioSortOption sortOption;
  final ProjectPortfolioViewPreset viewPreset;
  final DateTime? today;
  final int dueSoonDays;

  String get normalizedSearchQuery => searchQuery.trim().toLowerCase();
}

List<ProjectPortfolioItem> queryProjectPortfolio({
  required Iterable<ProjectPortfolioItem> projects,
  required ProjectPortfolioQuery query,
}) {
  final normalizedSearchQuery = query.normalizedSearchQuery;
  final filteredProjects = projects.where(
    (project) => projectMatchesPortfolioQuery(
      project,
      query,
      normalizedSearchQuery: normalizedSearchQuery,
    ),
  );

  return sortProjectPortfolio(filteredProjects, query.sortOption);
}

bool projectMatchesPortfolioQuery(
  ProjectPortfolioItem project,
  ProjectPortfolioQuery query, {
  String? normalizedSearchQuery,
}) {
  final searchQuery = normalizedSearchQuery ?? query.normalizedSearchQuery;
  final matchesView = projectMatchesPortfolioView(
    project,
    query.viewPreset,
    today: query.today,
    dueSoonDays: query.dueSoonDays,
  );
  final matchesHealth =
      query.healthFilter == null || project.health == query.healthFilter;
  final matchesDomainReadiness = projectMatchesDomainReadinessFilter(
    project,
    query.domainReadinessFilter,
  );
  final matchesDomainGapFocus = projectMatchesDomainGapFocus(
    project,
    query.domainGapFocus,
  );

  return matchesView &&
      matchesHealth &&
      matchesDomainReadiness &&
      matchesDomainGapFocus &&
      projectMatchesPortfolioSearch(project, searchQuery);
}

bool projectMatchesPortfolioSearch(
  ProjectPortfolioItem project,
  String normalizedSearchQuery,
) {
  final query = normalizedSearchQuery.trim().toLowerCase();
  if (query.isEmpty) return true;

  return project.name.toLowerCase().contains(query) ||
      project.client.toLowerCase().contains(query) ||
      project.owner.toLowerCase().contains(query) ||
      project.sponsor.toLowerCase().contains(query) ||
      project.businessDomain.toLowerCase().contains(query) ||
      project.customAttributes.any(
        (attribute) =>
            attribute.label.toLowerCase().contains(query) ||
            attribute.value.toLowerCase().contains(query),
      );
}
