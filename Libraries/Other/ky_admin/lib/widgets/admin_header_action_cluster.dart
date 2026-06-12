import 'package:flutter/material.dart';

import '../../../app/models/auth/user.dart';
import '../../../widgets/ui/app_icon_action_button.dart';
import '../models/admin_shell_layout.dart';
import 'account_widget.dart';
import 'admin_search_trigger.dart';

class AdminHeaderActionCluster extends StatelessWidget {
  const AdminHeaderActionCluster({
    super.key,
    required this.layout,
    required this.unreadNotifications,
    required this.themeMode,
    required this.user,
    required this.onSearchPressed,
    required this.onNotificationsPressed,
    required this.onThemeTogglePressed,
    required this.onAccountActionSelected,
  });

  final AdminShellLayout layout;
  final int unreadNotifications;
  final ThemeMode themeMode;
  final User user;
  final VoidCallback onSearchPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onThemeTogglePressed;
  final ValueChanged<AccountMenuAction> onAccountActionSelected;

  @override
  Widget build(BuildContext context) {
    final actionGap = layout.isCompact ? 4.0 : 8.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdminSearchTrigger(
          expanded: layout.showExpandedSearch,
          onPressed: onSearchPressed,
        ),
        SizedBox(width: actionGap),
        _NotificationActionButton(
          unreadNotifications: unreadNotifications,
          onPressed: onNotificationsPressed,
        ),
        _ThemeModeActionButton(
          themeMode: themeMode,
          onPressed: onThemeTogglePressed,
        ),
        SizedBox(width: actionGap),
        AccountWidget(
          user: user,
          showCopy: layout.showAccountCopy,
          onSelected: onAccountActionSelected,
        ),
      ],
    );
  }
}

class _NotificationActionButton extends StatelessWidget {
  const _NotificationActionButton({
    required this.unreadNotifications,
    required this.onPressed,
  });

  final int unreadNotifications;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppIconActionButton(
      icon: Icons.notifications_outlined,
      tooltip: 'Notifications',
      badgeCount: unreadNotifications,
      onPressed: onPressed,
    );
  }
}

class _ThemeModeActionButton extends StatelessWidget {
  const _ThemeModeActionButton({
    required this.themeMode,
    required this.onPressed,
  });

  final ThemeMode themeMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppIconActionButton(
      icon:
          themeMode == ThemeMode.dark
              ? Icons.wb_sunny_outlined
              : Icons.nightlight_round,
      tooltip: 'Toggle theme',
      onPressed: onPressed,
    );
  }
}
