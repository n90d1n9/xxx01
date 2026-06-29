import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/features/feature_routes.dart';

class HomeLargeScreen extends ConsumerStatefulWidget {
  final Widget body;
  final List<FeatureRoutes>? menuItems;
  const HomeLargeScreen({super.key, this.menuItems, required this.body});

  @override
  ConsumerState<HomeLargeScreen> createState() => _HomeLargeScreenState();
}

class _HomeLargeScreenState extends ConsumerState<HomeLargeScreen> {
  var currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Use provided menuItems or fallback to mainMenuRoutes
    // final menuItems = widget.menuItems;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          /* Expanded(
            flex: 1,
            child: SideMenu(
              title: const Text(appName),
              image: imageIcon,
              menuItems: menuItems,
              onMenuClick: (menu) {
                safeNavigate(context, menu.path!);
                ref.read(sidebarProvider.notifier).selectMenu(menu);
              },
            ),
          ), */
          Expanded(flex: 5, child: _mainContent(widget.body)),
        ],
      ),
    );
  }

  Widget _mainContent(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          //const Header(),
          const SizedBox(height: 70),
          Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(8),
            child: child,
          ),
        ],
      ),
    );
  }
}
