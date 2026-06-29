import 'package:go_router/go_router.dart';

import '../../app/pages/home_large.dart';
import '../../core/routes/routes.dart';

class DashboardRoutes {
  DashboardRoutes._();
  static String dashboard = '/dashboard';

  static final List<GoRoute> goroutes = <GoRoute>[
    Routes.pageFadeTrans(dashboard, const HomeLargePage()),
  ];

  static final List<StatefulShellBranch> branches = [
    Routes.shellBranch('dashboard', dashboard, const HomeLargePage(),[]),
  ];
}
