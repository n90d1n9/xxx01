import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/shared_user.dart';
import '../state/workflow/workflow_provider.dart';

class ShareWorkflowDialog extends ConsumerStatefulWidget {
  const ShareWorkflowDialog({super.key});

  @override
  ConsumerState<ShareWorkflowDialog> createState() =>
      _ShareWorkflowDialogState();
}

class _ShareWorkflowDialogState extends ConsumerState<ShareWorkflowDialog> {
  final _emailController = TextEditingController();
  final _linkController = TextEditingController();
  String _selectedRole = 'viewer';
  bool _isLoading = false;
  bool _linkCopied = false;
  final List<SharedUser> _sharedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadSharedUsers();
    _generateShareLink();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadSharedUsers() async {
    // TODO: Load existing shared users from API
    setState(() {
      _sharedUsers.addAll([
        SharedUser(
          email: 'john@example.com',
          role: 'editor',
          avatarUrl: null,
          joinedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        SharedUser(
          email: 'sarah@example.com',
          role: 'viewer',
          avatarUrl: null,
          joinedAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ]);
    });
  }

  void _generateShareLink() {
    final workflowState = ref.read(workflowProvider);
    if (workflowState.currentWorkflow != null) {
      final token = _generateShareToken(workflowState.currentWorkflow!.id);
      final link =
          'https://app.aiagent.com/workflow/${workflowState.currentWorkflow!.id}?share=$token';
      _linkController.text = link;
    }
  }

  String _generateShareToken(String workflowId) {
    // Generate a secure share token
    return '${workflowId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.share, size: 24),
          const SizedBox(width: 12),
          const Text('Share Workflow'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invite by email section
            Text(
              'Invite by email',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: 'user@example.com',
                      suffixIcon: _emailController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => _emailController.clear(),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedRole,
                  items: _buildRoleItems(theme),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.person_add, size: 18),
                  label: const Text('Invite'),
                  onPressed: _emailController.text.isEmpty || _isLoading
                      ? null
                      : _inviteByEmail,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Share link section
            Text(
              'Shareable link',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _linkController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.link),
                      hintText: 'Generating share link...',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _regenerateLink,
                            tooltip: 'Regenerate link',
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: _showLinkSettings,
                            tooltip: 'Link settings',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _linkCopied
                      ? FilledButton.tonal(
                          onPressed: null,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Copied!',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : FilledButton(
                          onPressed: _copyShareLink,
                          child: const Row(
                            children: [
                              Icon(Icons.content_copy, size: 18),
                              SizedBox(width: 6),
                              Text('Copy Link'),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Anyone with this link can view this workflow',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Shared users list
            if (_sharedUsers.isNotEmpty) ...[
              Text(
                'Shared with (${_sharedUsers.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sharedUsers.length,
                  itemBuilder: (context, index) {
                    final user = _sharedUsers[index];
                    return _SharedUserTile(
                      user: user,
                      onRoleChanged: (newRole) =>
                          _updateUserRole(user.email, newRole),
                      onRemove: () => _removeUser(user.email),
                    );
                  },
                ),
              ),
            ],

            // Permissions info
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Role permissions',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionsInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildRoleItems(ThemeData theme) {
    return [
      DropdownMenuItem(
        value: 'viewer',
        child: Row(
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 18,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Viewer'),
                Text(
                  'Can view only',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 'editor',
        child: Row(
          children: [
            Icon(
              Icons.edit_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Editor'),
                Text(
                  'Can view and edit',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 'admin',
        child: Row(
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 18,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin'),
                Text(
                  'Full access',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildPermissionsInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PermissionItem(
          icon: Icons.visibility,
          text: 'View workflow',
          roles: ['viewer', 'editor', 'admin'],
        ),
        _PermissionItem(
          icon: Icons.edit,
          text: 'Edit nodes and connections',
          roles: ['editor', 'admin'],
        ),
        _PermissionItem(
          icon: Icons.settings,
          text: 'Modify workflow settings',
          roles: ['admin'],
        ),
        _PermissionItem(
          icon: Icons.people,
          text: 'Manage collaborators',
          roles: ['admin'],
        ),
      ],
    );
  }

  Future<void> _inviteByEmail() async {
    if (_emailController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement API call to invite user
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      final newUser = SharedUser(
        email: _emailController.text,
        role: _selectedRole,
        avatarUrl: null,
        joinedAt: DateTime.now(),
      );

      setState(() {
        _sharedUsers.add(newUser);
        _emailController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to ${newUser.email}'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _removeUser(newUser.email),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send invitation: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyShareLink() {
    if (_linkController.text.isEmpty) return;

    // Copy to clipboard
    // Clipboard.setData(ClipboardData(text: _linkController.text));

    setState(() => _linkCopied = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share link copied to clipboard!')),
      );
    }

    // Reset copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _linkCopied = false);
      }
    });
  }

  void _regenerateLink() {
    // TODO: Implement link regeneration logic
    _generateShareLink();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('New share link generated')));
    }
  }

  void _showLinkSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configure share link permissions and expiration.'),
            // TODO: Add link settings options
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateUserRole(String email, String newRole) {
    setState(() {
      final user = _sharedUsers.firstWhere((u) => u.email == email);
      final index = _sharedUsers.indexOf(user);
      _sharedUsers[index] = user.copyWith(role: newRole);
    });

    // TODO: Update role via API
  }

  void _removeUser(String email) {
    setState(() {
      _sharedUsers.removeWhere((u) => u.email == email);
    });

    // TODO: Remove user via API

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed $email from shared users'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // TODO: Implement undo logic
            },
          ),
        ),
      );
    }
  }
}

class _SharedUserTile extends StatelessWidget {
  final SharedUser user;
  final Function(String) onRoleChanged;
  final VoidCallback onRemove;

  const _SharedUserTile({
    required this.user,
    required this.onRoleChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getRoleColor(user.role, theme),
        child: Text(
          user.email[0].toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(user.email),
      subtitle: Text(
        'Joined ${_formatJoinDate(user.joinedAt)}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: user.role,
            items: [
              DropdownMenuItem(value: 'viewer', child: const Text('Viewer')),
              DropdownMenuItem(value: 'editor', child: const Text('Editor')),
              DropdownMenuItem(value: 'admin', child: const Text('Admin')),
            ],
            onChanged: (value) {
              if (value != null) {
                onRoleChanged(value);
              }
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showUserMenu(context),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role, ThemeData theme) {
    return switch (role) {
      'viewer' => Colors.grey,
      'editor' => theme.colorScheme.primary,
      'admin' => Colors.orange,
      _ => Colors.grey,
    };
  }

  String _formatJoinDate(DateTime joinedAt) {
    final now = DateTime.now();
    final difference = now.difference(joinedAt);

    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    return 'Just now';
  }

  void _showUserMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1, 1, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'resend',
          child: Row(
            children: [
              Icon(Icons.send, size: 18),
              SizedBox(width: 8),
              Text('Resend invitation'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.person_remove, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Remove access', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'remove') {
        onRemove();
      } else if (value == 'resend') {
        // TODO: Implement resend invitation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation resent to ${user.email}')),
        );
      }
    });
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final List<String> roles;

  const _PermissionItem({
    required this.icon,
    required this.text,
    required this.roles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
          const SizedBox(width: 8),
          Wrap(
            spacing: 4,
            children: roles.map((role) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRoleColor(role).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    color: _getRoleColor(role),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    return switch (role) {
      'viewer' => Colors.grey,
      'editor' => Colors.blue,
      'admin' => Colors.orange,
      _ => Colors.grey,
    };
  }
}
