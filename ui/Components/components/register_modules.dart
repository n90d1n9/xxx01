import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasir/modules/expedition/expedition_module.dart';
import 'package:kasir/modules/image_editor/bingkai_module.dart';
import 'package:kasir/modules/ecommerce/ecommerce_module.dart';
import 'package:kayys_components/kayys_components.dart';
import 'package:kasir/modules/pos/pos_module.dart';
import 'package:kasir/modules/product/product_module.dart';
import 'package:kasir/modules/shop/shop_module.dart';
import 'package:kasir/modules/syirkah/syirkah_module.dart';

import 'accounting/accounting_module.dart';
import '../app/app_module.dart';
import 'account/user_module.dart';


List<Menu> registerPages(BuildContext context){
  return [
    ...AppModule().pages(context),
    //...DashboardModule().pages(context),
    ...SyirkahModule().pages(context),
    ...UserModule().pages(context),
    ...EcommerceModule().pages(context),
    ...ProductModule().pages(context),
    ...BingkaiModule().pages(context),
    ...AccountingModule().pages(context),
    ...PosModule().pages(context),
    ...ShopModule().pages(context),
    ...ExpeditionModule().pages(context),
  ];
}

List<List<GoRoute>> modulesGoroutes()=>[
  AppModule().goroutes(),
  SyirkahModule().goroutes(),
  BingkaiModule().goroutes(),
  AccountingModule().goroutes(),
  PosModule().goroutes(),
  ShopModule().goroutes(),
  ExpeditionModule().goroutes(),
];

List<List<StatefulShellBranch>> modulesBranches(){
  return [
    AppModule().branches(),
    //DashboardModule().branches(),
    UserModule().branches(),
    EcommerceModule().branches(),
    SyirkahModule().branches(),
    ProductModule().branches(),
    BingkaiModule().branches(),
    AccountingModule().branches(),
    PosModule().branches(),
    ShopModule().branches(),
    ExpeditionModule().branches(),
  ];
}