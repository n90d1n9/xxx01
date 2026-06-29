import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth/app_module.dart';
import '../core/features_core/menu.dart';

List<Menu> registerPages(BuildContext context){
  return [
    ...AppModule().pages(context),

  ];
}

List<List<GoRoute>> featuresGoroutes()=>[
  AppModule().goroutes(),
 
];

List<List<StatefulShellBranch>> featuresBranches(){
  return [
    AppModule().branches(),
     
  ];
}