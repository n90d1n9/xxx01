import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ky_core/core/features/feature_routes.dart';
import 'package:ky_core/core/features/features_base.dart';
import 'package:kaysir/features/hris/assesment/screens/feedback_screen.dart';
import 'package:kaysir/features/hris/attendance/screens/attendance_screen.dart';
import 'package:kaysir/features/hris/company/screens/company_management_screen.dart';
import 'package:kaysir/features/hris/compliance/screens/compliance_screen.dart';
import 'package:kaysir/features/hris/compensation/screens/compensation_screen.dart';
import 'package:kaysir/features/hris/employee/screens/employee/empl_self_service.dart';
import 'package:kaysir/features/hris/employee/screens/employee_directory_table_screen.dart';
import 'package:kaysir/features/hris/engagement/screens/engagement_screen.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hr_dashboard/screens/hr_dashboard_screen.dart';
import 'package:kaysir/features/hris/holidays/screens/holiday_management_screen.dart';
import 'package:kaysir/features/hris/leave/screens/leave_management_screen.dart';
import 'package:kaysir/features/hris/manager/mss.dart';
import 'package:kaysir/features/hris/payroal/screens/payroll_screen.dart';
import 'package:kaysir/features/hris/performance/screens/performance_screen.dart';
import 'package:kaysir/features/hris/people_ops/screens/people_ops_screen.dart';
import 'package:kaysir/features/hris/recruitment/screens/recruitment_screen.dart';
import 'package:kaysir/features/hris/service_center/screens/service_center_screen.dart';
import 'package:kaysir/features/hris/talent/screens/talent_development_screen.dart';
import 'package:kaysir/features/hris/workforce_planning/screens/workforce_planning_screen.dart';

class HrisFeatures extends FeaturesBase {
  @override
  List<FeatureRoutes> registerScreens() => [
    FeatureRoutes(
      name: 'Human Resources',
      items: [
        FeatureRoutes(
          name: 'HR Dashboard',
          path: '/hrdashboard',
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: HRDashboardScreen()),
        ),
        ...hrisWorkspaces.map(_workspaceRoute),
        FeatureRoutes(
          name: 'Assesment 360',
          path: '/assestment360',
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: FeedbackScreen()),
        ),
      ],
    ),
  ];
}

FeatureRoutes _workspaceRoute(HrisWorkspace workspace) {
  return FeatureRoutes(
    name: workspace.title,
    path: workspace.path,
    pageBuilder:
        (BuildContext context, GoRouterState state) =>
            MaterialPage(child: _workspaceScreen(workspace.id)),
  );
}

Widget _workspaceScreen(HrisWorkspaceId id) {
  switch (id) {
    case HrisWorkspaceId.companyManagement:
      return CompanyManagementScreen();
    case HrisWorkspaceId.peopleOps:
      return PeopleOpsScreen();
    case HrisWorkspaceId.compliance:
      return ComplianceScreen();
    case HrisWorkspaceId.workforcePlanning:
      return WorkforcePlanningScreen();
    case HrisWorkspaceId.recruitment:
      return RecruitmentScreen();
    case HrisWorkspaceId.talent:
      return TalentDevelopmentScreen();
    case HrisWorkspaceId.performance:
      return PerformanceScreen();
    case HrisWorkspaceId.compensation:
      return CompensationScreen();
    case HrisWorkspaceId.engagement:
      return EngagementScreen();
    case HrisWorkspaceId.serviceCenter:
      return ServiceCenterScreen();
    case HrisWorkspaceId.attendance:
      return AttendanceScreen();
    case HrisWorkspaceId.leave:
      return LeaveManagementScreen();
    case HrisWorkspaceId.holidays:
      return HolidayManagementScreen();
    case HrisWorkspaceId.payroll:
      return PayrollScreen();
    case HrisWorkspaceId.employeeDirectory:
      return EmployeeDirectoryTableScreen();
    case HrisWorkspaceId.employeeSelfService:
      return EmployeeSelfServiceScreen();
    case HrisWorkspaceId.manager:
      return ManagerSelfServiceScreen();
  }
}
