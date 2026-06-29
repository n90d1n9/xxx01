import 'hr_metric.dart';
import 'hris_workspace.dart';

class DepartmentPerformancePoint {
  final String department;
  final double current;
  final double previous;

  const DepartmentPerformancePoint({
    required this.department,
    required this.current,
    required this.previous,
  });

  double get delta => current - previous;
}

class HiringTrendPoint {
  final String month;
  final double hires;

  const HiringTrendPoint({required this.month, required this.hires});
}

class DashboardInsightSummary {
  final int averageDepartmentPerformance;
  final String strongestDepartment;
  final String fastestImprovingDepartment;
  final int totalHires;
  final String peakHiringMonth;
  final int improvedMetricCount;

  const DashboardInsightSummary({
    required this.averageDepartmentPerformance,
    required this.strongestDepartment,
    required this.fastestImprovingDepartment,
    required this.totalHires,
    required this.peakHiringMonth,
    required this.improvedMetricCount,
  });

  factory DashboardInsightSummary.fromData({
    required List<HRMetric> metrics,
    required List<DepartmentPerformancePoint> departmentPerformance,
    required List<HiringTrendPoint> hiringTrends,
  }) {
    final averageDepartmentPerformance =
        departmentPerformance.isEmpty
            ? 0
            : (departmentPerformance
                        .map((point) => point.current)
                        .reduce((total, value) => total + value) /
                    departmentPerformance.length)
                .round();
    final strongestDepartment = departmentPerformance.fold(
      departmentPerformance.first,
      (best, point) => point.current > best.current ? point : best,
    );
    final fastestImprovingDepartment = departmentPerformance.fold(
      departmentPerformance.first,
      (best, point) => point.delta > best.delta ? point : best,
    );
    final totalHires = hiringTrends.fold<int>(
      0,
      (total, point) => total + point.hires.round(),
    );
    final peakHiringMonth = hiringTrends.fold(
      hiringTrends.first,
      (best, point) => point.hires > best.hires ? point : best,
    );

    return DashboardInsightSummary(
      averageDepartmentPerformance: averageDepartmentPerformance,
      strongestDepartment: strongestDepartment.department,
      fastestImprovingDepartment: fastestImprovingDepartment.department,
      totalHires: totalHires,
      peakHiringMonth: peakHiringMonth.month,
      improvedMetricCount: metrics.where((metric) => metric.isPositive).length,
    );
  }
}

enum DashboardRiskSeverity { stable, elevated, critical }

extension DashboardRiskSeverityLabel on DashboardRiskSeverity {
  String get label {
    switch (this) {
      case DashboardRiskSeverity.stable:
        return 'Stable';
      case DashboardRiskSeverity.elevated:
        return 'Elevated';
      case DashboardRiskSeverity.critical:
        return 'Critical';
    }
  }
}

class DashboardRiskItem {
  final HrisWorkspace workspace;
  final int totalRisks;
  final int timeSensitiveRisks;
  final String leadingSignal;

  const DashboardRiskItem({
    required this.workspace,
    required this.totalRisks,
    required this.timeSensitiveRisks,
    required this.leadingSignal,
  });

  String get label => workspace.title;

  String get route => workspace.path;

  DashboardRiskSeverity get severity {
    if (totalRisks >= 8 || timeSensitiveRisks >= 7) {
      return DashboardRiskSeverity.critical;
    }
    if (totalRisks >= 4 || timeSensitiveRisks >= 2) {
      return DashboardRiskSeverity.elevated;
    }
    return DashboardRiskSeverity.stable;
  }
}

class DashboardRiskRollup {
  final List<DashboardRiskItem> items;

  const DashboardRiskRollup({required this.items});

  List<DashboardRiskItem> get rankedItems {
    return [...items]..sort((a, b) {
      final riskCompare = b.totalRisks.compareTo(a.totalRisks);
      if (riskCompare != 0) return riskCompare;
      return b.timeSensitiveRisks.compareTo(a.timeSensitiveRisks);
    });
  }

  List<DashboardRiskItem> get topItems => rankedItems.take(3).toList();

  int countBySeverity(DashboardRiskSeverity severity) {
    return items.where((item) => item.severity == severity).length;
  }

  int get criticalWorkspaceCount {
    return countBySeverity(DashboardRiskSeverity.critical);
  }

  int get elevatedWorkspaceCount {
    return countBySeverity(DashboardRiskSeverity.elevated);
  }

  int get stableWorkspaceCount {
    return countBySeverity(DashboardRiskSeverity.stable);
  }

  int get workspaceCount => items.length;

  int get totalRisks {
    return items.fold<int>(0, (total, item) => total + item.totalRisks);
  }

  int get timeSensitiveRisks {
    return items.fold<int>(0, (total, item) => total + item.timeSensitiveRisks);
  }

  String get highestRiskWorkspace {
    final ranked = rankedItems;
    return ranked.isEmpty ? 'None' : ranked.first.label;
  }
}
