import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/collaborative_user.dart';
import '../../state/collaboration_provider.dart';
import '../../state/workflow/workflow_provider.dart';
import '../chat_message_bubble.dart';

class CollaborationChatPanel extends ConsumerStatefulWidget {
  const CollaborationChatPanel({super.key});

  @override
  ConsumerState<CollaborationChatPanel> createState() =>
      _CollaborationChatPanelState();
}

class _CollaborationChatPanelState
    extends ConsumerState<CollaborationChatPanel> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAutoScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final threshold = _scrollController.position.maxScrollExtent - 100;
    _isAutoScroll = _scrollController.position.pixels >= threshold;
  }

  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);
    if (workflowState.currentWorkflow == null) return const SizedBox.shrink();

    final collaborationState = ref.watch(
      collaborationProvider(workflowState.currentWorkflow!.id),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline),
                const SizedBox(width: 12),
                const Text(
                  'Team Chat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                if (collaborationState.users.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      collaborationState.users.length.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close chat',
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: collaborationState.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: collaborationState.messages.length,
                    itemBuilder: (context, index) {
                      final message = collaborationState.messages[index];
                      final isCurrentUser =
                          message.userId == collaborationState.currentUser?.id;

                      return ChatMessageBubble(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        userColor: _getUserColor(
                          message.userId,
                          collaborationState.users,
                        ),
                        onReply: (replyToId) {
                          _messageController.text = '@${message.userName} ';
                          _messageController.selection =
                              TextSelection.collapsed(
                                offset: _messageController.text.length,
                              );
                        },
                      );
                    },
                  ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        onPressed: () {
                          // TODO: Add emoji picker
                        },
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: _messageController.text.trim().isEmpty
                      ? IconButton(
                          icon: const Icon(Icons.mic),
                          onPressed: () {
                            // TODO: Add voice message
                          },
                        )
                      : FloatingActionButton.small(
                          onPressed: _sendMessage,
                          child: const Icon(Icons.send),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final workflowState = ref.read(workflowProvider);
    if (workflowState.currentWorkflow == null) return;

    ref
        .read(collaborationProvider(workflowState.currentWorkflow!.id).notifier)
        .sendChatMessage(text);

    _messageController.clear();
    setState(() {});

    // Auto-scroll to bottom
    if (_isAutoScroll) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getUserColor(String userId, Map<String, CollaborativeUser> users) {
    final user = users[userId];
    return user?.color ?? Colors.grey;
  }
}
