import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = Provider<User>((ref) {
  return User(
    id: 'u1',
    name: 'Alex Johnson',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    role: 'Software Developer',
  );
});

class User {
  final String id;
  final String name;
  final String avatarUrl;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.role,
  });
}
