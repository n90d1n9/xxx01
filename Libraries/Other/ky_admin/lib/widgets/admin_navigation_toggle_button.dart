import 'package:flutter/material.dart';

import '../../../widgets/ui/app_icon_action_button.dart';
import '../states/sidebar_provider.dart';

class AdminNavigationToggleButton extends StatelessWidget {
  const AdminNavigationToggleButton({
    super.key,
    required this.sidebarMode,
    required this.useDrawerNavigation,
    required this.onOpenDrawer,
    required this.onToggleSidebar,
  });

  final SidebarMode sidebarMode;
  final bool useDrawerNavigation;
  final VoidCallback onOpenDrawer;
  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    return AppIconActionButton(
      icon: _navigationIcon,
      tooltip: useDrawerNavigation ? 'Open navigation' : 'Toggle navigation',
      onPressed: useDrawerNavigation ? onOpenDrawer : onToggleSidebar,
    );
  }

  IconData get _navigationIcon {
    if (useDrawerNavigation) return Icons.menu;
    return sidebarMode == SidebarMode.expanded ? Icons.menu_open : Icons.menu;
  }
}
