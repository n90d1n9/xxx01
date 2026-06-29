import 'package:flutter/material.dart';

class Navigation {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo(String routeName, {data}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: data);
  }

  static close() {
    return navigatorKey.currentState!.pop(true);
  }

  static go(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}
