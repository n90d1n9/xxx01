import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../shared/theme/gantt_theme.dart';

// ─── Role model ───────────────────────────────────────────────────────────────

enum ProjectRole {
  viewer, // read-only
  commenter, // can comment only
  editor, // can edit tasks
  manager, // can assign, lock, set constraints
  owner; // full control including role management

  bool get canEdit => index >= editor.index;
  bool get canManage => index >= manager.index;
  bool get canComment => index >= commenter.index;
  bool get canAssign => index >= manager.index;
  bool get canLock => index >= manager.index;
  bool get canExport => index >= editor.index;
  bool get canDelete => index >= manager.index;
  bool get canManageRoles => this == owner;

  String get label => name[0].toUpperCase() + name.substring(1);

  Color get color => switch (this) {
        ProjectRole.viewer => const Color(0xFF64748B),
        ProjectRole.commenter => const Color(0xFF06B6D4),
        ProjectRole.editor => const Color(0xFF6366F1),
        ProjectRole.manager => const Color(0xFFF59E0B),
        ProjectRole.owner => const Color(0xFFEF4444),
      };

  IconData get icon => switch (this) {
        ProjectRole.viewer => Icons.visibility_outlined,
        ProjectRole.commenter => Icons.comment_outlined,
        ProjectRole.editor => Icons.edit_outlined,
        ProjectRole.manager => Icons.manage_accounts_outlined,
        ProjectRole.owner => Icons.admin_panel_settings_outlined,
      };
}

class ProjectUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final ProjectRole role;

  const ProjectUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
  });

  ProjectUser copyWith({ProjectRole? role}) => ProjectUser(
        id: id,
        name: name,
        email: email,
        avatarUrl: avatarUrl,
        role: role ?? this.role,
      );

  bool get canEdit => role.canEdit;
  bool get canManage => role.canManage;
  bool get canComment => role.canComment;
  bool get canDelete => role.canDelete;
}

// ─── Providers ────────────────────────────────────────────────────────────────

final currentUserProvider = StateProvider<ProjectUser?>((ref) => _demoUser);

final projectUsersProvider =
    StateNotifierProvider<ProjectUsersNotifier, List<ProjectUser>>(
        (ref) => ProjectUsersNotifier());

class ProjectUsersNotifier extends StateNotifier<List<ProjectUser>> {
  ProjectUsersNotifier() : super(_demoUsers);

  void updateRole(String userId, ProjectRole role) {
    state =
        state.map((u) => u.id == userId ? u.copyWith(role: role) : u).toList();
  }

  void remove(String userId) =>
      state = state.where((u) => u.id != userId).toList();

  void add(ProjectUser user) => state = [...state, user];
}

// Demo data
const _demoUser = ProjectUser(
  id: 'user_1',
  name: 'You (Owner)',
  email: 'owner@company.com',
  role: ProjectRole.owner,
);

final _demoUsers = [
  _demoUser,
  const ProjectUser(
      id: 'user_2',
      name: 'Alice Chen',
      email: 'alice@company.com',
      role: ProjectRole.editor),
  const ProjectUser(
      id: 'user_3',
      name: 'Bob Torres',
      email: 'bob@company.com',
      role: ProjectRole.manager),
  const ProjectUser(
      id: 'user_4',
      name: 'Carol Smith',
      email: 'carol@company.com',
      role: ProjectRole.viewer),
  const ProjectUser(
      id: 'user_5',
      name: 'Dave Nguyen',
      email: 'dave@company.com',
      role: ProjectRole.commenter),
];

// ─── Guard widget ─────────────────────────────────────────────────────────────

/// Wraps a widget and shows a lock/disabled state if the current user
/// doesn't have the required permission.
class RoleGuard extends ConsumerWidget {
  final bool Function(ProjectRole) permission;
  final Widget child;
  final Widget? fallback;
  final String? tooltip;

  const RoleGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final allowed = user != null && permission(user.role);

    if (allowed) return child;

    final locked = fallback ?? const SizedBox.shrink();
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: locked);
    }
    return locked;
  }
}

