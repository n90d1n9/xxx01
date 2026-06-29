// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ProviderScope(child: InboxApp()));
}

class InboxApp extends StatelessWidget {
  const InboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Inbox',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
      ),
      themeMode: ThemeMode.system,
      home: const InboxScreen(),
    );
  }
}

// Models
class EmailMessage {
  final String id;
  final String sender;
  final String senderEmail;
  final String subject;
  final String preview;
  final DateTime time;
  final bool isRead;
  final bool isStarred;
  final String? avatar;
  final List<String>? attachments;
  final List<String>? labels;

  EmailMessage({
    required this.id,
    required this.sender,
    required this.senderEmail,
    required this.subject,
    required this.preview,
    required this.time,
    this.isRead = false,
    this.isStarred = false,
    this.avatar,
    this.attachments,
    this.labels,
  });

  EmailMessage copyWith({
    String? id,
    String? sender,
    String? senderEmail,
    String? subject,
    String? preview,
    DateTime? time,
    bool? isRead,
    bool? isStarred,
    String? avatar,
    List<String>? attachments,
    List<String>? labels,
  }) {
    return EmailMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      senderEmail: senderEmail ?? this.senderEmail,
      subject: subject ?? this.subject,
      preview: preview ?? this.preview,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      avatar: avatar ?? this.avatar,
      attachments: attachments ?? this.attachments,
      labels: labels ?? this.labels,
    );
  }
}

// Providers
final mailboxFilterProvider = StateProvider<String>((ref) => 'inbox');

final searchQueryProvider = StateProvider<String>((ref) => '');

final emailsProvider =
    StateNotifierProvider<EmailsNotifier, List<EmailMessage>>((ref) {
      return EmailsNotifier();
    });

