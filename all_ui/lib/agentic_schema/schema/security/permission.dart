import 'role.dart';
import 'user_permission.dart';

class Permissions {
  final List<Role>? roles;
  final List<UserPermission>? users;

  Permissions({this.roles, this.users});

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(
      roles: json['roles'] != null
          ? (json['roles'] as List)
                .map((e) => Role.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      users: json['users'] != null
          ? (json['users'] as List)
                .map((e) => UserPermission.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (roles != null) 'roles': roles!.map((e) => e.toJson()).toList(),
      if (users != null) 'users': users!.map((e) => e.toJson()).toList(),
    };
  }
}
