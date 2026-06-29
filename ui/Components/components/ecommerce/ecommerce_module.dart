import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasir/modules/ecommerce/pages/home_page.dart';
import 'package:kasir/shared/data/__raw/complete_form.dart';
import 'package:kasir/modules/file/pages/file_explorer.dart';
import 'package:kasir/modules/file/pages/file_explorer2.dart';
import 'package:kasir/modules/file/pages/file_manager.dart';
import 'package:kayys_components/kayys_components.dart';

import '../../core/routes/routes.dart';

import '../../core/modules/module_model.dart';


class EcommerceModule implements Module {
  @override
  String? name = 'Apps';
  static String main = '/';
  static String login = '/login';
  static String dashboard = '/dashboard';
  static String splash = '/splash';
  static String about = '/about';

  @override
  String? baseRoute = '';

  @override
  pages(BuildContext context) => [
        const Menu(title: 'Ecommerce', path: '/ecommerce', showInDrawer: false),
  
      ];

  @override
  services() {}

  @override
  goroutes() => [];//MainRoutes.goroutes;

  @override
  List<StatefulShellBranch> branches() => [
        Routes.shellBranch('Ecommerce', '/ecommerce', const ShopHomeScreen(), []),
    /*     Routes.shellBranch('File Manager', '/filemanager', FileManager(), []),
        Routes.shellBranch('File Explorer', '/fileexplorer', FileExplorer(), []),
        Routes.shellBranch('File Explorer2', '/fileexplorer2', FileExplorer2(), []) */
      ];
}
