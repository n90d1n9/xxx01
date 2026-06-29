import 'package:go_router/go_router.dart';
import 'package:syirkah/modules/dashboard/pages/dashboard_page.dart';

import '../../core/routes/routes.dart';

class DashboardRoutes {
  DashboardRoutes._();
  static String dashboard = '/dashboard';

  static final List<GoRoute> goroutes = <GoRoute>[
    Routes.pageFadeTrans(dashboard, const DashboardPage()),
  ];

  static final List<StatefulShellBranch> branches = [
    Routes.shellBranch('dashboard', dashboard, const DashboardPage(),[]),
  ];
}