final filteredEmailsProvider = Provider<List<EmailMessage>>((ref) {
  final filter = ref.watch(mailboxFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final emails = ref.watch(emailsProvider);

  return emails.where((email) {
    // First apply mailbox filter
    if (filter == 'starred' && !email.isStarred) {
      return false;
    } else if (filter == 'unread' && email.isRead) {
      return false;
    }

    // Then apply search if there is any
    if (searchQuery.isNotEmpty) {
      return email.subject.toLowerCase().contains(searchQuery) ||
          email.sender.toLowerCase().contains(searchQuery) ||
          email.preview.toLowerCase().contains(searchQuery);
    }

    return true;
  }).toList();
});

class EmailsNotifier extends StateNotifier<List<EmailMessage>> {
  EmailsNotifier() : super(_initialEmails);

  void toggleRead(String id) {
    state = [
      for (final email in state)
        if (email.id == id) email.copyWith(isRead: !email.isRead) else email,
    ];
  }

  void toggleStar(String id) {
    state = [
      for (final email in state)
        if (email.id == id)
          email.copyWith(isStarred: !email.isStarred)
        else
          email,
    ];
  }

  void deleteEmail(String id) {
    state = state.where((email) => email.id != id).toList();
  }

  void markAllAsRead() {
    state = [for (final email in state) email.copyWith(isRead: true)];
  }
}

// Sample data
final List<EmailMessage> _initialEmails = [
  EmailMessage(
    id: '1',
    sender: 'Olivia Johnson',
    senderEmail: 'olivia@company.com',
    subject: 'Project Status Update',
    preview:
        'Hey team, I just wanted to share the latest updates on our project. We\'ve hit several milestones ahead of schedule...',
    time: DateTime.now().subtract(const Duration(minutes: 15)),
    isStarred: true,
    avatar: 'OJ',
    attachments: ['report.pdf', 'metrics.xlsx'],
    labels: ['work', 'important'],
  ),
  EmailMessage(
    id: '2',
    sender: 'Ethan Williams',
    senderEmail: 'ethan@company.com',
    subject: 'Team Lunch Next Week',
    preview:
        'Let\'s plan for a team lunch next Wednesday. I was thinking we could try that new restaurant downtown...',
    time: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
    avatar: 'EW',
    labels: ['social'],
  ),
  EmailMessage(
    id: '3',
    sender: 'Shopify',
    senderEmail: 'updates@shopify.com',
    subject: 'Your Order Has Shipped',
    preview:
        'Your recent order #57829 has been shipped and is expected to arrive by March 25th...',
    time: DateTime.now().subtract(const Duration(hours: 5)),
    avatar: 'S',
    labels: ['shopping'],
  ),
  EmailMessage(
    id: '4',
    sender: 'Amelia Chen',
    senderEmail: 'amelia@design.co',
    subject: 'Design Review Feedback',
    preview:
        'I\'ve reviewed the latest mockups and wanted to share some thoughts. The color scheme is perfect, but I think we should reconsider...',
    time: DateTime.now().subtract(const Duration(hours: 8)),
    isStarred: true,
    avatar: 'AC',
    attachments: ['design_feedback.sketch'],
    labels: ['work', 'design'],
  ),
  EmailMessage(
    id: '5',
    sender: 'Noah Garcia',
    senderEmail: 'noah@company.com',
    subject: 'Weekly Meeting Agenda',
    preview:
        'Here\'s the agenda for our weekly meeting tomorrow at 10 AM. I\'ve included all the discussion points we need to cover...',
    time: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
    avatar: 'NG',
    attachments: ['agenda.docx'],
    labels: ['work'],
  ),
  EmailMessage(
    id: '6',
    sender: 'Dropbox',
    senderEmail: 'no-reply@dropbox.com',
    subject: 'Your storage is almost full',
    preview:
        'You\'ve used 85% of your Dropbox storage. Upgrade now to ensure you don\'t run out of space for your important files...',
    time: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    isRead: true,
    avatar: 'D',
  ),
  EmailMessage(
    id: '7',
    sender: 'Isabella Murphy',
    senderEmail: 'isabella@gmail.com',
    subject: 'Weekend Plans',
    preview:
        'Are you free this weekend? I was thinking we could catch that new movie everyone has been talking about...',
    time: DateTime.now().subtract(const Duration(days: 2)),
    avatar: 'IM',
    labels: ['personal'],
  ),
  EmailMessage(
    id: '8',
    sender: 'Lucas Taylor',
    senderEmail: 'lucas@tech.org',
    subject: 'API Documentation Review',
    preview:
        'I\'ve put together the draft of our API documentation. Could you take a look and let me know if anything is unclear or missing?',
    time: DateTime.now().subtract(const Duration(days: 3)),
    isRead: true,
    avatar: 'LT',
    attachments: ['api_docs_v1.md'],
    labels: ['work', 'technical'],
  ),
];

// Screens
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(mailboxFilterProvider);
    final emails = ref.watch(filteredEmailsProvider);
    final totalUnread =
        ref.watch(emailsProvider).where((email) => !email.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options menu
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, totalUnread),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(filter),
          Expanded(
            child:
                emails.isEmpty ? _buildEmptyState() : _buildEmailList(emails),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Compose new email
        },
        elevation: 2,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search in emails',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              ref.read(searchQueryProvider.notifier).state = '';
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildFilterChips(String currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildFilterChip('inbox', 'All', currentFilter),
          const SizedBox(width: 8),
          _buildFilterChip('unread', 'Unread', currentFilter),
          const SizedBox(width: 8),
          _buildFilterChip('starred', 'Starred', currentFilter),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, String currentFilter) {
    final isSelected = value == currentFilter;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {
        ref.read(mailboxFilterProvider.notifier).state = value;
      },
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildEmailList(List<EmailMessage> emails) {
    return RefreshIndicator(
      onRefresh: () async {
        // Simulate network delay
        await Future.delayed(const Duration(seconds: 1));
        // In a real app, you would fetch new emails here
      },
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8),
        itemCount: emails.length,
        separatorBuilder:
            (context, index) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final email = emails[index];
          return _buildEmailTile(email);
        },
      ),
    );
  }

  Widget _buildEmailTile(EmailMessage email) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(email.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.blueGrey,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // Delete
          ref.read(emailsProvider.notifier).deleteEmail(email.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Email deleted'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  // Undo delete action
                },
              ),
            ),
          );
        } else {
          // Archive
          ref.read(emailsProvider.notifier).deleteEmail(email.id);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Email archived')));
        }
      },
      child: InkWell(
        onTap: () {
          // Mark as read when opened
          if (!email.isRead) {
            ref.read(emailsProvider.notifier).toggleRead(email.id);
          }
          // Navigate to email detail screen
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor:
                    email.isRead
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.primary,
                foregroundColor:
                    email.isRead
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onPrimary,
                radius: 20,
                child: Text(email.avatar ?? email.sender[0]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            email.sender,
                            style: TextStyle(
                              fontWeight:
                                  email.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTime(email.time),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email.subject,
                      style: TextStyle(
                        fontWeight:
                            email.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email.preview,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (email.attachments != null &&
                        email.attachments!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attachment,
                              size: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              email.attachments!.length > 1
                                  ? '${email.attachments!.length} attachments'
                                  : email.attachments!.first,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (email.labels != null && email.labels!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Wrap(
                          spacing: 4,
                          children:
                              email.labels!.map((label) {
                                return Chip(
                                  label: Text(label),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  labelStyle: const TextStyle(fontSize: 10),
                                  padding: EdgeInsets.zero,
                                );
                              }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      email.isStarred ? Icons.star : Icons.star_border,
                      color:
                          email.isStarred
                              ? Colors.amber
                              : theme.colorScheme.onSurface,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      ref.read(emailsProvider.notifier).toggleStar(email.id);
                    },
                  ),
                  if (!email.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No emails found',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your search or filters',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, int unreadCount) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: const Text('Alex Morgan'),
            accountEmail: const Text('alex.morgan@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              child: const Text('AM'),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inbox),
            title: const Text('Inbox'),
            trailing:
                unreadCount > 0
                    ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                        ),
                      ),
                    )
                    : null,
            selected: ref.watch(mailboxFilterProvider) == 'inbox',
            onTap: () {
              ref.read(mailboxFilterProvider.notifier).state = 'inbox';
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Starred'),
            selected: ref.watch(mailboxFilterProvider) == 'starred',
            onTap: () {
              ref.read(mailboxFilterProvider.notifier).state = 'starred';
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.send),
            title: const Text('Sent'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.drafts),
            title: const Text('Drafts'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archive'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Trash'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Spam'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Feedback'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      if (difference.inDays > 6) {
        return DateFormat('MMM d').format(time);
      } else {
        return DateFormat('E').format(time); // Day of week
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }
}
