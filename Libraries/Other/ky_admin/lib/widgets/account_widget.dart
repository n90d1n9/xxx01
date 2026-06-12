import 'package:flutter/material.dart';

import '../../../app/models/auth/user.dart';
import '../models/admin_account_identity.dart';
import '../services/admin_shell_layout_resolver.dart';
import 'account_avatar.dart';

enum AccountMenuAction { profile, settings, logout }

class AccountWidget extends StatelessWidget {
  const AccountWidget({
    super.key,
    required this.user,
    this.showCopy,
    this.onSelected,
  });

  final User user;
  final bool? showCopy;
  final ValueChanged<AccountMenuAction>? onSelected;

  @override
  Widget build(BuildContext context) {
    final identity = AdminAccountIdentity.fromUser(user);
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<AccountMenuAction>(
      offset: const Offset(0, 12),
      tooltip: 'Account',
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            PopupMenuItem<AccountMenuAction>(
              enabled: false,
              padding: EdgeInsets.zero,
              child: _AccountMenuHeader(identity: identity),
            ),
            const PopupMenuDivider(),
            _AccountMenuItem(
              action: AccountMenuAction.profile,
              icon: Icons.person_outline,
              label: 'Profile',
            ),
            _AccountMenuItem(
              action: AccountMenuAction.settings,
              icon: Icons.settings_outlined,
              label: 'Settings',
            ),
            const PopupMenuDivider(),
            _AccountMenuItem(
              action: AccountMenuAction.logout,
              icon: Icons.logout,
              label: 'Logout',
              foregroundColor: colorScheme.error,
            ),
          ],
      child: _AccountTrigger(identity: identity, showCopy: showCopy),
    );
  }
}

class _AccountTrigger extends StatelessWidget {
  const _AccountTrigger({required this.identity, required this.showCopy});

  final AdminAccountIdentity identity;
  final bool? showCopy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shouldShowCopy =
        showCopy ??
        resolveAdminShellLayout(
          MediaQuery.sizeOf(context).width,
        ).showAccountCopy;

    return Semantics(
      button: true,
      label: 'Account menu for ${identity.displayName}',
      child: Container(
        constraints: BoxConstraints(maxWidth: shouldShowCopy ? 230 : 44),
        padding: EdgeInsets.only(
          left: shouldShowCopy ? 6 : 0,
          right: shouldShowCopy ? 8 : 0,
          top: 5,
          bottom: 5,
        ),
        decoration: BoxDecoration(
          color:
              shouldShowCopy
                  ? colorScheme.surfaceContainerLow
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:
              shouldShowCopy
                  ? Border.all(color: colorScheme.outlineVariant)
                  : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AccountAvatar(identity: identity),
            if (shouldShowCopy) ...[
              const SizedBox(width: 9),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      identity.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      identity.roleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountMenuHeader extends StatelessWidget {
  const _AccountMenuHeader({required this.identity});

  final AdminAccountIdentity identity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      color: colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          AccountAvatar(identity: identity, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  identity.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  identity.emailLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

class _AccountMenuItem extends PopupMenuItem<AccountMenuAction> {
  _AccountMenuItem({
    required AccountMenuAction action,
    required IconData icon,
    required String label,
    Color? foregroundColor,
  }) : super(
         value: action,
         child: _AccountMenuItemContent(
           icon: icon,
           label: label,
           foregroundColor: foregroundColor,
         ),
       );
}

class _AccountMenuItemContent extends StatelessWidget {
  const _AccountMenuItemContent({
    required this.icon,
    required this.label,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
