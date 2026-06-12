import 'package:flutter/material.dart';

import '../models/project_custom_attribute.dart';
import '../models/project_portfolio_item.dart';
import 'project_table_custom_column_service.dart';

enum ProjectDomainGapFocus {
  all,
  missingAny,
  missingRequired,
  missingRecommended,
  missingRiskSignals,
}

extension ProjectDomainGapFocusPresentation on ProjectDomainGapFocus {
  String get label {
    return switch (this) {
      ProjectDomainGapFocus.all => 'All Projects',
      ProjectDomainGapFocus.missingAny => 'Any Field Gaps',
      ProjectDomainGapFocus.missingRequired => 'Required Gaps',
      ProjectDomainGapFocus.missingRecommended => 'Recommended Gaps',
      ProjectDomainGapFocus.missingRiskSignals => 'Risk Signal Gaps',
    };
  }

  IconData get icon {
    return switch (this) {
      ProjectDomainGapFocus.all => Icons.view_list_outlined,
      ProjectDomainGapFocus.missingAny => Icons.rule_folder_outlined,
      ProjectDomainGapFocus.missingRequired => Icons.priority_high_rounded,
      ProjectDomainGapFocus.missingRecommended => Icons.fact_check_outlined,
      ProjectDomainGapFocus.missingRiskSignals => Icons.sensors_outlined,
    };
  }
}

bool projectMatchesDomainGapFocus(
  ProjectPortfolioItem project,
  ProjectDomainGapFocus focus,
) {
  if (focus == ProjectDomainGapFocus.all) return true;

  final columns = buildProjectTableCustomColumns(
    projects: [project],
    maxColumns: projectCustomAttributeLimit,
  );

  return switch (focus) {
    ProjectDomainGapFocus.all => true,
    ProjectDomainGapFocus.missingAny => columns.any(
      (column) => column.missingProjectIds.contains(project.id),
    ),
    ProjectDomainGapFocus.missingRequired => columns.any(
      (column) => column.missingRequiredProjectIds.contains(project.id),
    ),
    ProjectDomainGapFocus.missingRecommended => columns.any(
      (column) => column.missingRecommendedProjectIds.contains(project.id),
    ),
    ProjectDomainGapFocus.missingRiskSignals => columns.any(
      (column) => column.missingRiskSignalProjectIds.contains(project.id),
    ),
  };
}
