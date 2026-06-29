import 'package:flutter/material.dart';

import '../../features/register_features.dart';
import '../routes/routes.dart';
import 'menu.dart';

class FeaturesRegistry {
  // singleton object
  static final FeaturesRegistry _singleton = FeaturesRegistry._();

  // factory method to return the same object each time its needed
  factory FeaturesRegistry() => _singleton;

  FeaturesRegistry._();
  static List<Menu> menus = [];

  static List<Menu> routes(BuildContext context) {
    return registerPages(context);
  }


  static goroutes() {
    featuresGoroutes().forEach((m) {
      Routes.addRoutes(m);
    });
  }

  static branches() {
    featuresBranches().forEach((m) {
      Routes.addBranches(m);
    });
  }
}

