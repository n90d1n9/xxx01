import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/modules/module_model.dart';
import 'dashboard_routes.dart';

class DashboardModule implements Module {
  @override
  String? name = 'Dashboard';

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