/// Returns true if current user passes the permission check.
bool checkPermission(WidgetRef ref, bool Function(ProjectRole) permission) {
  final user = ref.read(currentUserProvider);
  return user != null && permission(user.role);
}

// ─── Team members panel ───────────────────────────────────────────────────────

class TeamMembersPanel extends ConsumerWidget {
  const TeamMembersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(projectUsersProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser?.role == ProjectRole.owner;

    return Container(
      width: 340,
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(left: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Column(children: [
        // Header
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: GanttTheme.surface4))),
          child: Row(children: [
            const Icon(Icons.people_outline,
                size: 16, color: GanttTheme.textSecondary),
            const SizedBox(width: 8),
            const Text('Team Members',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: GanttTheme.textPrimary)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                  color: GanttTheme.surface3,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('${users.length}',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: GanttTheme.textSecondary)),
            ),
            const Spacer(),
            if (isOwner)
              IconButton(
                icon: const Icon(Icons.person_add_outlined, size: 14),
                color: GanttTheme.accentLight,
                tooltip: 'Invite member',
                onPressed: () => _showInviteDialog(context, ref),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
          ]),
        ),
        // Role summary chips
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
              children: ProjectRole.values.map((r) {
            final count = users.where((u) => u.role == r).length;
            if (count == 0) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: r.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count ${r.label}${count > 1 ? 's' : ''}',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: r.color)),
            );
          }).toList()),
        ),
        const Divider(height: 1, color: GanttTheme.surface4),
        // User list
        Expanded(
            child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: users.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: GanttTheme.surface4),
          itemBuilder: (_, i) => _UserRow(
            user: users[i],
            canManage: isOwner && users[i].id != currentUser?.id,
          ),
        )),
      ]),
    );
  }

  void _showInviteDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (_) => _InviteDialog());
  }
}

class _UserRow extends ConsumerWidget {
  final ProjectUser user;
  final bool canManage;
  const _UserRow({required this.user, required this.canManage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(children: [
        // Avatar
        CircleAvatar(
          radius: 16,
          backgroundColor: user.role.color.withOpacity(0.2),
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(user.name[0].toUpperCase(),
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: user.role.color))
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.name,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: GanttTheme.textPrimary)),
          Text(user.email,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: GanttTheme.textMuted)),
        ])),
        // Role badge / dropdown
        if (canManage)
          DropdownButton<ProjectRole>(
            value: user.role,
            underline: const SizedBox.shrink(),
            icon: const SizedBox.shrink(),
            isDense: true,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: user.role.color),
            dropdownColor: GanttTheme.surface2,
            items: ProjectRole.values
                .map((r) => DropdownMenuItem(
                      value: r,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(r.icon, size: 12, color: r.color),
                        const SizedBox(width: 6),
                        Text(r.label,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: r.color)),
                      ]),
                    ))
                .toList(),
            onChanged: (r) {
              if (r != null)
                ref.read(projectUsersProvider.notifier).updateRole(user.id, r);
            },
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: user.role.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(user.role.icon, size: 10, color: user.role.color),
              const SizedBox(width: 4),
              Text(user.role.label,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: user.role.color)),
            ]),
          ),
      ]),
    );
  }
}

class _InviteDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<_InviteDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  ProjectRole _role = ProjectRole.editor;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: GanttTheme.surface2,
        title: const Text('Invite Team Member',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GanttTheme.textPrimary)),
        content: SizedBox(
            width: 300,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: GanttTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 10),
              TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: GanttTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 10),
              DropdownButtonFormField<ProjectRole>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ProjectRole.values
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.label,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: GanttTheme.textPrimary)),
                        ))
                    .toList(),
                onChanged: (r) => setState(() => _role = r!),
              ),
            ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty ||
                  _emailCtrl.text.trim().isEmpty) return;
              ref.read(projectUsersProvider.notifier).add(ProjectUser(
                    id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                    name: _nameCtrl.text.trim(),
                    email: _emailCtrl.text.trim(),
                    role: _role,
                  ));
              Navigator.pop(context);
            },
            child: const Text('Send Invite'),
          ),
        ],
      );
}
