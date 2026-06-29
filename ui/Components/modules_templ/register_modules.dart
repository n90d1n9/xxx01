import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:golokApps/modules/ecommerce/ecommerce_module.dart';
import 'package:kayys_components/kayys_components.dart';

import 'main/main_module.dart';
import 'user/user_module.dart';


List<Menu> registerPages(BuildContext context){
  return [
    ...MainModule().pages(context),
    ...UserModule().pages(context),
    ...EcommerceModule().pages(context)
    //...DashboardModule().pages(context),
  ];
}

List<List<StatefulShellBranch>> modulesBranches(){
  return [
    MainModule().branches(),
    UserModule().branches(),
    EcommerceModule().branches()
    //DashboardModule().branches(),
  ];
}