import 'package:adaptive_screen/adaptive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/features_core/menu.dart';
import '../core/features_core/features_registry.dart';
import 'large_screen.dart';
import 'medium_screen.dart';
import 'phone_screen.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  var valueCart = 0;
  var valueNotif = 0;
  List<Menu> menuItems = [];

  @override
  Widget build(BuildContext context) {
    menuItems = FeaturesRegistry.routes(context);
    return SafeArea(
        child: AdaptiveScreen(
            // If fit large screen (Desktop)
            largeScreen: LargeScreen(
              body: widget.navigationShell,
              menuItems: menuItems,
            ),

            // If fit medium screen (Tablet)
            mediumScreen: MediumScreen(
              body: widget.navigationShell,
              menuItems: menuItems,
              actions: [],
              currentIndex: 0,
            ),

            // If fit small screen (Phone)
            phone: PhoneScreen(
              menuItems: menuItems,
              body: widget.navigationShell,
            )));
  }
}
