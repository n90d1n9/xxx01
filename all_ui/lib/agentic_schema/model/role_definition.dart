import 'package:flutter/material.dart';

import 'permission.dart';

enum Role { viewer, editor, admin, owner, custom }

class RoleDefinition {
  final Role role;
  final String name;
  final String description;
  final Set<Permission> permissions;
  final Color color;

  RoleDefinition({
    required this.role,
    required this.name,
    required this.description,
    required this.permissions,
    required this.color,
  });

  static final Map<Role, RoleDefinition> defaults = {
    Role.viewer: RoleDefinition(
      role: Role.viewer,
      name: 'Viewer',
      description: 'Can view workflows but not edit',
      permissions: {Permission.workflowView, Permission.workflowExecute},
      color: Colors.grey,
    ),
    Role.editor: RoleDefinition(
      role: Role.editor,
      name: 'Editor',
      description: 'Can create and edit workflows',
      permissions: {
        Permission.workflowView,
        Permission.workflowEdit,
        Permission.workflowExecute,
        Permission.nodeCreate,
        Permission.nodeEdit,
        Permission.nodeDelete,
      },
      color: Colors.blue,
    ),
    Role.admin: RoleDefinition(
      role: Role.admin,
      name: 'Admin',
      description: 'Full access to workflows and team management',
      permissions: {
        Permission.workflowView,
        Permission.workflowEdit,
        Permission.workflowDelete,
        Permission.workflowExecute,
        Permission.workflowPublish,
        Permission.nodeCreate,
        Permission.nodeEdit,
        Permission.nodeDelete,
        Permission.inviteUsers,
        Permission.managePermissions,
        Permission.viewAuditLog,
      },
      color: Colors.orange,
    ),
    Role.owner: RoleDefinition(
      role: Role.owner,
      name: 'Owner',
      description: 'Organization owner with all permissions',
      permissions: Permission.values.toSet(),
      color: Colors.purple,
    ),
  };
}
