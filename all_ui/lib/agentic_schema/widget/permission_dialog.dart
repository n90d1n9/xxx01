import 'package:flutter/material.dart';

class PermissionsDialog extends ConsumerStatefulWidget {
  final UserRole member;

  const PermissionsDialog({Key? key, required this.member}) : super(key: key);

  @override
  ConsumerState<PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends ConsumerState<PermissionsDialog> {
  late Set<Permission> _selectedPermissions;

  @override
  void initState() {
    super.initState();
    _selectedPermissions = widget.member.effectivePermissions;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Manage Permissions for ${widget.member.userName}'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: ListView(
          children: Permission.values.map((permission) {
            return CheckboxListTile(
              value: _selectedPermissions.contains(permission),
              title: Text(_formatPermission(permission)),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedPermissions.add(permission);
                  } else {
                    _selectedPermissions.remove(permission);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Save custom permissions
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _formatPermission(Permission permission) {
    return permission.name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim();
  }
}
