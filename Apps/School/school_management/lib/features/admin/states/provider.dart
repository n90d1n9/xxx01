// Theme mode provider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/models/auth/user.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// User provider
final userProvider = Provider(
  (ref) => User(
    firstName: 'Alex',
    lastName: 'Johnson',
    email: 'alex@example.com',
    imageUrl: 'https://i.pravatar.cc/150?img=12',
    role: UserRole.admin,
    id: 0,
  ),
);

// Example user model
/* class User {
  final String name;
  final String email;
  final String avatarUrl;
  final String role;

  User({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
  });
} */

// Current route provider
final currentRouteProvider = StateProvider<String>((ref) => '/dashboard');
