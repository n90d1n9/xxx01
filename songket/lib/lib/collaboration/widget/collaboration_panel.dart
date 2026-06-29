import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../collaboration_user.dart';
import '../comment.dart';
import '../comment_reply.dart';
import '../model/activity.dart';
import '../state/collaboration_provider.dart';
import '../user_role.dart';

class CollaborationPanel extends ConsumerWidget {
  const CollaborationPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collabState = ref.watch(collaborationProvider);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        border: Border(left: BorderSide(color: Colors.white24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Collaboration',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${collabState.activeUsers.where((u) => u.isOnline).length} online',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: Colors.blue,
                  tabs: const [
                    Tab(text: 'Users', icon: Icon(Icons.people, size: 16)),
                    Tab(text: 'Comments', icon: Icon(Icons.comment, size: 16)),
                    Tab(text: 'Activity', icon: Icon(Icons.history, size: 16)),
                  ],
                ),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    children: [
                      _UsersTab(users: collabState.activeUsers),
                      _CommentsTab(comments: collabState.comments),
                      _ActivityTab(activities: collabState.activityFeed),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  final List<CollaborationUser> users;

  const _UsersTab({required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Invite button
        ElevatedButton.icon(
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Invite User'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () => _showInviteDialog(context),
        ),
        const SizedBox(height: 16),

        // User list
        ...users.map((user) => _UserCard(user: user)),
      ],
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('Invite User', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: UserRole.editor,
              dropdownColor: const Color(0xFF2D2D2D),
              decoration: InputDecoration(
                labelText: 'Role',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(
                    role.toString().split('.').last,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📧 Invitation sent!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final CollaborationUser user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: user.color,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (user.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1E1E1E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              user.role.toString().split('.').last,
              style: TextStyle(
                color: _getRoleColor(user.role),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Colors.purple;
      case UserRole.editor:
        return Colors.blue;
      case UserRole.viewer:
        return Colors.grey;
    }
  }
}

class _CommentsTab extends ConsumerWidget {
  final List<Comment> comments;

  const _CommentsTab({required this.comments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unresolvedComments = comments.where((c) => !c.isResolved).toList();
    final resolvedComments = comments.where((c) => c.isResolved).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (unresolvedComments.isEmpty && resolvedComments.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.comment_outlined, size: 60, color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  'No comments yet',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          )
        else ...[
          if (unresolvedComments.isNotEmpty) ...[
            const Text(
              'OPEN',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...unresolvedComments.map((c) => _CommentCard(comment: c)),
            const SizedBox(height: 16),
          ],
          if (resolvedComments.isNotEmpty) ...[
            const Text(
              'RESOLVED',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...resolvedComments.map((c) => _CommentCard(comment: c)),
          ],
        ],
      ],
    );
  }
}

class _CommentCard extends ConsumerWidget {
  final Comment comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: comment.isResolved
              ? Colors.green.withOpacity(0.3)
              : Colors.white24,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blue,
                child: Text(
                  comment.userName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _formatTime(comment.createdAt),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!comment.isResolved)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  color: Colors.green,
                  onPressed: () {
                    ref
                        .read(collaborationProvider.notifier)
                        .resolveComment(comment.id);
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          if (comment.mentions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: comment.mentions.map((mention) {
                return Chip(
                  label: Text(
                    '@$mention',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.blue),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
          if (comment.replies.isNotEmpty) ...[
            const Divider(color: Colors.white24),
            ...comment.replies.map((reply) => _ReplyItem(reply: reply)),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ReplyItem extends StatelessWidget {
  final CommentReply reply;

  const _ReplyItem({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.grey,
            child: Text(
              reply.userName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 8),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reply.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  reply.text,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  final List<Activity> activities;

  const _ActivityTab({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.white24),
            const SizedBox(height: 16),
            Text('No activity yet', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _ActivityItem(activity: activity);
      },
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Activity activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: _getActivityColor(activity.type),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    children: [
                      TextSpan(
                        text: activity.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' ${activity.description}'),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(activity.timestamp),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.fieldAdded:
        return Colors.green;
      case ActivityType.fieldDeleted:
        return Colors.red;
      case ActivityType.fieldUpdated:
        return Colors.blue;
      case ActivityType.commentAdded:
        return Colors.orange;
      case ActivityType.userJoined:
        return Colors.purple;
      case ActivityType.userLeft:
        return Colors.grey;
      case ActivityType.formPublished:
        return Colors.green;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.fieldAdded:
        return Icons.add_circle;
      case ActivityType.fieldDeleted:
        return Icons.delete;
      case ActivityType.fieldUpdated:
        return Icons.edit;
      case ActivityType.commentAdded:
        return Icons.comment;
      case ActivityType.userJoined:
        return Icons.login;
      case ActivityType.userLeft:
        return Icons.logout;
      case ActivityType.formPublished:
        return Icons.publish;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
