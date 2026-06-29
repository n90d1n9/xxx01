import 'permission.dart';
import 'role_definition.dart';

class UserRole {
  final String userId;
  final String userName;
  final String email;
  final Role role;
  final Set<Permission> customPermissions;
  final DateTime assignedAt;
  final String? assignedBy;

  UserRole({
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
    this.customPermissions = const {},
    required this.assignedAt,
    this.assignedBy,
  });

  Set<Permission> get effectivePermissions {
    final basePermissions = RoleDefinition.defaults[role]?.permissions ?? {};
    return {...basePermissions, ...customPermissions};
  }

  bool hasPermission(Permission permission) {
    return effectivePermissions.contains(permission);
  }

  bool hasAnyPermission(Set<Permission> permissions) {
    return effectivePermissions.intersection(permissions).isNotEmpty;
  }

  bool hasAllPermissions(Set<Permission> permissions) {
    return permissions.every((p) => effectivePermissions.contains(p));
  }
}
