import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syirkah/modules/finance/accounting/accounting_module.dart';
import 'package:syirkah/modules/utility/image_editor/bingkai_module.dart';
import 'package:syirkah/modules/ecommerce/ecommerce_module.dart';
import 'package:kayys_components/kayys_components.dart';
import 'package:syirkah/modules/pos/pos_module.dart';
import 'package:syirkah/modules/product/product_module.dart';
import 'package:syirkah/modules/shop/shop_module.dart';
import 'package:syirkah/modules/social_preneur/social_module.dart';

import '../app/app_module.dart';
import 'account/user_module.dart';


List<Menu> registerPages(BuildContext context){
  return [
    ...AppModule().pages(context),
    ...AccountingModule().pages(context),
    ...PosModule().pages(context),
    //...DashboardModule().pages(context),
    ...SocialPreneurModule().pages(context),
    ...UserModule().pages(context),
    ...EcommerceModule().pages(context),
    ...ProductModule().pages(context),
    ...BingkaiModule().pages(context),
   
    
    ...ShopModule().pages(context)
  ];
}

List<List<GoRoute>> modulesGoroutes()=>[
  AppModule().goroutes(),
  SocialPreneurModule().goroutes(),
  BingkaiModule().goroutes(),
  AccountingModule().goroutes(),
  PosModule().goroutes(),
  ShopModule().goroutes()
];

List<List<StatefulShellBranch>> modulesBranches(){
  return [
    AppModule().branches(),
    AccountingModule().branches(),
    //DashboardModule().branches(),
    UserModule().branches(),
    EcommerceModule().branches(),
    SocialPreneurModule().branches(),
    ProductModule().branches(),
    BingkaiModule().branches(),
    
    PosModule().branches(),
    ShopModule().branches()
  ];
}