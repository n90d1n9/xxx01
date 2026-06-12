import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../app/models/auth/user.dart';
import '../../../app/states/auth/auth_provider.dart';
import '../../../app/states/settings/settings_notifier.dart';
import '../services/admin_route_search_launcher.dart';
import '../services/admin_shell_layout_resolver.dart';
import '../states/dashboard_provider.dart';
import '../states/notification_provider.dart';
import '../states/sidebar_provider.dart';
import '../../notification/widgets/notification_center.dart';
import 'admin_account_dialogs.dart';
import 'admin_header_action_cluster.dart';
import 'admin_header_title.dart';
import 'admin_navigation_toggle_button.dart';

class AdminHeader extends ConsumerWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final sidebarMode = ref.watch(sidebarModeProvider);
    final settings = ref.watch(settingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);
    final user = ref.watch(authProvider).user ?? _fallbackUser;
    final layout = resolveAdminShellLayout(MediaQuery.sizeOf(context).width);
    final actionGap = layout.isCompact ? 4.0 : 8.0;

    return Container(
      height: layout.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          AdminNavigationToggleButton(
            sidebarMode: sidebarMode,
            useDrawerNavigation: layout.useDrawerNavigation,
            onOpenDrawer: () => Scaffold.maybeOf(context)?.openDrawer(),
            onToggleSidebar: () => _toggleSidebar(ref, sidebarMode),
          ),
          SizedBox(width: actionGap),
          Expanded(child: AdminHeaderTitle(title: currentPage)),
          AdminHeaderActionCluster(
            layout: layout,
            unreadNotifications: unreadNotifications,
            themeMode: settings.themeMode,
            user: user,
            onSearchPressed: () => AdminRouteSearchLauncher.open(context, ref),
            onNotificationsPressed: () => _openNotifications(context),
            onThemeTogglePressed: () =>
                ref.read(settingsProvider.notifier).toggleTheme(),
            onAccountActionSelected: (action) =>
                AdminAccountDialogs.handleAction(
                  context,
                  ref,
                  action,
                  ref.read(authProvider).user ?? _fallbackUser,
                ),
          ),
        ],
      ),
    );
  }

  static const User _fallbackUser = User(
    id: 0,
    username: 'Kaysir User',
    firstName: 'Kaysir',
    lastName: 'User',
    email: 'operator@kaysir.local',
    role: UserRole.admin,
  );

  void _toggleSidebar(WidgetRef ref, SidebarMode sidebarMode) {
    ref.read(sidebarModeProvider.notifier).state = nextSidebarMode(sidebarMode);
  }

  Future<void> _openNotifications(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const NotificationCenter(),
    );
  }
}
