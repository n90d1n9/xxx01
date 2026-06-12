import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_dialog_actions.dart';
import 'admin_dialog_header.dart';
import 'admin_dialog_surface.dart';

class AdminLogoutConfirmationPanel extends StatelessWidget {
  const AdminLogoutConfirmationPanel({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AdminDialogSurface(
      maxWidth: 420,
      maxHeight: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdminDialogHeader(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'End this local session',
            onClose: onCancel,
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Text(
              'Return to login and clear the active workspace session?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: AppDialogActions(
              cancelLabel: 'Cancel',
              confirmLabel: 'Logout',
              confirmIcon: Icons.logout,
              confirmVariant: AppActionButtonVariant.destructive,
              onCancel: onCancel,
              onConfirm: onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}
