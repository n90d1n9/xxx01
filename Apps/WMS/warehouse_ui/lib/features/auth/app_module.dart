import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/features_core/menu.dart';
import '../../core/features_core/feature_model.dart';
import '../../core/routes/routes.dart';
import '../about/screens/about.dart';

class AppModule implements Module {
  @override
  String? name = 'Apps';
  static String main = '/home';
  static String login = '/login';
  static String dashboard = '/dashboard';
  static String splash = '/splash';
  static String about = '/about';
  static String signup = '/signup';
  static String forgotPassword = '/forgotPassword';
  static String profile = '/profile';
  static String settings = '/settings';

  @override
  pages(BuildContext context) => [
        Menu(
            title: 'Dashboard',
            path: main,
            iconWidget: const Icon(Icons.dashboard)),
        Menu(title: 'Profile', path: profile, showInDrawer: false),
        Menu(title: 'Admin', showInDrawer: false, items: [
          Menu(title: 'About', path: about, showInDrawer: false),
          Menu(title: 'Settings', path: settings, showInDrawer: false),
        ]),
      ];

  @override
  services() {}

  @override
  goroutes() => [];

  @override
  List<StatefulShellBranch> branches() => [
        Routes.shellBranch('About', about, const AboutPage(), []),
       // Routes.shellBranch(settings, settings, const SettingsPage()),
      ];
}
