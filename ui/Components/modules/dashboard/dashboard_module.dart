import 'package:flutter/material.dart';
import 'package:go_router/src/route.dart';

import '../../utils/modules/module_model.dart';
import 'dashboard_routes.dart';

class DashboardModule implements Module {
  @override
  String? name = 'Dashboard';

  @override
  String? baseRoute = '/dashboard';

  @override
  pages(BuildContext context) => [
      //  Menu(title: 'Dashboard', path: DashboardRoutes.dashboard),
      ];

  @override
  services() {}

  @override
  goroutes() => DashboardRoutes.goroutes;

  @override
  List<StatefulShellBranch> branches() => DashboardRoutes.branches;
}
