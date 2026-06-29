import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

final usersProvider = Provider<List<User>>((ref) {
  return [
    User(
      id: 'user-001',
      name: 'Alex Johnson',
      email: 'alex.johnson@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      role: 'Project Manager',
      department: 'Engineering',
    ),
    User(
      id: 'user-002',
      name: 'Maria Garcia',
      email: 'maria.garcia@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      role: 'Designer',
      department: 'Design',
    ),
    User(
      id: 'user-003',
      name: 'David Chen',
      email: 'david.chen@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      role: 'Engineer',
      department: 'Engineering',
    ),
    User(
      id: 'user-004',
      name: 'Sarah Wilson',
      email: 'sarah.wilson@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=6',
      role: 'Engineer',
      department: 'Engineering',
    ),
    User(
      id: 'user-005',
      name: 'James Taylor',
      email: 'james.taylor@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=13',
      role: 'QA Engineer',
      department: 'Quality Assurance',
    ),
    User(
      id: 'user-006',
      name: 'Lisa Brown',
      email: 'lisa.brown@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=7',
      role: 'Product Manager',
      department: 'Product',
    ),
    User(
      id: 'user-007',
      name: 'Sophie Martin',
      email: 'sophie.martin@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      role: 'Project Manager',
      department: 'Engineering',
    ),
    User(
      id: 'user-008',
      name: 'Michael Wong',
      email: 'michael.wong@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      role: 'Marketing Manager',
      department: 'Marketing',
    ),
  ];
});
