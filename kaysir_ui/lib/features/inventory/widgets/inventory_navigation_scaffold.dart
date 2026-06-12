import 'package:flutter/material.dart';

import 'inventory_navigation_drawer.dart';

class InventoryNavigationScaffold extends StatelessWidget {
  const InventoryNavigationScaffold({
    super.key,
    required this.currentDestination,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.onDestinationSelected,
    this.isCanonicalDestination = true,
  });

  final InventoryNavigationDestination currentDestination;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final ValueChanged<InventoryNavigationDestination>? onDestinationSelected;
  final bool isCanonicalDestination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: InventoryNavigationDrawer(
        currentDestination: currentDestination,
        onDestinationSelected:
            onDestinationSelected ??
            (destination) => _selectDestination(context, destination),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  void _selectDestination(
    BuildContext context,
    InventoryNavigationDestination destination,
  ) {
    Navigator.pop(context);

    if (isCanonicalDestination && destination == currentDestination) return;

    Navigator.of(context).pushReplacementNamed(destination.routePath);
  }
}

class InventoryNavigationDrawerAction extends StatelessWidget {
  const InventoryNavigationDrawerAction({
    super.key,
    this.onlyWhenRouteCanPop = false,
  });

  final bool onlyWhenRouteCanPop;

  @override
  Widget build(BuildContext context) {
    if (onlyWhenRouteCanPop && !Navigator.of(context).canPop()) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: 'Open inventory navigation',
      icon: const Icon(Icons.menu_open_rounded),
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}
