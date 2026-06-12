import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../app/models/auth/user.dart';
import '../../../app/states/auth/auth_provider.dart';
import '../../../app/states/settings/settings_notifier.dart';
import 'account_widget.dart';
import 'admin_account_profile_panel.dart';
import 'admin_account_settings_panel.dart';
import 'admin_logout_confirmation_panel.dart';

class AdminAccountDialogs {
  const AdminAccountDialogs._();

  static Future<void> handleAction(
    BuildContext context,
    WidgetRef ref,
    AccountMenuAction action,
    User user,
  ) async {
    switch (action) {
      case AccountMenuAction.profile:
        await _openProfileDialog(context, user);
      case AccountMenuAction.settings:
        await _openQuickSettingsDialog(context);
      case AccountMenuAction.logout:
        await _confirmLogout(context, ref);
    }
  }

  static Future<void> _openProfileDialog(BuildContext context, User user) {
    return showDialog<void>(
      context: context,
      builder: (context) => AdminAccountProfilePanel(
        user: user,
        onClose: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  static Future<void> _openQuickSettingsDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final settings = ref.watch(settingsProvider);
          final settingsNotifier = ref.read(settingsProvider.notifier);

          return AdminAccountSettingsPanel(
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: settingsNotifier.supportedLocales,
            onToggleTheme: () =>
                ref.read(settingsProvider.notifier).toggleTheme(),
            onLocaleChanged: (locale) =>
                ref.read(settingsProvider.notifier).changeLocale(locale),
            onClose: () => Navigator.of(context).maybePop(),
          );
        },
      ),
    );
  }

  static Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AdminLogoutConfirmationPanel(
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(authProvider.notifier).logout();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Logged out')));
    context.go('/login');
  }
}
