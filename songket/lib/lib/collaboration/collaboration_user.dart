import 'package:flutter/material.dart';

import 'user_role.dart';

class CollaborationUser {
  final String id;
  final String name;
  final String email;
  final Color color;
  final String? avatarUrl;
  final DateTime lastActive;
  final bool isOnline;
  final UserRole role;

  const CollaborationUser({
    required this.id,
    required this.name,
    required this.email,
    required this.color,
    this.avatarUrl,
    required this.lastActive,
    this.isOnline = false,
    this.role = UserRole.viewer,
  });
}
