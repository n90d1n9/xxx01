import '../models/project_portfolio_item.dart';
import 'project_domain_gap_focus_service.dart';
import 'project_domain_extension_readiness_service.dart';
import 'project_priority_service.dart';
import 'project_saved_view_service.dart';
import 'project_table_view_service.dart';

enum ProjectDomainReadinessFilter { all, needsContext, inProgress, ready }

extension ProjectDomainReadinessFilterPresentation
    on ProjectDomainReadinessFilter {
  String get label {
    switch (this) {
      case ProjectDomainReadinessFilter.all:
        return 'All Domains';
      case ProjectDomainReadinessFilter.needsContext:
        return 'Needs Context';
      case ProjectDomainReadinessFilter.inProgress:
        return 'In Progress';
      case ProjectDomainReadinessFilter.ready:
        return 'Ready';
    }
  }
}

class ProjectPortfolioViewPreferences {
  const ProjectPortfolioViewPreferences({
    required this.query,
    required this.healthFilter,
    required this.domainReadinessFilter,
    required this.domainGapFocus,
    required this.sortOption,
    required this.viewPreset,
    required this.tableColumnProfile,
  });

  static const initial = ProjectPortfolioViewPreferences(
    query: '',
    healthFilter: null,
    domainReadinessFilter: ProjectDomainReadinessFilter.all,
    domainGapFocus: ProjectDomainGapFocus.all,
    sortOption: ProjectPortfolioSortOption.attention,
    viewPreset: ProjectPortfolioViewPreset.all,
    tableColumnProfile: ProjectTableColumnProfile.operations,
  );

  final String query;
  final ProjectHealth? healthFilter;
  final ProjectDomainReadinessFilter domainReadinessFilter;
  final ProjectDomainGapFocus domainGapFocus;
  final ProjectPortfolioSortOption sortOption;
  final ProjectPortfolioViewPreset viewPreset;
  final ProjectTableColumnProfile tableColumnProfile;

  ProjectPortfolioViewPreferences copyWith({
    String? query,
    Object? healthFilter = _unchanged,
    ProjectDomainReadinessFilter? domainReadinessFilter,
    ProjectDomainGapFocus? domainGapFocus,
    ProjectPortfolioSortOption? sortOption,
    ProjectPortfolioViewPreset? viewPreset,
    ProjectTableColumnProfile? tableColumnProfile,
  }) {
    return ProjectPortfolioViewPreferences(
      query: query ?? this.query,
      healthFilter:
          identical(healthFilter, _unchanged)
              ? this.healthFilter
              : healthFilter as ProjectHealth?,
      domainReadinessFilter:
          domainReadinessFilter ?? this.domainReadinessFilter,
      domainGapFocus: domainGapFocus ?? this.domainGapFocus,
      sortOption: sortOption ?? this.sortOption,
      viewPreset: viewPreset ?? this.viewPreset,
      tableColumnProfile: tableColumnProfile ?? this.tableColumnProfile,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'query': query,
      'healthFilter': healthFilter?.name,
      'domainReadinessFilter': domainReadinessFilter.name,
      'domainGapFocus': domainGapFocus.name,
      'sortOption': sortOption.name,
      'viewPreset': viewPreset.name,
      'tableColumnProfile': tableColumnProfile.name,
    };
  }

  factory ProjectPortfolioViewPreferences.fromJson(Map<String, Object?> json) {
    return ProjectPortfolioViewPreferences(
      query: json['query'] is String ? json['query'] as String : '',
      healthFilter: _enumFromName(
        ProjectHealth.values,
        json['healthFilter'],
        null,
      ),
      domainReadinessFilter:
          _enumFromName(
            ProjectDomainReadinessFilter.values,
            json['domainReadinessFilter'],
            ProjectDomainReadinessFilter.all,
          ) ??
          ProjectDomainReadinessFilter.all,
      domainGapFocus:
          _enumFromName(
            ProjectDomainGapFocus.values,
            json['domainGapFocus'],
            ProjectDomainGapFocus.all,
          ) ??
          ProjectDomainGapFocus.all,
      sortOption:
          _enumFromName(
            ProjectPortfolioSortOption.values,
            json['sortOption'],
            ProjectPortfolioSortOption.attention,
          ) ??
          ProjectPortfolioSortOption.attention,
      viewPreset:
          _enumFromName(
            ProjectPortfolioViewPreset.values,
            json['viewPreset'],
            ProjectPortfolioViewPreset.all,
          ) ??
          ProjectPortfolioViewPreset.all,
      tableColumnProfile:
          _enumFromName(
            ProjectTableColumnProfile.values,
            json['tableColumnProfile'],
            ProjectTableColumnProfile.operations,
          ) ??
          ProjectTableColumnProfile.operations,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectPortfolioViewPreferences &&
        other.query == query &&
        other.healthFilter == healthFilter &&
        other.domainReadinessFilter == domainReadinessFilter &&
        other.domainGapFocus == domainGapFocus &&
        other.sortOption == sortOption &&
        other.viewPreset == viewPreset &&
        other.tableColumnProfile == tableColumnProfile;
  }

  @override
  int get hashCode => Object.hash(
    query,
    healthFilter,
    domainReadinessFilter,
    domainGapFocus,
    sortOption,
    viewPreset,
    tableColumnProfile,
  );
}

const _unchanged = Object();

T? _enumFromName<T extends Enum>(
  Iterable<T> values,
  Object? name,
  T? fallback,
) {
  if (name is! String) return fallback;

  for (final value in values) {
    if (value.name == name) return value;
  }

  return fallback;
}

bool projectMatchesDomainReadinessFilter(
  ProjectPortfolioItem project,
  ProjectDomainReadinessFilter filter, {
  ProjectDomainExtensionReadinessService readinessService =
      const ProjectDomainExtensionReadinessService(),
}) {
  if (filter == ProjectDomainReadinessFilter.all) return true;

  final summary = readinessService.build(
    businessDomain: project.businessDomain,
    attributes: project.customAttributes,
  );

  switch (filter) {
    case ProjectDomainReadinessFilter.all:
      return true;
    case ProjectDomainReadinessFilter.needsContext:
      return summary.status ==
          ProjectDomainExtensionReadinessStatus.needsContext;
    case ProjectDomainReadinessFilter.inProgress:
      return summary.status == ProjectDomainExtensionReadinessStatus.inProgress;
    case ProjectDomainReadinessFilter.ready:
      return summary.status == ProjectDomainExtensionReadinessStatus.ready;
  }
}
