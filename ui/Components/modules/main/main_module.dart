import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:syirkah/modules/main/pages/complete_form.dart';
import 'package:syirkah/modules/main/pages/file_explorer.dart';
import 'package:syirkah/modules/main/pages/file_explorer2.dart';
import 'package:syirkah/modules/main/pages/file_manager.dart';
import 'package:kayys_components/kayys_components.dart';

import '../../utils/routes.dart';
import '../../utils/modules/module_model.dart';
import 'pages/about.dart';

class MainModule implements Module {
  @override
  String? name = 'Apps';
  static String main = '/';
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
        const Menu(
            title: 'Sample Form', path: '/sampleform', showInDrawer: false),
        const Menu(
            title: 'File Manager',
            path: '/filemanager',
            showInDrawer: false,
            items: [
              Menu(
                  title: 'File Explorer',
                  path: '/fileexplorer',
                  showInDrawer: false),
              Menu(
                  title: 'File Explorer2',
                  path: '/fileexplorer2',
                  showInDrawer: false),
            ]),
        Menu(title: 'Profile', path: profile, showInDrawer: false),
        Menu(title: 'Admin', showInDrawer: false, items: [
          Menu(title: 'About', path: about, showInDrawer: false),
          Menu(title: 'Settings', path: settings, showInDrawer: false),
        ]),
      ];

  @override
  services() {}

  @override
  goroutes() => []; //MainRoutes.goroutes;

  @override
  List<StatefulShellBranch> branches() => [
        Routes.shellBranch('About', about, AboutPage(), []),
        Routes.shellBranch('Sample Form', '/sampleform', CompleteForm(), []),
        Routes.shellBranch('File Manager', '/filemanager', FileManager(), []),
        Routes.shellBranch(
            'File Explorer', '/fileexplorer', FileExplorer(), []),
        Routes.shellBranch(
            'File Explorer2', '/fileexplorer2', FileExplorer2(), [])
      ];
}
