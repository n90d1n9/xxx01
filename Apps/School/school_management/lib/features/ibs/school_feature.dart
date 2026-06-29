import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/features/feature_routes.dart';
import '../../core/features/features_base.dart';

import 'screens/attendance_screen.dart';
import 'screens/class_group_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/school_dashboard_screen.dart';
import 'screens/teacher_screen.dart';

class SchoolFeature implements FeaturesBase {
  @override
  List<FeatureRoutes> registerScreens() => [
    FeatureRoutes(
      name: 'School',
      items: [
        FeatureRoutes(
          name: 'School Dashboard',
          path: '/dashboardSchool',
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: SchoolDashboardScreen()),
        ),
        FeatureRoutes(
          name: 'Class',
          path: '/class',
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: ClassGroupScreen()),
        ),
        FeatureRoutes(
          name: 'Student Attendance',
          path: '/attendanceStudent',
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: AttendanceScreen()),
        ),
        FeatureRoutes(
          name: 'Hafidz Progress',
          path: '/hafidz',
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: HafizProgressScreen(studentId: 1)),
        ),
        FeatureRoutes(
          name: 'Teacher',
          path: '/teacher',
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: TeachersScreen()),
        ),
      ],
    ),
  ];
}
