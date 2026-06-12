import 'package:flutter/material.dart';

import 'inventory_navigation_drawer.dart';
import 'inventory_navigation_scaffold.dart';

class InventoryReportScaffold extends StatelessWidget {
  const InventoryReportScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.currentDestination = InventoryNavigationDestination.reports,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final InventoryNavigationDestination currentDestination;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      drawer: InventoryNavigationDrawer(
        currentDestination: currentDestination,
        onDestinationSelected:
            (destination) => _selectDestination(
              context,
              destination,
              isCanonicalDestination: !canPop,
            ),
      ),
      appBar: AppBar(
        leading: canPop ? const BackButton() : null,
        title: Text(title),
        actions: [
          ...actions,
          if (canPop) const InventoryNavigationDrawerAction(),
        ],
      ),
      body: body,
    );
  }

  void _selectDestination(
    BuildContext context,
    InventoryNavigationDestination destination, {
    required bool isCanonicalDestination,
  }) {
    Navigator.pop(context);

    if (isCanonicalDestination && destination == currentDestination) return;

    Navigator.of(context).pushReplacementNamed(destination.routePath);
  }
}
