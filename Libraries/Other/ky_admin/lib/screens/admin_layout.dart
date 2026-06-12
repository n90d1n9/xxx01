import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../services/admin_shell_layout_resolver.dart';
import '../services/admin_route_search_launcher.dart';
import '../states/sidebar_provider.dart';
import '../widgets/admin_footer.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_shell_shortcuts.dart';
import '../widgets/sidebar/admin_sidebar.dart';

class AdminScreen extends ConsumerWidget {
  final Widget? body;
  final StatefulNavigationShell? navigationShell;

  const AdminScreen({super.key, this.body, this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarMode = ref.watch(sidebarModeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final layout = resolveAdminShellLayout(MediaQuery.sizeOf(context).width);

    return AdminShellShortcuts(
      onSearchPressed: () => AdminRouteSearchLauncher.open(context, ref),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: SafeArea(
          child: Row(
            children: [
              if (!layout.useDrawerNavigation &&
                  sidebarMode != SidebarMode.hidden)
                AdminSidebar(navigationShell: navigationShell),

              Expanded(
                child: Column(
                  children: [
                    const AdminHeader(),

                    Expanded(
                      child: ColoredBox(
                        color: colorScheme.surfaceContainerLow,
                        child: body ?? const SizedBox.shrink(),
                      ),
                    ),

                    const AdminFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Drawer for mobile view
        drawer: layout.useDrawerNavigation
            ? Drawer(
                child: AdminSidebar(
                  isDrawer: true,
                  navigationShell: navigationShell,
                ),
              )
            : null,
      ),
    );
  }
}
