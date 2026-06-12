/* import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miku/features/dashboard/screens/dashboard_main.dart';

import '../../core/features/feature.dart';
import '../../core/routes/routes.dart';
import '../../core/features/features_base.dart';

class DashboardFeatures implements FeaturesBase {
  @override
  String? name = 'Apps';
  static String dashboard = '/dashboard';

  @override
  List<Feature> registerScreens() => [
        Feature(
            title: 'Gallery',
            path: dashboard,
            iconWidget: const Icon(Icons.dashboard)),
      ];

  @override
  List<GoRoute> goroutes() => [];

  @override
  List<StatefulShellBranch> branches() => [
        Routes.shellBranch('About', dashboard, const DashboardMainScreen(), []),
        // Routes.shellBranch(settings, settings, const SettingsPage()),
      ];
}
 */
