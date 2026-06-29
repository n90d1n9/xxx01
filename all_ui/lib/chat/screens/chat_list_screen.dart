import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_animate/flutter_animate.dart';

import '../models/chat_room.dart';
import '../models/story.dart';
import '../states/chat_room_provider.dart';
import '../states/story_provider.dart';
import 'archived_screen.dart';
import 'chat_screen.dart';
import 'qr_scanner_screen.dart';
import 'setting_screen.dart';
import 'story_view_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatRooms = ref.watch(chatRoomsProvider);
    final stories = ref.watch(storiesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final filteredRooms =
        searchQuery.isEmpty
            ? chatRooms
            : chatRooms
                .where(
                  (room) =>
                      room.name.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      room.lastMessage.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                )
                .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search messages...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                )
                : Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: Colors.grey[900],
            onSelected: (value) {
              switch (value) {
                case 'new_group':
                  _showCreateGroupDialog();
                  break;
                case 'new_channel':
                  _showCreateChannelDialog();
                  break;
                case 'settings':
                  _showSettingsDialog();
                  break;
                case 'archived':
                  _showArchivedChats();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'new_group',
                    child: Row(
                      children: [
                        Icon(Icons.group_add, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'New Group',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'new_channel',
                    child: Row(
                      children: [
                        Icon(Icons.campaign, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'New Channel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archived',
                    child: Row(
                      children: [
                        Icon(Icons.archive, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Archived', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Settings', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[500],
          tabs: [
            Tab(text: 'All'),
            // Continuing from the TabBar in ChatListScreen
            Tab(text: 'Unread'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stories Section
          if (stories.isNotEmpty)
            Container(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: stories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildAddStoryButton();
                  }
                  final story = stories[index - 1];
                  return _buildStoryItem(story);
                },
              ),
            ),

          // Chat List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatList(filteredRooms),
                _buildChatList(
                  filteredRooms.where((room) => room.unreadCount > 0).toList(),
                ),
                _buildChatList(
                  filteredRooms.where((room) => room.isGroup).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatDialog,
        backgroundColor: Colors.blue,
        child: Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildAddStoryButton() {
    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[700]!, width: 2),
            ),
            child: Icon(Icons.add, color: Colors.white, size: 30),
          ),
          SizedBox(height: 4),
          Text(
            'Your Story',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(Story story) {
    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _viewStory(story),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: story.isViewed ? Colors.grey[600]! : Colors.blue,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl:
                      story.userAvatar ?? 'https://via.placeholder.com/60',
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[800],
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              story.userName,
              style: TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(List<ChatRoom> rooms) {
    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[600]),
            SizedBox(height: 16),
            Text(
              'No chats yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      );
    }

    final pinnedRooms = rooms.where((room) => room.isPinned).toList();
    final unpinnedRooms = rooms.where((room) => !room.isPinned).toList();

    return ListView.builder(
      itemCount:
          pinnedRooms.length +
          unpinnedRooms.length +
          (pinnedRooms.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (pinnedRooms.isNotEmpty && index == 0) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Pinned',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        final adjustedIndex = pinnedRooms.isNotEmpty ? index - 1 : index;
        final room =
            adjustedIndex < pinnedRooms.length
                ? pinnedRooms[adjustedIndex]
                : unpinnedRooms[adjustedIndex - pinnedRooms.length];

        return _buildChatItem(room);
      },
    );
  }

  Widget _buildChatItem(ChatRoom room) {
    return Dismissible(
      key: Key(room.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.archive, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          ref.read(chatRoomsProvider.notifier).archiveRoom(room.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chat archived'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // Implement undo functionality
                },
              ),
            ),
          );
        }
      },
      child: ListTile(
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [room.theme.primaryColor, room.theme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipOval(
                child:
                    room.avatar != null
                        ? CachedNetworkImage(
                          imageUrl: room.avatar!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[800],
                                child: Icon(
                                  room.isGroup ? Icons.group : Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[800],
                                child: Icon(
                                  room.isGroup ? Icons.group : Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                        )
                        : Icon(
                          room.isGroup ? Icons.group : Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
              ),
            ),
            if (room.isOnline && !room.isGroup)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              ),
            if (room.isPinned)
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Icon(Icons.push_pin, color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                room.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                      room.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (room.isMuted)
              Icon(Icons.volume_off, color: Colors.grey[500], size: 16),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.lastMessage,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            if (!room.isGroup && room.lastSeen != null)
              Text(
                'Last seen ${_formatTime(room.lastSeen!)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(room.lastActivity),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            SizedBox(height: 4),
            if (room.unreadCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: room.isMuted ? Colors.grey[600] : Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  room.unreadCount > 99 ? '99+' : room.unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _openChat(room),
        onLongPress: () => _showChatOptions(room),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _openChat(ChatRoom room) {
    ref.read(selectedRoomProvider.notifier).state = room;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(room: room)),
    );
  }

  void _viewStory(Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryViewScreen(story: story)),
    );
  }

  void _showChatOptions(ChatRoom room) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.push_pin, color: Colors.white),
                  title: Text(
                    room.isPinned ? 'Unpin' : 'Pin',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    ref.read(chatRoomsProvider.notifier).togglePin(room.id);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    room.isMuted ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                  ),
                  title: Text(
                    room.isMuted ? 'Unmute' : 'Mute',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    ref.read(chatRoomsProvider.notifier).toggleMute(room.id);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.archive, color: Colors.white),
                  title: Text('Archive', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    ref.read(chatRoomsProvider.notifier).archiveRoom(room.id);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(room);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteConfirmation(ChatRoom room) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Delete Chat', style: TextStyle(color: Colors.white)),
            content: Text(
              'Are you sure you want to delete this chat?',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  // Implement delete functionality
                  Navigator.pop(context);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showNewChatDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.person_add, color: Colors.white),
                  title: Text(
                    'New Contact',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddContactDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.group_add, color: Colors.white),
                  title: Text(
                    'New Group',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreateGroupDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.qr_code_scanner, color: Colors.white),
                  title: Text(
                    'Scan QR Code',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showQRScanner();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showAddContactDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Add Contact', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  // Implement add contact functionality
                  Navigator.pop(context);
                },
                child: Text('Add', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
    );
  }

  void _showCreateGroupDialog() {
    final TextEditingController groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Create Group', style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: groupNameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Group Name',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  // Implement create group functionality
                  Navigator.pop(context);
                },
                child: Text('Create', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
    );
  }

  void _showCreateChannelDialog() {
    final TextEditingController channelNameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Create Channel',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: channelNameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Channel Name',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  // Implement create channel functionality
                  Navigator.pop(context);
                },
                child: Text('Create', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
    );
  }

  void _showSettingsDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  void _showArchivedChats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArchivedChatsScreen()),
    );
  }

  void _showQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen()),
    );
  }
}
