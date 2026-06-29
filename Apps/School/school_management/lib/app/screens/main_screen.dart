import 'package:adaptive_screen/adaptive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_layout.dart';
import 'home/home_large.dart';
import 'home/home_phone.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  var valueCart = 0;
  var valueNotif = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AdaptiveScreen(
        // For large screen (Desktop)
        largeScreen: AdminScreen(body: widget.navigationShell),

        // For medium screen (Tablet)
        mediumScreen: HomeLargeScreen(
          body: widget.navigationShell,
          //menuItems: menuList,
          /* actions: [],
              currentIndex: 0, */
        ),

        // For small screen (Phone)
        phone: PhoneScreen(),
      ),
    );
  }
}
