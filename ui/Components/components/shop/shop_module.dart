import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasir/modules/shop/pages/shop_home_page.dart';

import '../../core/modules/module_model.dart';
import '../../core/routes/routes.dart';
import 'pages/shop_page.dart';

class ShopModule implements Module {
@override
  String? name = 'Shop';
  static String shop = '/shop';
  static String shophome = '/shophome';

  @override
  pages(BuildContext context) => [
      //  Menu(title: 'Dashboard', path: DashboardRoutes.dashboard),
      ];

  @override
  services() {}

  @override
  goroutes() => [
   /*  Routes.pageFadeTrans(shophome, const ShopHomePage()),
    Routes.pageFadeTrans(shop, const ShopPage()) */
  ];

  @override
  List<StatefulShellBranch> branches() => [
     Routes.shellBranch(shophome, shophome, const ShopHomePage(), []),
     Routes.shellBranch(shop, shop, const ShopPage(), []),
  ];

   /* onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => InvoiceScreen())), */
}
