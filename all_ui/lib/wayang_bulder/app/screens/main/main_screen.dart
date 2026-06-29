import 'package:adaptive_screen/adaptive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../screen/wayang_builder.dart';

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
        largeScreen:
            WayangBuilder(), //AdminLayout(child: widget.navigationShell),
        mediumScreen:
            WayangBuilder(), //AdminLayout(child: widget.navigationShell),
        phone: WayangBuilder(),
      ),
    );
  }
}
