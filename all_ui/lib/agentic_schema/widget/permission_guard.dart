import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionGuard extends ConsumerWidget {
  final Permission permission;
  final Widget child;
  final Widget? fallback;

  const PermissionGuard({
    Key? key,
    required this.permission,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rbacState = ref.watch(rbacProvider);

    if (rbacState.canPerform(permission)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

// ============================================================================
// TEAM MANAGEMENT UI
// ============================================================================

class TeamManagementDialog extends ConsumerWidget {
  const TeamManagementDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rbacState = ref.watch(rbacProvider);

    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 8),
                Text(
                  'Team Management',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                if (rbacState.canPerform(Permission.inviteUsers))
                  ElevatedButton.icon(
                    onPressed: () => _showInviteDialog(context, ref),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Invite User'),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Team members list
            Expanded(
              child: rbacState.teamMembers.isEmpty
                  ? const Center(child: Text('No team members yet'))
                  : ListView.builder(
                      itemCount: rbacState.teamMembers.length,
                      itemBuilder: (context, index) {
                        final member = rbacState.teamMembers[index];
                        return _TeamMemberCard(member: member);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const InviteUserDialog(),
    );
  }
}

class _TeamMemberCard extends ConsumerWidget {
  final UserRole member;

  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rbacState = ref.watch(rbacProvider);
    final roleDefinition = RoleDefinition.defaults[member.role]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleDefinition.color,
          child: Text(
            member.userName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(member.userName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.email),
            const SizedBox(height: 4),
            Chip(
              label: Text(roleDefinition.name),
              backgroundColor: roleDefinition.color.withOpacity(0.2),
              avatar: Icon(
                _getRoleIcon(member.role),
                size: 16,
                color: roleDefinition.color,
              ),
            ),
          ],
        ),
        trailing: rbacState.canPerform(Permission.managePermissions)
            ? PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change_role',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz),
                        SizedBox(width: 8),
                        Text('Change Role'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'permissions',
                    child: Row(
                      children: [
                        Icon(Icons.security),
                        SizedBox(width: 8),
                        Text('Manage Permissions'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'change_role':
                      _showChangeRoleDialog(context, ref, member);
                      break;
                    case 'permissions':
                      _showPermissionsDialog(context, ref, member);
                      break;
                    case 'remove':
                      _confirmRemove(context, ref, member);
                      break;
                  }
                },
              )
            : null,
      ),
    );
  }

  IconData _getRoleIcon(Role role) {
    switch (role) {
      case Role.viewer:
        return Icons.visibility;
      case Role.editor:
        return Icons.edit;
      case Role.admin:
        return Icons.admin_panel_settings;
      case Role.owner:
        return Icons.star;
      default:
        return Icons.person;
    }
  }

  void _showChangeRoleDialog(
    BuildContext context,
    WidgetRef ref,
    UserRole member,
  ) {
    showDialog(
      context: context,
      builder: (context) => ChangeRoleDialog(member: member),
    );
  }

  void _showPermissionsDialog(
    BuildContext context,
    WidgetRef ref,
    UserRole member,
  ) {
    showDialog(
      context: context,
      builder: (context) => PermissionsDialog(member: member),
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref, UserRole member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Team Member'),
        content: Text('Are you sure you want to remove ${member.userName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(rbacProvider.notifier).removeUser(member.userId);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
