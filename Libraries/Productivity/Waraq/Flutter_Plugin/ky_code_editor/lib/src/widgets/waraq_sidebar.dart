import 'package:flutter/material.dart';

import '../models/waraq_shell_models.dart';

/// Sidebar navigation for Waraq editor package surfaces.
class WaraqSidebar extends StatelessWidget {
  /// Creates a Waraq sidebar backed by immutable destination metadata.
  const WaraqSidebar({
    super.key,
    required this.destinations,
    required this.selectedDestination,
    required this.expanded,
    required this.onDestinationSelected,
  });

  /// Destinations displayed in order.
  final List<WaraqDestinationSpec> destinations;

  /// Currently selected destination.
  final WaraqShellDestination selectedDestination;

  /// Whether labels should be visible beside icons.
  final bool expanded;

  /// Called when a destination is selected.
  final ValueChanged<WaraqShellDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = destinations.indexWhere(
      (spec) => spec.destination == selectedDestination,
    );

    return NavigationRail(
      extended: expanded,
      minWidth: 72,
      minExtendedWidth: 192,
      backgroundColor: const Color(0xFF21222C),
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      groupAlignment: -0.86,
      labelType: expanded ? null : NavigationRailLabelType.none,
      selectedIconTheme: const IconThemeData(color: Color(0xFF8BE9FD)),
      unselectedIconTheme: const IconThemeData(color: Color(0xFF6272A4)),
      selectedLabelTextStyle: const TextStyle(
        color: Color(0xFFF8F8F2),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: Color(0xFF9AA6C3),
        fontSize: 11,
      ),
      onDestinationSelected: (index) {
        onDestinationSelected(destinations[index].destination);
      },
      leading: const Padding(
        padding: EdgeInsets.only(top: 14, bottom: 24),
        child: Icon(Icons.view_sidebar, color: Color(0xFF50FA7B)),
      ),
      destinations: [
        for (final destination in destinations)
          NavigationRailDestination(
            icon: Tooltip(
              message: destination.label,
              child: Icon(destination.icon),
            ),
            selectedIcon: Tooltip(
              message: destination.label,
              child: Icon(destination.selectedIcon),
            ),
            label: Text(destination.label),
          ),
      ],
    );
  }
}
