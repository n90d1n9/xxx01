import 'package:flutter/material.dart';
import 'package:kayys_components/kayys_components.dart';

import '../../modules/register_modules.dart';
import '../routes/routes.dart';

class ModulesRegistry {
  // singleton object
  static final ModulesRegistry _singleton = ModulesRegistry._();

  // factory method to return the same object each time its needed
  factory ModulesRegistry() => _singleton;

  ModulesRegistry._();
  static List<Menu> menus = [];

  static List<Menu> routes(BuildContext context) {
    return registerPages(context);
  }


  static goroutes() {
    modulesGoroutes().forEach((m) {
      Routes.addRoutes(m);
    });
  }

  static branches() {
    modulesBranches().forEach((m) {
      Routes.addBranches(m);
    });
  }
}

/* 
class ModulesRegistry {
  // singleton object
/*   static final ModulesRegistry _singleton = ModulesRegistry._();

  // factory method to return the same object each time its needed
  factory ModulesRegistry() => _singleton;

  ModulesRegistry._(); */

   List<Menu> routes(BuildContext context) {
    registerModules().forEach((m) {
       m.pages(context).forEach((p) {
        Modules.addPages(p);
      });
      m.services();
    });

    return Modules.pages;
  }

   branches() {
    registerModules().forEach((m) {
      Routes.addRoutes(m.goroutes());
      Routes.addBranches(m.branches());
    });
  }
} */
