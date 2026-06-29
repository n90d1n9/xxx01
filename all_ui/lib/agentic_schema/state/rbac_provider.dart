import 'package:flutter_riverpod/legacy.dart';

import '../model/permission.dart';
import '../model/role_definition.dart';
import '../model/user_role.dart';

class RBACState {
  final UserRole? currentUser;
  final List<UserRole> teamMembers;
  final Map<String, Set<Permission>> resourcePermissions;
  final bool isLoading;
  final String? error;

  RBACState({
    this.currentUser,
    this.teamMembers = const [],
    this.resourcePermissions = const {},
    this.isLoading = false,
    this.error,
  });

  RBACState copyWith({
    UserRole? currentUser,
    List<UserRole>? teamMembers,
    Map<String, Set<Permission>>? resourcePermissions,
    bool? isLoading,
    String? error,
  }) {
    return RBACState(
      currentUser: currentUser ?? this.currentUser,
      teamMembers: teamMembers ?? this.teamMembers,
      resourcePermissions: resourcePermissions ?? this.resourcePermissions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool canPerform(Permission permission) {
    return currentUser?.hasPermission(permission) ?? false;
  }

  bool canAccessResource(String resourceId, Permission permission) {
    // Check resource-specific permissions
    final resourcePerms = resourcePermissions[resourceId];
    if (resourcePerms != null && !resourcePerms.contains(permission)) {
      return false;
    }
    return canPerform(permission);
  }
}

class RBACNotifier extends StateNotifier<RBACState> {
  RBACNotifier() : super(RBACState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load current user and team members from API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      final currentUser = UserRole(
        userId: 'user123',
        userName: 'John Doe',
        email: 'john@example.com',
        role: Role.admin,
        assignedAt: DateTime.now(),
      );

      state = state.copyWith(
        currentUser: currentUser,
        teamMembers: [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> inviteUser(String email, Role role) async {
    if (!state.canPerform(Permission.inviteUsers)) {
      throw Exception('Permission denied: Cannot invite users');
    }

    try {
      // Send invitation via API
      await Future.delayed(const Duration(milliseconds: 500));

      // Refresh team members
      await _loadTeamMembers();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateUserRole(String userId, Role newRole) async {
    if (!state.canPerform(Permission.managePermissions)) {
      throw Exception('Permission denied: Cannot manage permissions');
    }

    try {
      // Update via API
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local state
      final updatedMembers =
          state.teamMembers.map((member) {
            if (member.userId == userId) {
              return UserRole(
                userId: member.userId,
                userName: member.userName,
                email: member.email,
                role: newRole,
                assignedAt: DateTime.now(),
                assignedBy: state.currentUser?.userId,
              );
            }
            return member;
          }).toList();

      state = state.copyWith(teamMembers: updatedMembers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> removeUser(String userId) async {
    if (!state.canPerform(Permission.managePermissions)) {
      throw Exception('Permission denied: Cannot manage permissions');
    }

    try {
      // Remove via API
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedMembers =
          state.teamMembers.where((member) => member.userId != userId).toList();

      state = state.copyWith(teamMembers: updatedMembers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> setResourcePermissions(
    String resourceId,
    Set<Permission> permissions,
  ) async {
    final updatedPerms = Map<String, Set<Permission>>.from(
      state.resourcePermissions,
    );
    updatedPerms[resourceId] = permissions;

    state = state.copyWith(resourcePermissions: updatedPerms);
  }

  Future<void> _loadTeamMembers() async {
    // Load from API
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

final rbacProvider = StateNotifierProvider<RBACNotifier, RBACState>(
  (ref) => RBACNotifier(),
);
