import 'package:flutter/material.dart';

enum HrisWorkspaceId {
  companyManagement,
  peopleOps,
  compliance,
  workforcePlanning,
  recruitment,
  talent,
  performance,
  compensation,
  engagement,
  serviceCenter,
  attendance,
  leave,
  holidays,
  payroll,
  employeeDirectory,
  employeeSelfService,
  manager,
}

enum DashboardWorkspaceCategory { strategic, operational }

class HrisWorkspace {
  final HrisWorkspaceId id;
  final String title;
  final String path;
  final DashboardWorkspaceCategory category;
  final IconData icon;
  final Color color;

  const HrisWorkspace({
    required this.id,
    required this.title,
    required this.path,
    required this.category,
    required this.icon,
    required this.color,
  });
}

const hrisWorkspaces = [
  HrisWorkspace(
    id: HrisWorkspaceId.companyManagement,
    title: 'Company Management',
    path: '/hris-company-management',
    category: DashboardWorkspaceCategory.strategic,
    icon: Icons.business_center_outlined,
    color: Colors.blue,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.peopleOps,
    title: 'People Operations',
    path: '/hris-people-ops',
    category: DashboardWorkspaceCategory.strategic,
    icon: Icons.hub_outlined,
    color: Colors.indigo,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.compliance,
    title: 'Compliance & Risk',
    path: '/hris-compliance',
    category: DashboardWorkspaceCategory.strategic,
    icon: Icons.gpp_maybe_outlined,
    color: Colors.red,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.workforcePlanning,
    title: 'Workforce Planning',
    path: '/hris-workforce-planning',
    category: DashboardWorkspaceCategory.strategic,
    icon: Icons.account_tree_outlined,
    color: Colors.cyan,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.recruitment,
    title: 'Recruitment',
    path: '/hris-recruitment',
    category: DashboardWorkspaceCategory.strategic,
    icon: Icons.manage_search_outlined,
    color: Colors.teal,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.talent,
    title: 'Talent Development',
    path: '/hris-talent-development',
    category: DashboardWorkspaceCategory.strategic,
    icon: Icons.school_outlined,
    color: Colors.deepPurple,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.performance,
    title: 'Performance',
    path: '/hris-performance',
    category: DashboardWorkspaceCategory.strategic,
    icon: Icons.insights_outlined,
    color: Colors.orange,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.compensation,
    title: 'Compensation',
    path: '/hris-compensation',
    category: DashboardWorkspaceCategory.strategic,
    icon: Icons.payments_outlined,
    color: Colors.green,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.engagement,
    title: 'Engagement',
    path: '/hris-engagement',
    category: DashboardWorkspaceCategory.strategic,
    icon: Icons.favorite_border,
    color: Colors.pink,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.serviceCenter,
    title: 'Service Center',
    path: '/hris-service-center',
    category: DashboardWorkspaceCategory.strategic,
    icon: Icons.contact_support_outlined,
    color: Colors.blueGrey,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.attendance,
    title: 'Attendance',
    path: '/attendance',
    category: DashboardWorkspaceCategory.operational,
    icon: Icons.schedule_outlined,
    color: Colors.amber,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.leave,
    title: 'Leave',
    path: '/leave',
    category: DashboardWorkspaceCategory.operational,
    icon: Icons.event_available_outlined,
    color: Colors.lightBlue,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.holidays,
    title: 'Holidays',
    path: '/holidays',
    category: DashboardWorkspaceCategory.operational,
    icon: Icons.event_busy_outlined,
    color: Colors.teal,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.payroll,
    title: 'Payroll',
    path: '/payroll',
    category: DashboardWorkspaceCategory.operational,
    icon: Icons.receipt_long_outlined,
    color: Colors.green,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.employeeDirectory,
    title: 'Employee Directory',
    path: '/employee',
    category: DashboardWorkspaceCategory.operational,
    icon: Icons.badge_outlined,
    color: Colors.deepOrange,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.employeeSelfService,
    title: 'Employee Self-Service',
    path: '/employee-self-service',
    category: DashboardWorkspaceCategory.operational,
    icon: Icons.person_pin_circle_outlined,
    color: Colors.purple,
  ),
  HrisWorkspace(
    id: HrisWorkspaceId.manager,
    title: 'Manager',
    path: '/manager',
    category: DashboardWorkspaceCategory.operational,
    icon: Icons.supervisor_account_outlined,
    color: Colors.blue,
  ),
];

HrisWorkspace hrisWorkspaceById(HrisWorkspaceId id) {
  return hrisWorkspaces.firstWhere((workspace) => workspace.id == id);
}
