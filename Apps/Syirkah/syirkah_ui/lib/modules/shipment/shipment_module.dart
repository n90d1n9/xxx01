import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/modules/module_model.dart';

class PosModule implements Module {
  @override
  String? name = 'Dashboard';

  @override
  pages(BuildContext context) => [
      //  Menu(title: 'Dashboard', path: DashboardRoutes.dashboard),
      ];

  @override
  services() {}

  @override
  goroutes() => [];

  @override
  List<StatefulShellBranch> branches() => [];
}
