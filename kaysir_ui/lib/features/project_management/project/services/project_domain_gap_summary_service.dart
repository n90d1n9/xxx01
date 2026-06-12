import 'project_domain_gap_focus_service.dart';
import 'project_table_custom_column_service.dart';

class ProjectDomainGapSummary {
  const ProjectDomainGapSummary({
    required this.columnCount,
    required this.applicableFieldCount,
    required this.filledFieldCount,
    required this.missingRequiredCount,
    required this.missingRecommendedCount,
    required this.missingRiskSignalCount,
  });

  factory ProjectDomainGapSummary.fromColumns(
    Iterable<ProjectTableCustomColumn> columns,
  ) {
    var columnCount = 0;
    var applicableFieldCount = 0;
    var filledFieldCount = 0;
    var missingRequiredCount = 0;
    var missingRecommendedCount = 0;
    var missingRiskSignalCount = 0;

    for (final column in columns) {
      columnCount += 1;
      applicableFieldCount += column.applicableProjectCount;
      filledFieldCount += column.filledProjectCount;
      missingRequiredCount += column.missingRequiredProjectCount;
      missingRecommendedCount += column.missingRecommendedProjectCount;
      missingRiskSignalCount += column.missingRiskSignalProjectCount;
    }

    return ProjectDomainGapSummary(
      columnCount: columnCount,
      applicableFieldCount: applicableFieldCount,
      filledFieldCount: filledFieldCount,
      missingRequiredCount: missingRequiredCount,
      missingRecommendedCount: missingRecommendedCount,
      missingRiskSignalCount: missingRiskSignalCount,
    );
  }

  final int columnCount;
  final int applicableFieldCount;
  final int filledFieldCount;
  final int missingRequiredCount;
  final int missingRecommendedCount;
  final int missingRiskSignalCount;

  bool get isComplete =>
      applicableFieldCount > 0 && filledFieldCount == applicableFieldCount;
  bool get hasGaps => missingFieldCount > 0;
  int get missingFieldCount => applicableFieldCount - filledFieldCount;
  int get coveragePercent =>
      applicableFieldCount == 0
          ? 0
          : (filledFieldCount / applicableFieldCount * 100).round();
  String get coverageLabel => '$filledFieldCount/$applicableFieldCount filled';

  int countFor(ProjectDomainGapFocus focus) {
    return switch (focus) {
      ProjectDomainGapFocus.all => columnCount,
      ProjectDomainGapFocus.missingAny => missingFieldCount,
      ProjectDomainGapFocus.missingRequired => missingRequiredCount,
      ProjectDomainGapFocus.missingRecommended => missingRecommendedCount,
      ProjectDomainGapFocus.missingRiskSignals => missingRiskSignalCount,
    };
  }
}

ProjectDomainGapSummary buildProjectDomainGapSummary({
  required Iterable<ProjectTableCustomColumn> columns,
}) {
  return ProjectDomainGapSummary.fromColumns(columns);
}
