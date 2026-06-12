import 'package:adaptive_screen/adaptive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/admin/screens/admin_layout.dart';

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
        largeScreen: AdminScreen(
          body: widget.navigationShell,
          navigationShell: widget.navigationShell,
        ),

        // For medium screen (Tablet)
        mediumScreen: AdminScreen(
          body: widget.navigationShell,
          navigationShell: widget.navigationShell,
        ),

        // For small screen (Phone)
        phone: AdminScreen(
          body: widget.navigationShell,
          navigationShell: widget.navigationShell,
        ),
      ),
    );
  }
}
