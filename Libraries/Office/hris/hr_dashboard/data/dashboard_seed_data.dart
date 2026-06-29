import 'package:flutter/material.dart';

import '../models/dashboard_analytics.dart';
import '../models/hr_metric.dart';
import '../models/report_type.dart';

List<HRMetric> buildHrMetrics(String selectedPeriod) {
  final isCurrentMonth = selectedPeriod == 'This Month';

  return [
    HRMetric(
      title: 'Turnover Rate',
      value: isCurrentMonth ? 5.2 : 4.8,
      previousValue: 6.3,
      unit: '%',
      color: Colors.orange,
      lowerIsBetter: true,
    ),
    HRMetric(
      title: 'Recruitment Efficiency',
      value: isCurrentMonth ? 82.5 : 79.0,
      previousValue: 75.8,
      unit: '%',
      color: Colors.blue,
    ),
    HRMetric(
      title: 'Employee Satisfaction',
      value: isCurrentMonth ? 4.2 : 4.0,
      previousValue: 3.9,
      unit: '/5',
      color: Colors.green,
    ),
    HRMetric(
      title: 'Avg. Time to Hire',
      value: isCurrentMonth ? 24 : 27,
      previousValue: 29,
      unit: ' days',
      color: Colors.purple,
      lowerIsBetter: true,
    ),
  ];
}

List<ReportType> buildReportTypes() {
  return const [
    ReportType(
      name: 'Turnover Report',
      description: 'Employee turnover rates by department and time period',
      icon: Icons.people_alt_outlined,
    ),
    ReportType(
      name: 'Recruitment Report',
      description: 'Time to hire and hiring funnel conversion rates',
      icon: Icons.person_search_outlined,
    ),
    ReportType(
      name: 'Performance Report',
      description: 'Team and individual performance metrics',
      icon: Icons.assessment_outlined,
    ),
    ReportType(
      name: 'Training Report',
      description: 'Training completion rates and effectiveness',
      icon: Icons.school_outlined,
    ),
  ];
}

const dashboardDepartmentPerformance = [
  DepartmentPerformancePoint(department: 'Sales', current: 92, previous: 86),
  DepartmentPerformancePoint(
    department: 'Marketing',
    current: 78,
    previous: 72,
  ),
  DepartmentPerformancePoint(
    department: 'Engineering',
    current: 85,
    previous: 82,
  ),
  DepartmentPerformancePoint(department: 'HR', current: 88, previous: 80),
  DepartmentPerformancePoint(department: 'Finance', current: 90, previous: 85),
];

const dashboardHiringTrends = [
  HiringTrendPoint(month: 'Jan', hires: 12),
  HiringTrendPoint(month: 'Feb', hires: 10),
  HiringTrendPoint(month: 'Mar', hires: 14),
  HiringTrendPoint(month: 'Apr', hires: 19),
  HiringTrendPoint(month: 'May', hires: 15),
  HiringTrendPoint(month: 'Jun', hires: 25),
];
