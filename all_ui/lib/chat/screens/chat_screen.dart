import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/attachment.dart';
import '../models/chat_room.dart';
import '../models/location.dart';
import '../models/message.dart';
import '../models/voice_note.dart';
import '../states/call_provider.dart';
import '../states/chat_provider.dart';
import '../states/message_provider.dart';
import '../states/typing_provider.dart';
import '../states/user_provider.dart';
import '../states/voice_note_provider.dart';
import '../widgets/emoji_picker.dart';
import 'chat_info_screen.dart';
import 'media_gallery_screen.dart';
import 'search_in_chat_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatRoom room;

  const ChatScreen({super.key, required this.room});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _reactionAnimationController;
  late AnimationController _typingAnimationController;

  bool _isEmojiPickerVisible = false;
  bool _isRecording = false;
  String? _replyingToMessageId;

  @override
  void initState() {
    super.initState();
    _reactionAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _typingAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _reactionAnimationController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.room.id));
    final typingUsers = ref.watch(typingUsersProvider(widget.room.id));
    final voiceRecording = ref.watch(voiceRecordingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Chat messages
                ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length + (typingUsers.isNotEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 0 && typingUsers.isNotEmpty) {
                      return _buildTypingIndicator(typingUsers);
                    }
                    final messageIndex =
                        typingUsers.isNotEmpty ? index - 1 : index;
                    final message =
                        messages[messages.length - 1 - messageIndex];
                    return _buildMessageItem(message);
                  },
                ),
                // Reply preview
                if (_replyingToMessageId != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildReplyPreview(),
                  ),
              ],
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[900],
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: () => _showChatInfo(),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    widget.room.theme.primaryColor,
                    widget.room.theme.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipOval(
                child:
                    widget.room.avatar != null
                        ? CachedNetworkImage(
                          imageUrl: widget.room.avatar!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Icon(
                                widget.room.isGroup
                                    ? Icons.group
                                    : Icons.person,
                                color: Colors.white,
                              ),
                          errorWidget:
                              (context, url, error) => Icon(
                                widget.room.isGroup
                                    ? Icons.group
                                    : Icons.person,
                                color: Colors.white,
                              ),
                        )
                        : Icon(
                          widget.room.isGroup ? Icons.group : Icons.person,
                          color: Colors.white,
                        ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.room.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.room.isGroup)
                    Text(
                      '${widget.room.participants.length} members',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    )
                  else
                    Text(
                      widget.room.isOnline ? 'Online' : 'Last seen recently',
                      style: TextStyle(
                        color:
                            widget.room.isOnline
                                ? Colors.green
                                : Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam, color: Colors.white),
          onPressed: () => _startVideoCall(),
        ),
        IconButton(
          icon: Icon(Icons.call, color: Colors.white),
          onPressed: () => _startVoiceCall(),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white),
          color: Colors.grey[900],
          onSelected: (value) {
            switch (value) {
              case 'view_contact':
                _showChatInfo();
                break;
              case 'media':
                _showMediaGallery();
                break;
              case 'search':
                _showSearchInChat();
                break;
              case 'mute':
                _toggleMute();
                break;
              case 'wallpaper':
                _changeWallpaper();
                break;
              case 'clear_chat':
                _clearChat();
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'view_contact',
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'View Contact',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'media',
                  child: Row(
                    children: [
                      Icon(Icons.photo, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Media, Links, Docs',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'search',
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Search', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'mute',
                  child: Row(
                    children: [
                      Icon(Icons.volume_off, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Mute Notifications',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'wallpaper',
                  child: Row(
                    children: [
                      Icon(Icons.wallpaper, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Wallpaper', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_chat',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Clear Chat', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildMessageItem(Message message) {
    final isMe = message.senderId == ref.read(userProvider)?.id;
    final showAvatar = !isMe && widget.room.isGroup;

    return Container(
      margin: EdgeInsets.only(
        bottom: 8,
        left: isMe ? 50 : 0,
        right: isMe ? 0 : 50,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showAvatar)
            Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[700],
              ),
              child: ClipOval(
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
            ),
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(message),
              onDoubleTap: () => _quickReaction(message),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isMe ? widget.room.theme.primaryColor : Colors.grey[800],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showAvatar && message.senderName != null)
                      Text(
                        message.senderName!,
                        style: TextStyle(
                          color: widget.room.theme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (message.replyToId != null)
                      _buildReplyContent(
                        ref
                            .read(messagesProvider(widget.room.id))
                            .firstWhere(
                              (m) => m.id == message.replyToId,
                              orElse:
                                  () => Message(
                                    id: '',
                                    senderId: '',
                                    senderName: '',
                                    content: '',
                                    timestamp: DateTime.now(),
                                  ),
                            ),
                      ),
                    _buildMessageContent(message),
                    SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                        if (isMe) ...[
                          SizedBox(width: 4),
                          Icon(
                            message.status == MessageStatus.read
                                ? Icons.done_all
                                : message.status == MessageStatus.delivered
                                ? Icons.done
                                : Icons.access_time,
                            color:
                                message.status == MessageStatus.read
                                    ? Colors.blue
                                    : Colors.grey[400],
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                    if (message.reactions.isNotEmpty) _buildReactions(message),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Message message) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(color: Colors.white, fontSize: 16),
        );
      case MessageType.image:
        return _buildImageMessage(message);
      case MessageType.video:
        return _buildVideoMessage(message);
      case MessageType.voice:
        return _buildVoiceMessage(message);
      case MessageType.file:
        return _buildFileMessage(message);
      case MessageType.location:
        return _buildLocationMessage(message);
      default:
        return Text(
          'Unsupported message type',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        );
    }
  }

  Widget _buildImageMessage(Message message) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250, maxHeight: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: message.content,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                height: 200,
                color: Colors.grey[700],
                child: Center(
                  child: CircularProgressIndicator(
                    color: widget.room.theme.primaryColor,
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => Container(
                height: 200,
                color: Colors.grey[700],
                child: Icon(Icons.error, color: Colors.white),
              ),
        ),
      ),
    );
  }

  Widget _buildVideoMessage(Message message) {
    final attachment =
        message.attachments.isNotEmpty ? message.attachments[0] : null;
    return Container(
      constraints: BoxConstraints(maxWidth: 250, maxHeight: 300),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: attachment?.thumbnail ?? '',
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    height: 200,
                    color: Colors.grey[700],
                    child: Center(
                      child: CircularProgressIndicator(
                        color: widget.room.theme.primaryColor,
                      ),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[700],
                    child: Icon(Icons.video_library, color: Colors.white),
                  ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(Message message) {
    final duration = message.voiceNote?.duration;
    return Container(
      width: 200,
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.white),
            onPressed: () => _playVoice(message.content),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 30,
                  child: Row(
                    children: List.generate(20, (index) {
                      return Container(
                        width: 3,
                        height: (index % 3 + 1) * 10.0,
                        margin: EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color:
                              index < 8
                                  ? widget.room.theme.primaryColor
                                  : Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  duration != null ? _formatVoiceDuration(duration) : '0:00',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatVoiceDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildReplyContent(Message replyMessage) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: widget.room.theme.primaryColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyMessage.senderName ?? 'Unknown',
            style: TextStyle(
              color: widget.room.theme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            replyMessage.content,
            style: TextStyle(color: Colors.grey[300], fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReactions(Message message) {
    // Group reactions by emoji and count occurrences
    final Map<String, int> emojiCounts = {};
    for (final reaction in message.reactions) {
      emojiCounts[reaction.emoji] = (emojiCounts[reaction.emoji] ?? 0) + 1;
    }
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children:
            emojiCounts.entries.map((entry) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.key, style: TextStyle(fontSize: 12)),
                    SizedBox(width: 2),
                    Text(
                      entry.value.toString(),
                      style: TextStyle(color: Colors.grey[400], fontSize: 10),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTypingIndicator(List<String> typingUsers) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[700],
            ),
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  typingUsers.length == 1
                      ? '${typingUsers.first} is typing'
                      : '${typingUsers.length} people are typing',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _typingAnimationController,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final value =
                            (_typingAnimationController.value + delay) % 1.0;
                        return Container(
                          width: 6,
                          height: 6,
                          margin: EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[400]?.withOpacity(
                              0.3 +
                                  0.7 *
                                      (1 - (value - 0.5).abs() * 2).clamp(
                                        0.0,
                                        1.0,
                                      ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    final replyMessage = ref
        .read(messagesProvider(widget.room.id))
        .firstWhere((m) => m.id == _replyingToMessageId);

    return Container(
      color: Colors.grey[900],
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            color: widget.room.theme.primaryColor,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${replyMessage.senderName ?? 'Unknown'}',
                  style: TextStyle(
                    color: widget.room.theme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  replyMessage.content,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400]),
            onPressed: () {
              setState(() {
                _replyingToMessageId = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.grey[800]!, width: 1)),
      ),
      child: Column(
        children: [
          if (_isEmojiPickerVisible)
            EmojiPicker(
              onTap: (emoji) {
                _messageController.text += emoji;
              },
              text: _messageController.text,
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isEmojiPickerVisible
                              ? Icons.keyboard
                              : Icons.emoji_emotions,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            _isEmojiPickerVisible = !_isEmojiPickerVisible;
                          });
                          if (_isEmojiPickerVisible) {
                            _focusNode.unfocus();
                          } else {
                            _focusNode.requestFocus();
                          }
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            if (text.isNotEmpty) {
                              ref
                                  .read(chatProvider.notifier)
                                  .startTyping(widget.room.id);
                            } else {
                              ref
                                  .read(chatProvider.notifier)
                                  .stopTyping(widget.room.id);
                            }
                          },
                          onSubmitted: (text) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.attach_file, color: Colors.grey[400]),
                        onPressed: () => _showAttachmentOptions(),
                      ),
                      if (_messageController.text.isEmpty)
                        IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.grey[400]),
                          onPressed: () => _takePicture(),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: _messageController.text.isNotEmpty ? _sendMessage : null,
                onLongPressStart: (_) => _startVoiceRecording(),
                onLongPressEnd: (_) => _stopVoiceRecording(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.room.theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _messageController.text.isNotEmpty ? Icons.send : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  // Action Methods
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final user = ref.read(userProvider);
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _messageController.text.trim(),
      senderId: user?.id ?? '',
      senderName: user?.name ?? '',
      timestamp: DateTime.now(),
      type: MessageType.text,
      replyToId: _replyingToMessageId,
    );

    ref.read(chatProvider.notifier).sendMessage(widget.room.id, message);
    ref.read(chatProvider.notifier).stopTyping(widget.room.id);

    _messageController.clear();
    setState(() {
      _replyingToMessageId = null;
      _isEmojiPickerVisible = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.reply, color: Colors.white),
                  title: Text('Reply', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _replyingToMessageId = message.id;
                    });
                    _focusNode.requestFocus();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.copy, color: Colors.white),
                  title: Text('Copy', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Clipboard.setData(ClipboardData(text: message.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Message copied to clipboard')),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.forward, color: Colors.white),
                  title: Text('Forward', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _forwardMessage(message);
                  },
                ),
                if (message.senderId == ref.read(userProvider)?.id)
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      _deleteMessage(message);
                    },
                  ),
              ],
            ),
          ),
    );
  }

  void _quickReaction(Message message) {
    setState(() {
      _reactionAnimationController.forward();
    });

    ref
        .read(chatProvider.notifier)
        .addReaction(
          widget.room.id,
          message.id,
          '❤️',
          ref.read(userProvider)?.id ?? '',
        );

    Future.delayed(Duration(milliseconds: 300), () {
      _reactionAnimationController.reverse();
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      Icons.photo_library,
                      'Gallery',
                      Colors.purple,
                      () => _pickFromGallery(),
                    ),
                    _buildAttachmentOption(
                      Icons.camera_alt,
                      'Camera',
                      Colors.red,
                      () => _takePicture(),
                    ),
                    _buildAttachmentOption(
                      Icons.videocam,
                      'Video',
                      Colors.green,
                      () => _recordVideo(),
                    ),
                    _buildAttachmentOption(
                      Icons.insert_drive_file,
                      'Document',
                      Colors.blue,
                      () => _pickDocument(),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      Icons.location_on,
                      'Location',
                      Colors.orange,
                      () => _shareLocation(),
                    ),
                    _buildAttachmentOption(
                      Icons.person,
                      'Contact',
                      Colors.teal,
                      () => _shareContact(),
                    ),
                    _buildAttachmentOption(
                      Icons.music_note,
                      'Audio',
                      Colors.indigo,
                      () => _pickAudio(),
                    ),
                    _buildAttachmentOption(
                      Icons.poll,
                      'Poll',
                      Colors.amber,
                      () => _createPoll(),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildAttachmentOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  // Voice Recording Methods
  void _startVoiceRecording() {
    if (!_isRecording) {
      setState(() {
        _isRecording = true;
      });
      ref.read(voiceRecordingProvider.notifier).startRecording();

      // Haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  void _stopVoiceRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
      ref.read(voiceRecordingProvider.notifier).stopRecording();
    }
  }

  void _sendVoiceMessage(String audioPath) {
    final user = ref.read(userProvider);
    final voiceState = ref.read(voiceRecordingProvider);
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: audioPath,
      senderId: user?.id ?? '',
      senderName: user?.name ?? '',
      timestamp: DateTime.now(),
      type: MessageType.voice,
      voiceNote:
          voiceState.filePath == audioPath && voiceState.duration != null
              ? VoiceNote(url: audioPath, duration: voiceState.duration!)
              : null,
    );

    ref.read(chatProvider.notifier).sendMessage(widget.room.id, message);
    _scrollToBottom();
  }

  // Media Methods
  void _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _sendImageMessage(pickedFile.path);
    }
  }

  void _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _sendImageMessage(pickedFile.path);
    }
  }

  void _recordVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.camera);

    if (pickedFile != null) {
      _sendVideoMessage(pickedFile.path);
    }
  }

  void _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.first;
      _sendFileMessage(file.path!, file.name, file.size);
    }
  }

  void _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      final file = result.files.first;
      _sendAudioMessage(file.path!, file.name);
    }
  }

  void _sendImageMessage(String imagePath) {
    final user = ref.read(userProvider);
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: imagePath,
      senderId: user?.id ?? '',
      senderName: user?.name ?? '',
      timestamp: DateTime.now(),
      type: MessageType.image,
    );

    ref.read(chatProvider.notifier).sendMessage(widget.room.id, message);
    _scrollToBottom();
  }

  void _sendVideoMessage(String videoPath) {
    final user = ref.read(userProvider);
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: videoPath,
      senderId: user?.id ?? '',
      senderName: user?.name ?? '',
      timestamp: DateTime.now(),
      type: MessageType.video,
    );

    ref.read(chatProvider.notifier).sendMessage(widget.room.id, message);
    _scrollToBottom();
  }

  void _sendFileMessage(String filePath, String fileName, int fileSize) {
    final user = ref.read(userProvider);
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: filePath,
      senderId: user?.id ?? '',
      senderName: user?.name ?? '',
      timestamp: DateTime.now(),
      type: MessageType.file,
      attachments: [
        Attachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: fileName,
          url: filePath,
          type: AttachmentType.document,
          size: fileSize,
        ),
      ],
    );

    ref.read(chatProvider.notifier).sendMessage(widget.room.id, message);
    _scrollToBottom();
  }

  void _sendAudioMessage(String audioPath, String fileName) {
    final user = ref.read(userProvider);
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: audioPath,
      senderId: user?.id ?? '',
      senderName: user?.name ?? '',
      timestamp: DateTime.now(),
      type: MessageType.voice,
      attachments: [
        Attachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: fileName,
          url: audioPath,
          type: AttachmentType.audio,
        ),
      ],
    );

    ref.read(chatProvider.notifier).sendMessage(widget.room.id, message);
    _scrollToBottom();
  }

  void _shareLocation() {
    // Implementation for sharing location
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Share Location',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'This will share your current location with the chat.',
              style: TextStyle(color: Colors.grey[400]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendLocationMessage();
                },
                child: Text('Share'),
              ),
            ],
          ),
    );
  }

  void _sendLocationMessage() {
    final user = ref.read(userProvider);
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Current Location',
      senderId: user?.id ?? '',
      senderName: user?.name ?? '',
      timestamp: DateTime.now(),
      type: MessageType.location,
      location: Location(
        latitude: 0.0,
        longitude: 0.0,
        name: 'Current Location',
      ),
    );

    ref.read(chatProvider.notifier).sendMessage(widget.room.id, message);
    _scrollToBottom();
  }

  void _shareContact() {
    // Implementation for sharing contact
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Share Contact', style: TextStyle(color: Colors.white)),
            content: Text(
              'Select a contact to share',
              style: TextStyle(color: Colors.grey[400]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _createPoll() {
    // Implementation for creating poll
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Create Poll', style: TextStyle(color: Colors.white)),
            content: Text(
              'Poll feature coming soon!',
              style: TextStyle(color: Colors.grey[400]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  // Audio/Video Methods
  void _playAudio(String audioPath) {
    // Implementation for playing audio
    print('Playing audio: $audioPath');
  }

  void _playVoice(String voicePath) {
    // Implementation for playing voice message
    print('Playing voice: $voicePath');
  }

  // Message Actions
  void _forwardMessage(Message message) {
    // Implementation for forwarding message
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Forward Message',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Select chats to forward this message to',
              style: TextStyle(color: Colors.grey[400]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _deleteMessage(Message message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Delete Message',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to delete this message?',
              style: TextStyle(color: Colors.grey[400]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref
                      .read(chatProvider.notifier)
                      .deleteMessage(widget.room.id, message.id);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // AppBar Actions
  void _showChatInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatInfoScreen(room: widget.room),
      ),
    );
  }

  void _showMediaGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaGalleryScreen(roomId: widget.room.id),
      ),
    );
  }

  void _showSearchInChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchInChatScreen(roomId: widget.room.id),
      ),
    );
  }

  void _startVideoCall() {
    // Implementation for video call
    ref.read(callProvider.notifier).startVideoCall(widget.room.id);
  }

  void _startVoiceCall() {
    // Implementation for voice call
    ref.read(callProvider.notifier).startVoiceCall(widget.room.id);
  }

  void _toggleMute() {
    ref.read(chatProvider.notifier).toggleMute(widget.room.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.room.isMuted ? 'Chat unmuted' : 'Chat muted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _changeWallpaper() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Change Wallpaper',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Wallpaper feature coming soon!',
              style: TextStyle(color: Colors.grey[400]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Clear Chat', style: TextStyle(color: Colors.white)),
            content: Text(
              'Are you sure you want to clear this chat? This action cannot be undone.',
              style: TextStyle(color: Colors.grey[400]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(chatProvider.notifier).clearChat(widget.room.id);
                },
                child: Text('Clear', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // Utility Methods
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildFileMessage(Message message) {
    final attachment =
        message.attachments.isNotEmpty ? message.attachments[0] : null;
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.room.theme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.insert_drive_file, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment?.name ?? 'File',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  attachment?.size != null
                      ? _formatFileSize(attachment!.size!)
                      : '0 KB',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(Message message) {
    final location = message.location;
    return Container(
      width: 250,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Center(
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              location?.name ?? 'Location',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
