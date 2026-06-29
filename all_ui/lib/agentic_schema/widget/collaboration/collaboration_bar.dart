import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/collaborative_user.dart';
import '../../state/collaboration_provider.dart';
import '../../state/collaboration_state.dart';
import '../../state/workflow/workflow_provider.dart';
import 'collaborative_chat_panel.dart';

class CollaborationBar extends ConsumerWidget {
  const CollaborationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowState = ref.watch(workflowProvider);
    if (workflowState.currentWorkflow == null) return const SizedBox.shrink();

    final collaborationState = ref.watch(
      collaborationProvider(workflowState.currentWorkflow!.id),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 48,
      decoration: BoxDecoration(
        color: _getStatusColor(collaborationState.connectionStatus),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          if (collaborationState.connectionStatus == ConnectionStatus.connected)
            BoxShadow(
              color: Colors.green.shade100,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),

          // Connection status with animation
          _ConnectionStatusIndicator(collaborationState.connectionStatus),
          const SizedBox(width: 8),
          _ConnectionStatusText(collaborationState.connectionStatus),

          const SizedBox(width: 16),
          const VerticalDivider(),
          const SizedBox(width: 16),

          // Active users section
          if (collaborationState.users.isNotEmpty) ...[
            const Icon(Icons.people_outline, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              '${collaborationState.users.length}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(width: 4),
            Text(
              'online',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(width: 16),

            // User avatars with better tooltips
            ..._buildUserAvatars(collaborationState.users),

            if (collaborationState.users.length > 5)
              Tooltip(
                message: _getAdditionalUsersText(collaborationState.users),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    '+${collaborationState.users.length - 5}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ] else if (collaborationState.isConnected) ...[
            const Icon(Icons.person_outline, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Alone here',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(width: 16),
          ],

          const Spacer(),

          // Error indicator
          if (collaborationState.error != null)
            Tooltip(
              message: collaborationState.error!,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Connection issue',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Action buttons
          _CollaborationActions(workflowId: workflowState.currentWorkflow!.id),
        ],
      ),
    );
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green.shade50;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Colors.blue.shade50;
      case ConnectionStatus.disconnected:
        return Colors.grey.shade100;
    }
  }

  List<Widget> _buildUserAvatars(Map<String, CollaborativeUser> users) {
    return users.values.take(5).map((user) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Tooltip(
          message: '${user.name}\nLast seen: ${_formatLastSeen(user.lastSeen)}',
          child: Stack(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: user.color,
                child: Text(
                  user.name.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              // Online indicator
              if (user.isActive &&
                  user.lastSeen.isAfter(
                    DateTime.now().subtract(const Duration(minutes: 1)),
                  ))
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _getAdditionalUsersText(Map<String, CollaborativeUser> users) {
    final additionalUsers = users.values.skip(5);
    return additionalUsers.map((user) => user.name).join(', ');
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class _ConnectionStatusIndicator extends StatelessWidget {
  final ConnectionStatus status;

  const _ConnectionStatusIndicator(this.status);

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      ConnectionStatus.connected => Icons.cloud_done,
      ConnectionStatus.connecting => Icons.cloud_queue,
      ConnectionStatus.reconnecting => Icons.cloud_sync,
      ConnectionStatus.disconnected => Icons.cloud_off,
    };

    final color = switch (status) {
      ConnectionStatus.connected => Colors.green,
      ConnectionStatus.connecting => Colors.blue,
      ConnectionStatus.reconnecting => Colors.orange,
      ConnectionStatus.disconnected => Colors.grey,
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Icon(icon, key: ValueKey(status), color: color, size: 20),
    );
  }
}

class _ConnectionStatusText extends StatelessWidget {
  final ConnectionStatus status;

  const _ConnectionStatusText(this.status);

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      ConnectionStatus.connected => 'Connected',
      ConnectionStatus.connecting => 'Connecting...',
      ConnectionStatus.reconnecting => 'Reconnecting...',
      ConnectionStatus.disconnected => 'Offline',
    };

    final color = switch (status) {
      ConnectionStatus.connected => Colors.green,
      ConnectionStatus.connecting => Colors.blue,
      ConnectionStatus.reconnecting => Colors.orange,
      ConnectionStatus.disconnected => Colors.grey,
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey(status),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CollaborationActions extends ConsumerWidget {
  final String workflowId;

  const _CollaborationActions({required this.workflowId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collaborationState = ref.watch(collaborationProvider(workflowId));
    final hasUnreadMessages = collaborationState.messages.any(
      (msg) => msg.timestamp.isAfter(
        DateTime.now().subtract(const Duration(hours: 1)),
      ),
    );

    return Row(
      children: [
        // Share button
        Tooltip(
          message: 'Copy share link',
          child: IconButton(
            icon: const Icon(Icons.link),
            onPressed: () => _copyShareLink(context, workflowId),
          ),
        ),

        // Chat button with badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_outlined),
              onPressed: () => _openChat(context, workflowId),
            ),
            if (hasUnreadMessages)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),

        // Settings menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) =>
              _handleMenuAction(context, value, workflowId, ref),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'invite',
              child: Row(
                children: [
                  Icon(Icons.person_add, size: 20),
                  SizedBox(width: 8),
                  Text('Invite people'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 8),
                  Text('Collaboration settings'),
                ],
              ),
            ),
            if (collaborationState.isConnected)
              const PopupMenuItem(
                value: 'disconnect',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Disconnect'),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _copyShareLink(BuildContext context, String workflowId) {
    final link = 'https://app.aiagent.com/workflow/$workflowId';
    // Copy to clipboard implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share link copied to clipboard!'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            // Open link
          },
        ),
      ),
    );
  }

  void _openChat(BuildContext context, String workflowId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CollaborationChatPanel(),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String value,
    String workflowId,
    WidgetRef ref,
  ) {
    switch (value) {
      case 'invite':
        _showInviteDialog(context, workflowId);
        break;
      case 'settings':
        _showSettingsDialog(context, workflowId, ref);
        break;
      case 'disconnect':
        ref.read(collaborationProvider(workflowId).notifier).disconnect();
        break;
    }
  }

  void _showInviteDialog(BuildContext context, String workflowId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite to collaborate'),
        content: const Text(
          'Share this link with others to collaborate in real-time:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _copyShareLink(context, workflowId);
              Navigator.of(context).pop();
            },
            child: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(
    BuildContext context,
    String workflowId,
    WidgetRef ref,
  ) {
    // Implementation for collaboration settings
  }
}
