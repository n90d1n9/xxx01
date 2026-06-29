import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:golokApps/modules/main/pages/complete_form.dart';
import 'package:golokApps/modules/main/pages/file_explorer.dart';
import 'package:golokApps/modules/main/pages/file_explorer2.dart';
import 'package:golokApps/modules/main/pages/file_manager.dart';
import 'package:kayys_components/kayys_components.dart';

import '../../utils/routes.dart';
import '../../utils/modules/module_model.dart';
import 'pages/product_detail_page.dart';
import 'pages/product_page.dart';

class ProductModule extends Module {
  @override
  String? name = 'Product';
  static String daftar = '/products';
  static String detail = ':id';
  static String tambah = '/product/add';
  static String category = '/product/category';

  @override
  pages(BuildContext context) => [
         Menu(
            title: 'Product',
            showInDrawer: false,
            items: [
              Menu(
                  title: 'Daftar product',
                  path: daftar,
                  showInDrawer: false),
              Menu(
                  title: 'Tambah Product',
                  path: tambah,
                  showInDrawer: false),
              Menu(
                  title: 'Tambah Product',
                  path: category,
                  showInDrawer: false),
            ]),

      ];

  @override
  services() {}

  @override
  goroutes() => []; //MainRoutes.goroutes;

  @override
  List<StatefulShellBranch> branches() => [
       Routes.shellBranch('Users List', daftar, const ProductPage(), [
        GoRoute(
            name: 'Product Detail',
            path: detail,
            pageBuilder: (context, state) {
              return MaterialPage(
                  child: ProductDetailPage(
                id: double.parse(state.pathParameters['id']!),
              ));
            })
      ]),
        Routes.shellBranch('Sample Form', '/sampleform', CompleteForm(), []),
        Routes.shellBranch('File Manager', '/filemanager', FileManager(), []),
        Routes.shellBranch(
            'File Explorer', '/fileexplorer', FileExplorer(), []),
        Routes.shellBranch(
            'File Explorer2', '/fileexplorer2', FileExplorer2(), [])
      ];
}
