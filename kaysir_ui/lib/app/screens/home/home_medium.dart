import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ky_core/core/features/feature_routes.dart';
import '../../../widgets/side_menu/side_menu_fold.dart';

class HomeMediumScreen extends StatefulWidget {
  final Widget? title;
  final List<Widget> actions;
  final Widget? body;
  final int currentIndex;
  final String? currentPath;
  final List<FeatureRoutes> menuItems;
  final ValueChanged<int>? onFoldMenuTap;
  final ValueChanged<int>? onBottomTap;
  final ValueChanged<FeatureRoutes>? onMenuClick;
  final FloatingActionButton? floatingActionButton;

  const HomeMediumScreen({
    this.title,
    this.body,
    required this.actions,
    required this.currentIndex,
    required this.menuItems,
    this.currentPath,
    this.onMenuClick,
    this.onBottomTap,
    this.floatingActionButton,
    this.onFoldMenuTap,
    super.key,
  });

  @override
  State<HomeMediumScreen> createState() => _HomeMediumScreenState();
}

class _HomeMediumScreenState extends State<HomeMediumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: widget.title,
        actions: widget.actions,
      ),
      body: Row(
        children: [
          SideMenuFold(
            menuItems: widget.menuItems,
            currentIndex: widget.currentIndex,
            currentPath:
                widget.currentPath ?? GoRouter.maybeOf(context)?.state.uri.path,
            floatingActionButton: widget.floatingActionButton,
            onMenuClick: _handleMenuClick,
          ),

          verticalDivider(),

          Expanded(child: widget.body ?? const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget verticalDivider() => VerticalDivider(
    width: 1,
    thickness: 1,
    color: Theme.of(context).dividerColor,
  );

  void _handleMenuClick(FeatureRoutes menu) {
    if (widget.onMenuClick != null) {
      widget.onMenuClick!(menu);
      return;
    }

    final path = menu.path?.trim();
    if (path == null || path.isEmpty) {
      return;
    }

    context.go(path);
  }
}
