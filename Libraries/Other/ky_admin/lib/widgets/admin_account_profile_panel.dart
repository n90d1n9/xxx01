import 'package:flutter/material.dart';

import '../../../app/models/auth/user.dart';
import '../../../widgets/ui/app_info_row.dart';
import '../models/admin_account_identity.dart';
import 'account_avatar.dart';
import 'admin_dialog_header.dart';
import 'admin_dialog_surface.dart';

class AdminAccountProfilePanel extends StatelessWidget {
  const AdminAccountProfilePanel({super.key, required this.user, this.onClose});

  final User user;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final identity = AdminAccountIdentity.fromUser(user);
    final colorScheme = Theme.of(context).colorScheme;
    final detailLabelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );
    final detailValueStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700);

    return AdminDialogSurface(
      maxWidth: 460,
      maxHeight: 560,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdminDialogHeader(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Signed-in workspace identity',
            onClose: onClose,
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: _ProfileSummary(identity: identity),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppInfoRow(
                  icon: Icons.mail_outline,
                  title: 'Email',
                  subtitle: identity.emailLabel,
                  padding: const EdgeInsets.only(bottom: 12),
                  titleStyle: detailLabelStyle,
                  subtitleStyle: detailValueStyle,
                  subtitleMaxLines: 2,
                  titleGap: 2,
                ),
                AppInfoRow(
                  icon: Icons.alternate_email,
                  title: 'Username',
                  subtitle: identity.usernameLabel,
                  padding: const EdgeInsets.only(bottom: 12),
                  titleStyle: detailLabelStyle,
                  subtitleStyle: detailValueStyle,
                  subtitleMaxLines: 2,
                  titleGap: 2,
                ),
                AppInfoRow(
                  icon: Icons.verified_user_outlined,
                  title: 'Role',
                  subtitle: identity.roleLabel,
                  padding: const EdgeInsets.only(bottom: 12),
                  titleStyle: detailLabelStyle,
                  subtitleStyle: detailValueStyle,
                  subtitleMaxLines: 2,
                  titleGap: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.identity});

  final AdminAccountIdentity identity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          AccountAvatar(identity: identity, radius: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  identity.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  identity.roleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
