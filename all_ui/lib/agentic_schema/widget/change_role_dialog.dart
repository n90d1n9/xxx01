import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/user_role.dart';
import '../schema/security/role.dart';
import '../state/rbac_provider.dart';

class ChangeRoleDialog extends ConsumerStatefulWidget {
  final UserRole member;

  const ChangeRoleDialog({super.key, required this.member});

  @override
  ConsumerState<ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends ConsumerState<ChangeRoleDialog> {
  late Role _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.member.role;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Role for ${widget.member.userName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...Role.values.where((r) => r != Role.custom).map((role) {
            final roleDef = RoleDefinition.defaults[role]!;
            return RadioListTile<Role>(
              value: role,
              groupValue: _selectedRole,
              title: Text(roleDef.name),
              subtitle: Text(roleDef.description),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRole = value);
                }
              },
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await ref
                .read(rbacProvider.notifier)
                .updateUserRole(widget.member.userId, _selectedRole);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
