import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../config/config.dart';
import '../../../core/features/feature_routes.dart';
import '../../states/sidebar_states/sidebar_notifier.dart';
import '../../widgets/header.dart';
import '../../widgets/side_menu/side_menu.dart';

class HomeLargeScreen extends ConsumerStatefulWidget {
  final Widget? body;
  final List<FeatureRoutes>? menuItems;
  const HomeLargeScreen({super.key, required this.body, this.menuItems});

  @override
  ConsumerState<HomeLargeScreen> createState() => _HomeLargeScreenState();
}

class _HomeLargeScreenState extends ConsumerState<HomeLargeScreen> {
  var currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    //final selectedTab = ref.watch(selectedTabProvider);
    //final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: SideMenu(
              title: const Text(appName),
              image: imageIcon,
              menuItems: widget.menuItems,
              onMenuClick: (menu) {
                context.go(menu.path!);
                ref.read(sidebarProvider.notifier).selectMenu(menu);
              },
            ),
          ),
          Expanded(flex: 5, child: _mainContent(widget.body!)),
        ],
      ),
    );
  }

  Widget _mainContent(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Header(), const SizedBox(height: 70),
          Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(8),
            child: child,
          ),
          // child
        ],
      ),
    );
  }
}
