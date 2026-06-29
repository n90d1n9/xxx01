import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kayys_components/kayys_components.dart';


abstract class Module {
  String? name;
  List<Menu> pages(BuildContext context);
  void services();
  List<GoRoute> goroutes();
  List<StatefulShellBranch> branches();
}
