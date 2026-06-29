import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kayys_components/kayys_components.dart';
import 'package:syirkah/modules/social_preneur/pages/post_page.dart';

import '../../core/modules/module_model.dart';
import '../../core/routes/routes.dart';

class SocialPreneurModule implements Module {
  @override
  String? name = 'Apps';
  static String bursaSyirkah = '/syirkah';
  static String login = '/login';
  static String dashboard = '/dashboard';
  static String splash = '/splash';
  static String aboutSyirkah = '/about_syirkah';
  static String signup = '/signup';
  static String forgotPassword = '/forgotPassword';
  static String profile = '/profile';
  static String settings = '/settings';

  @override
  pages(BuildContext context) => [
        Menu(
            title: 'Bursa Syirkah',
            path: aboutSyirkah,
            iconWidget: const Icon(Icons.dashboard)),
        Menu(title: 'Profile', path: aboutSyirkah, showInDrawer: false),
      ];

  @override
  services() {}

  @override
  goroutes() => [
        /* GoRoute(
          path: bursaSyirkah,
          builder: (BuildContext context, GoRouterState state) =>
              const BursaSyirkahPage(),
        ), */
      ];

  @override
  List<StatefulShellBranch> branches() => [
        Routes.shellBranch(
            'bursasyirkah', bursaSyirkah, const BursaSyirkahPage(), []),
      ];
}
