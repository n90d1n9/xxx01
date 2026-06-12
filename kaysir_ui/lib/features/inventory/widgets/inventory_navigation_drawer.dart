import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../../widgets/ui/app_text_cluster.dart';
import 'inventory_navigation_destination_details.dart';

export 'inventory_navigation_destination_details.dart';

class InventoryNavigationDrawer extends StatelessWidget {
  const InventoryNavigationDrawer({
    super.key,
    this.currentDestination = InventoryNavigationDestination.inventory,
    this.onDestinationSelected,
  });

  static const destinations = inventoryNavigationDestinations;

  final InventoryNavigationDestination currentDestination;
  final ValueChanged<InventoryNavigationDestination>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = destinations.indexOf(currentDestination);
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompactHeight = constraints.maxHeight < 700;

            return NavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                onDestinationSelected?.call(destinations[index]);
              },
              children: [
                Padding(
                  padding:
                      isCompactHeight
                          ? const EdgeInsets.fromLTRB(20, 10, 20, 8)
                          : const EdgeInsets.fromLTRB(24, 18, 24, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextCluster(
                        eyebrow: 'Kaysir',
                        title: 'Inventory',
                        subtitle: 'Stock operations',
                        titleStyle: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      if (!isCompactHeight) ...[
                        const SizedBox(height: 12),
                        AppStatusPill(
                          label: 'Workspace',
                          icon: Icons.layers_rounded,
                          color: colorScheme.primary,
                          maxWidth: 140,
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1),
                SizedBox(height: isCompactHeight ? 4 : 10),
                for (final destination in destinations)
                  NavigationDrawerDestination(
                    icon: Icon(destination.details.icon),
                    selectedIcon: Icon(destination.details.selectedIcon),
                    label: Text(destination.details.label),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

@Preview(name: 'Inventory navigation drawer')
Widget inventoryNavigationDrawerPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 360,
          child: InventoryNavigationDrawer(
            currentDestination: InventoryNavigationDestination.stockOpname,
          ),
        ),
      ),
    ),
  );
}
