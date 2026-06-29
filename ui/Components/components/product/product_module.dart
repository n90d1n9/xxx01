import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kayys_components/kayys_components.dart';

import '../../core/routes/routes.dart';
import '../../core/modules/module_model.dart';
import 'pages/product_detail_page.dart';
import 'pages/product_page.dart';

class ProductModule extends Module {

  static String daftar = '/products';
  static String detail = ':id';
  static String tambah = '/product/add';
  static String category = '/product/category';

  @override
  pages(BuildContext context) => [
        Menu(title: 'Product', showInDrawer: false, items: [
          Menu(title: 'Daftar product', path: daftar, showInDrawer: false),
          Menu(title: 'Tambah Product', path: tambah, showInDrawer: false),
          Menu(title: 'Tambah Product', path: category, showInDrawer: false),
        ]),
      ];

  @override
  services() {}

  @override
  goroutes() => []; //MainRoutes.goroutes;

  @override
  List<StatefulShellBranch> branches() => [
        Routes.shellBranch('Product', daftar, const ProductPage(), [
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

        /* Routes.shellBranch('File Manager', '/filemanager', FileManager(), []),
        Routes.shellBranch(
            'File Explorer', '/fileexplorer', FileExplorer(), []),
        Routes.shellBranch(
            'File Explorer2', '/fileexplorer2', FileExplorer2(), []) */
      ];
}
